import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Notification } from './entities/notification.entity';
import { NotificationDelivery } from './entities/notification-delivery.entity';
import { NotificationTemplate } from './entities/notification-template.entity';
import { NotificationAuditLog } from './entities/notification-audit-log.entity';
import { NotificationService } from './notification.service';
import { TemplateSeedService } from './services/template-seed.service';
import { NotificationController } from './notification.controller';
import { EmailChannel } from './channels/email.channel';
import { SmsChannel } from './channels/sms.channel';
import { WhatsappChannel } from './channels/whatsapp.channel';
import { PushChannel } from './channels/push.channel';
import { IamModule } from '../iam/iam.module';
import { Company } from '../tenant/entities/company.entity';
import { Site } from '../tenant/entities/site.entity';
import { User } from '../iam/entities/user.entity';

@Module({
  imports: [
    ConfigModule,
    IamModule, // Import IAM module to access UserDeviceService
    TypeOrmModule.forFeature([
      Notification,
      NotificationDelivery,
      NotificationTemplate,
      NotificationAuditLog,
      Company,
      Site,
      User,
    ]),
  ],
  controllers: [NotificationController],
  providers: [
    NotificationService,
    TemplateSeedService,
    EmailChannel,
    SmsChannel,
    WhatsappChannel,
    PushChannel,
  ],
  exports: [NotificationService, TemplateSeedService],
})
export class NotificationModule {}


