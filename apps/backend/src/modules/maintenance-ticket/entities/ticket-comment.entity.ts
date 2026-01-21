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

export enum CommentType {
  PUBLIC = 'PUBLIC',         // Visible to all including tenant
  INTERNAL = 'INTERNAL',     // Visible only to staff (not tenant)
  WORK_NOTE = 'WORK_NOTE',   // Technician work notes
  SYSTEM = 'SYSTEM',         // System-generated comments
}

@Entity('ticket_comments')
@Index(['companyId', 'ticketId'])
@Index(['companyId', 'createdById'])
@Index(['companyId', 'commentType'])
export class TicketComment extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'ticket_id' })
  ticketId!: string;

  @ManyToOne(() => MaintenanceTicket, { nullable: false })
  @JoinColumn({ name: 'ticket_id' })
  ticket!: MaintenanceTicket;

  @Column({ type: 'uuid', name: 'created_by_id' })
  createdById!: string;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'created_by_id' })
  createdBy!: User;

  @Column({ type: 'text' })
  content!: string;

  @Column({
    type: 'enum',
    enum: CommentType,
    default: CommentType.PUBLIC,
    name: 'comment_type',
  })
  commentType!: CommentType;

  @Column({ type: 'boolean', default: false, name: 'is_edited' })
  isEdited!: boolean;

  @Column({ type: 'timestamp with time zone', nullable: true, name: 'edited_at' })
  editedAt?: Date;

  @Column({ type: 'uuid', nullable: true, name: 'parent_comment_id' })
  parentCommentId?: string;

  @ManyToOne(() => TicketComment, { nullable: true })
  @JoinColumn({ name: 'parent_comment_id' })
  parentComment?: TicketComment;

  @Column({ type: 'boolean', default: false, name: 'is_deleted' })
  isDeleted!: boolean;

  @Column({ type: 'timestamp with time zone', nullable: true, name: 'deleted_at' })
  deletedAt?: Date;
}

