import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Req,
  UseGuards,
  HttpCode,
  HttpStatus,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiTags,
} from '@nestjs/swagger';
import { PermissionService } from '../services/permission.service';
import { CreatePermissionDto } from '../dto/create-permission.dto';
import { UpdatePermissionDto } from '../dto/update-permission.dto';
import { Permission } from '../entities/permission.entity';
import { Role } from '../entities/role.entity';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { TenantGuard } from '../../../shared/guards/tenant.guard';
import { TenantAwareRequest } from '../../../shared/middleware/tenant-resolution.middleware';
import { Request } from 'express';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

interface AuthenticatedRequest extends TenantAwareRequest, Request {
  user: {
    userId: string;
    email?: string;
    companyId?: string;
    roles?: string[];
    permissions?: string[];
  };
}

@ApiTags('iam')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('iam/permissions')
export class PermissionController {
  constructor(
    private readonly permissionService: PermissionService,
    @InjectRepository(Permission)
    private readonly permissionRepository: Repository<Permission>,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all permissions (global)' })
  @ApiOkResponse({ description: 'List of permissions', type: [Permission] })
  async findAll(): Promise<Permission[]> {
    // Permissions are now global (not tenant-scoped)
    return this.permissionRepository.find({
      order: { category: 'ASC', resource: 'ASC', action: 'ASC' },
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get permission by ID' })
  @ApiOkResponse({ description: 'Permission details', type: Permission })
  async findOne(@Param('id') id: string): Promise<Permission> {
    const permission = await this.permissionRepository.findOne({
      where: { id },
    });

    if (!permission) {
      throw new NotFoundException(`Permission with ID ${id} not found`);
    }

    return permission;
  }

  @Post()
  @ApiOperation({ summary: 'Create a new permission' })
  @ApiCreatedResponse({ description: 'Permission created', type: Permission })
  async create(@Body() dto: CreatePermissionDto): Promise<Permission> {
    return this.permissionService.createPermission(
      dto.resource,
      dto.action,
      dto.description,
      dto.category,
    );
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a permission' })
  @ApiOkResponse({ description: 'Permission updated', type: Permission })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdatePermissionDto,
  ): Promise<Permission> {
    const permission = await this.findOne(id);

    // Check if resource/action change would conflict
    if (
      (dto.resource && dto.resource !== permission.resource) ||
      (dto.action && dto.action !== permission.action)
    ) {
      const existing = await this.permissionRepository.findOne({
        where: {
          resource: dto.resource ?? permission.resource,
          action: dto.action ?? permission.action,
        },
      });

      if (existing && existing.id !== id) {
        throw new BadRequestException(
          `Permission with resource "${dto.resource ?? permission.resource}" and action "${dto.action ?? permission.action}" already exists`,
        );
      }
    }

    Object.assign(permission, {
      resource: dto.resource ?? permission.resource,
      action: dto.action ?? permission.action,
      description:
        dto.description !== undefined
          ? dto.description
          : permission.description,
      category: dto.category ?? permission.category,
    });

    return this.permissionRepository.save(permission);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a permission' })
  @ApiNoContentResponse({ description: 'Permission deleted' })
  async delete(@Param('id') id: string): Promise<void> {
    const permission = await this.findOne(id);
    await this.permissionRepository.remove(permission);
  }

  @Get('by-resource/:resource')
  @ApiOperation({
    summary: 'Get permissions by resource',
    description: 'Returns all permissions for a specific resource',
  })
  @ApiOkResponse({ description: 'List of permissions', type: [Permission] })
  async findByResource(@Param('resource') resource: string): Promise<Permission[]> {
    return this.permissionRepository.find({
      where: { resource },
      order: { action: 'ASC' },
    });
  }

  @Get('by-action/:action')
  @ApiOperation({
    summary: 'Get permissions by action',
    description: 'Returns all permissions for a specific action',
  })
  @ApiOkResponse({ description: 'List of permissions', type: [Permission] })
  async findByAction(@Param('action') action: string): Promise<Permission[]> {
    return this.permissionRepository.find({
      where: { action },
      order: { resource: 'ASC' },
    });
  }

  @Get(':id/usage')
  @ApiOperation({
    summary: 'Get permission usage',
    description: 'Returns all roles that have this permission assigned',
  })
  @ApiOkResponse({ description: 'List of roles with this permission', type: [Role] })
  async getPermissionUsage(
    @Param('id') id: string,
    @Req() req: AuthenticatedRequest,
  ): Promise<Role[]> {
    // Verify permission exists
    await this.findOne(id);
    return this.permissionService.getPermissionUsage(req.companyId!, id);
  }
}
