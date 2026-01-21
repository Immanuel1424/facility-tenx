import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, LessThan, MoreThan, IsNull } from 'typeorm';
import { Announcement } from '../entities/announcement.entity';
import { AnnouncementRead } from '../entities/announcement-read.entity';
import { CreateAnnouncementDto } from '../dto/create-announcement.dto';
import { UpdateAnnouncementDto } from '../dto/update-announcement.dto';
import { AnnouncementQueryDto } from '../dto/announcement-query.dto';
import { AnnouncementTargetAudience } from '../enums/announcement-target-audience.enum';
import { User } from '../../iam/entities/user.entity';
import { UserRole } from '../../iam/entities/user-role.entity';
import { Role } from '../../iam/entities/role.entity';
import { NotificationService } from '../../notification/notification.service';
import { NotificationSeverity } from '../../notification/enums/notification-severity.enum';
import { NotificationChannel } from '../../notification/enums/notification-channel.enum';
import { NotificationTemplate } from '../../notification/entities/notification-template.entity';
import { UserStatus } from '../../iam/entities/user.entity';

@Injectable()
export class AnnouncementService {
  private readonly logger = new Logger(AnnouncementService.name);

  constructor(
    @InjectRepository(Announcement)
    private readonly announcementRepository: Repository<Announcement>,
    @InjectRepository(AnnouncementRead)
    private readonly announcementReadRepository: Repository<AnnouncementRead>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(UserRole)
    private readonly userRoleRepository: Repository<UserRole>,
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
    @InjectRepository(NotificationTemplate)
    private readonly notificationTemplateRepository: Repository<NotificationTemplate>,
    private readonly notificationService: NotificationService,
  ) {}

  async create(
    companyId: string,
    userId: string,
    createDto: CreateAnnouncementDto,
  ): Promise<Announcement> {
    // Validate target roles if target audience is roles
    if (
      createDto.targetAudience === AnnouncementTargetAudience.ROLES &&
      (!createDto.targetRoles || createDto.targetRoles.length === 0)
    ) {
      throw new BadRequestException(
        'targetRoles is required when targetAudience is "roles"',
      );
    }

    // Validate scheduled_at is in the future
    if (createDto.scheduledAt) {
      const scheduledDate = new Date(createDto.scheduledAt);
      if (scheduledDate <= new Date()) {
        throw new BadRequestException(
          'scheduledAt must be in the future',
        );
      }
    }

    // Validate expires_at is after scheduled_at if both are provided
    if (createDto.scheduledAt && createDto.expiresAt) {
      const scheduledDate = new Date(createDto.scheduledAt);
      const expiresDate = new Date(createDto.expiresAt);
      if (expiresDate <= scheduledDate) {
        throw new BadRequestException(
          'expiresAt must be after scheduledAt',
        );
      }
    }

    const announcement = this.announcementRepository.create({
      companyId,
      createdByUserId: userId,
      title: createDto.title,
      message: createDto.message,
      category: createDto.category,
      priority: createDto.priority,
      targetAudience: createDto.targetAudience,
      targetRoles:
        createDto.targetAudience === AnnouncementTargetAudience.ROLES
          ? createDto.targetRoles
          : null,
      scheduledAt: createDto.scheduledAt
        ? new Date(createDto.scheduledAt)
        : null,
      expiresAt: createDto.expiresAt ? new Date(createDto.expiresAt) : null,
      isPublished: createDto.publishImmediately ?? false,
      publishedAt: createDto.publishImmediately ? new Date() : null,
    });

    const savedAnnouncement = await this.announcementRepository.save(
      announcement,
    );

    // If publish immediately, send notifications
    if (createDto.publishImmediately) {
      await this.sendNotifications(companyId, savedAnnouncement);
    }

    return savedAnnouncement;
  }

