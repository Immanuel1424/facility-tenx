"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const auth_module_1 = require("./modules/auth/auth.module");
const iam_module_1 = require("./modules/iam/iam.module");
const jwt_auth_guard_1 = require("./modules/auth/guards/jwt-auth.guard");
const maintenance_ticket_module_1 = require("./modules/maintenance-ticket/maintenance-ticket.module");
const dashboard_module_1 = require("./modules/dashboard/dashboard.module");
const notification_module_1 = require("./modules/notification/notification.module");
const tenant_module_1 = require("./modules/tenant/tenant.module");
const user_module_1 = require("./modules/user/user.module");
const audit_module_1 = require("./modules/audit/audit.module");
const health_module_1 = require("./modules/health/health.module");
const gemini_module_1 = require("./modules/gemini/gemini.module");
const announcement_module_1 = require("./modules/announcement/announcement.module");
const uploads_module_1 = require("./modules/uploads/uploads.module");
const typeorm_config_1 = require("./shared/config/typeorm.config");
const global_exception_filter_1 = require("./shared/filters/global-exception.filter");
const company_scope_guard_1 = require("./shared/guards/company-scope.guard");
const response_transform_interceptor_1 = require("./shared/interceptors/response-transform.interceptor");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
            }),
            typeorm_1.TypeOrmModule.forRootAsync({
                useFactory: typeorm_config_1.typeOrmConfig,
            }),
            iam_module_1.IamModule,
            auth_module_1.AuthModule,
            tenant_module_1.TenantModule,
            user_module_1.UserModule,
            maintenance_ticket_module_1.MaintenanceTicketModule,
            dashboard_module_1.DashboardModule,
            notification_module_1.NotificationModule,
            audit_module_1.AuditModule,
            health_module_1.HealthModule,
            gemini_module_1.GeminiModule,
            announcement_module_1.AnnouncementModule,
            uploads_module_1.UploadsModule,
        ],
        providers: [
            {
                provide: core_1.APP_GUARD,
                useClass: jwt_auth_guard_1.JwtAuthGuard,
            },
            {
                provide: core_1.APP_GUARD,
                useClass: company_scope_guard_1.CompanyScopeGuard,
            },
            {
                provide: core_1.APP_FILTER,
                useClass: global_exception_filter_1.GlobalExceptionFilter,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: response_transform_interceptor_1.ResponseTransformInterceptor,
            },
        ],
    })
], AppModule);
