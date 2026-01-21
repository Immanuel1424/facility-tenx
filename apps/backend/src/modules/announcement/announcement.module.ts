import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { AnnouncementController } from './controllers/announcement.controller';
import { AnnouncementService } from './services/announcement.service';
import { AnnouncementSchedulerService } from './services/announcement-scheduler.service';
import { Announcement } from './entities/announcement.entity';
import { AnnouncementRead } from './entities/announcement-read.entity';
import { User } from '../iam/entities/user.entity';
import { UserRole } from '../iam/entities/user-role.entity';
import { Role } from '../iam/entities/role.entity';
import { NotificationModule } from '../notification/notification.module';
import { NotificationTemplate } from '../notification/entities/notification-template.entity';
import { IamModule } from '../iam/iam.module';
import { TenantModule } from '../tenant/tenant.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      NotificationTemplate,
      Announcement,
      AnnouncementRead,
      User,
      UserRole,
      Role,
    ]),
    ScheduleModule.forRoot(),
    NotificationModule,
    IamModule,
    forwardRef(() => TenantModule),
  ],
  controllers: [AnnouncementController],
  providers: [AnnouncementService, AnnouncementSchedulerService],
  exports: [AnnouncementService],
})
export class AnnouncementModule {}

