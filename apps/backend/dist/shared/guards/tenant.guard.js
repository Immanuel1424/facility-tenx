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
exports.TenantGuard = void 0;
const common_1 = require("@nestjs/common");
const super_admin_service_1 = require("../services/super-admin.service");
let TenantGuard = class TenantGuard {
    constructor(superAdminService) {
        this.superAdminService = superAdminService;
    }
    canActivate(context) {
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (user) {
            const userPayload = {
                sub: user.userId || '',
                email: user.email,
                companyId: user.companyId,
                siteId: user.siteId,
                siteCode: user.siteCode,
                roles: user.roles,
            };
            if (this.superAdminService.isSuperAdmin(userPayload)) {
                if (!request.companyId && user.companyId) {
                    request.companyId = user.companyId;
                }
                if (!request.siteId && user.siteId) {
                    request.siteId = user.siteId;
                }
                return true;
            }
        }
        if (!request.companyId && request.user?.companyId) {
            request.companyId = request.user.companyId;
        }
        if (!request.siteId && request.user?.siteId) {
            request.siteId = request.user.siteId;
        }
        if (!request.companyId) {
            throw new common_1.ForbiddenException('Missing tenant context. Ensure JWT token contains companyId.');
        }
        if (!request.siteId) {
            throw new common_1.ForbiddenException('Missing site context. Ensure JWT token contains siteId.');
        }
        return true;
    }
};
exports.TenantGuard = TenantGuard;
exports.TenantGuard = TenantGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [super_admin_service_1.SuperAdminService])
], TenantGuard);
