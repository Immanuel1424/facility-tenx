import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  Param,
  Res,
  Req,
  UseGuards,
  Version,
  HttpCode,
  HttpStatus,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Request, Response } from 'express';
import { Inject } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { TenantGuard } from '../../../shared/guards/tenant.guard';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { IStorageService } from '../../maintenance-ticket/services/storage.interface';
import { GeneratePresignedUrlDto } from '../dto/generate-presigned-url.dto';
import { ApiResponseUtil } from '../../../shared/utils/api-response.util';

/**
 * Generic upload controller for pre-signed S3 URLs
 * Industry-standard pattern: Backend generates pre-signed URL, client uploads directly to S3
 */
@ApiTags('uploads')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('uploads')
export class UploadController {
  constructor(
    @Inject('StorageService') private readonly storageService: IStorageService,
  ) {}

  /**
   * Generate pre-signed URL for direct S3 upload
   * 
   * SECURITY:
   * - Requires authenticated user (JWT)
   * - Validates file metadata (size, MIME type)
   * - URL expires in 15 minutes (900 seconds)
   * - Returns only pre-signed URL and S3 key (no AWS credentials)
   * 
   * FLOW:
   * 1. Client calls this endpoint with file metadata
   * 2. Backend validates and generates pre-signed URL
   * 3. Client uploads file directly to S3 using pre-signed URL
   * 4. Client stores S3 key for later use
   */
  @Post('presigned-url')
  @Version('1')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Generate pre-signed URL for direct S3 upload',
    description:
      'Returns a pre-signed URL that allows direct upload to S3. ' +
      'The URL expires in 15 minutes. Client must upload using HTTP PUT with correct Content-Type.',
  })
  @ApiResponse({
    status: 200,
    description: 'Pre-signed URL generated successfully',
    schema: {
      type: 'object',
      properties: {
        presignedUrl: {
          type: 'string',
          description: 'Pre-signed URL for direct S3 upload (PUT operation)',
        },
        s3Key: {
          type: 'string',
          description: 'S3 object key (store this for later reference)',
        },
        expiresAt: {
          type: 'string',
          format: 'date-time',
          description: 'URL expiration timestamp',
        },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid file metadata' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async generatePresignedUrl(
    @CurrentUser() user: CurrentUserData,
    @Body() dto: GeneratePresignedUrlDto,
  ) {
    // Generate pre-signed URL with 15-minute expiry (900 seconds)
    // Industry standard: pre-signed URLs should expire quickly for security
    const expiresIn = 900; // 15 minutes in seconds

    const presignedData = await this.storageService.generatePresignedUploadUrl(
      dto.entityId,
      dto.fileName,
      dto.mimeType,
      dto.fileSize,
      dto.checksum,
      expiresIn,
      dto.entityType,
    );

    return ApiResponseUtil.success(
      {
        presignedUrl: presignedData.presignedUrl,
        s3Key: presignedData.s3Key,
        expiresAt: presignedData.expiresAt,
      },
      'Pre-signed URL generated successfully',
    );
  }

  /**
   * Generate pre-signed URL for downloading/viewing files from S3
   * 
   * SECURITY:
   * - Requires authenticated user (JWT) - files are private
   * - Validates storage path format
   * - URL expires in 1 hour by default (configurable)
   * - Returns only pre-signed URL (no AWS credentials)
   * 
   * FLOW:
   * 1. Client calls this endpoint with storagePath
   * 2. Backend validates and generates pre-signed URL
   * 3. Client uses pre-signed URL to download/view file directly from S3
   * 
   * This follows the same pattern as upload: generic endpoint for all entity types
   */
  @Get('presigned-url')
  @Version('1')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Generate pre-signed URL for downloading/viewing files from S3',
    description:
      'Returns a pre-signed URL that allows direct download/viewing from S3. ' +
      'The URL expires in 1 hour by default (configurable via expiresIn parameter). ' +
      'Client can use this URL to access the file directly from S3.',
  })
  @ApiQuery({
    name: 'storagePath',
    required: true,
    description: 'S3 storage path (key) of the file to download',
    example: 'tenx-attachments/maintenance-ticket/123/abc-123.jpg',
  })
  @ApiQuery({
    name: 'expiresIn',
    required: false,
    description: 'URL expiration time in seconds (default: 3600 = 1 hour, max: 3600)',
    type: Number,
    example: 3600,
  })
  @ApiResponse({
    status: 200,
    description: 'Pre-signed URL generated successfully',
    schema: {
      type: 'object',
      properties: {
        presignedUrl: {
          type: 'string',
          description: 'Pre-signed URL for direct S3 download/view (GET operation)',
        },
        expiresIn: {
          type: 'number',
          description: 'URL expiration time in seconds',
        },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid storage path' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async generatePresignedDownloadUrl(
    @CurrentUser() user: CurrentUserData,
    @Query('storagePath') storagePath: string,
    @Query('expiresIn') expiresIn?: number,
  ) {
    if (!storagePath || storagePath.trim().length === 0) {
      throw new BadRequestException('storagePath query parameter is required');
    }

    // Validate that the path starts with expected prefix (security check)
    // Support both local storage (tickets/) and S3 storage (tenx-attachments/)
    const s3Prefix = process.env.AWS_S3_BASE_PREFIX || 'tenx-attachments';
    const localPrefix = 'tickets';
    if (!storagePath.startsWith(s3Prefix) && !storagePath.startsWith(localPrefix)) {
      throw new BadRequestException(
        `Invalid storage path. Path must start with '${s3Prefix}' (S3) or '${localPrefix}' (local storage)`,
      );
    }

    // Enforce maximum expiry of 1 hour (3600 seconds) for security
    const maxExpiry = 3600; // 1 hour
    const actualExpiresIn = expiresIn
      ? Math.min(expiresIn, maxExpiry)
      : maxExpiry;

    if (expiresIn && expiresIn > maxExpiry) {
      // Log warning but use maxExpiry
      console.warn(
        `Requested expiry ${expiresIn}s exceeds maximum ${maxExpiry}s. Using ${maxExpiry}s.`,
      );
    }

    try {
      // Generate presigned URL for viewing (GET operation)
      const presignedUrl = await this.storageService.getPresignedUrl(
        storagePath,
        actualExpiresIn,
      );

      return ApiResponseUtil.success(
        {
          presignedUrl,
          expiresIn: actualExpiresIn,
        },
        'Pre-signed URL generated successfully',
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      throw new BadRequestException(`Failed to generate pre-signed URL: ${errorMessage}`);
    }
  }

  /**
   * Redirect endpoint for legacy /uploads/* URLs
   * Handles direct file access requests and redirects to S3 presigned URLs
   * 
   * This provides backward compatibility for frontend code that constructs
   * URLs like: /uploads/tenx-attachments/maintenance-ticket/.../file.jpg
   * 
   * SECURITY:
   * - Requires authenticated user (JWT) - files are private
   * - Validates storage path format
   * - Generates presigned URL with 1-hour expiry
   * - Redirects (302) to S3 presigned URL
   * 
   * FLOW:
   * 1. Client requests file via /uploads/{storagePath}
   * 2. Backend extracts S3 key from path
   * 3. Backend generates presigned URL
   * 4. Backend redirects (302) to S3 presigned URL
   * 5. Browser follows redirect and downloads from S3
   */
  @Get('*')
  @Version('1')
  async redirectToPresignedUrl(
    @Param('0') path: string,
    @Req() req: Request,
    @Res() res: Response,
    @CurrentUser() user: CurrentUserData,
  ) {
    // Extract the S3 key from the path
    // NestJS wildcard route (*) captures everything after /uploads/ in @Param('0')
    // Remove leading slash if present
    const cleanS3Key = path.startsWith('/') ? path.substring(1) : path;

    if (!cleanS3Key || cleanS3Key.trim().length === 0) {
      throw new NotFoundException('File path is required');
    }

    // Validate that the path starts with expected prefix (security check)
    // Support both local storage (tickets/) and S3 storage (tenx-attachments/)
    const s3Prefix = process.env.AWS_S3_BASE_PREFIX || 'tenx-attachments';
    const localPrefix = 'tickets';
    if (!cleanS3Key.startsWith(s3Prefix) && !cleanS3Key.startsWith(localPrefix)) {
      throw new NotFoundException(
        `Invalid file path. Path must start with '${s3Prefix}' (S3) or '${localPrefix}' (local storage)`,
      );
    }

    try {
      // Generate presigned URL for viewing (GET operation)
      // Default expiry: 1 hour (3600 seconds)
      const presignedUrl = await this.storageService.getPresignedUrl(cleanS3Key, 3600);

      // Redirect to S3 presigned URL (302 Found - temporary redirect)
      res.redirect(302, presignedUrl);
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      throw new NotFoundException(`File not found: ${errorMessage}`);
    }
  }
}
