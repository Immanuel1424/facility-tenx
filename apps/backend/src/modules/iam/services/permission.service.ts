import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Permission } from '../entities/permission.entity';
import { RolePermission } from '../entities/role-permission.entity';
import { UserRole } from '../entities/user-role.entity';
import { Role } from '../entities/role.entity';

@Injectable()
export class PermissionService {
  constructor(
    @InjectRepository(Permission)
    private readonly permissionRepository: Repository<Permission>,
    @InjectRepository(RolePermission)
    private readonly rolePermissionRepository: Repository<RolePermission>,
    @InjectRepository(UserRole)
    private readonly userRoleRepository: Repository<UserRole>,
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
  ) {}

  /**
   * Create a new permission (global - no company scope)
   */
  async createPermission(
    resource: string,
    action: string,
    description?: string,
    category?: string,
  ): Promise<Permission> {
    const permission = this.permissionRepository.create({
      resource,
      action,
      description,
      category,
    });
    return this.permissionRepository.save(permission);
  }

  /**
   * Find all permissions (global)
   */
  async findAll(): Promise<Permission[]> {
    return this.permissionRepository.find({
      order: { category: 'ASC', resource: 'ASC', action: 'ASC' },
    });
  }

  /**
   * Find permission by resource and action (global)
   */
  async getPermissionByResourceAndAction(
    resource: string,
    action: string,
  ): Promise<Permission | null> {
    return this.permissionRepository.findOne({
      where: { resource, action },
    });
  }

  /**
   * Assign permission to role (tenant-scoped via role_permissions)
   */
  async assignPermissionToRole(
    companyId: string,
    roleId: string,
    permissionId: string,
  ): Promise<RolePermission> {
    const existing = await this.rolePermissionRepository.findOne({
      where: { companyId, roleId, permissionId },
    });

    if (existing) {
      return existing;
    }

    const rolePermission = this.rolePermissionRepository.create({
      companyId,
      roleId,
      permissionId,
    });
    return this.rolePermissionRepository.save(rolePermission);
  }

  /**
   * Get all permissions for a user (via their roles)
   */
  async getUserPermissions(
    companyId: string,
    userId: string,
  ): Promise<Array<{ resource: string; action: string }>> {
    const userRoles = await this.userRoleRepository.find({
      where: { companyId, userId },
      relations: ['role'],
    });

    if (userRoles.length === 0) {
      return [];
    }

    const roleIds = userRoles.map((ur) => ur.roleId);
    const allRoles = await this.getRolesWithHierarchy(companyId, roleIds);

    const allRoleIds = allRoles.map((r) => r.id);

    const rolePermissions = await this.rolePermissionRepository.find({
      where: {
        companyId,
        roleId: In(allRoleIds),
      },
      relations: ['permission'],
    });

    const permissions = rolePermissions.map((rp) => ({
      resource: rp.permission.resource,
      action: rp.permission.action,
    }));

    return Array.from(
      new Map(permissions.map((p) => [`${p.resource}:${p.action}`, p])).values(),
    );
  }

  private async getRolesWithHierarchy(
    companyId: string,
    roleIds: string[],
  ): Promise<Role[]> {
    const roles = await this.roleRepository.find({
      where: { companyId, id: In(roleIds) },
      relations: ['parentRole'],
    });

    const allRoles = new Map<string, Role>();
    roles.forEach((r) => allRoles.set(r.id, r));

    const processed = new Set<string>();
    const queue = [...roleIds];

    while (queue.length > 0) {
      const roleId = queue.shift()!;
      if (processed.has(roleId)) continue;

      const role = allRoles.get(roleId);
      if (!role) continue;

      processed.add(roleId);

      if (role.parentRoleId && !processed.has(role.parentRoleId)) {
        if (!allRoles.has(role.parentRoleId)) {
          const parent = await this.roleRepository.findOne({
            where: { companyId, id: role.parentRoleId },
            relations: ['parentRole'],
          });
          if (parent) {
            allRoles.set(parent.id, parent);
            queue.push(parent.id);
          }
        } else {
          queue.push(role.parentRoleId);
        }
      }
    }

    return Array.from(allRoles.values());
  }

  async removePermissionFromRole(
    companyId: string,
    roleId: string,
    permissionId: string,
  ): Promise<void> {
    const rolePermission = await this.rolePermissionRepository.findOne({
      where: { companyId, roleId, permissionId },
    });

    if (!rolePermission) {
      throw new NotFoundException(
        `Permission ${permissionId} is not assigned to role ${roleId}`,
      );
    }

    await this.rolePermissionRepository.remove(rolePermission);
  }

  async getRolePermissions(
    companyId: string,
    roleId: string,
  ): Promise<Permission[]> {
    const rolePermissions = await this.rolePermissionRepository.find({
      where: { companyId, roleId },
      relations: ['permission'],
    });

    return rolePermissions.map((rp) => rp.permission);
  }

  async bulkAssignPermissionsToRole(
    companyId: string,
    roleId: string,
    permissionIds: string[],
  ): Promise<{ assigned: number; skipped: number }> {
    let assigned = 0;
    let skipped = 0;

    for (const permissionId of permissionIds) {
      const existing = await this.rolePermissionRepository.findOne({
        where: { companyId, roleId, permissionId },
      });

      if (!existing) {
        const rolePermission = this.rolePermissionRepository.create({
          companyId,
          roleId,
          permissionId,
        });
        await this.rolePermissionRepository.save(rolePermission);
        assigned++;
      } else {
        skipped++;
      }
    }

    return { assigned, skipped };
  }

  async bulkRemovePermissionsFromRole(
    companyId: string,
    roleId: string,
    permissionIds: string[],
  ): Promise<{ removed: number; notFound: number }> {
    let removed = 0;
    let notFound = 0;

    for (const permissionId of permissionIds) {
      const rolePermission = await this.rolePermissionRepository.findOne({
        where: { companyId, roleId, permissionId },
      });

      if (rolePermission) {
        await this.rolePermissionRepository.remove(rolePermission);
        removed++;
      } else {
        notFound++;
      }
    }

    return { removed, notFound };
  }

  async getPermissionUsage(
    companyId: string,
    permissionId: string,
  ): Promise<Role[]> {
    const rolePermissions = await this.rolePermissionRepository.find({
      where: { companyId, permissionId },
      relations: ['role'],
    });

    return rolePermissions.map((rp) => rp.role);
  }
}
