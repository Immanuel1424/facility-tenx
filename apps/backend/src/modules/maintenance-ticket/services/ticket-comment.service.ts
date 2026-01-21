import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TicketComment, CommentType } from '../entities/ticket-comment.entity';
import { MaintenanceTicket } from '../entities/maintenance-ticket.entity';
import { User } from '../../iam/entities/user.entity';
import { UserService } from '../../iam/services/user.service';
import { CreateCommentDto } from '../dto/create-comment.dto';
import { UpdateCommentDto } from '../dto/update-comment.dto';
import { UserRole } from '../enums/user-role.enum';
import { TicketStatus } from '../enums/ticket-status.enum';
import {
  ResourceNotFoundException,
  TicketClosedException,
  TenantAccessViolationException,
  VillaMismatchException,
} from '../../../shared/exceptions/business.exception';

@Injectable()
export class TicketCommentService {
  constructor(
    @InjectRepository(TicketComment)
    private readonly commentRepository: Repository<TicketComment>,
    @InjectRepository(MaintenanceTicket)
    private readonly ticketRepository: Repository<MaintenanceTicket>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly userService: UserService,
  ) {}

  async create(
    companyId: string,
    ticketId: string,
    userId: string,
    userRoles: string[],
    createDto: CreateCommentDto,
  ): Promise<TicketComment> {
    // Verify ticket exists and belongs to company
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new ResourceNotFoundException('Ticket', ticketId);
    }

    // Check if ticket is closed (tenants cannot comment on closed tickets)
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

      if (user) {
        // Multi-villa support: Check against all assigned villas
        const allowedVillas = await this.userService.getAllowedVillaNumbers(
          companyId,
          userId,
        );

        if (
          ticket.villaNumber &&
          !allowedVillas.includes(String(ticket.villaNumber))
        ) {
          throw new VillaMismatchException(
            user.villaNumber,
            ticket.villaNumber,
          );
        }
      }
    }

    // Determine comment type based on user role
    let commentType = createDto.comment_type || CommentType.PUBLIC;

    // Tenants can only create PUBLIC comments
    if (isTenant && !isAdmin) {
      commentType = CommentType.PUBLIC;
    }

    // Validate parent comment if provided
    if (createDto.parent_comment_id) {
      const parentComment = await this.commentRepository.findOne({
        where: { id: createDto.parent_comment_id, companyId, ticketId },
      });

      if (!parentComment) {
        throw new ResourceNotFoundException('Parent comment', createDto.parent_comment_id);
      }

      // Tenants cannot reply to internal comments
      if (isTenant && !isAdmin && parentComment.commentType === CommentType.INTERNAL) {
        throw new TenantAccessViolationException('Cannot reply to internal comments');
      }
    }

    const comment = this.commentRepository.create({
      companyId,
      ticketId,
      createdById: userId,
      content: createDto.content,
      commentType,
      parentCommentId: createDto.parent_comment_id,
    });

    const savedComment = await this.commentRepository.save(comment);

    return this.findOne(companyId, ticketId, savedComment.id, userRoles);
  }

  async findAllByTicket(
    companyId: string,
    ticketId: string,
    userRoles: string[],
  ): Promise<TicketComment[]> {
    // Verify ticket exists
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new ResourceNotFoundException('Ticket', ticketId);
    }

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    const queryBuilder = this.commentRepository
      .createQueryBuilder('comment')
      .leftJoinAndSelect('comment.createdBy', 'createdBy')
      .where('comment.companyId = :companyId', { companyId })
      .andWhere('comment.ticketId = :ticketId', { ticketId })
      .andWhere('comment.isDeleted = :isDeleted', { isDeleted: false });

    // Tenants cannot see internal comments or work notes
    if (isTenant && !isAdmin) {
      queryBuilder.andWhere('comment.commentType IN (:...types)', {
        types: [CommentType.PUBLIC, CommentType.SYSTEM],
      });
    }

    return queryBuilder
      .orderBy('comment.createdAt', 'ASC')
      .getMany();
  }

  async findOne(
    companyId: string,
    ticketId: string,
    commentId: string,
    userRoles: string[],
  ): Promise<TicketComment> {
    const comment = await this.commentRepository.findOne({
      where: { id: commentId, companyId, ticketId },
      relations: ['createdBy', 'parentComment'],
    });

    if (!comment || comment.isDeleted) {
      throw new ResourceNotFoundException('Comment', commentId);
    }

    const isTenant = userRoles.includes(UserRole.TENANT);
    const isAdmin = userRoles.includes(UserRole.ADMIN);

    // Tenants cannot see internal comments or work notes
    if (
      isTenant &&
      !isAdmin &&
      (comment.commentType === CommentType.INTERNAL ||
        comment.commentType === CommentType.WORK_NOTE)
    ) {
      throw new ResourceNotFoundException('Comment', commentId);
    }

    return comment;
  }

  async update(
    companyId: string,
    ticketId: string,
    commentId: string,
    userId: string,
    userRoles: string[],
    updateDto: UpdateCommentDto,
  ): Promise<TicketComment> {
    const comment = await this.findOne(companyId, ticketId, commentId, userRoles);

    const isAdmin = userRoles.includes(UserRole.ADMIN);

    // Only the comment creator or admin can update
    if (comment.createdById !== userId && !isAdmin) {
      throw new TenantAccessViolationException('You can only edit your own comments');
    }

    comment.content = updateDto.content;
    comment.isEdited = true;
    comment.editedAt = new Date();

    await this.commentRepository.save(comment);

    return this.findOne(companyId, ticketId, commentId, userRoles);
  }

  async delete(
    companyId: string,
    ticketId: string,
    commentId: string,
    userId: string,
    userRoles: string[],
  ): Promise<void> {
    const comment = await this.findOne(companyId, ticketId, commentId, userRoles);

    const isAdmin = userRoles.includes(UserRole.ADMIN);

    // Only the comment creator or admin can delete
    if (comment.createdById !== userId && !isAdmin) {
      throw new TenantAccessViolationException('You can only delete your own comments');
    }

    // Soft delete
    comment.isDeleted = true;
    comment.deletedAt = new Date();

    await this.commentRepository.save(comment);
  }

  async addInternalNote(
    companyId: string,
    ticketId: string,
    userId: string,
    content: string,
  ): Promise<TicketComment> {
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new ResourceNotFoundException('Ticket', ticketId);
    }

    const comment = this.commentRepository.create({
      companyId,
      ticketId,
      createdById: userId,
      content,
      commentType: CommentType.INTERNAL,
    });

    return this.commentRepository.save(comment);
  }

  async addWorkNote(
    companyId: string,
    ticketId: string,
    userId: string,
    content: string,
  ): Promise<TicketComment> {
    const ticket = await this.ticketRepository.findOne({
      where: { id: ticketId, companyId },
    });

    if (!ticket) {
      throw new ResourceNotFoundException('Ticket', ticketId);
    }

    const comment = this.commentRepository.create({
      companyId,
      ticketId,
      createdById: userId,
      content,
      commentType: CommentType.WORK_NOTE,
    });

    return this.commentRepository.save(comment);
  }

  async addSystemComment(
    companyId: string,
    ticketId: string,
    content: string,
  ): Promise<TicketComment> {
    const comment = this.commentRepository.create({
      companyId,
      ticketId,
      content,
      commentType: CommentType.SYSTEM,
    });

    return this.commentRepository.save(comment);
  }
}

