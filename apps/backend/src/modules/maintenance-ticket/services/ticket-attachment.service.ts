import { Injectable, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TicketAttachment, AttachmentType, AttachmentContext } from '../entities/ticket-attachment.entity';
import { MaintenanceTicket } from '../entities/maintenance-ticket.entity';
import { User } from '../../iam/entities/user.entity';
import { CreateAttachmentDto } from '../dto/create-attachment.dto';
import { UserRole } from '../enums/user-role.enum';
import { TicketStatus } from '../enums/ticket-status.enum';
import { IStorageService } from './storage.interface';
import {
  ResourceNotFoundException,
  TicketClosedException,
  TenantAccessViolationException,
  VillaMismatchException,
  AttachmentLimitExceededException,
} from '../../../shared/exceptions/business.exception';

const MAX_ATTACHMENTS_PER_TICKET = 20;
const MAX_ATTACHMENT_SIZE_BYTES = 52428800; // 50MB

@Injectable()
export class TicketAttachmentService {
  constructor(
    @InjectRepository(TicketAttachment)
    private readonly attachmentRepository: Repository<TicketAttachment>,
    @InjectRepository(MaintenanceTicket)
    private readonly ticketRepository: Repository<MaintenanceTicket>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @Inject('StorageService') private readonly storageService: IStorageService,
  ) {}

  async create(
    companyId: string,
    ticketId: string,
    userId: string,
    userRoles: string[],
    createDto: CreateAttachmentDto,
  ): Promise<TicketAttachment> {
    // Verify ticket exists and belongs to company
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new ResourceNotFoundException('Ticket', ticketId);
    }

    // Check if ticket is closed
    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (isTenant && !isAdmin) {
      if (ticket.status === TicketStatus.CANCELLED) {
        throw new TicketClosedException(ticketId);
      }

      // Verify tenant owns this ticket
      const user = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (user && ticket.villaNumber && user.villaNumber && ticket.villaNumber !== user.villaNumber) {
        // NOTE: Multi-villa support is enforced at the ticket level in MaintenanceTicketService.
        // This check remains as a safety net for legacy single-villa users.
        throw new VillaMismatchException(user.villaNumber, ticket.villaNumber);
      }
    }

    // Check attachment count limit
    const existingCount = await this.attachmentRepository.count({
      where: { ticketId, companyId, isDeleted: false },
    });

    if (existingCount >= MAX_ATTACHMENTS_PER_TICKET) {
      throw new AttachmentLimitExceededException(MAX_ATTACHMENTS_PER_TICKET);
    }

    // Determine attachment type from mime type
    const attachmentType = this.determineAttachmentType(createDto.mime_type);

    const attachment = this.attachmentRepository.create({
      companyId,
      ticketId,
      uploadedById: userId,
      fileName: createDto.file_name,
      originalName: createDto.original_name,
      mimeType: createDto.mime_type,
      fileSize: createDto.file_size,
      storagePath: createDto.storage_path,
      storageUrl: createDto.storage_url,
      attachmentType: createDto.attachment_type || attachmentType,
      attachmentContext: createDto.attachment_context || AttachmentContext.TICKET_CREATION,
      description: createDto.description,
      checksum: createDto.checksum,
      commentId: createDto.comment_id,
      imageWidth: createDto.image_width,
      imageHeight: createDto.image_height,
      thumbnailUrl: createDto.thumbnail_url,
    });

