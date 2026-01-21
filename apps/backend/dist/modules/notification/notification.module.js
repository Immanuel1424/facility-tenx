"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const notification_entity_1 = require("./entities/notification.entity");
const notification_delivery_entity_1 = require("./entities/notification-delivery.entity");
const notification_template_entity_1 = require("./entities/notification-template.entity");
const notification_audit_log_entity_1 = require("./entities/notification-audit-log.entity");
const notification_service_1 = require("./notification.service");
const template_seed_service_1 = require("./services/template-seed.service");
const notification_controller_1 = require("./notification.controller");
const email_channel_1 = require("./channels/email.channel");
const sms_channel_1 = require("./channels/sms.channel");
const whatsapp_channel_1 = require("./channels/whatsapp.channel");
const push_channel_1 = require("./channels/push.channel");
const iam_module_1 = require("../iam/iam.module");
const company_entity_1 = require("../tenant/entities/company.entity");
const site_entity_1 = require("../tenant/entities/site.entity");
const user_entity_1 = require("../iam/entities/user.entity");
let NotificationModule = class NotificationModule {
};
exports.NotificationModule = NotificationModule;
exports.NotificationModule = NotificationModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule,
            iam_module_1.IamModule,
            typeorm_1.TypeOrmModule.forFeature([
                notification_entity_1.Notification,
                notification_delivery_entity_1.NotificationDelivery,
                notification_template_entity_1.NotificationTemplate,
                notification_audit_log_entity_1.NotificationAuditLog,
                company_entity_1.Company,
                site_entity_1.Site,
                user_entity_1.User,
            ]),
        ],
        controllers: [notification_controller_1.NotificationController],
        providers: [
            notification_service_1.NotificationService,
            template_seed_service_1.TemplateSeedService,
            email_channel_1.EmailChannel,
            sms_channel_1.SmsChannel,
            whatsapp_channel_1.WhatsappChannel,
            push_channel_1.PushChannel,
        ],
        exports: [notification_service_1.NotificationService, template_seed_service_1.TemplateSeedService],
    })
], NotificationModule);
