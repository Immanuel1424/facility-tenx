import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemConfig } from '../entities/system-config.entity';
import { UpdateEscalationSchedulerConfigDto } from '../dto/update-escalation-scheduler-config.dto';

@Injectable()
export class SystemConfigService {
  private readonly logger = new Logger(SystemConfigService.name);
  private readonly ESCALATION_INTERVAL_KEY = 'escalation_check_interval_minutes';

  constructor(
    @InjectRepository(SystemConfig)
    private readonly systemConfigRepository: Repository<SystemConfig>,
  ) {}

  /**
   * Get escalation scheduler configuration
   */
  async getEscalationSchedulerConfig(companyId: string): Promise<{
    intervalMinutes: number;
  }> {
    const config = await this.systemConfigRepository.findOne({
      where: {
        companyId,
        key: this.ESCALATION_INTERVAL_KEY,
      },
    });

    // Default to 1 minute if not configured
    const intervalMinutes = config
      ? parseInt(config.value, 10)
      : 1;

    return {
      intervalMinutes: Math.max(1, Math.min(60, intervalMinutes)),
    };
  }

  /**
   * Update escalation scheduler configuration
   */
  async updateEscalationSchedulerConfig(
    companyId: string,
    dto: UpdateEscalationSchedulerConfigDto,
  ): Promise<SystemConfig> {
    let config = await this.systemConfigRepository.findOne({
      where: {
        companyId,
        key: this.ESCALATION_INTERVAL_KEY,
      },
    });

    if (config) {
      config.value = dto.intervalMinutes.toString();
      config.type = 'number';
    } else {
      config = this.systemConfigRepository.create({
        companyId,
        key: this.ESCALATION_INTERVAL_KEY,
        value: dto.intervalMinutes.toString(),
        type: 'number',
        description: 'Interval in minutes for escalation scheduler check (1-60)',
      });
    }

    const savedConfig = await this.systemConfigRepository.save(config);

    this.logger.log(
      `Escalation scheduler configuration saved: ${dto.intervalMinutes} minutes. Changes will take effect after server restart or scheduler refresh.`,
    );

    return savedConfig;
  }
}
