import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Version,
} from '@nestjs/common';
import { ApiOperation, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { AnnouncementService } from '../services/announcement.service';
import { CreateAnnouncementDto } from '../dto/create-announcement.dto';
import { UpdateAnnouncementDto } from '../dto/update-announcement.dto';
import { AnnouncementQueryDto } from '../dto/announcement-query.dto';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RequirePermission } from '../../iam/decorators/require-permission.decorator';
import { PermissionGuard } from '../../iam/guards/permission.guard';

@ApiTags('announcements')
@Controller('announcements')
@UseGuards(PermissionGuard)
@ApiBearerAuth()
export class AnnouncementController {
  constructor(private readonly announcementService: AnnouncementService) {}

  @Post()
  @Version('1')
  @RequirePermission('announcement', 'create')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new announcement (ADMIN only)' })
  async create(
    @CurrentUser() user: CurrentUserData,
    @Body() createDto: CreateAnnouncementDto,
  ) {
    return this.announcementService.create(
      user.companyId,
      user.userId,
      createDto,
    );
  }

  @Get()
  @Version('1')
  @RequirePermission('announcement', 'read')
  @ApiOperation({ summary: 'List announcements (filtered by user role)' })
  async findAll(
    @CurrentUser() user: CurrentUserData,
    @Query() queryDto: AnnouncementQueryDto,
  ) {
    return this.announcementService.findAll(
      user.companyId,
      user.userId,
      queryDto,
    );
  }

  @Get('admin')
  @Version('1')
  @RequirePermission('announcement', 'read')
  @ApiOperation({ summary: 'List all announcements for admin (including drafts)' })
  async findAllForAdmin(
    @CurrentUser() user: CurrentUserData,
    @Query() queryDto: AnnouncementQueryDto,
  ) {
    return this.announcementService.findAllForAdmin(
      user.companyId,
      queryDto,
    );
  }

  @Get(':id')
  @Version('1')
  @RequirePermission('announcement', 'read')
  @ApiOperation({ summary: 'Get announcement details' })
  async findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    return this.announcementService.findOne(
      user.companyId,
      id,
      user.userId,
    );
  }

  @Patch(':id')
  @Version('1')
  @RequirePermission('announcement', 'update')
  @ApiOperation({ summary: 'Update announcement (ADMIN only)' })
  async update(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() updateDto: UpdateAnnouncementDto,
  ) {
    return this.announcementService.update(
      user.companyId,
      id,
      updateDto,
    );
  }

  @Delete(':id')
  @Version('1')
  @RequirePermission('announcement', 'delete')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete announcement (ADMIN only)' })
  async delete(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    await this.announcementService.delete(user.companyId, id);
  }

  @Post(':id/publish')
  @Version('1')
  @RequirePermission('announcement', 'publish')
  @ApiOperation({ summary: 'Publish announcement immediately (ADMIN only)' })
  async publish(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    return this.announcementService.publish(user.companyId, id);
  }

  @Post(':id/read')
  @Version('1')
  @RequirePermission('announcement', 'read')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Mark announcement as read' })
  async markAsRead(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    return this.announcementService.markAsRead(
      user.companyId,
      id,
      user.userId,
    );
  }

  @Get('unread/count')
  @Version('1')
  @RequirePermission('announcement', 'read')
  @ApiOperation({ summary: 'Get unread announcement count' })
  async getUnreadCount(@CurrentUser() user: CurrentUserData) {
    const count = await this.announcementService.getUnreadCount(
      user.companyId,
      user.userId,
    );
    return { count };
  }

  @Get('unread/list')
  @Version('1')
  @RequirePermission('announcement', 'read')
  @ApiOperation({ summary: 'Get unread announcements list' })
  async getUnreadList(
    @CurrentUser() user: CurrentUserData,
    @Query() queryDto: AnnouncementQueryDto,
  ) {
    return this.announcementService.getUnreadList(
      user.companyId,
      user.userId,
      queryDto,
    );
  }
}

