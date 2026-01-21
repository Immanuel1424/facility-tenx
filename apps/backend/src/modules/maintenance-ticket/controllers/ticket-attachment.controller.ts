import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Version,
  UseInterceptors,
  UploadedFile,
  Inject,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { TicketAttachmentService } from '../services/ticket-attachment.service';
import { IStorageService } from '../services/storage.interface';
import { CreateAttachmentDto } from '../dto/create-attachment.dto';
import { GeneratePresignedUrlDto } from '../dto/generate-presigned-url.dto';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RolesGuard } from '../guards/roles.guard';
import { ApiResponseUtil } from '../../../shared/utils/api-response.util';
import { AttachmentContext } from '../entities/ticket-attachment.entity';
import * as crypto from 'crypto';

@Controller('maintenance-tickets/:ticketId/attachments')
@UseGuards(RolesGuard)
export class TicketAttachmentController {
  constructor(
    private readonly attachmentService: TicketAttachmentService,
    @Inject('StorageService') private readonly storageService: IStorageService,
  ) {}

  @Post('upload')
  @Version('1')
  @UseInterceptors(FileInterceptor('file'))
  async upload(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @UploadedFile() file: Express.Multer.File | undefined,
  ) {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    // Save file to storage (local or S3)
    let savedFileInfo;
    try {
      savedFileInfo = await this.storageService.saveFile(file, ticketId);
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      console.error(`File upload failed for ticket ${ticketId}:`, error);
      throw new BadRequestException(`File upload failed: ${errorMessage}`);
    }

    // Create attachment metadata DTO
    const createDto: CreateAttachmentDto = {
      file_name: savedFileInfo.fileName,
      original_name: savedFileInfo.originalName,
      mime_type: savedFileInfo.mimeType,
      file_size: savedFileInfo.fileSize,
      storage_path: savedFileInfo.storagePath,
      storage_url: savedFileInfo.storageUrl,
      checksum: savedFileInfo.checksum,
      attachment_context: AttachmentContext.TICKET_CREATION,
    };

    // Create attachment record in database
    const attachment = await this.attachmentService.create(
      user.companyId,
      ticketId,
      user.userId,
      user.roles || [],
      createDto,
    );

    return ApiResponseUtil.created(attachment, 'Attachment uploaded successfully');
  }

  @Post()
  @Version('1')
  async create(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Body() createDto: CreateAttachmentDto,
  ) {
    const attachment = await this.attachmentService.create(
      user.companyId,
      ticketId,
      user.userId,
      user.roles || [],
      createDto,
    );
    return ApiResponseUtil.created(attachment, 'Attachment uploaded successfully');
  }

  @Get()
  @Version('1')
  async findAll(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
  ) {
    const attachments = await this.attachmentService.findAllByTicket(
      user.companyId,
      ticketId,
      user.roles || [],
      user.userId,
    );
    return ApiResponseUtil.success(attachments, 'Attachments retrieved successfully');
  }

  @Get('stats')
  @Version('1')
  async getStats(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
  ) {
    const stats = await this.attachmentService.getAttachmentStats(
      user.companyId,
      ticketId,
    );
    return ApiResponseUtil.success(stats, 'Attachment stats retrieved successfully');
  }

  @Get('context/:context')
  @Version('1')
  async getByContext(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('context') context: AttachmentContext,
  ) {
    const attachments = await this.attachmentService.getAttachmentsByContext(
      user.companyId,
      ticketId,
      context,
    );
    return ApiResponseUtil.success(attachments, 'Attachments retrieved successfully');
  }

  @Get(':attachmentId')
  @Version('1')
  async findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('attachmentId') attachmentId: string,
  ) {
    const attachment = await this.attachmentService.findOne(
      user.companyId,
      ticketId,
      attachmentId,
      user.roles || [],
      user.userId,
    );
    return ApiResponseUtil.success(attachment, 'Attachment retrieved successfully');
  }

  @Delete(':attachmentId')
  @Version('1')
  @HttpCode(HttpStatus.OK)
  async delete(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('attachmentId') attachmentId: string,
  ) {
    await this.attachmentService.delete(
      user.companyId,
      ticketId,
      attachmentId,
      user.userId,
      user.roles || [],
    );
    return ApiResponseUtil.noContent('Attachment deleted successfully');
  }

  /**
   * Generate presigned URL for direct S3 upload
   * Client uploads directly to S3, then calls create() with metadata
   * 
   * DEPRECATED: Use /uploads/presigned-url for new code
   * Kept for backward compatibility
   */
  @Post('presigned-url')
  @Version('1')
  async generatePresignedUrl(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Body() dto: GeneratePresignedUrlDto,
  ) {
    // Calculate checksum if provided, or generate from metadata
    const checksum = dto.checksum || this.calculateMetadataChecksum(dto);

    // Use 15-minute expiry (900 seconds) for security
    // Industry standard: pre-signed URLs should expire quickly
    const expiresIn = 900;

    const presignedData = await this.storageService.generatePresignedUploadUrl(
      ticketId,
      dto.fileName,
      dto.mimeType,
      dto.fileSize,
      checksum,
      expiresIn,
      'maintenance-ticket', // Explicit entity type
    );

    return ApiResponseUtil.success(
      {
        presignedUrl: presignedData.presignedUrl,
        s3Key: presignedData.s3Key,
        storageUrl: presignedData.storageUrl,
        expiresAt: presignedData.expiresAt,
        fileName: dto.fileName,
        mimeType: dto.mimeType,
        fileSize: dto.fileSize,
        checksum,
      },
      'Presigned URL generated successfully',
    );
  }

  /**
   * Get presigned URL for viewing/downloading an attachment
   * This is needed for private S3 buckets
   */
  @Get(':attachmentId/presigned-url')
  @Version('1')
  async getPresignedViewUrl(
    @CurrentUser() user: CurrentUserData,
    @Param('ticketId') ticketId: string,
    @Param('attachmentId') attachmentId: string,
    @Query('expiresIn') expiresIn?: number,
  ) {
    // Get attachment to verify it exists and user has access
    const attachment = await this.attachmentService.findOne(
      user.companyId,
      ticketId,
      attachmentId,
      user.roles || [],
      user.userId,
    );

    if (!attachment) {
      throw new Error('Attachment not found');
    }

    // Generate presigned URL for viewing (GET operation)
    const presignedUrl = await this.storageService.getPresignedUrl(
      attachment.storagePath,
      expiresIn || 3600, // Default 1 hour
    );

    return ApiResponseUtil.success(
      {
        presignedUrl,
        expiresIn: expiresIn || 3600,
      },
      'Presigned URL generated successfully',
    );
  }

  /**
   * Calculate a simple checksum from metadata (for tracking)
   * In production, client should calculate actual file checksum
   */
  private calculateMetadataChecksum(dto: GeneratePresignedUrlDto): string {
    const data = `${dto.fileName}-${dto.mimeType}-${dto.fileSize}-${Date.now()}`;
    return crypto.createHash('md5').update(data).digest('hex');
  }
}

