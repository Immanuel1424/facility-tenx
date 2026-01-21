import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { SchedulerRegistry } from '@nestjs/schedule';
import { CronJob } from 'cron';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EscalationService } from './escalation.service';
import { SystemConfig } from '../entities/system-config.entity';
import { SlaConfiguration } from '../entities/sla-configuration.entity';

@Injectable()
export class EscalationSchedulerService implements OnModuleInit {
  private readonly logger = new Logger(EscalationSchedulerService.name);
  private readonly jobName = 'escalation-check';
  private currentIntervalMinutes = 1;

  constructor(
    @InjectRepository(SlaConfiguration)
    private readonly slaConfigRepository: Repository<SlaConfiguration>,
    @InjectRepository(SystemConfig)
    private readonly systemConfigRepository: Repository<SystemConfig>,
    private readonly escalationService: EscalationService,
    private readonly configService: ConfigService,
    private readonly schedulerRegistry: SchedulerRegistry,
  ) {}

  async onModuleInit() {
    await this.initializeScheduler();
  }

  private async initializeScheduler() {
    // Try to get interval from database first, fallback to environment variable
    let intervalMinutes = 1;
    
    try {
      // Try to get from database (any company's config - in multi-tenant, use first available)
      const config = await this.systemConfigRepository.findOne({
        where: {
          key: 'escalation_check_interval_minutes',
        },
        order: { createdAt: 'DESC' },
      });

      if (config) {
        intervalMinutes = parseInt(config.value, 10);
        this.logger.log(
          `Found escalation interval in database: ${intervalMinutes} minutes`,
        );
      } else {
        // Fallback to environment variable
        const envInterval = parseInt(
          this.configService.get<string>('ESCALATION_CHECK_INTERVAL_MINUTES', '1'),
          10,
        );
        intervalMinutes = Math.max(1, Math.min(60, envInterval));
        this.logger.log(
          `Using escalation interval from environment: ${intervalMinutes} minutes`,
        );
      }
    } catch (error) {
      this.logger.warn(
        'Could not read escalation interval from config, using default: 1 minute',
      );
    }

    // Validate and clamp interval
    intervalMinutes = Math.max(1, Math.min(60, intervalMinutes));
    this.currentIntervalMinutes = intervalMinutes;
    await this.updateScheduler(intervalMinutes);
  }

  /**
   * Update scheduler interval dynamically
   */
  async updateSchedulerInterval(companyId: string, intervalMinutes: number): Promise<void> {
    const validInterval = Math.max(1, Math.min(60, intervalMinutes));
    this.currentIntervalMinutes = validInterval;
    await this.updateScheduler(validInterval);
    this.logger.log(
      `Escalation scheduler updated to run every ${validInterval} minute(s)`,
    );
  }

  private async updateScheduler(intervalMinutes: number) {
    // Remove existing job if it exists
    try {
      const existingJob = this.schedulerRegistry.getCronJob(this.jobName);
      existingJob.stop();
      this.schedulerRegistry.deleteCronJob(this.jobName);
    } catch (error) {
      // Job doesn't exist yet, that's fine
    }

    // Generate cron expression: run every N minutes
    const cronExpression = `*/${intervalMinutes} * * * *`;

    // Create and register the new cron job
    const job = new CronJob(cronExpression, async () => {
      try {
        await this.handleScheduledEscalations();
      } catch (error) {
        const errorMessage =
          error instanceof Error ? error.message : String(error);
        this.logger.error(
          `Unhandled error in escalation scheduler: ${errorMessage}`,
        );
      }
    });

    this.schedulerRegistry.addCronJob(this.jobName, job);
    job.start();

    this.logger.log(
      `Escalation scheduler configured to run every ${intervalMinutes} minute(s) (cron: ${cronExpression})`,
    );
  }

  async handleScheduledEscalations(): Promise<void> {
    try {
      this.logger.log('Starting scheduled escalation check...');

      // Find all companies that have active SLA configurations
      const companiesWithSla = await this.slaConfigRepository
        .createQueryBuilder('config')
        .select('DISTINCT config.companyId', 'companyId')
        .where('config.isActive = :isActive', { isActive: true })
        .getRawMany();

      const companyIds = companiesWithSla.map((row) => row.companyId);

      if (companyIds.length === 0) {
        this.logger.log('No companies with active SLA configurations found');
        return;
      }

      this.logger.log(
        `Checking escalations for ${companyIds.length} company(ies)`,
      );

      // Process each company
      for (const companyId of companyIds) {
        try {
          await this.escalationService.checkAndEscalateTickets(companyId);
        } catch (error) {
          const errorMessage =
            error instanceof Error ? error.message : String(error);
          this.logger.error(
            `Error processing escalations for company ${companyId}: ${errorMessage}`,
          );
          // Continue with other companies
        }
      }

      this.logger.log('Completed scheduled escalation check');
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Error in scheduled escalation handler: ${errorMessage}`,
      );
    }
  }
}
