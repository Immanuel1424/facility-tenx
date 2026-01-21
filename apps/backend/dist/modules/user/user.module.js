"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const user_entity_1 = require("../iam/entities/user.entity");
const role_entity_1 = require("../iam/entities/role.entity");
const user_role_entity_1 = require("../iam/entities/user-role.entity");
const iam_module_1 = require("../iam/iam.module");
const auth_module_1 = require("../auth/auth.module");
const notification_module_1 = require("../notification/notification.module");
const tenant_module_1 = require("../tenant/tenant.module");
const user_controller_1 = require("./user.controller");
let UserModule = class UserModule {
};
exports.UserModule = UserModule;
exports.UserModule = UserModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forFeature([user_entity_1.User, role_entity_1.Role, user_role_entity_1.UserRole]),
            iam_module_1.IamModule,
            auth_module_1.AuthModule,
            notification_module_1.NotificationModule,
            (0, common_1.forwardRef)(() => tenant_module_1.TenantModule),
        ],
        controllers: [user_controller_1.UserController],
    })
], UserModule);
