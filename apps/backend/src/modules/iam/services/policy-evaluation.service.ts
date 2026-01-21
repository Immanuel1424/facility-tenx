import { Injectable, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { AclEntry, AclEffect } from '../entities/acl-entry.entity';
import { PermissionService } from './permission.service';
import { PermissionCheck } from '../decorators/require-permission.decorator';

export interface ResourceContext {
  resourceType: string;
  resourceId?: string;
  metadata?: Record<string, unknown>;
}

@Injectable()
export class PolicyEvaluationService {
  constructor(
    @InjectRepository(AclEntry)
    private readonly aclRepository: Repository<AclEntry>,
    private readonly permissionService: PermissionService,
  ) {}

  async checkPermission(
    companyId: string,
    userId: string,
    permission: PermissionCheck,
    context?: ResourceContext,
  ): Promise<boolean> {
    const { resource, action } = permission;

    if (context) {
      const aclDecision = await this.evaluateAcl(
        companyId,
        userId,
        context,
        permission,
      );

      if (aclDecision !== null) {
        return aclDecision;
      }
    }

    const userPermissions =
      await this.permissionService.getUserPermissions(companyId, userId);

    const hasPermission = userPermissions.some(
      (p) => p.resource === resource && p.action === action,
    );

    return hasPermission;
  }

  async requirePermission(
    companyId: string,
    userId: string,
    permission: PermissionCheck,
    context?: ResourceContext,
  ): Promise<void> {
    const hasPermission = await this.checkPermission(
      companyId,
      userId,
      permission,
      context,
    );

    if (!hasPermission) {
      throw new ForbiddenException(
        `Access denied: ${permission.resource}:${permission.action}`,
      );
    }
  }

  private async evaluateAcl(
    companyId: string,
    userId: string,
    context: ResourceContext,
    permission: PermissionCheck,
  ): Promise<boolean | null> {
    // Permissions are now global (not tenant-scoped)
    const permissionEntity =
      await this.permissionService.getPermissionByResourceAndAction(
        permission.resource,
        permission.action,
      );

    if (!permissionEntity) {
      return null;
    }

    const aclEntries = await this.aclRepository.find({
      where: [
        {
          companyId,
          resourceType: context.resourceType,
          resourceId: context.resourceId || IsNull(),
          userId,
          permissionId: permissionEntity.id,
        },
        {
          companyId,
          resourceType: context.resourceType,
          resourceId: context.resourceId || IsNull(),
          userId: IsNull(),
          permissionId: permissionEntity.id,
        },
      ],
      relations: ['permission'],
      order: {
        userId: 'DESC',
      },
    });

    if (aclEntries.length === 0) {
      return null;
    }

    for (const entry of aclEntries) {
      if (this.evaluateConditions(entry.conditions, context.metadata)) {
        return entry.effect === AclEffect.ALLOW;
      }
    }

    const mostSpecificEntry = aclEntries[0];
    return mostSpecificEntry.effect === AclEffect.ALLOW;
  }

  private evaluateConditions(
    conditions: Record<string, unknown> | undefined,
    metadata: Record<string, unknown> | undefined,
  ): boolean {
    if (!conditions || !metadata) {
      return true;
    }

    for (const [key, value] of Object.entries(conditions)) {
      if (metadata[key] !== value) {
        return false;
      }
    }

    return true;
  }

  async createAclEntry(
    companyId: string,
    resourceType: string,
    effect: AclEffect,
    options: {
      resourceId?: string;
      userId?: string;
      permissionId?: string;
      conditions?: Record<string, unknown>;
    },
  ): Promise<AclEntry> {
    const aclEntry = this.aclRepository.create({
      companyId,
      resourceType,
      resourceId: options.resourceId,
      userId: options.userId,
      permissionId: options.permissionId,
      effect,
      conditions: options.conditions,
    });

    return this.aclRepository.save(aclEntry);
  }

  async deleteAclEntry(companyId: string, aclEntryId: string): Promise<void> {
    await this.aclRepository.delete({ companyId, id: aclEntryId });
  }
}
