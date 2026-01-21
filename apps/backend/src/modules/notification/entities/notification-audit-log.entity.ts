import {
  Column,
  Entity,
  Index,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { NotificationSeverity } from '../enums/notification-severity.enum';

@Entity({ name: 'notification_audit_logs' })
@Index(['companyId', 'createdAt'])
export class NotificationAuditLog extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 128 })
  eventType!: string;

  @Column({ type: 'enum', enum: NotificationSeverity })
  severity!: NotificationSeverity;

  @Column({ type: 'uuid', name: 'recipient_user_id', nullable: true })
  recipientUserId!: string | null;

  @Column({ type: 'jsonb', name: 'event_payload', nullable: true })
  eventPayload!: Record<string, unknown> | null;

  @Column({ type: 'jsonb', name: 'metadata', nullable: true })
  metadata!: Record<string, unknown> | null;
}
