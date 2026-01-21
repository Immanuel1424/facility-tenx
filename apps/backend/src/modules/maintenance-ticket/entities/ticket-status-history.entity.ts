import {
  Entity,
  Column,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { MaintenanceTicket } from './maintenance-ticket.entity';
import { TicketStatus } from '../enums/ticket-status.enum';
import { User } from '../../iam/entities/user.entity';

@Entity('ticket_status_history')
@Index(['companyId', 'ticketId'])
@Index(['companyId', 'changedBy'])
export class TicketStatusHistory extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'ticket_id', nullable: false })
  ticketId!: string;

  @ManyToOne(() => MaintenanceTicket, (ticket) => ticket.statusHistory, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'ticket_id' })
  ticket!: MaintenanceTicket;

  @Column({
    type: 'enum',
    enum: TicketStatus,
    nullable: true,
    name: 'previous_status',
  })
  previousStatus?: TicketStatus;

  @Column({
    type: 'enum',
    enum: TicketStatus,
    nullable: false,
    name: 'new_status',
  })
  newStatus!: TicketStatus;

  @Column({ type: 'uuid', name: 'changed_by', nullable: false })
  changedBy!: string;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'changed_by' })
  changer!: User;

  @Column({ type: 'text', nullable: true })
  notes?: string;

  @Column({ type: 'jsonb', nullable: true, name: 'metadata' })
  metadata?: Record<string, unknown>;
}