  async update(
    companyId: string,
    announcementId: string,
    updateDto: UpdateAnnouncementDto,
  ): Promise<Announcement> {
    const announcement = await this.announcementRepository.findOne({
      where: { id: announcementId, companyId, deletedAt: IsNull() },
    });

    if (!announcement) {
      throw new NotFoundException('Announcement not found');
    }

    // Cannot update published announcements
    if (announcement.isPublished) {
      throw new BadRequestException(
        'Cannot update a published announcement',
      );
    }

    // Validate target roles if target audience is roles
    if (
      updateDto.targetAudience === AnnouncementTargetAudience.ROLES &&
      (!updateDto.targetRoles || updateDto.targetRoles.length === 0)
    ) {
      throw new BadRequestException(
        'targetRoles is required when targetAudience is "roles"',
      );
    }

    // Update fields
    if (updateDto.title !== undefined) {
      announcement.title = updateDto.title;
    }
    if (updateDto.message !== undefined) {
      announcement.message = updateDto.message;
    }
    if (updateDto.category !== undefined) {
      announcement.category = updateDto.category;
    }
    if (updateDto.priority !== undefined) {
      announcement.priority = updateDto.priority;
    }
    if (updateDto.targetAudience !== undefined) {
      announcement.targetAudience = updateDto.targetAudience;
    }
    if (updateDto.targetRoles !== undefined) {
      announcement.targetRoles =
        updateDto.targetAudience === AnnouncementTargetAudience.ROLES
          ? updateDto.targetRoles
          : null;
    }
    if (updateDto.scheduledAt !== undefined) {
      announcement.scheduledAt = updateDto.scheduledAt
        ? new Date(updateDto.scheduledAt)
        : null;
    }
    if (updateDto.expiresAt !== undefined) {
      announcement.expiresAt = updateDto.expiresAt
        ? new Date(updateDto.expiresAt)
        : null;
    }

    return this.announcementRepository.save(announcement);
  }

  async publish(
    companyId: string,
    announcementId: string,
  ): Promise<Announcement> {
    const announcement = await this.announcementRepository.findOne({
      where: { id: announcementId, companyId, deletedAt: IsNull() },
    });

    if (!announcement) {
      throw new NotFoundException('Announcement not found');
    }

    if (announcement.isPublished) {
      throw new BadRequestException('Announcement is already published');
    }

    // Check if scheduled time has arrived
    if (announcement.scheduledAt && announcement.scheduledAt > new Date()) {
      throw new BadRequestException(
        'Cannot publish before scheduled time',
      );
    }

    announcement.isPublished = true;
    announcement.publishedAt = new Date();

    const savedAnnouncement = await this.announcementRepository.save(
      announcement,
    );

    // Send notifications
    await this.sendNotifications(companyId, savedAnnouncement);

    return savedAnnouncement;
  }

  async findAll(
    companyId: string,
    userId: string,
    queryDto: AnnouncementQueryDto,
  ): Promise<{ data: Announcement[]; total: number }> {
    // Get user roles
    const userRoles = await this.getUserRoles(companyId, userId);

    // Build query
    const queryBuilder = this.announcementRepository
      .createQueryBuilder('announcement')
      .where('announcement.companyId = :companyId', { companyId })
      .andWhere('announcement.deletedAt IS NULL')
      .andWhere('announcement.isPublished = :isPublished', {
        isPublished: true,
      })
      .andWhere(
        '(announcement.expiresAt IS NULL OR announcement.expiresAt > :now)',
        { now: new Date() },
      );

    // Filter by target audience
    if (userRoles.length > 0) {
      // For role-based announcements, check if any user role exists in targetRoles JSONB array
      // Use PostgreSQL's ? operator to check if a string exists as a top-level key or array element in JSONB
      // For JSONB arrays, we need to check each role individually
      const roleConditions = userRoles
        .map((_, index) => `announcement.targetRoles ? :role${index}`)
        .join(' OR ');
      
      const roleParams: Record<string, string> = {};
      userRoles.forEach((role, index) => {
        roleParams[`role${index}`] = role;
      });

      queryBuilder.andWhere(
        `(announcement.targetAudience = :all OR (announcement.targetAudience = :roles AND (${roleConditions})))`,
        {
          all: AnnouncementTargetAudience.ALL,
          roles: AnnouncementTargetAudience.ROLES,
          ...roleParams,
        },
      );
    } else {
      // If user has no roles, only show announcements for ALL audience
      queryBuilder.andWhere('announcement.targetAudience = :all', {
        all: AnnouncementTargetAudience.ALL,
      });
    }

    // Apply filters
    if (queryDto.category) {
      queryBuilder.andWhere('announcement.category = :category', {
        category: queryDto.category,
      });
    }

    if (queryDto.priority) {
      queryBuilder.andWhere('announcement.priority = :priority', {
        priority: queryDto.priority,
      });
    }

    if (queryDto.search) {
      queryBuilder.andWhere(
        '(announcement.title ILIKE :search OR announcement.message ILIKE :search)',
        { search: `%${queryDto.search}%` },
      );
    }

    // Apply sorting
    const sortBy = queryDto.sortBy || 'createdAt';
    const sortOrder = queryDto.sortOrder || 'DESC';
    queryBuilder.orderBy(`announcement.${sortBy}`, sortOrder);

    // Apply pagination
    const page = queryDto.page || 1;
    const limit = queryDto.limit || 20;
    const skip = (page - 1) * limit;

    queryBuilder.skip(skip).take(limit);

    const [data, total] = await queryBuilder.getManyAndCount();

    return { data, total };
  }

