import {
  Column,
  Entity,
  Index,
  ManyToOne,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { NotificationChannel } from '../enums/notification-channel.enum';
import { Notification } from './notification.entity';

export enum DeliveryStatus {
  PENDING = 'pending',
  SUCCESS = 'success',
  FAILED = 'failed',
  RETRYING = 'retrying',
}

@Entity({ name: 'notification_deliveries' })
@Index(['companyId', 'notificationId', 'channel'])
export class NotificationDelivery extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'notification_id' })
  notificationId!: string;

  @ManyToOne(
    () => Notification,
    (notification) => notification.deliveries,
    { onDelete: 'CASCADE' },
  )
  notification!: Notification;

  @Column({ type: 'enum', enum: NotificationChannel })
  channel!: NotificationChannel;

  @Column({ type: 'enum', enum: DeliveryStatus, default: DeliveryStatus.PENDING })
  status!: DeliveryStatus;

  @Column({ type: 'int', name: 'attempt_count', default: 0 })
  attemptCount!: number;

  @Column({ type: 'text', name: 'last_error', nullable: true })
  lastError!: string | null;
}
