import { Entity, Column, Index, ManyToOne, JoinColumn } from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { User } from './user.entity';

export enum DevicePlatform {
  WEB = 'web',
  ANDROID = 'android',
  IOS = 'ios',
}

@Entity('user_devices')
@Index(['companyId', 'userId'])
@Index(['userId', 'isActive'], { where: 'is_active = true' })
@Index(['fcmToken'])
export class UserDevice extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @Column({ type: 'text', name: 'fcm_token' })
  fcmToken!: string;

  @Column({
    type: 'varchar',
    length: 20,
    enum: DevicePlatform,
  })
  platform!: DevicePlatform;

  @Column({ type: 'jsonb', name: 'device_info', nullable: true })
  deviceInfo?: Record<string, unknown> | null;

  @Column({ type: 'boolean', name: 'is_active', default: true })
  isActive!: boolean;

  @Column({ type: 'timestamp', name: 'last_used_at', default: () => 'now()' })
  lastUsedAt!: Date;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: User;
}

