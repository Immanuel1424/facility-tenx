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
exports.UserController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const config_1 = require("@nestjs/config");
const class_transformer_1 = require("class-transformer");
const user_service_1 = require("../iam/services/user.service");
const require_permission_decorator_1 = require("../iam/decorators/require-permission.decorator");
const current_user_decorator_1 = require("../iam/decorators/current-user.decorator");
const tenant_guard_1 = require("../../shared/guards/tenant.guard");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const create_user_dto_1 = require("./dto/create-user.dto");
const update_user_dto_1 = require("./dto/update-user.dto");
const reset_password_dto_1 = require("./dto/reset-password.dto");
const user_response_dto_1 = require("./dto/user-response.dto");
const change_password_dto_1 = require("./dto/change-password.dto");
const query_user_dto_1 = require("./dto/query-user.dto");
const email_service_1 = require("../auth/services/email.service");
const notification_service_1 = require("../notification/notification.service");
const template_seed_service_1 = require("../notification/services/template-seed.service");
const notification_severity_enum_1 = require("../notification/enums/notification-severity.enum");
const user_site_service_1 = require("../tenant/services/user-site.service");
const tenant_service_1 = require("../tenant/tenant.service");
let UserController = class UserController {
    constructor(userService, emailService, notificationService, templateSeedService, userSiteService, tenantService, configService) {
        this.userService = userService;
        this.emailService = emailService;
        this.notificationService = notificationService;
        this.templateSeedService = templateSeedService;
        this.userSiteService = userSiteService;
        this.tenantService = tenantService;
        this.configService = configService;
    }
    async getUsers(currentUser, queryDto, req) {
        const roles = req?.user?.roles ?? [];
        const isSuperAdmin = roles.some((role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN');
        const targetCompanyId = isSuperAdmin
            ? queryDto.companyId
            : currentUser.companyId;
        const users = await this.userService.findAll(targetCompanyId, {
            role: queryDto.role,
            status: queryDto.status,
        });
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, users, {
            excludeExtraneousValues: true,
        });
    }
    async createUser(currentUser, dto, req) {
        const roles = req?.user?.roles ?? [];
        const isSuperAdmin = roles.some((role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN');
        const targetCompanyId = isSuperAdmin && dto.companyId
            ? dto.companyId
            : currentUser.companyId;
        const user = await this.userService.createUserFromDto(targetCompanyId, {
            email: dto.email,
            password: dto.password,
            firstName: dto.firstName,
            lastName: dto.lastName,
            villaNumber: dto.villaNumber,
            villaNumbers: dto.villaNumbers,
            status: dto.status,
            employeeId: dto.employeeId,
            designation: dto.designation,
            joiningDate: dto.joiningDate,
            emergencyContactName: dto.emergencyContactName,
            emergencyContactPhone: dto.emergencyContactPhone,
            notes: dto.notes,
            roleId: dto.roleId,
            departmentId: dto.departmentId,
        });
        let siteIdToAssign = dto.siteId;
        if (!siteIdToAssign) {
            const userRoles = await this.userService.getUserRoles(targetCompanyId, user.id);
            const siteScopedRoles = [
                'TENANT',
                'TECHNICIAN',
                'SUPERVISOR',
                'SITE_COORDINATOR',
            ];
            const hasSiteScopedRole = userRoles.some((r) => siteScopedRoles.includes(r.name.toUpperCase()));
            if (hasSiteScopedRole) {
                const currentUserSiteId = currentUser.siteId;
                if (currentUserSiteId) {
                    siteIdToAssign = currentUserSiteId;
                }
            }
        }
        if (siteIdToAssign) {
            try {
                await this.userSiteService.assignUserToSite(targetCompanyId, user.id, siteIdToAssign);
                console.log(`[UserController] Automatically assigned user ${user.id} to site ${siteIdToAssign}`);
            }
            catch (error) {
                console.error(`[UserController] Failed to assign user to site: ${error instanceof Error ? error.message : error}`);
            }
        }
        if (dto.sendCredentialsViaEmail) {
            await this.templateSeedService.seedEmailTemplates(targetCompanyId);
            let loginUrl = '';
            try {
                const frontendUrl = this.configService.get('FRONTEND_URL');
                if (frontendUrl) {
                    const company = await this.tenantService.getCompanyById(targetCompanyId);
                    const companyCode = company.code;
                    let siteCode = '';
                    if (siteIdToAssign) {
                        try {
                            const site = await this.tenantService.getSiteById(siteIdToAssign);
                            siteCode = site.code;
                        }
                        catch (error) {
                            console.warn(`Site not found for siteId: ${siteIdToAssign}`);
                        }
                    }
                    const url = new URL('/login', frontendUrl);
                    url.searchParams.set('companyId', targetCompanyId);
                    if (siteCode) {
                        url.searchParams.set('siteCode', siteCode);
                    }
                    loginUrl = `\nLogin URL: ${url.toString()}`;
                }
            }
            catch (error) {
                console.error('Failed to generate login URL:', error);
            }
            await this.notificationService.publishEvent({
                type: 'user_created',
                companyId: targetCompanyId,
                recipientUserId: user.id,
                severity: notification_severity_enum_1.NotificationSeverity.INFO,
                templateCode: 'user_created',
                variables: {
                    firstName: user.firstName || 'User',
                    email: user.email,
                    password: dto.password,
                    loginUrl: loginUrl,
                    siteId: siteIdToAssign || null,
                    recipient: {
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName,
                    },
                },
                channels: ['email'],
            });
        }
        const userWithVillas = await this.userService.getUserWithVillas(targetCompanyId, user.id);
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, userWithVillas, {
            excludeExtraneousValues: true,
        });
    }
    async getTechnicians(currentUser, siteId) {
        const technicians = await this.userService.findTechnicians(currentUser.companyId, siteId);
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, technicians, {
            excludeExtraneousValues: true,
        });
    }
    async getCurrentUser(currentUser) {
        const userWithVillas = await this.userService.getUserWithVillas(currentUser.companyId, currentUser.userId);
        console.log('🔍 Raw user data:', {
            firstName: userWithVillas.firstName,
            lastName: userWithVillas.lastName,
            phoneNumber: userWithVillas.phoneNumber,
            alternatePhoneNumber: userWithVillas.alternatePhoneNumber,
            leaseExpiryDate: userWithVillas.leaseExpiryDate,
        });
        const dto = (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, userWithVillas, {
            excludeExtraneousValues: true,
            exposeDefaultValues: true,
        });
        console.log('🔍 Transformed DTO:', {
            firstName: dto.firstName,
            lastName: dto.lastName,
            phoneNumber: dto.phoneNumber,
            alternatePhoneNumber: dto.alternatePhoneNumber,
            leaseExpiryDate: dto.leaseExpiryDate,
        });
        return dto;
    }
    async getUser(currentUser, id, req) {
        const roles = req?.user?.roles ?? [];
        const isSuperAdmin = roles.some((role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN');
        const headerCompanyId = req?.headers?.['x-company-id'];
        console.log('[getUser] Debug info:', {
            userId: id,
            isSuperAdmin,
            headerCompanyId,
            currentUserCompanyId: currentUser.companyId,
            reqCompanyId: req?.companyId,
        });
        const targetCompanyId = isSuperAdmin && headerCompanyId
            ? headerCompanyId
            : currentUser.companyId;
        console.log('[getUser] Using companyId:', targetCompanyId);
        let user = await this.userService.findById(targetCompanyId, id);
        if (!user && isSuperAdmin) {
            console.log('[getUser] User not found in specified company, searching globally for SUPER_ADMIN');
            user = await this.userService.findByIdWithoutCompany(id);
        }
        if (!user) {
            console.log('[getUser] User not found:', { targetCompanyId, userId: id, isSuperAdmin });
            throw new common_1.NotFoundException('User not found');
        }
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, user, {
            excludeExtraneousValues: true,
        });
    }
    async updateUser(currentUser, id, dto) {
        const user = await this.userService.updateUserFromDto(currentUser.companyId, id, {
            email: dto.email,
            firstName: dto.firstName,
            lastName: dto.lastName,
            status: dto.status,
            villaNumber: dto.villaNumber,
            villaNumbers: dto.villaNumbers,
            roleId: dto.roleId,
            departmentId: dto.departmentId,
        });
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, user, {
            excludeExtraneousValues: true,
        });
    }
    async activateUser(currentUser, id) {
        const user = await this.userService.activate(currentUser.companyId, id);
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, user, {
            excludeExtraneousValues: true,
        });
    }
    async deactivateUser(currentUser, id) {
        const user = await this.userService.deactivate(currentUser.companyId, id);
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, user, {
            excludeExtraneousValues: true,
        });
    }
    async resetPassword(currentUser, id, dto) {
        await this.userService.resetPassword(currentUser.companyId, id, dto.newPassword);
        return { message: 'Password reset successfully' };
    }
    async changePassword(currentUser, dto) {
        await this.userService.changePassword(currentUser.companyId, currentUser.userId, dto.currentPassword, dto.newPassword);
        return { message: 'Password changed successfully' };
    }
    async assignRole(currentUser, userId, body) {
        await this.userService.assignRole(currentUser.companyId, userId, body.roleId);
        return { message: 'Role assigned successfully' };
    }
    async removeRole(currentUser, userId, roleId) {
        await this.userService.removeRole(currentUser.companyId, userId, roleId);
        return { message: 'Role removed successfully' };
    }
    async deleteUser(currentUser, id) {
        const user = await this.userService.delete(currentUser.companyId, id);
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, user, {
            excludeExtraneousValues: true,
        });
    }
};
exports.UserController = UserController;
__decorate([
    (0, common_1.Get)(),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'read'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all users in the current company' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'List of users retrieved successfully',
        type: [user_response_dto_1.UserResponseDto],
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, query_user_dto_1.QueryUserDto, Object]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "getUsers", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'create'),
    (0, swagger_1.ApiOperation)({ summary: 'Create a user in the current company' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'User created successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_user_dto_1.CreateUserDto, Object]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "createUser", null);
__decorate([
    (0, common_1.Get)('technicians'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'read'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get list of technicians',
        description: 'Returns a list of active users with technician, maintenance, or staff roles for assignment. Technicians are independent - no filtering by team, site, or department. Returns all technicians for the company.'
    }),
    (0, swagger_1.ApiOkResponse)({
        description: 'List of technicians retrieved successfully',
        type: [user_response_dto_1.UserResponseDto],
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Query)('siteId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "getTechnicians", null);
__decorate([
    (0, common_1.Get)('me'),
    (0, common_1.Version)('1'),
    (0, swagger_1.ApiOperation)({ summary: 'Get current user profile' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Current user profile retrieved successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "getCurrentUser", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'read'),
    (0, swagger_1.ApiOperation)({ summary: 'Get a user by id in the current company' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'User retrieved successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "getUser", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Update a user in the current company' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'User updated successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_user_dto_1.UpdateUserDto]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "updateUser", null);
__decorate([
    (0, common_1.Patch)(':id/activate'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Activate a user' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'User activated successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "activateUser", null);
__decorate([
    (0, common_1.Patch)(':id/deactivate'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Deactivate a user' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'User deactivated successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "deactivateUser", null);
__decorate([
    (0, common_1.Post)(':id/reset-password'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Reset password for a user' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Password reset successfully',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, reset_password_dto_1.ResetPasswordDto]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "resetPassword", null);
__decorate([
    (0, common_1.Post)('me/change-password'),
    (0, common_1.Version)('1'),
    (0, swagger_1.ApiOperation)({ summary: 'Change password for current user' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Password changed successfully',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, change_password_dto_1.ChangePasswordDto]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "changePassword", null);
__decorate([
    (0, common_1.Post)(':id/roles'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Assign a role to a user' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Role assigned successfully',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "assignRole", null);
__decorate([
    (0, common_1.Delete)(':id/roles/:roleId'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Remove a role from a user' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Role removed successfully',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Param)('roleId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "removeRole", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'delete'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete a user (soft delete - marks as deleted)' }),
    (0, swagger_1.ApiOkResponse)({
        description: 'User deleted successfully',
        type: user_response_dto_1.UserResponseDto,
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], UserController.prototype, "deleteUser", null);
exports.UserController = UserController = __decorate([
    (0, swagger_1.ApiTags)('users'),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, tenant_guard_1.TenantGuard),
    (0, common_1.Controller)('users'),
    __metadata("design:paramtypes", [user_service_1.UserService,
        email_service_1.EmailService,
        notification_service_1.NotificationService,
        template_seed_service_1.TemplateSeedService,
        user_site_service_1.UserSiteService,
        tenant_service_1.TenantService,
        config_1.ConfigService])
], UserController);
