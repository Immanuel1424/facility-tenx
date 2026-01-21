"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PermissionService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const permission_entity_1 = require("../entities/permission.entity");
const role_permission_entity_1 = require("../entities/role-permission.entity");
const user_role_entity_1 = require("../entities/user-role.entity");
const role_entity_1 = require("../entities/role.entity");
let PermissionService = class PermissionService {
    constructor(permissionRepository, rolePermissionRepository, userRoleRepository, roleRepository) {
        this.permissionRepository = permissionRepository;
        this.rolePermissionRepository = rolePermissionRepository;
        this.userRoleRepository = userRoleRepository;
        this.roleRepository = roleRepository;
    }
    async createPermission(resource, action, description, category) {
        const permission = this.permissionRepository.create({
            resource,
            action,
            description,
            category,
        });
        return this.permissionRepository.save(permission);
    }
    async findAll() {
        return this.permissionRepository.find({
            order: { category: 'ASC', resource: 'ASC', action: 'ASC' },
        });
    }
    async getPermissionByResourceAndAction(resource, action) {
        return this.permissionRepository.findOne({
            where: { resource, action },
        });
    }
    async assignPermissionToRole(companyId, roleId, permissionId) {
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
    async getUserPermissions(companyId, userId) {
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
                roleId: (0, typeorm_2.In)(allRoleIds),
            },
            relations: ['permission'],
        });
        const permissions = rolePermissions.map((rp) => ({
            resource: rp.permission.resource,
            action: rp.permission.action,
        }));
        return Array.from(new Map(permissions.map((p) => [`${p.resource}:${p.action}`, p])).values());
    }
    async getRolesWithHierarchy(companyId, roleIds) {
        const roles = await this.roleRepository.find({
            where: { companyId, id: (0, typeorm_2.In)(roleIds) },
            relations: ['parentRole'],
        });
        const allRoles = new Map();
        roles.forEach((r) => allRoles.set(r.id, r));
        const processed = new Set();
        const queue = [...roleIds];
        while (queue.length > 0) {
            const roleId = queue.shift();
            if (processed.has(roleId))
                continue;
            const role = allRoles.get(roleId);
            if (!role)
                continue;
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
                }
                else {
                    queue.push(role.parentRoleId);
                }
            }
        }
        return Array.from(allRoles.values());
    }
    async removePermissionFromRole(companyId, roleId, permissionId) {
        const rolePermission = await this.rolePermissionRepository.findOne({
            where: { companyId, roleId, permissionId },
        });
        if (!rolePermission) {
            throw new common_1.NotFoundException(`Permission ${permissionId} is not assigned to role ${roleId}`);
        }
        await this.rolePermissionRepository.remove(rolePermission);
    }
    async getRolePermissions(companyId, roleId) {
        const rolePermissions = await this.rolePermissionRepository.find({
            where: { companyId, roleId },
            relations: ['permission'],
        });
        return rolePermissions.map((rp) => rp.permission);
    }
    async bulkAssignPermissionsToRole(companyId, roleId, permissionIds) {
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
            }
            else {
                skipped++;
            }
        }
        return { assigned, skipped };
    }
    async bulkRemovePermissionsFromRole(companyId, roleId, permissionIds) {
        let removed = 0;
        let notFound = 0;
        for (const permissionId of permissionIds) {
            const rolePermission = await this.rolePermissionRepository.findOne({
                where: { companyId, roleId, permissionId },
            });
            if (rolePermission) {
                await this.rolePermissionRepository.remove(rolePermission);
                removed++;
            }
            else {
                notFound++;
            }
        }
        return { removed, notFound };
    }
    async getPermissionUsage(companyId, permissionId) {
        const rolePermissions = await this.rolePermissionRepository.find({
            where: { companyId, permissionId },
            relations: ['role'],
        });
        return rolePermissions.map((rp) => rp.role);
    }
};
exports.PermissionService = PermissionService;
exports.PermissionService = PermissionService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(permission_entity_1.Permission)),
    __param(1, (0, typeorm_1.InjectRepository)(role_permission_entity_1.RolePermission)),
    __param(2, (0, typeorm_1.InjectRepository)(user_role_entity_1.UserRole)),
    __param(3, (0, typeorm_1.InjectRepository)(role_entity_1.Role)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], PermissionService);
