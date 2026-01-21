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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PermissionGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const policy_evaluation_service_1 = require("../services/policy-evaluation.service");
const require_permission_decorator_1 = require("../decorators/require-permission.decorator");
const user_site_service_1 = require("../../tenant/services/user-site.service");
let PermissionGuard = class PermissionGuard {
    constructor(reflector, policyService, userSiteService) {
        this.reflector = reflector;
        this.policyService = policyService;
        this.userSiteService = userSiteService;
    }
    async canActivate(context) {
        const permission = this.reflector.getAllAndOverride(require_permission_decorator_1.PERMISSION_KEY, [context.getHandler(), context.getClass()]);
        if (!permission) {
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user) {
            return false;
        }
        const roles = (user.roles ?? []).map((role) => role.toUpperCase().trim());
        if (roles.includes('SUPER_ADMIN')) {
            return true;
        }
        if (roles.includes('ADMIN')) {
            const siteId = request.siteId || user.siteId;
            if (!siteId) {
                return true;
            }
            const isAssigned = await this.userSiteService.isUserAssignedToSite(user.companyId, user.userId, siteId);
            if (!isAssigned) {
                throw new common_1.ForbiddenException(`Admin access denied: User is not assigned to site ${siteId}`);
            }
            return true;
        }
        const resourceContext = request.resourceContext;
        await this.policyService.requirePermission(user.companyId, user.userId, permission, resourceContext);
        return true;
    }
};
exports.PermissionGuard = PermissionGuard;
exports.PermissionGuard = PermissionGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [core_1.Reflector,
        policy_evaluation_service_1.PolicyEvaluationService,
        user_site_service_1.UserSiteService])
], PermissionGuard);
