import {
  Column,
  Entity,
  Index,
  OneToMany,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { NotificationChannel } from '../enums/notification-channel.enum';
import { NotificationSeverity } from '../enums/notification-severity.enum';
import { NotificationDelivery } from './notification-delivery.entity';

@Entity({ name: 'notifications' })
@Index(['companyId', 'recipientUserId', 'createdAt'])
export class Notification extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'recipient_user_id', nullable: true })
  recipientUserId!: string | null;

  @Column({ type: 'varchar', length: 128 })
  type!: string;

  @Column({ type: 'enum', enum: NotificationSeverity, default: NotificationSeverity.INFO })
  severity!: NotificationSeverity;

  @Column({ type: 'varchar', length: 255, nullable: true })
  title!: string | null;

  @Column({ type: 'text' })
  message!: string;

  @Column({ type: 'jsonb', name: 'payload', nullable: true })
  payload!: Record<string, unknown> | null;

  @Column({ type: 'boolean', name: 'is_read', default: false })
  isRead!: boolean;

  @Column({ type: 'timestamp', name: 'read_at', nullable: true })
  readAt!: Date | null;

  @Column({ type: 'enum', enum: NotificationChannel, array: true })
  channels!: NotificationChannel[];

  @OneToMany(
    () => NotificationDelivery,
    (delivery) => delivery.notification,
    { cascade: true },
  )
  deliveries!: NotificationDelivery[];
}
