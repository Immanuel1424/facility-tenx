import { Module } from '@nestjs/common';
import { APP_GUARD, APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { ConfigModule as NestConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { IamModule } from './modules/iam/iam.module';
import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { MaintenanceTicketModule } from './modules/maintenance-ticket/maintenance-ticket.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { NotificationModule } from './modules/notification/notification.module';
import { TenantModule } from './modules/tenant/tenant.module';
import { UserModule } from './modules/user/user.module';
import { AuditModule } from './modules/audit/audit.module';
import { HealthModule } from './modules/health/health.module';
import { GeminiModule } from './modules/gemini/gemini.module';
import { AnnouncementModule } from './modules/announcement/announcement.module';
import { UploadsModule } from './modules/uploads/uploads.module';
import { typeOrmConfig } from './shared/config/typeorm.config';
import { GlobalExceptionFilter } from './shared/filters/global-exception.filter';
import { CompanyScopeGuard } from './shared/guards/company-scope.guard';
import { ResponseTransformInterceptor } from './shared/interceptors/response-transform.interceptor';

@Module({
  imports: [
    NestConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      useFactory: typeOrmConfig,
    }),
    IamModule,
    AuthModule,
    TenantModule,
    UserModule,
    MaintenanceTicketModule,
    DashboardModule,
    NotificationModule,
    AuditModule,
    HealthModule,
    GeminiModule,
    AnnouncementModule,
    UploadsModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: CompanyScopeGuard,
    },
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseTransformInterceptor,
    },
  ],
})
export class AppModule {}


