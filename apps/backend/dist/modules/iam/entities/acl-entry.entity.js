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
exports.AclEntry = exports.AclEffect = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const user_entity_1 = require("./user.entity");
const permission_entity_1 = require("./permission.entity");
var AclEffect;
(function (AclEffect) {
    AclEffect["ALLOW"] = "allow";
    AclEffect["DENY"] = "deny";
})(AclEffect || (exports.AclEffect = AclEffect = {}));
let AclEntry = class AclEntry extends tenant_base_entity_1.TenantBaseEntity {
};
exports.AclEntry = AclEntry;
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 100, name: 'resource_type' }),
    __metadata("design:type", String)
], AclEntry.prototype, "resourceType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true, name: 'resource_id' }),
    __metadata("design:type", String)
], AclEntry.prototype, "resourceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true, name: 'user_id' }),
    __metadata("design:type", String)
], AclEntry.prototype, "userId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true, name: 'permission_id' }),
    __metadata("design:type", String)
], AclEntry.prototype, "permissionId", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: AclEffect,
        default: AclEffect.ALLOW,
    }),
    __metadata("design:type", String)
], AclEntry.prototype, "effect", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', nullable: true }),
    __metadata("design:type", Object)
], AclEntry.prototype, "conditions", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, (user) => user.aclEntries, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'user_id' }),
    __metadata("design:type", user_entity_1.User)
], AclEntry.prototype, "user", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => permission_entity_1.Permission, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'permission_id' }),
    __metadata("design:type", permission_entity_1.Permission)
], AclEntry.prototype, "permission", void 0);
exports.AclEntry = AclEntry = __decorate([
    (0, typeorm_1.Entity)('acl_entries'),
    (0, typeorm_1.Index)(['companyId', 'resourceType', 'resourceId', 'userId']),
    (0, typeorm_1.Index)(['companyId', 'resourceType', 'resourceId'])
], AclEntry);
