import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { UserDevice, DevicePlatform } from '../entities/user-device.entity';

@Injectable()
export class UserDeviceService {
  constructor(
    @InjectRepository(UserDevice)
    private readonly deviceRepo: Repository<UserDevice>,
  ) {}

  async registerDevice(
    companyId: string,
    userId: string,
    fcmToken: string,
    platform: DevicePlatform,
    deviceInfo?: Record<string, unknown>,
  ): Promise<UserDevice> {
    // Check if device already exists
    const existing = await this.deviceRepo.findOne({
      where: {
        companyId,
        userId,
        fcmToken,
      },
    });

    if (existing) {
      // Update existing device
      existing.isActive = true;
      existing.lastUsedAt = new Date();
      existing.platform = platform;
      if (deviceInfo) {
        existing.deviceInfo = deviceInfo;
      }
      return this.deviceRepo.save(existing);
    }

    // Create new device
    const device = this.deviceRepo.create({
      companyId,
      userId,
      fcmToken,
      platform,
      deviceInfo,
      isActive: true,
      lastUsedAt: new Date(),
    });

    return this.deviceRepo.save(device);
  }

  async unregisterDevice(
    companyId: string,
    userId: string,
    fcmToken: string,
  ): Promise<void> {
    await this.deviceRepo.update(
      {
        companyId,
        userId,
        fcmToken,
      },
      {
        isActive: false,
      },
    );
  }

  async getActiveTokensForUser(
    companyId: string,
    userId: string,
  ): Promise<string[]> {
    const devices = await this.deviceRepo.find({
      where: {
        companyId,
        userId,
        isActive: true,
      },
      select: ['fcmToken'],
    });

    return devices.map((device) => device.fcmToken);
  }

  async deactivateStaleTokens(olderThanDays: number = 90): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

    const devices = await this.deviceRepo.find({
      where: {
        isActive: true,
        lastUsedAt: LessThan(cutoffDate),
      },
    });

    if (devices.length === 0) {
      return 0;
    }

    // Update each device
    for (const device of devices) {
      device.isActive = false;
      await this.deviceRepo.save(device);
    }

    return devices.length;
  }
}

