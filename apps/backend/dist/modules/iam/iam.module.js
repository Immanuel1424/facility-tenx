"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.IamModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const user_entity_1 = require("./entities/user.entity");
const role_entity_1 = require("./entities/role.entity");
const permission_entity_1 = require("./entities/permission.entity");
const user_role_entity_1 = require("./entities/user-role.entity");
const role_permission_entity_1 = require("./entities/role-permission.entity");
const acl_entry_entity_1 = require("./entities/acl-entry.entity");
const refresh_token_entity_1 = require("./entities/refresh-token.entity");
const user_device_entity_1 = require("./entities/user-device.entity");
const user_service_1 = require("./services/user.service");
const permission_service_1 = require("./services/permission.service");
const role_service_1 = require("./services/role.service");
const policy_evaluation_service_1 = require("./services/policy-evaluation.service");
const refresh_token_service_1 = require("./services/refresh-token.service");
const user_device_service_1 = require("./services/user-device.service");
const permission_guard_1 = require("./guards/permission.guard");
const role_controller_1 = require("./controllers/role.controller");
const permission_controller_1 = require("./controllers/permission.controller");
const super_admin_service_1 = require("../../shared/services/super-admin.service");
const tenant_module_1 = require("../tenant/tenant.module");
let IamModule = class IamModule {
};
exports.IamModule = IamModule;
exports.IamModule = IamModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forFeature([
                user_entity_1.User,
                role_entity_1.Role,
                permission_entity_1.Permission,
                user_role_entity_1.UserRole,
                role_permission_entity_1.RolePermission,
                acl_entry_entity_1.AclEntry,
                refresh_token_entity_1.RefreshToken,
                user_device_entity_1.UserDevice,
            ]),
            (0, common_1.forwardRef)(() => tenant_module_1.TenantModule),
        ],
        controllers: [role_controller_1.RoleController, permission_controller_1.PermissionController],
        providers: [
            user_service_1.UserService,
            permission_service_1.PermissionService,
            role_service_1.RoleService,
            policy_evaluation_service_1.PolicyEvaluationService,
            refresh_token_service_1.RefreshTokenService,
            user_device_service_1.UserDeviceService,
            permission_guard_1.PermissionGuard,
            super_admin_service_1.SuperAdminService,
        ],
        exports: [
            user_service_1.UserService,
            permission_service_1.PermissionService,
            role_service_1.RoleService,
            policy_evaluation_service_1.PolicyEvaluationService,
            refresh_token_service_1.RefreshTokenService,
            user_device_service_1.UserDeviceService,
            permission_guard_1.PermissionGuard,
            super_admin_service_1.SuperAdminService,
        ],
    })
], IamModule);