  async findOne(
    companyId: string,
    announcementId: string,
    userId: string,
  ): Promise<Announcement> {
    // Get user roles
    const userRoles = await this.getUserRoles(companyId, userId);

    const announcement = await this.announcementRepository.findOne({
      where: {
        id: announcementId,
        companyId,
        deletedAt: IsNull(),
        isPublished: true,
      },
    });

    if (!announcement) {
      throw new NotFoundException('Announcement not found');
    }

    // Check if expired
    if (announcement.expiresAt && announcement.expiresAt <= new Date()) {
      throw new NotFoundException('Announcement has expired');
    }

    // Check if user has access
    if (
      announcement.targetAudience === AnnouncementTargetAudience.ROLES &&
      (!announcement.targetRoles ||
        !announcement.targetRoles.some((role) => userRoles.includes(role)))
    ) {
      throw new NotFoundException('Announcement not found');
    }

    return announcement;
  }

  async markAsRead(
    companyId: string,
    announcementId: string,
    userId: string,
  ): Promise<AnnouncementRead> {
    // Verify announcement exists and user has access
    await this.findOne(companyId, announcementId, userId);

    // Check if already read
    const existingRead = await this.announcementReadRepository.findOne({
      where: { companyId, announcementId, userId },
    });

    if (existingRead) {
      return existingRead;
    }

    // Create read record
    const read = this.announcementReadRepository.create({
      companyId,
      announcementId,
      userId,
      readAt: new Date(),
    });

    return this.announcementReadRepository.save(read);
  }

  async getUnreadCount(
    companyId: string,
    userId: string,
  ): Promise<number> {
    // Get user roles
    const userRoles = await this.getUserRoles(companyId, userId);

    // Get all accessible published announcements
    const queryBuilder = this.announcementRepository
      .createQueryBuilder('announcement')
      .where('announcement.companyId = :companyId', { companyId })
      .andWhere('announcement.deletedAt IS NULL')
      .andWhere('announcement.isPublished = :isPublished', {
        isPublished: true,
      })
      .andWhere(
        '(announcement.expiresAt IS NULL OR announcement.expiresAt > :now)',
        { now: new Date() },
      );

    // Filter by target audience - fix JSONB array query
    // Use @> operator to check if JSONB array contains any of the user roles
    if (userRoles.length > 0) {
      const roleConditions = userRoles
        .map((_, index) => `announcement.targetRoles @> :roleArray${index}::jsonb`)
        .join(' OR ');
      
      const roleParams: Record<string, string> = {};
      userRoles.forEach((role, index) => {
        roleParams[`roleArray${index}`] = JSON.stringify([role]);
      });

      queryBuilder.andWhere(
        `(announcement.targetAudience = :all OR (announcement.targetAudience = :roles AND (${roleConditions})))`,
        {
          all: AnnouncementTargetAudience.ALL,
          roles: AnnouncementTargetAudience.ROLES,
          ...roleParams,
        },
      );
    } else {
      queryBuilder.andWhere('announcement.targetAudience = :all', {
        all: AnnouncementTargetAudience.ALL,
      });
    }

    const accessibleAnnouncements = await queryBuilder.getMany();
    const announcementIds = accessibleAnnouncements.map((a) => a.id);

    if (announcementIds.length === 0) {
      return 0;
    }

    // Get read announcements
    const readAnnouncements = await this.announcementReadRepository.find({
      where: {
        companyId,
        userId,
        announcementId: In(announcementIds),
      },
    });

    const readIds = readAnnouncements.map((r) => r.announcementId);

    // Count unread
    return announcementIds.filter((id) => !readIds.includes(id)).length;
  }