    return this.attachmentRepository.save(attachment);
  }

  async findAllByTicket(
    companyId: string,
    ticketId: string,
    userRoles: string[],
    userId: string,
  ): Promise<TicketAttachment[]> {
    // Verify ticket exists
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new ResourceNotFoundException('Ticket', ticketId);
    }

    // Verify tenant can access this ticket
    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (isTenant && !isAdmin) {
      const user = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (user && ticket.villaNumber && user.villaNumber && ticket.villaNumber !== user.villaNumber) {
        throw new VillaMismatchException(user.villaNumber, ticket.villaNumber);
      }
    }

    return this.attachmentRepository.find({
      where: { ticketId, companyId, isDeleted: false },
      relations: ['uploadedBy'],
      order: { createdAt: 'ASC' },
    });
  }

  async findOne(
    companyId: string,
    ticketId: string,
    attachmentId: string,
    userRoles: string[],
    userId: string,
  ): Promise<TicketAttachment> {
    const attachment = await this.attachmentRepository.findOne({
      where: { id: attachmentId, companyId, ticketId },
      relations: ['uploadedBy', 'ticket'],
    });

    if (!attachment || attachment.isDeleted) {
      throw new ResourceNotFoundException('Attachment', attachmentId);
    }

    // Verify tenant can access this attachment
    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    if (isTenant && !isAdmin) {
      const user = await this.userRepository.findOne({
        where: { id: userId, companyId },
      });

      if (user && attachment.ticket.villaNumber && user.villaNumber && attachment.ticket.villaNumber !== user.villaNumber) {
        throw new VillaMismatchException(user.villaNumber, attachment.ticket.villaNumber);
      }
    }

    return attachment;
  }

  async delete(
    companyId: string,
    ticketId: string,
    attachmentId: string,
    userId: string,
    userRoles: string[],
  ): Promise<void> {
    const attachment = await this.findOne(companyId, ticketId, attachmentId, userRoles, userId);

    const isAdmin = userRoles.includes(UserRole.ADMIN);

    // Only the uploader or admin can delete
    if (attachment.uploadedById !== userId && !isAdmin) {
      throw new TenantAccessViolationException('You can only delete your own attachments');
    }

    // Check if ticket is closed
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (ticket && ticket.status === TicketStatus.CANCELLED) {
      if (!isAdmin) {
        throw new TicketClosedException(ticketId);
      }
    }

    // Delete file from S3
    if (attachment.storagePath) {
      try {
        await this.storageService.deleteFile(attachment.storagePath);
      } catch (error) {
        // Log error but continue with soft delete
        // File might already be deleted or not exist
        console.error(`Failed to delete file from S3: ${attachment.storagePath}`, error);
      }
    }

    // Soft delete
    attachment.isDeleted = true;
    attachment.deletedAt = new Date();

    await this.attachmentRepository.save(attachment);
  }

  async getAttachmentsByContext(
    companyId: string,
    ticketId: string,
    context: AttachmentContext,
  ): Promise<TicketAttachment[]> {
    return this.attachmentRepository.find({
      where: { ticketId, companyId, attachmentContext: context, isDeleted: false },
      relations: ['uploadedBy'],
      order: { createdAt: 'ASC' },
    });
  }

  async getAttachmentStats(
    companyId: string,
    ticketId: string,
  ): Promise<{ count: number; totalSize: number }> {
    const result = await this.attachmentRepository
      .createQueryBuilder('attachment')
      .select('COUNT(*)', 'count')
      .addSelect('COALESCE(SUM(attachment.fileSize), 0)', 'totalSize')
      .where('attachment.companyId = :companyId', { companyId })
      .andWhere('attachment.ticketId = :ticketId', { ticketId })
      .andWhere('attachment.isDeleted = :isDeleted', { isDeleted: false })
      .getRawOne();

    return {
      count: parseInt(result.count, 10),
      totalSize: parseInt(result.totalSize, 10),
    };
  }

  private determineAttachmentType(mimeType: string): AttachmentType {
    if (mimeType.startsWith('image/')) {
      return AttachmentType.IMAGE;
    }
    if (mimeType.startsWith('video/')) {
      return AttachmentType.VIDEO;
    }
    if (mimeType.startsWith('audio/')) {
      return AttachmentType.AUDIO;
    }
    if (
      mimeType.startsWith('application/pdf') ||
      mimeType.startsWith('application/msword') ||
      mimeType.startsWith('application/vnd.') ||
      mimeType.startsWith('text/')
    ) {
      return AttachmentType.DOCUMENT;
    }
    return AttachmentType.OTHER;
  }
}

