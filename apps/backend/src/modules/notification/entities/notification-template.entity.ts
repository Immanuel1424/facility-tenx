import {
  Column,
  Entity,
  Index,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { NotificationChannel } from '../enums/notification-channel.enum';

@Entity({ name: 'notification_templates' })
@Index(['companyId', 'code', 'channel'], { unique: true })
export class NotificationTemplate extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 128 })
  code!: string;

  @Column({ type: 'enum', enum: NotificationChannel })
  channel!: NotificationChannel;

  @Column({ type: 'varchar', length: 255, nullable: true })
  subject!: string | null;

  @Column({ type: 'text' })
  body!: string;

  @Column({ type: 'jsonb', name: 'default_variables', nullable: true })
  defaultVariables!: Record<string, unknown> | null;
}
