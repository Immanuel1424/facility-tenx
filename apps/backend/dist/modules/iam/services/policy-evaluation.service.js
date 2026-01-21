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
exports.PolicyEvaluationService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const acl_entry_entity_1 = require("../entities/acl-entry.entity");
const permission_service_1 = require("./permission.service");
let PolicyEvaluationService = class PolicyEvaluationService {
    constructor(aclRepository, permissionService) {
        this.aclRepository = aclRepository;
        this.permissionService = permissionService;
    }
    async checkPermission(companyId, userId, permission, context) {
        const { resource, action } = permission;
        if (context) {
            const aclDecision = await this.evaluateAcl(companyId, userId, context, permission);
            if (aclDecision !== null) {
                return aclDecision;
            }
        }
        const userPermissions = await this.permissionService.getUserPermissions(companyId, userId);
        const hasPermission = userPermissions.some((p) => p.resource === resource && p.action === action);
        return hasPermission;
    }
    async requirePermission(companyId, userId, permission, context) {
        const hasPermission = await this.checkPermission(companyId, userId, permission, context);
        if (!hasPermission) {
            throw new common_1.ForbiddenException(`Access denied: ${permission.resource}:${permission.action}`);
        }
    }
    async evaluateAcl(companyId, userId, context, permission) {
        const permissionEntity = await this.permissionService.getPermissionByResourceAndAction(permission.resource, permission.action);
        if (!permissionEntity) {
            return null;
        }
        const aclEntries = await this.aclRepository.find({
            where: [
                {
                    companyId,
                    resourceType: context.resourceType,
                    resourceId: context.resourceId || (0, typeorm_2.IsNull)(),
                    userId,
                    permissionId: permissionEntity.id,
                },
                {
                    companyId,
                    resourceType: context.resourceType,
                    resourceId: context.resourceId || (0, typeorm_2.IsNull)(),
                    userId: (0, typeorm_2.IsNull)(),
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
                return entry.effect === acl_entry_entity_1.AclEffect.ALLOW;
            }
        }
        const mostSpecificEntry = aclEntries[0];
        return mostSpecificEntry.effect === acl_entry_entity_1.AclEffect.ALLOW;
    }
    evaluateConditions(conditions, metadata) {
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
    async createAclEntry(companyId, resourceType, effect, options) {
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
    async deleteAclEntry(companyId, aclEntryId) {
        await this.aclRepository.delete({ companyId, id: aclEntryId });
    }
};
exports.PolicyEvaluationService = PolicyEvaluationService;
exports.PolicyEvaluationService = PolicyEvaluationService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(acl_entry_entity_1.AclEntry)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        permission_service_1.PermissionService])
], PolicyEvaluationService);
