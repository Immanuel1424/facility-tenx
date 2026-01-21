import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, IsNull } from 'typeorm';
import { Announcement } from '../entities/announcement.entity';
import { AnnouncementService } from './announcement.service';

@Injectable()
export class AnnouncementSchedulerService {
  private readonly logger = new Logger(AnnouncementSchedulerService.name);

  constructor(
    @InjectRepository(Announcement)
    private readonly announcementRepository: Repository<Announcement>,
    private readonly announcementService: AnnouncementService,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async handleScheduledAnnouncements(): Promise<void> {
    try {
      const now = new Date();

      // Find announcements that are scheduled and not yet published
      const scheduledAnnouncements =
        await this.announcementRepository.find({
          where: {
            isPublished: false,
            scheduledAt: LessThanOrEqual(now),
            deletedAt: IsNull(),
          },
        });

      if (scheduledAnnouncements.length === 0) {
        return;
      }

      this.logger.log(
        `Found ${scheduledAnnouncements.length} scheduled announcement(s) to publish`,
      );

      // Publish each scheduled announcement
      for (const announcement of scheduledAnnouncements) {
        try {
          await this.announcementService.publish(
            announcement.companyId,
            announcement.id,
          );
          this.logger.log(
            `Published scheduled announcement ${announcement.id}`,
          );
        } catch (error) {
          const errorMessage =
            error instanceof Error ? error.message : String(error);
          this.logger.error(
            `Failed to publish scheduled announcement ${announcement.id}: ${errorMessage}`,
          );
        }
      }
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Error in scheduled announcement handler: ${errorMessage}`,
      );
    }
  }
}

