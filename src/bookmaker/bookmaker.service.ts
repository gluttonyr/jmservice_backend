import { BadRequestException, Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { randomUUID } from 'node:crypto';
import {
  Bookmaker,
  BookmakerIntegration,
  DEFAULT_BOOKMAKER_CODE,
  isBookmakerAvailable,
} from './entities/bookmaker.entity';
import { BookmakerResponseDto, CreateBookmakerDto, UpdateBookmakerDto } from './dto/bookmaker.dto';

type BookmakerSeed = { code: string; nom: string; integration: BookmakerIntegration | null; ordre: number };

const DEFAULT_BOOKMAKERS: BookmakerSeed[] = [
  { code: DEFAULT_BOOKMAKER_CODE, nom: '1XBET', integration: BookmakerIntegration.SERVCUL, ordre: 1 },
  { code: '1WIN', nom: '1WIN', integration: null, ordre: 2 },
  { code: 'MELBET', nom: 'MELBET', integration: null, ordre: 3 },
];

@Injectable()
export class BookmakerService implements OnModuleInit {
  constructor(@InjectRepository(Bookmaker) private readonly repository: Repository<Bookmaker>) {}

  async onModuleInit() {
    for (const seed of DEFAULT_BOOKMAKERS) {
      const existing = await this.repository.findOne({ where: { code: seed.code } });
      if (!existing) {
        await this.repository.save(this.repository.create({ trackingId: randomUUID(), ...seed, active: true }));
      } else if (existing.integration !== seed.integration) {
        // The integration belongs to the code: keep it in sync, leave the admin's name, image, order and visibility.
        existing.integration = seed.integration;
        await this.repository.save(existing);
      }
    }
  }

  /** Bookmakers shown to clients, available ones and "bientôt" ones. */
  findVisible() {
    return this.repository.find({ where: { active: true }, order: { ordre: 'ASC', nom: 'ASC' } });
  }

  findAll() {
    return this.repository.find({ order: { ordre: 'ASC', nom: 'ASC' } });
  }

  findByCode(code: string) {
    return this.repository
      .createQueryBuilder('bookmaker')
      .where('UPPER(bookmaker.code) = UPPER(:code)', { code: code.trim() })
      .getOne();
  }

  /**
   * Bookmaker of a new transaction. Apps installed before the bookmaker step send nothing: 1XBET.
   * Throws when the bookmaker is unknown, hidden, or has no API yet.
   */
  async resolveForTransaction(code?: string | null): Promise<Bookmaker> {
    const wanted = code?.trim() || DEFAULT_BOOKMAKER_CODE;
    const bookmaker = await this.findByCode(wanted);
    if (!bookmaker || !bookmaker.active) throw new BadRequestException('Bookmaker introuvable');
    if (!isBookmakerAvailable(bookmaker)) {
      throw new BadRequestException(`${bookmaker.nom} n’est pas encore disponible. Choisissez un autre bookmaker.`);
    }
    return bookmaker;
  }

  async create(payload: CreateBookmakerDto) {
    const code = payload.code.trim().toUpperCase();
    if (await this.findByCode(code)) throw new BadRequestException('Un bookmaker avec ce code existe déjà');
    return this.repository.save(this.repository.create({
      trackingId: randomUUID(),
      code,
      nom: payload.nom.trim(),
      imageUrl: payload.imageUrl ?? null,
      integration: null,
      active: payload.active ?? true,
      ordre: payload.ordre ?? 0,
    }));
  }

  async update(trackingId: string, payload: UpdateBookmakerDto) {
    const bookmaker = await this.repository.findOne({ where: { trackingId } });
    if (!bookmaker) throw new BadRequestException('Bookmaker introuvable');
    if (payload.nom !== undefined) bookmaker.nom = payload.nom.trim();
    if (payload.imageUrl !== undefined) bookmaker.imageUrl = payload.imageUrl || null;
    if (payload.active !== undefined) bookmaker.active = payload.active;
    if (payload.ordre !== undefined) bookmaker.ordre = payload.ordre;
    return this.repository.save(bookmaker);
  }

  async remove(trackingId: string) {
    const bookmaker = await this.repository.findOne({ where: { trackingId } });
    if (!bookmaker) throw new BadRequestException('Bookmaker introuvable');
    if (bookmaker.code === DEFAULT_BOOKMAKER_CODE) {
      // Old app versions always deposit on 1XBET: it cannot disappear, only be hidden.
      throw new BadRequestException('1XBET ne peut pas être supprimé. Vous pouvez le désactiver.');
    }
    await this.repository.remove(bookmaker);
  }

  toResponse(bookmaker: Bookmaker): BookmakerResponseDto {
    return {
      trackingId: bookmaker.trackingId,
      code: bookmaker.code,
      nom: bookmaker.nom,
      imageUrl: bookmaker.imageUrl ?? null,
      active: bookmaker.active,
      ordre: bookmaker.ordre,
      disponible: isBookmakerAvailable(bookmaker),
    };
  }
}
