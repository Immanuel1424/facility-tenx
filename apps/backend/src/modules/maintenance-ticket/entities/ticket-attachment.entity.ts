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

export enum AttachmentType {
  IMAGE = 'IMAGE',
  DOCUMENT = 'DOCUMENT',
  VIDEO = 'VIDEO',
  AUDIO = 'AUDIO',
  OTHER = 'OTHER',
}

export enum AttachmentContext {
  TICKET_CREATION = 'TICKET_CREATION',    // Attached when creating ticket
  WORK_PROGRESS = 'WORK_PROGRESS',         // Attached during work
  COMPLETION = 'COMPLETION',                // Attached on completion (before/after photos)
  COMMENT = 'COMMENT',                      // Attached to a comment
}

@Entity('ticket_attachments')
@Index(['companyId', 'ticketId'])
@Index(['companyId', 'uploadedById'])
@Index(['companyId', 'attachmentType'])
export class TicketAttachment extends TenantBaseEntity {
  @Column({ type: 'uuid', name: 'ticket_id' })
  ticketId!: string;

  @ManyToOne(() => MaintenanceTicket, { nullable: false })
  @JoinColumn({ name: 'ticket_id' })
  ticket!: MaintenanceTicket;

  @Column({ type: 'uuid', name: 'uploaded_by_id' })
  uploadedById!: string;

  @ManyToOne(() => User, { nullable: false })
  @JoinColumn({ name: 'uploaded_by_id' })
  uploadedBy!: User;

  @Column({ type: 'varchar', length: 255, name: 'file_name' })
  fileName!: string;

  @Column({ type: 'varchar', length: 255, name: 'original_name' })
  originalName!: string;

  @Column({ type: 'varchar', length: 100, name: 'mime_type' })
  mimeType!: string;

  @Column({ type: 'int', name: 'file_size' })
  fileSize!: number;

  @Column({ type: 'varchar', length: 500, name: 'storage_path' })
  storagePath!: string;

  @Column({ type: 'varchar', length: 1000, nullable: true, name: 'storage_url' })
  storageUrl?: string;

  @Column({
    type: 'enum',
    enum: AttachmentType,
    default: AttachmentType.OTHER,
    name: 'attachment_type',
  })
  attachmentType!: AttachmentType;

  @Column({
    type: 'enum',
    enum: AttachmentContext,
    default: AttachmentContext.TICKET_CREATION,
    name: 'attachment_context',
  })
  attachmentContext!: AttachmentContext;

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ type: 'varchar', length: 64, nullable: true, name: 'checksum' })
  checksum?: string;

  @Column({ type: 'boolean', default: false, name: 'is_deleted' })
  isDeleted!: boolean;

  @Column({ type: 'timestamp with time zone', nullable: true, name: 'deleted_at' })
  deletedAt?: Date;

  @Column({ type: 'uuid', nullable: true, name: 'comment_id' })
  commentId?: string;

  @Column({ type: 'int', nullable: true, name: 'image_width' })
  imageWidth?: number;

  @Column({ type: 'int', nullable: true, name: 'image_height' })
  imageHeight?: number;

  @Column({ type: 'varchar', length: 500, nullable: true, name: 'thumbnail_url' })
  thumbnailUrl?: string;
}

