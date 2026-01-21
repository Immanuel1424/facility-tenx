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
exports.NotificationAuditLog = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const notification_severity_enum_1 = require("../enums/notification-severity.enum");
let NotificationAuditLog = class NotificationAuditLog extends tenant_base_entity_1.TenantBaseEntity {
};
exports.NotificationAuditLog = NotificationAuditLog;
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 128 }),
    __metadata("design:type", String)
], NotificationAuditLog.prototype, "eventType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: notification_severity_enum_1.NotificationSeverity }),
    __metadata("design:type", String)
], NotificationAuditLog.prototype, "severity", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', name: 'recipient_user_id', nullable: true }),
    __metadata("design:type", Object)
], NotificationAuditLog.prototype, "recipientUserId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', name: 'event_payload', nullable: true }),
    __metadata("design:type", Object)
], NotificationAuditLog.prototype, "eventPayload", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', name: 'metadata', nullable: true }),
    __metadata("design:type", Object)
], NotificationAuditLog.prototype, "metadata", void 0);
exports.NotificationAuditLog = NotificationAuditLog = __decorate([
    (0, typeorm_1.Entity)({ name: 'notification_audit_logs' }),
    (0, typeorm_1.Index)(['companyId', 'createdAt'])
], NotificationAuditLog);
