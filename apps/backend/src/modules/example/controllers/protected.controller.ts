import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { PermissionGuard } from '../../iam/guards/permission.guard';
import { RequirePermission } from '../../iam/decorators/require-permission.decorator';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';

@ApiTags('Protected Resources')
@ApiBearerAuth('access-token')
@Controller('protected')
@UseGuards(JwtAuthGuard, PermissionGuard)
export class ProtectedController {
  @Get('users')
  @RequirePermission('user', 'read')
  @ApiOperation({ summary: 'List users (requires user:read permission)' })
  async listUsers(@CurrentUser() user: CurrentUserData) {
    return {
      message: 'Access granted to list users',
      user: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      timestamp: new Date().toISOString(),
    };
  }

  @Get('users/:id')
  @RequirePermission('user', 'read')
  @ApiOperation({ summary: 'Get user by ID (requires user:read permission)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  async getUser(
    @Param('id') id: string,
    @CurrentUser() user: CurrentUserData,
  ) {
    return {
      message: 'Access granted to view user',
      requestedUserId: id,
      currentUser: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      timestamp: new Date().toISOString(),
    };
  }

  @Post('users')
  @RequirePermission('user', 'create')
  @ApiOperation({ summary: 'Create user (requires user:create permission)' })
  async createUser(
    @Body() createDto: { email: string; name: string },
    @CurrentUser() user: CurrentUserData,
  ) {
    return {
      message: 'Access granted to create user',
      data: createDto,
      createdBy: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      timestamp: new Date().toISOString(),
    };
  }

  @Put('users/:id')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Update user (requires user:update permission)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  async updateUser(
    @Param('id') id: string,
    @Body() updateDto: { email?: string; name?: string },
    @CurrentUser() user: CurrentUserData,
  ) {
    return {
      message: 'Access granted to update user',
      userId: id,
      data: updateDto,
      updatedBy: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      timestamp: new Date().toISOString(),
    };
  }

  @Delete('users/:id')
  @RequirePermission('user', 'delete')
  @ApiOperation({ summary: 'Delete user (requires user:delete permission)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  async deleteUser(
    @Param('id') id: string,
    @CurrentUser() user: CurrentUserData,
  ) {
    return {
      message: 'Access granted to delete user',
      userId: id,
      deletedBy: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      timestamp: new Date().toISOString(),
    };
  }

  @Get('reports')
  @RequirePermission('report', 'read')
  @ApiOperation({ summary: 'Access reports (requires report:read permission)' })
  async getReports(@CurrentUser() user: CurrentUserData) {
    return {
      message: 'Access granted to view reports',
      user: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      reports: [],
      timestamp: new Date().toISOString(),
    };
  }

  @Post('reports')
  @RequirePermission('report', 'create')
  @ApiOperation({ summary: 'Create report (requires report:create permission)' })
  async createReport(
    @Body() reportDto: { name: string; type: string },
    @CurrentUser() user: CurrentUserData,
  ) {
    return {
      message: 'Access granted to create report',
      data: reportDto,
      createdBy: {
        id: user.userId,
        email: user.email,
        companyId: user.companyId,
      },
      timestamp: new Date().toISOString(),
    };
  }
}

