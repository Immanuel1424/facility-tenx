import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';

// Controllers
import { MaintenanceTicketController } from './controllers/maintenance-ticket.controller';
import { DepartmentController } from './controllers/department.controller';
import { TicketCategoryController } from './controllers/ticket-category.controller';
import { TicketCommentController } from './controllers/ticket-comment.controller';
import { TicketAttachmentController } from './controllers/ticket-attachment.controller';
import { SlaController } from './controllers/sla.controller';

// Services
import { MaintenanceTicketService } from './services/maintenance-ticket.service';
import { StatusTransitionService } from './services/status-transition.service';
import { TicketCategoryService } from './services/ticket-category.service';
import { TicketCommentService } from './services/ticket-comment.service';
import { TicketAttachmentService } from './services/ticket-attachment.service';
import { S3StorageService } from './services/s3-storage.service';
import { FileStorageService } from './services/file-storage.service';
import { IStorageService } from './services/storage.interface';
import { SlaService } from './services/sla.service';
import { GeminiAiService } from './services/gemini-ai.service';
import { EscalationService } from './services/escalation.service';
import { EscalationSchedulerService } from './services/escalation-scheduler.service';
import { SystemConfigService } from './services/system-config.service';

// Entities
import { MaintenanceTicket } from './entities/maintenance-ticket.entity';
import { TicketStatusHistory } from './entities/ticket-status-history.entity';
import { Department } from './entities/department.entity';
import { TicketCategory } from './entities/ticket-category.entity';
import { TicketComment } from './entities/ticket-comment.entity';
import { TicketAttachment } from './entities/ticket-attachment.entity';
import { SlaConfiguration } from './entities/sla-configuration.entity';
import { TicketSla } from './entities/ticket-sla.entity';
import { Team } from './entities/team.entity';
import { TeamMember } from './entities/team-member.entity';
import { Holiday } from './entities/holiday.entity';
import { EscalationHistory } from './entities/escalation-history.entity';
import { SystemConfig } from './entities/system-config.entity';
import { NotificationTemplate } from '../notification/entities/notification-template.entity';

// Shared
import { User } from '../iam/entities/user.entity';
import { UserRole } from '../iam/entities/user-role.entity';
import { Role } from '../iam/entities/role.entity';
import { RolesGuard } from './guards/roles.guard';
import { TicketOwnershipGuard } from './guards/ticket-ownership.guard';
import { IamModule } from '../iam/iam.module';
import { AuthModule } from '../auth/auth.module';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      MaintenanceTicket,
      TicketStatusHistory,
      Department,
      TicketCategory,
      TicketComment,
      TicketAttachment,
      SlaConfiguration,
      TicketSla,
      Team,
      TeamMember,
      Holiday,
      EscalationHistory,
      SystemConfig,
      User,
      UserRole,
      Role,
      NotificationTemplate,
    ]),
    ScheduleModule.forRoot(),
    IamModule,
    AuthModule,
    NotificationModule,
  ],
  controllers: [
    MaintenanceTicketController,
    DepartmentController,
    TicketCategoryController,
    TicketCommentController,
    TicketAttachmentController,
    SlaController,
  ],
  providers: [
    MaintenanceTicketService,
    StatusTransitionService,
    TicketCategoryService,
    TicketCommentService,
    TicketAttachmentService,
    // Provide both storage services
    FileStorageService,
    S3StorageService,
    // Factory to select storage provider based on environment variable
    {
      provide: 'StorageService',
      useFactory: (
        configService: ConfigService,
        fileStorage: FileStorageService,
        s3Storage: S3StorageService,
      ): IStorageService => {
        const provider = configService.get<string>('STORAGE_PROVIDER') || 'local';
        return provider === 's3' ? s3Storage : fileStorage;
      },
      inject: [ConfigService, FileStorageService, S3StorageService],
    },
    SlaService,
    GeminiAiService,
    EscalationService,
    EscalationSchedulerService,
    SystemConfigService,
    RolesGuard,
    TicketOwnershipGuard,
  ],
  exports: [
    MaintenanceTicketService,
    StatusTransitionService,
    TicketCategoryService,
    TicketCommentService,
    TicketAttachmentService,
    // Export StorageService token for use in other modules
    'StorageService',
    // Also export individual services for direct access if needed
    FileStorageService,
    S3StorageService,
    SlaService,
    EscalationService,
    SystemConfigService,
  ],
})
export class MaintenanceTicketModule {}
