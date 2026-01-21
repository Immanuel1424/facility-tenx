import {
  Entity,
  Column,
  Index,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { TenantBaseEntity } from '../../../shared/database/tenant-base.entity';
import { TicketStatus } from '../enums/ticket-status.enum';
import { TicketPriority } from '../enums/ticket-priority.enum';
import { TicketType } from '../enums/ticket-type.enum';
import { TicketStatusHistory } from './ticket-status-history.entity';
import { TicketComment } from './ticket-comment.entity';
import { TicketAttachment } from './ticket-attachment.entity';
import { Department } from './department.entity';
import { TicketCategory } from './ticket-category.entity';
import { Team } from './team.entity';
import { User } from '../../iam/entities/user.entity';
import { Site } from '../../tenant/entities/site.entity';
import { Space } from '../../tenant/entities/space.entity';
import { Villa } from '../../tenant/entities/villa.entity';

@Entity('maintenance_tickets')
// Identification indexes
@Index(['companyId', 'ticketNumber'], { unique: true })
@Index(['companyId', 'ticketType'])
// Location indexes
@Index(['companyId', 'villaNumber'])
@Index(['companyId', 'villaId'])
@Index(['companyId', 'siteId'])
@Index(['companyId', 'spaceId'])
// Status/filtering indexes
@Index(['companyId', 'status'])
@Index(['companyId', 'priority'])
@Index(['companyId', 'createdBy'])
// Assignment indexes
@Index(['companyId', 'assignedTechnicianId'])
@Index(['companyId', 'assignedSupervisorId'])
@Index(['companyId', 'assignedTeamId'])
@Index(['companyId', 'categoryId'])
// Hierarchy index
@Index(['companyId', 'parentTicketId'])
export class MaintenanceTicket extends TenantBaseEntity {
  @Column({ type: 'varchar', length: 50, name: 'ticket_number' })
  ticketNumber!: string;

  // ============================================================================
  // TICKET TYPE (NEW - from service_requests)
  // ============================================================================
  @Column({
    type: 'enum',
    enum: TicketType,
    default: TicketType.MAINTENANCE,
    name: 'ticket_type',
  })
  ticketType!: TicketType;

  // ============================================================================
  // LOCATION (villa_number kept for backward compatibility, villa_id is preferred)
  // ============================================================================
  /**
   * @deprecated Use villaId instead. Kept for backward compatibility.
   */
  @Column({ type: 'varchar', length: 50, name: 'villa_number', nullable: true })
  villaNumber?: string;

  @Column({ type: 'uuid', name: 'villa_id', nullable: true })
  villaId?: string;

  @ManyToOne(() => Villa, { nullable: true })
  @JoinColumn({ name: 'villa_id' })
  villa?: Villa;

  @Column({ type: 'uuid', name: 'site_id', nullable: true })
  siteId?: string;

  @ManyToOne(() => Site, { nullable: true })
  @JoinColumn({ name: 'site_id' })
  site?: Site;

  @Column({ type: 'uuid', name: 'space_id', nullable: true })
  spaceId?: string;

  @ManyToOne(() => Space, { nullable: true })
  @JoinColumn({ name: 'space_id' })
  space?: Space;

  @Column({ type: 'uuid', name: 'created_by', nullable: false })
  createdBy!: string;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'created_by' })
  creator!: User;

  @Column({ type: 'varchar', length: 255 })
  title!: string;

  @Column({ type: 'text', nullable: true })
  description?: string;

  /**
   * Free-text location detail inside the villa/space
   * Examples: "Kitchen", "Living Room", "Bedroom 2"
   */
  @Column({
    type: 'varchar',
    length: 255,
    name: 'location_detail',
    nullable: true,
  })
  locationDetail?: string;

  @Column({
    type: 'enum',
    enum: TicketStatus,
    default: TicketStatus.NEW,
  })
  status!: TicketStatus;

  @Column({
    type: 'enum',
    enum: TicketPriority,
    default: TicketPriority.MEDIUM,
  })
  priority!: TicketPriority;

  @Column({ type: 'uuid', name: 'category_id', nullable: true })
  categoryId?: string;

  @ManyToOne(() => TicketCategory, { nullable: true })
  @JoinColumn({ name: 'category_id' })
  category?: TicketCategory;

  // ============================================================================
  // TENANT CONTACT INFORMATION
  // ============================================================================
  @Column({ type: 'varchar', length: 50, name: 'contact_number', nullable: true })
  contactNumber?: string;

  @Column({ type: 'varchar', length: 50, name: 'alternate_contact', nullable: true })
  alternateContact?: string;

  @Column({ type: 'varchar', length: 255, name: 'preferred_time', nullable: true })
  preferredTime?: string;

  @Column({ type: 'uuid', name: 'department_id', nullable: true })
  departmentId?: string;

  @ManyToOne(() => Department, { nullable: true })
  @JoinColumn({ name: 'department_id' })
  department?: Department;

  @Column({ type: 'uuid', name: 'assigned_supervisor_id', nullable: true })
  assignedSupervisorId?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'assigned_supervisor_id' })
  assignedSupervisor?: User;

  @Column({
    type: 'timestamp with time zone',
    name: 'supervisor_assigned_at',
    nullable: true,
  })
  supervisorAssignedAt?: Date;

  @Column({ type: 'uuid', name: 'assigned_technician_id', nullable: true })
  assignedTechnicianId?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'assigned_technician_id' })
  assignedTechnician?: User;

  @Column({ type: 'uuid', name: 'assigned_by', nullable: true })
  assignedBy?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'assigned_by' })
  assigner?: User;

  @Column({
    type: 'timestamp with time zone',
    name: 'assigned_at',
    nullable: true,
  })
  assignedAt?: Date;

  @Column({ type: 'uuid', name: 'acknowledged_by', nullable: true })
  acknowledgedBy?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'acknowledged_by' })
  acknowledger?: User;

  @Column({
    type: 'timestamp with time zone',
    name: 'acknowledged_at',
    nullable: true,
  })
  acknowledgedAt?: Date;

  @Column({
    type: 'timestamp with time zone',
    name: 'scheduled_at',
    nullable: true,
  })
  scheduledAt?: Date;

  @Column({ type: 'text', nullable: true, name: 'technician_notes' })
  technicianNotes?: string;

  @Column({ type: 'text', nullable: true, name: 'resolution_notes' })
  resolutionNotes?: string;

  @Column({
    type: 'timestamp with time zone',
    name: 'completed_at',
    nullable: true,
  })
  completedAt?: Date;

  @Column({
    type: 'timestamp with time zone',
    name: 'closed_at',
    nullable: true,
  })
  closedAt?: Date;

  @Column({
    type: 'timestamp with time zone',
    name: 'auto_close_at',
    nullable: true,
  })
  autoCloseAt?: Date;

  @Column({ type: 'boolean', default: false, name: 'tenant_confirmed' })
  tenantConfirmed!: boolean;

  // ============================================================================
  // RATING (NEW - tenant rating after ticket closure)
  // ============================================================================
  @Column({ type: 'integer', nullable: true })
  rating?: number;

  @Column({ type: 'text', name: 'rating_comment', nullable: true })
  ratingComment?: string;

  @Column({
    type: 'timestamp with time zone',
    name: 'rated_at',
    nullable: true,
  })
  ratedAt?: Date;

  @Column({ type: 'uuid', name: 'rated_by', nullable: true })
  ratedBy?: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'rated_by' })
  ratedByUser?: User;

  // ============================================================================
  // TEAM ASSIGNMENT (NEW - from service_requests)
  // ============================================================================
  @Column({ type: 'uuid', name: 'assigned_team_id', nullable: true })
  assignedTeamId?: string;

  @ManyToOne(() => Team, { nullable: true })
  @JoinColumn({ name: 'assigned_team_id' })
  assignedTeam?: Team;

  // ============================================================================
  // PARENT/CHILD TICKETS (NEW - from service_requests)
  // ============================================================================
  @Column({ type: 'uuid', name: 'parent_ticket_id', nullable: true })
  parentTicketId?: string;

  @ManyToOne(() => MaintenanceTicket, (ticket) => ticket.childTickets, { nullable: true })
  @JoinColumn({ name: 'parent_ticket_id' })
  parentTicket?: MaintenanceTicket;

  @OneToMany(() => MaintenanceTicket, (ticket) => ticket.parentTicket)
  childTickets!: MaintenanceTicket[];

  // ============================================================================
  // ESCALATION (NEW - from service_requests)
  // ============================================================================
  @Column({ type: 'boolean', default: false, name: 'is_escalated' })
  isEscalated!: boolean;

  @Column({ type: 'int', default: 0, nullable: true, name: 'escalation_level' })
  escalationLevel?: number;

  @Column({
    type: 'timestamp with time zone',
    name: 'escalated_at',
    nullable: true,
  })
  escalatedAt?: Date;

  // ============================================================================
  // RELATIONS
  // ============================================================================
  @OneToMany(() => TicketStatusHistory, (history) => history.ticket, {
    cascade: true,
  })
  statusHistory!: TicketStatusHistory[];

  @OneToMany(() => TicketComment, (comment) => comment.ticket, {
    cascade: true,
  })
  comments!: TicketComment[];

  @OneToMany(() => TicketAttachment, (attachment) => attachment.ticket, {
    cascade: true,
  })
  attachments!: TicketAttachment[];
}

