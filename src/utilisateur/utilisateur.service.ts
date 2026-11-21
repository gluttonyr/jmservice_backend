import { Injectable, BadRequestException, OnModuleInit } from '@nestjs/common';
import { isValidEmail, isValidPhone, normalizeEmail, normalizePhone, phoneDigits } from './contact';
import * as bcrypt from 'bcryptjs';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserRepository } from './user.repository';
import { UserMapper } from './mappers/user.mapper';
import { DiscussionService } from 'src/discussion/discussion.service';
import { Discussion } from 'src/discussion/entities/discussion.entity';
import { UserRole } from './enums/user-role.enum';
import { In } from 'typeorm';
import { Transaction, TransactionStatus } from 'src/transaction/entities/transaction.entity';
import { PushDevice } from 'src/push-device/entities/push-device.entity';

@Injectable()
export class UtilisateurService implements OnModuleInit {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly userMapper: UserMapper,
    private readonly discussionService: DiscussionService
  ) { }

  async onModuleInit() {
    await this.dropUsernameUniqueConstraint();
    await this.ensureAdminExists();
    await this.ensureEnvAdmins();
  }

  /**
   * ADMIN_ACCOUNTS="email1:motdepasse1,email2:motdepasse2": at each start, creates the admin accounts that do
   * not exist yet. An existing account is never changed (its password may have been changed since), so removing
   * an entry does not delete the account either.
   */
  private async ensureEnvAdmins() {
    const raw = process.env.ADMIN_ACCOUNTS?.trim();
    if (!raw) return;
    for (const entry of raw.split(',').map((e) => e.trim()).filter(Boolean)) {
      const sep = entry.indexOf(':');
      const email = (sep > 0 ? entry.slice(0, sep) : '').trim().toLowerCase();
      const password = sep > 0 ? entry.slice(sep + 1) : '';
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || password.length < 8) {
        console.warn(`⚠️ ADMIN_ACCOUNTS : entrée ignorée « ${email || entry.split(':')[0]} » (format email:motdepasse, 8 caractères minimum)`);
        continue;
      }
      try {
        const existing = await this.userRepository.findOne({ where: { email } });
        if (existing) {
          if (existing.role !== UserRole.ADMIN)
            console.warn(`⚠️ ADMIN_ACCOUNTS : ${email} existe déjà comme utilisateur simple, il n'est pas passé admin`);
          continue;
        }
        const name = email.split('@')[0];
        await this.userRepository.save(
          this.userRepository.create({
            nom: 'Admin',
            prenom: name,
            username: name,
            email,
            password: await bcrypt.hash(password, 10),
            role: UserRole.ADMIN,
            active: true,
          }),
        );
        console.log(`👑 Compte admin créé depuis ADMIN_ACCOUNTS : ${email}`);
      } catch (error) {
        // One bad entry must not stop the server from starting.
        console.warn(`⚠️ ADMIN_ACCOUNTS : création de ${email} impossible :`, error);
      }
    }
  }

  // Prod runs without TypeORM synchronize, so the old UNIQUE(username) stays in the database after the entity
  // dropped it. Removes it once (no-op afterwards); it only stops refusing equal usernames, no data is touched.
  private async dropUsernameUniqueConstraint() {
    try {
      await this.userRepository.query(`
        DO $$
        DECLARE c text;
        BEGIN
          FOR c IN
            SELECT con.conname FROM pg_constraint con
            JOIN pg_attribute a ON a.attrelid = con.conrelid AND a.attnum = ANY (con.conkey)
            WHERE con.conrelid = 'users'::regclass AND con.contype = 'u'
              AND array_length(con.conkey, 1) = 1 AND a.attname = 'username'
          LOOP
            EXECUTE format('ALTER TABLE users DROP CONSTRAINT %I', c);
            RAISE NOTICE 'Dropped unique constraint % on users.username', c;
          END LOOP;
        END $$;
      `);
    } catch (error) {
      console.warn('⚠️ Could not drop the unique constraint on users.username:', error);
    }
  }

  private async ensureAdminExists() {
    const admin = await this.userRepository.findOne({
      where: {
        role: UserRole.ADMIN,
      },
    });

    if (admin) {
      console.log('✅ Compte admin déjà existant');
      return;
    }

    // Only used the first time, when no admin exists. Set ADMIN_INITIAL_PASSWORD in production:
    // the fallback is public (it is in the code).
    const password = process.env.ADMIN_INITIAL_PASSWORD || 'Admin@123456';
    if (!process.env.ADMIN_INITIAL_PASSWORD && process.env.NODE_ENV === 'production') {
      console.warn('⚠️ ADMIN_INITIAL_PASSWORD absent : compte admin créé avec le mot de passe par défaut, à changer tout de suite.');
    }

    const adminUser = this.userRepository.create({
      nom: 'Admin',
      prenom: 'System',
      username: 'admin',
      email: 'admin@jmservices.local',
      password: await bcrypt.hash(password, 10),
      role: UserRole.ADMIN,
      active: true,
    });

    await this.userRepository.save(adminUser);

    console.log(`
  ====================================
  👑 Compte administrateur créé
  Email : admin@jmservices.local
  Mot de passe : ${password}
  ====================================
  `);
  }



  async create(payload: CreateUserDto) {
    // Sign-up with an email address, a phone number, or both (at least one): both are sign-in identifiers.
    const email = normalizeEmail(payload.email);
    const telephone = normalizePhone(payload.telephone);
    if (!email && !telephone) {
      throw new BadRequestException('Indiquez une adresse e-mail ou un numéro de téléphone');
    }
    await this.assertContactsAvailable({ email, telephone });
    payload = { ...payload, email: email as string, telephone: telephone as string };

    // One of the two names is enough (e.g. single-name Google accounts); the other stays empty.
    const rawNom = (payload.nom ?? '').trim();
    const rawPrenom = (payload.prenom ?? '').trim();
    if (!rawNom && !rawPrenom) {
      throw new BadRequestException('Indiquez au moins votre prénom ou votre nom');
    }

    const entity = await this.userMapper.toEntity({ ...payload, nom: rawNom, prenom: rawPrenom });
    if (!entity.username) {
      const nom = rawNom.toUpperCase();

      const prenom = rawPrenom
        .toLowerCase()
        .split(/\s+/)
        .map((p) => p.charAt(0).toUpperCase() + p.slice(1))
        .join(' ');

      entity.username = `${nom} ${prenom}`.trim();
    }

    const user = this.userRepository.create({
      ...entity,
      active: payload.active ?? true,
      password: payload.password
        ? await bcrypt.hash(payload.password, 10)
        : undefined,
    });

    const savedUser = await this.userRepository.save(user);

    await this.discussionService.createForUser(savedUser);

    return savedUser;

  }

  async getAdminPushTokens(): Promise<string[]> {
  // Adapte selon comment tu récupères déjà les users par rôle ailleurs
  const admins = await this.userRepository.find({
    where: { role: UserRole.ADMIN, active: true },
    relations: { pushDevices: true },
  });
  return admins
    .flatMap((u) => u.pushDevices ?? [])
    .filter((d) => d.active)
    .map((d) => d.token);
}

  async findAll() {
    return this.userRepository.find();
  }

  async findActiveUserIds(): Promise<number[]> {
    const users = await this.userRepository.find({
      select: { id: true },
      where: { role: UserRole.USER, active: true },
    });
    return users.map((user) => user.id);
  }

  count() {
    return this.userRepository.count();
  }

  countNewToday() {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    return this.userRepository.countCreatedSince(startOfDay);
  }

  findByEmail(email: string) {
    return this.userRepository.findOne({ where: { email } });
  }

  findByAppleId(appleId: string) {
    return this.userRepository.findByAppleId(appleId);
  }

  async linkAppleId(user: User, appleId: string) {
    user.appleId = appleId;
    return this.userRepository.save(user);
  }

  findById(id: string) {
    return this.userRepository.findOne({ where: { trackingId: id } });
  }

  findUserById(id: number) {
    return this.userRepository.findOne({ where: { id } });
  }

  async updatePawword(adminId: number, userId: number, password: string) {
    const admin = await this.findUserById(adminId);
    if (!admin) {
      throw new BadRequestException('Compte Administrateur introuvable');
    }
    if (admin.role != UserRole.ADMIN) {
      throw new BadRequestException('Acces refusez, vous ne pouvez pas effectuer cette modification');
    }
    const user = await this.findUserById(adminId);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable');
    }
    if (!user) {
      throw new BadRequestException('Mot de passe invalide');
    }


    user.password = await bcrypt.hash(password, 10);


    return this.userRepository.save(user);

  }

  async updatePushToken(id: number, expoPushToken: string) {
    const user = await this.findUserById(id);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable');
    }
    user.expoPushToken = expoPushToken;
    return this.userRepository.save(user);
  }

  async getAllPushTokens(): Promise<string[]> {
    const users = await this.userRepository.find();
    return users.map((u) => u.expoPushToken).filter((t): t is string => !!t);
  }

  async update(id: string, payload: UpdateUserDto) {
    const user = await this.findById(id);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable');
    }
    // if (payload.password) {
    //   payload.password = await bcrypt.hash(payload.password, 10);
    // }
    payload = { ...payload };
    if (payload.email !== undefined) payload.email = normalizeEmail(payload.email) as string;
    if (payload.telephone !== undefined) payload.telephone = normalizePhone(payload.telephone) as string;
    if (payload.email !== undefined || payload.telephone !== undefined) {
      const email = payload.email !== undefined ? payload.email : user.email;
      const telephone = payload.telephone !== undefined ? payload.telephone : user.telephone;
      // The account must keep a way to sign in.
      if (!email && !telephone) {
        throw new BadRequestException('Gardez au moins une adresse e-mail ou un numéro de téléphone');
      }
      await this.assertContactsAvailable(
        {
          email: payload.email !== undefined && payload.email !== user.email ? payload.email : null,
          telephone: payload.telephone !== undefined && phoneDigits(payload.telephone) !== phoneDigits(user.telephone)
            ? payload.telephone
            : null,
        },
        user.id,
      );
    }
    Object.assign(user, payload);
    return this.userRepository.save(user);
  }

  /** Active accounts whose phone number has these digits (normally one; older data may hold duplicates). */
  findActiveByPhone(phone: string) {
    const digits = phoneDigits(phone);
    if (!digits) return Promise.resolve([] as User[]);
    return this.userRepository.createQueryBuilder('user')
      .where("regexp_replace(user.telephone, '[^0-9]', '', 'g') = :digits", { digits })
      .andWhere('user.active = true')
      .orderBy('user.id', 'ASC')
      .getMany();
  }

  // An email or a phone number identifies one account only.
  private async assertContactsAvailable(
    { email, telephone }: { email?: string | null; telephone?: string | null },
    exceptUserId?: number,
  ) {
    if (email) {
      if (!isValidEmail(email)) throw new BadRequestException('Adresse e-mail invalide');
      const existing = await this.userRepository.findOne({ where: { email } });
      if (existing && existing.id !== exceptUserId) {
        throw new BadRequestException('Email déjà utilisé par un autre utilisateur');
      }
    }
    if (telephone) {
      if (!isValidPhone(telephone)) throw new BadRequestException('Numéro de téléphone invalide');
      const owners = await this.findActiveByPhone(telephone);
      if (owners.some((owner) => owner.id !== exceptUserId)) {
        throw new BadRequestException('Ce numéro de téléphone est déjà utilisé par un autre compte');
      }
    }
  }

  async remove(id: string) {
    const user = await this.findById(id);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable');
    }
    return this.userRepository.remove(user);
  }

  // Account deletion requested by the user (App Store guideline 5.1.1(v)). Transactions must stay for the
  // financial records and reference the user row, so the row is anonymised instead of removed: every personal
  // field is erased, the email/Google/Apple links are freed and the account can no longer sign in.
  async deleteOwnAccount(userId: number) {
    const user = await this.findUserById(userId);
    if (!user || !user.active) {
      throw new BadRequestException('Compte introuvable');
    }
    if (user.role === UserRole.ADMIN) {
      throw new BadRequestException('Un compte administrateur ne peut pas être supprimé depuis l’application');
    }
    const openTransactions = await this.userRepository.manager.count(Transaction, {
      where: { user: { id: userId }, statut: In(OPEN_TRANSACTION_STATUSES) },
    });
    if (openTransactions > 0) {
      throw new BadRequestException('Une transaction est encore en cours sur votre compte. Attendez son traitement avant de supprimer le compte.');
    }

    await this.userRepository.manager.update(PushDevice, { userId }, { active: false });
    Object.assign(user, {
      nom: 'Compte',
      prenom: 'supprimé',
      username: 'Compte supprimé',
      email: `deleted-${user.trackingId}@deleted.jmservices.invalid`,
      telephone: null,
      image: null,
      password: null,
      googleId: null,
      appleId: null,
      provider: null,
      expoPushToken: null,
      active: false,
    });
    await this.userRepository.save(user);
  }
}

const OPEN_TRANSACTION_STATUSES = [
  TransactionStatus.EN_ATTENTE_AUTO,
  TransactionStatus.EN_VERIFICATION,
  TransactionStatus.EN_ATTENTE_PREUVE,
  TransactionStatus.EN_ATTENTE_ADMIN,
  TransactionStatus.EN_RECLAMATION,
];
