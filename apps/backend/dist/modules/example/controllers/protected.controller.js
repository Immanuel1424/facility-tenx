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
exports.ProtectedController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../../auth/guards/jwt-auth.guard");
const permission_guard_1 = require("../../iam/guards/permission.guard");
const require_permission_decorator_1 = require("../../iam/decorators/require-permission.decorator");
const current_user_decorator_1 = require("../../iam/decorators/current-user.decorator");
let ProtectedController = class ProtectedController {
    async listUsers(user) {
        return {
            message: 'Access granted to list users',
            user: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            timestamp: new Date().toISOString(),
        };
    }
    async getUser(id, user) {
        return {
            message: 'Access granted to view user',
            requestedUserId: id,
            currentUser: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            timestamp: new Date().toISOString(),
        };
    }
    async createUser(createDto, user) {
        return {
            message: 'Access granted to create user',
            data: createDto,
            createdBy: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            timestamp: new Date().toISOString(),
        };
    }
    async updateUser(id, updateDto, user) {
        return {
            message: 'Access granted to update user',
            userId: id,
            data: updateDto,
            updatedBy: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            timestamp: new Date().toISOString(),
        };
    }
    async deleteUser(id, user) {
        return {
            message: 'Access granted to delete user',
            userId: id,
            deletedBy: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            timestamp: new Date().toISOString(),
        };
    }
    async getReports(user) {
        return {
            message: 'Access granted to view reports',
            user: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            reports: [],
            timestamp: new Date().toISOString(),
        };
    }
    async createReport(reportDto, user) {
        return {
            message: 'Access granted to create report',
            data: reportDto,
            createdBy: {
                id: user.userId,
                email: user.email,
                companyId: user.companyId,
            },
            timestamp: new Date().toISOString(),
        };
    }
};
exports.ProtectedController = ProtectedController;
__decorate([
    (0, common_1.Get)('users'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'read'),
    (0, swagger_1.ApiOperation)({ summary: 'List users (requires user:read permission)' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "listUsers", null);
__decorate([
    (0, common_1.Get)('users/:id'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'read'),
    (0, swagger_1.ApiOperation)({ summary: 'Get user by ID (requires user:read permission)' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'User ID' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "getUser", null);
__decorate([
    (0, common_1.Post)('users'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'create'),
    (0, swagger_1.ApiOperation)({ summary: 'Create user (requires user:create permission)' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "createUser", null);
__decorate([
    (0, common_1.Put)('users/:id'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'update'),
    (0, swagger_1.ApiOperation)({ summary: 'Update user (requires user:update permission)' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'User ID' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "updateUser", null);
__decorate([
    (0, common_1.Delete)('users/:id'),
    (0, require_permission_decorator_1.RequirePermission)('user', 'delete'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete user (requires user:delete permission)' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: 'User ID' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "deleteUser", null);
__decorate([
    (0, common_1.Get)('reports'),
    (0, require_permission_decorator_1.RequirePermission)('report', 'read'),
    (0, swagger_1.ApiOperation)({ summary: 'Access reports (requires report:read permission)' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "getReports", null);
__decorate([
    (0, common_1.Post)('reports'),
    (0, require_permission_decorator_1.RequirePermission)('report', 'create'),
    (0, swagger_1.ApiOperation)({ summary: 'Create report (requires report:create permission)' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], ProtectedController.prototype, "createReport", null);
exports.ProtectedController = ProtectedController = __decorate([
    (0, swagger_1.ApiTags)('Protected Resources'),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, common_1.Controller)('protected'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, permission_guard_1.PermissionGuard)
], ProtectedController);
