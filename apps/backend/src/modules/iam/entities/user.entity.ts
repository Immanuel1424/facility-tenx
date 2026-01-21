import {
  Entity,
  Column,
  Index,
  OneToMany,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { RefreshToken } from './refresh-token.entity';
import { UserRole } from './user-role.entity';
import { AclEntry } from './acl-entry.entity';

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
}

export enum AuthProvider {
  LOCAL = 'local',
  AZURE_AD = 'azure_ad',
  OKTA = 'okta',
  AUTH0 = 'auth0',
  KEYCLOAK = 'keycloak',
}

@Entity('users')
@Index(['companyId', 'email'], { 
  unique: true,
  where: 'deleted_at IS NULL' // Partial unique index: only enforces uniqueness for non-deleted users
})
@Index(['companyId', 'externalId'], { unique: true, where: 'external_id IS NOT NULL' })
@Index(['companyId', 'villaNumber'], { unique: true, where: 'villa_number IS NOT NULL' })
export class User extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 255 })
  email!: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  passwordHash?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  firstName?: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  lastName?: string;

  @Column({ type: 'varchar', length: 20, nullable: true, name: 'phone_number' })
  phoneNumber?: string;

  @Column({ type: 'varchar', length: 20, nullable: true, name: 'alternate_phone_number' })
  alternatePhoneNumber?: string;

  @Column({ type: 'timestamp', nullable: true, name: 'lease_expiry_date' })
  leaseExpiryDate?: Date;

  @Column({ type: 'varchar', length: 50, nullable: true, name: 'villa_number' })
  villaNumber?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'villa_numbers' })
  villaNumbers?: string[];

  @Column({ type: 'uuid', nullable: true, name: 'department_id' })
  departmentId?: string;

  @Column({
    type: 'enum',
    enum: UserStatus,
    default: UserStatus.ACTIVE,
  })
  status!: UserStatus;

  @Column({
    type: 'enum',
    enum: AuthProvider,
    default: AuthProvider.LOCAL,
  })
  authProvider!: AuthProvider;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'external_id' })
  externalId?: string;

  @Column({ type: 'jsonb', nullable: true })
  providerMetadata?: Record<string, unknown>;

  @Column({ type: 'timestamp', nullable: true, name: 'last_login_at' })
  lastLoginAt?: Date;

  @Column({ type: 'timestamp', nullable: true, name: 'deleted_at' })
  deletedAt?: Date;

  @OneToMany(() => RefreshToken, (token) => token.user, { cascade: true })
  refreshTokens!: RefreshToken[];

  @OneToMany(() => UserRole, (userRole) => userRole.user, { cascade: true })
  userRoles!: UserRole[];

  @OneToMany(() => AclEntry, (acl) => acl.user, { cascade: true })
  aclEntries!: AclEntry[];
}

