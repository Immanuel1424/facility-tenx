import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { AuditLog, AuditAction, AuditResourceType } from './entities/audit-log.entity';
import { QueryAuditLogDto } from './dto/query-audit-log.dto';

export interface AuditLogParams {
  companyId: string;
  userId?: string;
  userEmail?: string;
  action: AuditAction;
  resourceType: AuditResourceType;
  resourceId?: string;
  resourceName?: string;
  description?: string;
  oldValues?: Record<string, unknown>;
  newValues?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
  requestPath?: string;
  requestMethod?: string;
  responseStatus?: number;
  durationMs?: number;
  isSuccess?: boolean;
  errorMessage?: string;
  metadata?: Record<string, unknown>;
}

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(
    @InjectRepository(AuditLog)
    private readonly auditRepository: Repository<AuditLog>,
  ) {}

  async log(params: AuditLogParams): Promise<AuditLog> {
    const changedFields = this.calculateChangedFields(
      params.oldValues,
      params.newValues,
    );

    const auditLog = this.auditRepository.create({
      companyId: params.companyId,
      userId: params.userId,
      userEmail: params.userEmail,
      action: params.action,
      resourceType: params.resourceType,
      resourceId: params.resourceId,
      resourceName: params.resourceName,
      description: params.description,
      oldValues: params.oldValues,
      newValues: params.newValues,
      changedFields,
      ipAddress: params.ipAddress,
      userAgent: params.userAgent,
      requestPath: params.requestPath,
      requestMethod: params.requestMethod,
      responseStatus: params.responseStatus,
      durationMs: params.durationMs,
      isSuccess: params.isSuccess ?? true,
      errorMessage: params.errorMessage,
      metadata: params.metadata,
    });

    try {
      return await this.auditRepository.save(auditLog);
    } catch (error) {
      this.logger.error('Failed to save audit log', error);
      throw error;
    }
  }

  async logTicketAction(
    companyId: string,
    userId: string,
    userEmail: string,
    action: AuditAction,
    ticketId: string,
    ticketNumber: string,
    description: string,
    oldValues?: Record<string, unknown>,
    newValues?: Record<string, unknown>,
    metadata?: Record<string, unknown>,
  ): Promise<AuditLog> {
    return this.log({
      companyId,
      userId,
      userEmail,
      action,
      resourceType: AuditResourceType.TICKET,
      resourceId: ticketId,
      resourceName: ticketNumber,
      description,
      oldValues,
      newValues,
      isSuccess: true,
      metadata,
    });
  }

  async logUserAction(
    companyId: string,
    userId: string,
    userEmail: string,
    action: AuditAction,
    targetUserId: string,
    targetUserEmail: string,
    description: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<AuditLog> {
    return this.log({
      companyId,
      userId,
      userEmail,
      action,
      resourceType: AuditResourceType.USER,
      resourceId: targetUserId,
      resourceName: targetUserEmail,
      description,
      ipAddress,
      userAgent,
      isSuccess: true,
    });
  }

  async logAuthAction(
    companyId: string,
    userId: string | undefined,
    userEmail: string,
    action: AuditAction,
    isSuccess: boolean,
    ipAddress?: string,
    userAgent?: string,
    errorMessage?: string,
  ): Promise<AuditLog> {
    return this.log({
      companyId,
      userId,
      userEmail,
      action,
      resourceType: AuditResourceType.SESSION,
      description: `${action} attempt for ${userEmail}`,
      ipAddress,
      userAgent,
      isSuccess,
      errorMessage,
    });
  }

  async findAll(
    companyId: string,
    queryDto: QueryAuditLogDto,
  ): Promise<{ logs: AuditLog[]; total: number }> {
    const queryBuilder = this.auditRepository
      .createQueryBuilder('audit')
      .where('audit.companyId = :companyId', { companyId });

    if (queryDto.user_id) {
      queryBuilder.andWhere('audit.userId = :userId', {
        userId: queryDto.user_id,
      });
    }

    if (queryDto.action) {
      queryBuilder.andWhere('audit.action = :action', {
        action: queryDto.action,
      });
    }

    if (queryDto.resource_type) {
      queryBuilder.andWhere('audit.resourceType = :resourceType', {
        resourceType: queryDto.resource_type,
      });
    }

    if (queryDto.resource_id) {
      queryBuilder.andWhere('audit.resourceId = :resourceId', {
        resourceId: queryDto.resource_id,
      });
    }

    if (queryDto.search) {
      queryBuilder.andWhere(
        '(audit.description ILIKE :search OR audit.userEmail ILIKE :search OR audit.resourceName ILIKE :search)',
        { search: `%${queryDto.search}%` },
      );
    }

    if (queryDto.start_date && queryDto.end_date) {
      queryBuilder.andWhere('audit.createdAt BETWEEN :startDate AND :endDate', {
        startDate: new Date(queryDto.start_date),
        endDate: new Date(queryDto.end_date),
      });
    } else if (queryDto.start_date) {
      queryBuilder.andWhere('audit.createdAt >= :startDate', {
        startDate: new Date(queryDto.start_date),
      });
    } else if (queryDto.end_date) {
      queryBuilder.andWhere('audit.createdAt <= :endDate', {
        endDate: new Date(queryDto.end_date),
      });
    }

    const total = await queryBuilder.getCount();

    const page = queryDto.page || 1;
    const limit = queryDto.limit || 20;

    const logs = await queryBuilder
      .orderBy('audit.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return { logs, total };
  }

  async findByResourceId(
    companyId: string,
    resourceType: AuditResourceType,
    resourceId: string,
  ): Promise<AuditLog[]> {
    return this.auditRepository.find({
      where: { companyId, resourceType, resourceId },
      order: { createdAt: 'DESC' },
    });
  }

  async findByUserId(
    companyId: string,
    userId: string,
    limit = 50,
  ): Promise<AuditLog[]> {
    return this.auditRepository.find({
      where: { companyId, userId },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async getAuditSummary(
    companyId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<{
    total_actions: number;
    by_action: Record<string, number>;
    by_resource: Record<string, number>;
    by_user: Array<{ user_id: string; user_email: string; count: number }>;
  }> {
    const logs = await this.auditRepository.find({
      where: {
        companyId,
        createdAt: Between(startDate, endDate),
      },
    });

    const byAction: Record<string, number> = {};
    const byResource: Record<string, number> = {};
    const byUser: Map<string, { email: string; count: number }> = new Map();

    for (const log of logs) {
      // Count by action
      byAction[log.action] = (byAction[log.action] || 0) + 1;

      // Count by resource type
      byResource[log.resourceType] = (byResource[log.resourceType] || 0) + 1;

      // Count by user
      if (log.userId) {
        const userEntry = byUser.get(log.userId) || {
          email: log.userEmail || 'unknown',
          count: 0,
        };
        userEntry.count++;
        byUser.set(log.userId, userEntry);
      }
    }

    const byUserArray = Array.from(byUser.entries()).map(([userId, data]) => ({
      user_id: userId,
      user_email: data.email,
      count: data.count,
    }));

    byUserArray.sort((a, b) => b.count - a.count);

    return {
      total_actions: logs.length,
      by_action: byAction,
      by_resource: byResource,
      by_user: byUserArray.slice(0, 10),
    };
  }

  async getRecentActivity(
    companyId: string,
    limit = 10,
  ): Promise<AuditLog[]> {
    return this.auditRepository.find({
      where: { companyId },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async deleteOldLogs(companyId: string, retentionDays = 365): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

    const result = await this.auditRepository
      .createQueryBuilder()
      .delete()
      .where('companyId = :companyId', { companyId })
      .andWhere('createdAt < :cutoffDate', { cutoffDate })
      .execute();

    return result.affected || 0;
  }

  private calculateChangedFields(
    oldValues?: Record<string, unknown>,
    newValues?: Record<string, unknown>,
  ): string[] | undefined {
    if (!oldValues || !newValues) {
      return undefined;
    }

    const changedFields: string[] = [];
    const allKeys = new Set([...Object.keys(oldValues), ...Object.keys(newValues)]);

    for (const key of allKeys) {
      if (JSON.stringify(oldValues[key]) !== JSON.stringify(newValues[key])) {
        changedFields.push(key);
      }
    }

    return changedFields.length > 0 ? changedFields : undefined;
  }
}

