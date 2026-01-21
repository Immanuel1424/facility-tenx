import { Entity, Column, Index, ManyToOne, JoinColumn } from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { User } from '../../iam/entities/user.entity';

@Entity('password_reset_tokens')
@Index(['companyId', 'token'], { unique: true })
@Index(['companyId', 'userId'])
@Index(['companyId', 'email'])
export class PasswordResetToken extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @Column({ type: 'varchar', length: 255 })
  email!: string;

  @Column({ type: 'varchar', length: 6 })
  otp!: string;

  @Column({ type: 'text' })
  token!: string;

  @Column({ type: 'timestamp', name: 'expires_at' })
  expiresAt!: Date;

  @Column({ type: 'timestamp', nullable: true, name: 'used_at' })
  usedAt?: Date;

  @Column({ type: 'int', default: 0, name: 'attempts' })
  attempts!: number;

  @Column({ type: 'varchar', length: 255, nullable: true, name: 'ip_address' })
  ipAddress?: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: User;
}

