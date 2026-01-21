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
exports.NotificationDelivery = exports.DeliveryStatus = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const notification_channel_enum_1 = require("../enums/notification-channel.enum");
const notification_entity_1 = require("./notification.entity");
var DeliveryStatus;
(function (DeliveryStatus) {
    DeliveryStatus["PENDING"] = "pending";
    DeliveryStatus["SUCCESS"] = "success";
    DeliveryStatus["FAILED"] = "failed";
    DeliveryStatus["RETRYING"] = "retrying";
})(DeliveryStatus || (exports.DeliveryStatus = DeliveryStatus = {}));
let NotificationDelivery = class NotificationDelivery extends tenant_base_entity_1.TenantBaseEntity {
};
exports.NotificationDelivery = NotificationDelivery;
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', name: 'notification_id' }),
    __metadata("design:type", String)
], NotificationDelivery.prototype, "notificationId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => notification_entity_1.Notification, (notification) => notification.deliveries, { onDelete: 'CASCADE' }),
    __metadata("design:type", notification_entity_1.Notification)
], NotificationDelivery.prototype, "notification", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: notification_channel_enum_1.NotificationChannel }),
    __metadata("design:type", String)
], NotificationDelivery.prototype, "channel", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: DeliveryStatus, default: DeliveryStatus.PENDING }),
    __metadata("design:type", String)
], NotificationDelivery.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', name: 'attempt_count', default: 0 }),
    __metadata("design:type", Number)
], NotificationDelivery.prototype, "attemptCount", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', name: 'last_error', nullable: true }),
    __metadata("design:type", Object)
], NotificationDelivery.prototype, "lastError", void 0);
exports.NotificationDelivery = NotificationDelivery = __decorate([
    (0, typeorm_1.Entity)({ name: 'notification_deliveries' }),
    (0, typeorm_1.Index)(['companyId', 'notificationId', 'channel'])
], NotificationDelivery);
