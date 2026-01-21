import {
  Entity,
  Column,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { TicketPriority } from '../enums/ticket-priority.enum';

@Entity('sla_configurations')
@Index(['companyId', 'priority'], { unique: true })
@Index(['companyId', 'isActive'])
export class SlaConfiguration extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 100 })
  name!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({
    type: 'enum',
    enum: TicketPriority,
  })
  priority!: TicketPriority;

  // First response time in minutes
  @Column({ type: 'int', name: 'first_response_time_minutes' })
  firstResponseTimeMinutes!: number;

  // Acknowledgement time in minutes
  @Column({ type: 'int', name: 'acknowledgement_time_minutes' })
  acknowledgementTimeMinutes!: number;

  // Start work time in minutes (deadline to change status from ASSIGNED to IN_PROGRESS)
  @Column({ type: 'int', name: 'start_work_time_minutes', nullable: true })
  startWorkTimeMinutes?: number;

  // Resolution time in minutes
  @Column({ type: 'int', name: 'resolution_time_minutes' })
  resolutionTimeMinutes!: number;

  // Escalation thresholds
  @Column({ type: 'int', name: 'escalation_level_1_minutes', nullable: true })
  escalationLevel1Minutes?: number;

  @Column({ type: 'int', name: 'escalation_level_2_minutes', nullable: true })
  escalationLevel2Minutes?: number;

  @Column({ type: 'int', name: 'escalation_level_3_minutes', nullable: true })
  escalationLevel3Minutes?: number;

  // Business hours settings
  @Column({ type: 'boolean', default: true, name: 'apply_business_hours' })
  applyBusinessHours!: boolean;

  @Column({ type: 'time', nullable: true, name: 'business_start_time' })
  businessStartTime?: string;

  @Column({ type: 'time', nullable: true, name: 'business_end_time' })
  businessEndTime?: string;

  // Working days (comma-separated: 1,2,3,4,5 for Mon-Fri)
  @Column({ type: 'varchar', length: 20, nullable: true, name: 'working_days' })
  workingDays?: string;

  // Exclude holidays
  @Column({ type: 'boolean', default: true, name: 'exclude_holidays' })
  excludeHolidays!: boolean;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive!: boolean;

  @Column({ type: 'uuid', nullable: true, name: 'created_by_id' })
  createdById?: string;
}

