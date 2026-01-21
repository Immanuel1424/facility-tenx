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
exports.NotificationTemplate = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const notification_channel_enum_1 = require("../enums/notification-channel.enum");
let NotificationTemplate = class NotificationTemplate extends tenant_base_entity_1.TenantBaseEntity {
};
exports.NotificationTemplate = NotificationTemplate;
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 128 }),
    __metadata("design:type", String)
], NotificationTemplate.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: notification_channel_enum_1.NotificationChannel }),
    __metadata("design:type", String)
], NotificationTemplate.prototype, "channel", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 255, nullable: true }),
    __metadata("design:type", Object)
], NotificationTemplate.prototype, "subject", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text' }),
    __metadata("design:type", String)
], NotificationTemplate.prototype, "body", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', name: 'default_variables', nullable: true }),
    __metadata("design:type", Object)
], NotificationTemplate.prototype, "defaultVariables", void 0);
exports.NotificationTemplate = NotificationTemplate = __decorate([
    (0, typeorm_1.Entity)({ name: 'notification_templates' }),
    (0, typeorm_1.Index)(['companyId', 'code', 'channel'], { unique: true })
], NotificationTemplate);
