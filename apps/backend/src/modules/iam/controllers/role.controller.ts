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
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiTags,
} from '@nestjs/swagger';
import { RoleService } from '../services/role.service';
import { PermissionService } from '../services/permission.service';
import { CreateRoleDto } from '../dto/create-role.dto';
import { UpdateRoleDto } from '../dto/update-role.dto';
import { AssignPermissionDto } from '../dto/assign-permission.dto';
import { BulkAssignPermissionsDto } from '../dto/bulk-assign-permissions.dto';
import { BulkRemovePermissionsDto } from '../dto/bulk-remove-permissions.dto';
import { Permission } from '../entities/permission.entity';
import { Role } from '../entities/role.entity';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { TenantGuard } from '../../../shared/guards/tenant.guard';
import { TenantAwareRequest } from '../../../shared/middleware/tenant-resolution.middleware';
import { Request } from 'express';

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
@Controller('iam/roles')
export class RoleController {
  constructor(
    private readonly roleService: RoleService,
    private readonly permissionService: PermissionService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all roles for current company' })
  @ApiOkResponse({ description: 'List of roles', type: [Role] })
  async findAll(
    @Req() req: AuthenticatedRequest,
    @Query('companyId') companyId?: string,
  ): Promise<Role[]> {
    const roles: string[] = req.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit companyId, otherwise fall back to tenant companyId
    const targetCompanyId = isSuperAdmin && companyId
      ? companyId
      : req.companyId!;

    return this.roleService.findAll(targetCompanyId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get role by ID' })
  @ApiOkResponse({ description: 'Role details', type: Role })
  async findOne(
    @Param('id') id: string,
    @Req() req: AuthenticatedRequest,
  ): Promise<Role> {
    return this.roleService.findOne(req.companyId!, id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new role' })
  @ApiCreatedResponse({ description: 'Role created', type: Role })
  async create(
    @Body() dto: CreateRoleDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<Role> {
    const roles: string[] = req.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit company_id, otherwise fall back to tenant companyId
    const targetCompanyId = isSuperAdmin && dto.company_id
      ? dto.company_id
      : req.companyId!;

    return this.roleService.create(targetCompanyId, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a role' })
  @ApiOkResponse({ description: 'Role updated', type: Role })
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateRoleDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<Role> {
    return this.roleService.update(req.companyId!, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a role' })
  @ApiNoContentResponse({ description: 'Role deleted' })
  async delete(
    @Param('id') id: string,
    @Req() req: AuthenticatedRequest,
  ): Promise<void> {
    return this.roleService.delete(req.companyId!, id);
  }

  @Get(':id/permissions')
  @ApiOperation({
    summary: 'Get all permissions for a role',
    description: 'Returns all permissions assigned to the specified role',
  })
  @ApiOkResponse({
    description: 'List of permissions',
    type: [Permission],
  })
  async getRolePermissions(
    @Param('id') roleId: string,
    @Req() req: AuthenticatedRequest,
  ): Promise<Permission[]> {
    return this.permissionService.getRolePermissions(req.companyId!, roleId);
  }

  @Post(':id/permissions')
  @ApiOperation({ summary: 'Assign a permission to a role' })
  @ApiOkResponse({ description: 'Permission assigned to role' })
  async assignPermission(
    @Param('id') roleId: string,
    @Body() dto: AssignPermissionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.permissionService.assignPermissionToRole(
      req.companyId!,
      roleId,
      dto.permissionId,
    );
    return { message: 'Permission assigned to role successfully' };
  }

  @Post(':id/permissions/bulk')
  @ApiOperation({
    summary: 'Bulk assign permissions to a role',
    description: 'Assigns multiple permissions to a role at once',
  })
  @ApiOkResponse({
    description: 'Bulk assignment result',
    schema: {
      type: 'object',
      properties: {
        assigned: { type: 'number' },
        skipped: { type: 'number' },
      },
    },
  })
  async bulkAssignPermissions(
    @Param('id') roleId: string,
    @Body() dto: BulkAssignPermissionsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ assigned: number; skipped: number }> {
    return this.permissionService.bulkAssignPermissionsToRole(
      req.companyId!,
      roleId,
      dto.permissionIds,
    );
  }

  @Delete(':id/permissions/:permissionId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Remove a permission from a role' })
  @ApiNoContentResponse({ description: 'Permission removed from role' })
  async removePermission(
    @Param('id') roleId: string,
    @Param('permissionId') permissionId: string,
    @Req() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.permissionService.removePermissionFromRole(
      req.companyId!,
      roleId,
      permissionId,
    );
  }

  @Delete(':id/permissions/bulk')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Bulk remove permissions from a role',
    description: 'Removes multiple permissions from a role at once',
  })
  @ApiOkResponse({
    description: 'Bulk removal result',
    schema: {
      type: 'object',
      properties: {
        removed: { type: 'number' },
        notFound: { type: 'number' },
      },
    },
  })
  async bulkRemovePermissions(
    @Param('id') roleId: string,
    @Body() dto: BulkRemovePermissionsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ removed: number; notFound: number }> {
    return this.permissionService.bulkRemovePermissionsFromRole(
      req.companyId!,
      roleId,
      dto.permissionIds,
    );
  }
}

