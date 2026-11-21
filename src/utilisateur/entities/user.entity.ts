import { Column, Entity, OneToMany } from 'typeorm';
import { BaseEntity } from '../../common/base.entity';
import { UserRole } from '../enums/user-role.enum';
import { PushDevice } from '../../push-device/entities/push-device.entity';

@Entity('users')
export class User extends BaseEntity {
  @Column()
  nom!: string;

  @Column()
  prenom!: string;

  // Display name built from nom + prenom: two people can share it (accounts are found by email / phone / id, never by username).
  @Column()
  username!: string;

  // Optional: a client may sign up with a phone number only (email or phone, at least one; see UtilisateurService).
  @Column({ type: 'varchar', unique: true, nullable: true })
  email!: string | null;

  @Column({ nullable: true })
  password?: string;

  // Also a sign-in identifier: stored as "+" and digits, never shared by two active accounts.
  @Column({ type: 'varchar', nullable: true })
  telephone?: string | null;

  @Column({ nullable: true })
  image?: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.USER })
  role!: UserRole;

  @Column({ default: true })
  active!: boolean;

  @Column({ nullable: true })
  googleId?: string;

  @Column({ nullable: true, unique: true })
  appleId?: string;

  @Column({ nullable: true })
  provider?: string;

  @Column({ nullable: true })
  expoPushToken?: string;

  @OneToMany(() => PushDevice, (pushDevice) => pushDevice.user)
  pushDevices!: PushDevice[];
}