  async getUnreadList(
    companyId: string,
    userId: string,
    queryDto: AnnouncementQueryDto,
  ): Promise<{ data: Announcement[]; total: number }> {
    // Get user roles
    const userRoles = await this.getUserRoles(companyId, userId);

    // Get all accessible published announcements
    const queryBuilder = this.announcementRepository
      .createQueryBuilder('announcement')
      .where('announcement.companyId = :companyId', { companyId })
      .andWhere('announcement.deletedAt IS NULL')
      .andWhere('announcement.isPublished = :isPublished', {
        isPublished: true,
      })
      .andWhere(
        '(announcement.expiresAt IS NULL OR announcement.expiresAt > :now)',
        { now: new Date() },
      );

    // Filter by target audience - fix JSONB array query
    // Use @> operator to check if JSONB array contains any of the user roles
    if (userRoles.length > 0) {
      const roleConditions = userRoles
        .map((_, index) => `announcement.targetRoles @> :roleArray${index}::jsonb`)
        .join(' OR ');
      
      const roleParams: Record<string, string> = {};
      userRoles.forEach((role, index) => {
        roleParams[`roleArray${index}`] = JSON.stringify([role]);
      });

      queryBuilder.andWhere(
        `(announcement.targetAudience = :all OR (announcement.targetAudience = :roles AND (${roleConditions})))`,
        {
          all: AnnouncementTargetAudience.ALL,
          roles: AnnouncementTargetAudience.ROLES,
          ...roleParams,
        },
      );
    } else {
      queryBuilder.andWhere('announcement.targetAudience = :all', {
        all: AnnouncementTargetAudience.ALL,
      });
    }

    // Apply filters
    if (queryDto.category) {
      queryBuilder.andWhere('announcement.category = :category', {
        category: queryDto.category,
      });
    }

    if (queryDto.priority) {
      queryBuilder.andWhere('announcement.priority = :priority', {
        priority: queryDto.priority,
      });
    }

    if (queryDto.search) {
      queryBuilder.andWhere(
        '(announcement.title ILIKE :search OR announcement.message ILIKE :search)',
        { search: `%${queryDto.search}%` },
      );
    }

    // Apply sorting
    const sortBy = queryDto.sortBy || 'createdAt';
    const sortOrder = queryDto.sortOrder || 'DESC';
    queryBuilder.orderBy(`announcement.${sortBy}`, sortOrder);

    const accessibleAnnouncements = await queryBuilder.getMany();
    const announcementIds = accessibleAnnouncements.map((a) => a.id);

    if (announcementIds.length === 0) {
      return { data: [], total: 0 };
    }

    // Get read announcements
    const readAnnouncements = await this.announcementReadRepository.find({
      where: {
        companyId,
        userId,
        announcementId: In(announcementIds),
      },
    });

    const readIds = new Set(readAnnouncements.map((r) => r.announcementId));

    // Filter unread
    const unreadAnnouncements = accessibleAnnouncements.filter(
      (a) => !readIds.has(a.id),
    );

    // Apply pagination
    const page = queryDto.page || 1;
    const limit = queryDto.limit || 20;
    const skip = (page - 1) * limit;

    const paginatedData = unreadAnnouncements.slice(skip, skip + limit);

    return { data: paginatedData, total: unreadAnnouncements.length };
  }

  async delete(companyId: string, announcementId: string): Promise<void> {
    const announcement = await this.announcementRepository.findOne({
      where: { id: announcementId, companyId, deletedAt: IsNull() },
    });

    if (!announcement) {
      throw new NotFoundException('Announcement not found');
    }

    // Soft delete
    announcement.deletedAt = new Date();
    await this.announcementRepository.save(announcement);
  }

  async findAllForAdmin(
    companyId: string,
    queryDto: AnnouncementQueryDto,
  ): Promise<{ data: Announcement[]; total: number }> {
    const queryBuilder = this.announcementRepository
      .createQueryBuilder('announcement')
      .where('announcement.companyId = :companyId', { companyId })
      .andWhere('announcement.deletedAt IS NULL');

    // Apply filters
    if (queryDto.category) {
      queryBuilder.andWhere('announcement.category = :category', {
        category: queryDto.category,
      });
    }

    if (queryDto.priority) {
      queryBuilder.andWhere('announcement.priority = :priority', {
        priority: queryDto.priority,
      });
    }

    if (queryDto.search) {
      queryBuilder.andWhere(
        '(announcement.title ILIKE :search OR announcement.message ILIKE :search)',
        { search: `%${queryDto.search}%` },
      );
    }

    // Apply sorting
    const sortBy = queryDto.sortBy || 'createdAt';
    const sortOrder = queryDto.sortOrder || 'DESC';
    queryBuilder.orderBy(`announcement.${sortBy}`, sortOrder);

    // Apply pagination
    const page = queryDto.page || 1;
    const limit = queryDto.limit || 20;
    const skip = (page - 1) * limit;

    queryBuilder.skip(skip).take(limit);

    const [data, total] = await queryBuilder.getManyAndCount();

    return { data, total };
  }

