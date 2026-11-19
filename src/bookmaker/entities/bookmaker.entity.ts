import { Column, Entity } from 'typeorm';
import { BaseEntity } from '../../common/base.entity';

/** How a bookmaker account is credited and debited. Only set by the code (seed), never by the admin API. */
export enum BookmakerIntegration {
  /** 1XBET cash desk API (src/servcul). */
  SERVCUL = 'SERVCUL',
}

/** Code of the bookmaker used when an app version that predates the bookmaker step sends no bookmaker. */
export const DEFAULT_BOOKMAKER_CODE = '1XBET';

@Entity('bookmakers')
export class Bookmaker extends BaseEntity {
  /** Stable identifier stored on transactions, e.g. "1XBET". */
  @Column({ type: 'varchar', length: 30, unique: true })
  code!: string;

  @Column({ type: 'varchar', length: 100 })
  nom!: string;

  @Column({ name: 'image_url', type: 'varchar', length: 255, nullable: true })
  imageUrl?: string | null;

  /** Null = no API yet: listed as "bientôt" and refused for new transactions. */
  @Column({ type: 'enum', enum: BookmakerIntegration, nullable: true })
  integration?: BookmakerIntegration | null;

  /** False = hidden from clients. */
  @Column({ default: true })
  active!: boolean;

  @Column({ type: 'int', default: 0 })
  ordre!: number;
}

export function isBookmakerAvailable(bookmaker: Pick<Bookmaker, 'active' | 'integration'>): boolean {
  return bookmaker.active && !!bookmaker.integration;
}
