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
exports.HierarchyController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const hierarchy_service_1 = require("./hierarchy.service");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const tenant_guard_1 = require("../../shared/guards/tenant.guard");
const permission_guard_1 = require("../iam/guards/permission.guard");
const require_permission_decorator_1 = require("../iam/decorators/require-permission.decorator");
const current_user_decorator_1 = require("../iam/decorators/current-user.decorator");
const create_hierarchy_node_dto_1 = require("./dto/create-hierarchy-node.dto");
let HierarchyController = class HierarchyController {
    constructor(hierarchyService) {
        this.hierarchyService = hierarchyService;
    }
    async createNode(currentUser, dto) {
        return this.hierarchyService.createNode(currentUser.companyId, dto);
    }
    async getSubtree(currentUser, id) {
        return this.hierarchyService.getSubtree(currentUser.companyId, id);
    }
};
exports.HierarchyController = HierarchyController;
__decorate([
    (0, common_1.Post)('nodes'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('hierarchy', 'write'),
    (0, swagger_1.ApiOperation)({ summary: 'Create a hierarchy node for current company' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_hierarchy_node_dto_1.CreateHierarchyNodeDto]),
    __metadata("design:returntype", Promise)
], HierarchyController.prototype, "createNode", null);
__decorate([
    (0, common_1.Get)('nodes/:id/children'),
    (0, common_1.Version)('1'),
    (0, require_permission_decorator_1.RequirePermission)('hierarchy', 'read'),
    (0, swagger_1.ApiOperation)({ summary: 'Get children of a hierarchy node' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], HierarchyController.prototype, "getSubtree", null);
exports.HierarchyController = HierarchyController = __decorate([
    (0, swagger_1.ApiTags)('hierarchy'),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, tenant_guard_1.TenantGuard, permission_guard_1.PermissionGuard),
    (0, common_1.Controller)('hierarchy'),
    __metadata("design:paramtypes", [hierarchy_service_1.HierarchyService])
], HierarchyController);
