import {
  Entity,
  Column,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { MaintenanceTicket } from './maintenance-ticket.entity';
import { SlaConfiguration } from './sla-configuration.entity';

export enum SlaStatus {
  ON_TRACK = 'ON_TRACK',
  AT_RISK = 'AT_RISK',
  BREACHED = 'BREACHED',
  PAUSED = 'PAUSED',
  MET = 'MET',
}

@Entity('ticket_sla')
@Index(['companyId', 'ticketId'])
@Index(['companyId', 'slaStatus'])
@Index(['companyId', 'responseDeadline'])
@Index(['companyId', 'resolutionDeadline'])
export class TicketSla extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'ticket_id' })
  ticketId!: string;

  @ManyToOne(() => MaintenanceTicket, { nullable: false })
  @JoinColumn({ name: 'ticket_id' })
  ticket!: MaintenanceTicket;

  @Column({ type: 'uuid', name: 'sla_configuration_id' })
  slaConfigurationId!: string;

  @ManyToOne(() => SlaConfiguration, { nullable: false })
  @JoinColumn({ name: 'sla_configuration_id' })
  slaConfiguration!: SlaConfiguration;

  // Deadlines
  @Column({ type: 'timestamp with time zone', name: 'first_response_deadline' })
  firstResponseDeadline!: Date;

  @Column({ type: 'timestamp with time zone', name: 'response_deadline' })
  responseDeadline!: Date;

  @Column({ type: 'timestamp with time zone', name: 'resolution_deadline' })
  resolutionDeadline!: Date;

  // Actual times
  @Column({ type: 'timestamp with time zone', nullable: true, name: 'first_response_at' })
  firstResponseAt?: Date;

  @Column({ type: 'timestamp with time zone', nullable: true, name: 'acknowledged_at' })
  acknowledgedAt?: Date;

  @Column({ type: 'timestamp with time zone', nullable: true, name: 'resolved_at' })
  resolvedAt?: Date;

  // Status tracking
  @Column({
    type: 'enum',
    enum: SlaStatus,
    default: SlaStatus.ON_TRACK,
    name: 'sla_status',
  })
  slaStatus!: SlaStatus;

  @Column({ type: 'boolean', default: false, name: 'first_response_breached' })
  firstResponseBreached!: boolean;

  @Column({ type: 'boolean', default: false, name: 'response_breached' })
  responseBreached!: boolean;

  @Column({ type: 'boolean', default: false, name: 'resolution_breached' })
  resolutionBreached!: boolean;

  // Pause tracking (for ON_HOLD status)
  @Column({ type: 'timestamp with time zone', nullable: true, name: 'paused_at' })
  pausedAt?: Date;

  @Column({ type: 'int', default: 0, name: 'total_paused_minutes' })
  totalPausedMinutes!: number;

  // Escalation tracking
  @Column({ type: 'int', default: 0, name: 'current_escalation_level' })
  currentEscalationLevel!: number;

  @Column({ type: 'timestamp with time zone', nullable: true, name: 'last_escalation_at' })
  lastEscalationAt?: Date;

  // Metrics
  @Column({ type: 'int', nullable: true, name: 'actual_response_minutes' })
  actualResponseMinutes?: number;

  @Column({ type: 'int', nullable: true, name: 'actual_resolution_minutes' })
  actualResolutionMinutes?: number;
}

