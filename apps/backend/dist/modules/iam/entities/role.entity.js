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
exports.Role = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const role_permission_entity_1 = require("./role-permission.entity");
const user_role_entity_1 = require("./user-role.entity");
let Role = class Role extends tenant_base_entity_1.TenantBaseEntity {
};
exports.Role = Role;
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 100 }),
    __metadata("design:type", String)
], Role.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Role.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', default: 0, name: 'hierarchy_level' }),
    __metadata("design:type", Number)
], Role.prototype, "hierarchyLevel", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true, name: 'parent_role_id' }),
    __metadata("design:type", String)
], Role.prototype, "parentRoleId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Role, (role) => role.childRoles, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'parent_role_id' }),
    __metadata("design:type", Role)
], Role.prototype, "parentRole", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => Role, (role) => role.parentRole),
    __metadata("design:type", Array)
], Role.prototype, "childRoles", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => role_permission_entity_1.RolePermission, (rolePermission) => rolePermission.role, {
        cascade: true,
    }),
    __metadata("design:type", Array)
], Role.prototype, "rolePermissions", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => user_role_entity_1.UserRole, (userRole) => userRole.role, { cascade: true }),
    __metadata("design:type", Array)
], Role.prototype, "userRoles", void 0);
exports.Role = Role = __decorate([
    (0, typeorm_1.Entity)('roles'),
    (0, typeorm_1.Index)(['companyId', 'name'], { unique: true })
], Role);