  private async getUserRoles(
    companyId: string,
    userId: string,
  ): Promise<string[]> {
    const userRoles = await this.userRoleRepository.find({
      where: { companyId, userId },
      relations: ['role'],
    });

    return userRoles.map((ur) => ur.role.name);
  }

  private async getRecipientUserIds(
    companyId: string,
    announcement: Announcement,
  ): Promise<string[]> {
    if (announcement.targetAudience === AnnouncementTargetAudience.ALL) {
      // Get all active users in the company
      const users = await this.userRepository.find({
        where: {
          companyId,
          status: UserStatus.ACTIVE,
        },
        select: ['id'],
      });

      return users.map((u) => u.id);
    } else {
      // Get users with specific roles
      if (!announcement.targetRoles || announcement.targetRoles.length === 0) {
        return [];
      }

      // Find role IDs
      const roles = await this.roleRepository.find({
        where: {
          companyId,
          name: In(announcement.targetRoles),
        },
        select: ['id'],
      });

      if (roles.length === 0) {
        return [];
      }

      const roleIds = roles.map((r) => r.id);

      // Find user roles
      const userRoles = await this.userRoleRepository.find({
        where: {
          companyId,
          roleId: In(roleIds),
        },
        relations: ['user'],
      });

      // Filter active users
      const activeUserIds = userRoles
        .filter((ur) => ur.user.status === UserStatus.ACTIVE)
        .map((ur) => ur.userId);

      // Remove duplicates
      return [...new Set(activeUserIds)];
    }
  }

  private async sendNotifications(
    companyId: string,
    announcement: Announcement,
  ): Promise<void> {
    try {
      // Ensure notification templates exist before sending
      await this.ensureAnnouncementTemplates(companyId);

      const recipientUserIds = await this.getRecipientUserIds(
        companyId,
        announcement,
      );

      // Determine severity based on priority
      let severity: NotificationSeverity = NotificationSeverity.INFO;
      if (announcement.priority === 'urgent') {
        severity = NotificationSeverity.CRITICAL;
      } else if (announcement.priority === 'high') {
        severity = NotificationSeverity.WARNING;
      }

      // Send notification to each recipient
      for (const userId of recipientUserIds) {
        await this.notificationService.publishEvent({
          type: 'announcement',
          companyId,
          recipientUserId: userId,
          severity,
          templateCode: 'announcement',
          variables: {
            title: announcement.title,
            message: announcement.message,
            category: announcement.category,
            priority: announcement.priority,
            announcementId: announcement.id,
          },
          channels: [NotificationChannel.PUSH, NotificationChannel.IN_APP],
        });
      }

      this.logger.log(
        `Sent ${recipientUserIds.length} notifications for announcement ${announcement.id}`,
      );
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Failed to send notifications for announcement ${announcement.id}: ${errorMessage}`,
      );
      // Don't throw - notification failure shouldn't break announcement creation
    }
  }

  /**
   * Ensure notification templates exist for announcement notifications
   */
  private async ensureAnnouncementTemplates(companyId: string): Promise<void> {
    const templateCode = 'announcement';

    // Check if push template exists
    let pushTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
      },
    });

    if (!pushTemplate) {
      pushTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.PUSH,
        subject: 'New Announcement',
        body: '{{message}}',
        defaultVariables: {
          message: 'A new announcement has been posted',
        },
      });
      await this.notificationTemplateRepository.save(pushTemplate);
      this.logger.log(`Created push notification template: ${templateCode}`);
    }

    // Check if in-app template exists
    let inAppTemplate = await this.notificationTemplateRepository.findOne({
      where: {
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
      },
    });

    if (!inAppTemplate) {
      inAppTemplate = this.notificationTemplateRepository.create({
        companyId,
        code: templateCode,
        channel: NotificationChannel.IN_APP,
        subject: null,
        body: '{{message}}',
        defaultVariables: {
          message: 'A new announcement has been posted',
        },
      });
      await this.notificationTemplateRepository.save(inAppTemplate);
      this.logger.log(`Created in-app notification template: ${templateCode}`);
    }
  }
}

