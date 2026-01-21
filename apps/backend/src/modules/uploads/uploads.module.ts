import { Module } from '@nestjs/common';
import { UploadController } from './controllers/upload.controller';
import { S3StorageService } from '../maintenance-ticket/services/s3-storage.service';
import { MaintenanceTicketModule } from '../maintenance-ticket/maintenance-ticket.module';
import { IamModule } from '../iam/iam.module';

/**
 * Generic uploads module for pre-signed S3 URLs
 * Provides industry-standard file upload flow:
 * 1. Client requests pre-signed URL from backend
 * 2. Client uploads directly to S3 using pre-signed URL
 * 3. Client stores S3 key for later reference
 */
@Module({
  imports: [
    MaintenanceTicketModule, // Import to access S3StorageService
    IamModule, // Import to access SuperAdminService for TenantGuard
  ],
  controllers: [UploadController],
  providers: [],
  exports: [],
})
export class UploadsModule {}
