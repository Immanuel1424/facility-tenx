import {
  Entity,
  Column,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { MaintenanceTicket } from './maintenance-ticket.entity';
import { User } from '../../iam/entities/user.entity';

@Entity('escalation_history')
@Index(['companyId', 'ticketId'])
@Index(['companyId', 'escalatedToRole'])
@Index(['companyId', 'escalatedAt'])
export class EscalationHistory extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'ticket_id', nullable: false })
  ticketId!: string;

  @ManyToOne(() => MaintenanceTicket, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'ticket_id' })
  ticket!: MaintenanceTicket;

  @Column({ type: 'int', name: 'escalation_level', nullable: false })
  escalationLevel!: number;

  @Column({
    type: 'varchar',
    length: 50,
    nullable: true,
    name: 'escalated_from_role',
  })
  escalatedFromRole?: string;

  @Column({
    type: 'varchar',
    length: 50,
    nullable: true,
    name: 'escalated_to_role',
  })
  escalatedToRole?: string;

  @Column({ type: 'text', nullable: true })
  reason?: string;

  @Column({ type: 'uuid', nullable: true, name: 'escalated_by' })
  escalatedBy?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'escalated_by' })
  escalator?: User;

  @Column({
    type: 'timestamp with time zone',
    name: 'escalated_at',
    nullable: false,
    default: () => 'now()',
  })
  escalatedAt!: Date;

  @Column({
    type: 'boolean',
    default: false,
    name: 'is_automatic',
  })
  isAutomatic!: boolean;
}
