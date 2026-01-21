import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Patch,
  Delete,
  Query,
  Req,
  UseGuards,
  Version,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags, ApiOkResponse } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { plainToInstance } from 'class-transformer';
import { UserService } from '../iam/services/user.service';
import { PermissionGuard } from '../iam/guards/permission.guard';
import { RequirePermission } from '../iam/decorators/require-permission.decorator';
import { CurrentUser } from '../iam/decorators/current-user.decorator';
import { CurrentUserData } from '../iam/decorators/current-user.decorator';
import { TenantGuard } from '../../shared/guards/tenant.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UserResponseDto } from './dto/user-response.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { QueryUserDto } from './dto/query-user.dto';
import { EmailService } from '../auth/services/email.service';
import { NotificationService } from '../notification/notification.service';
import { TemplateSeedService } from '../notification/services/template-seed.service';
import { NotificationSeverity } from '../notification/enums/notification-severity.enum';
import { TenantAwareRequest } from '../../shared/middleware/tenant-resolution.middleware';
import { UserSiteService } from '../tenant/services/user-site.service';
import { TenantService } from '../tenant/tenant.service';

@ApiTags('users')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('users')
export class UserController {
  constructor(
    private readonly userService: UserService,
    private readonly emailService: EmailService,
    private readonly notificationService: NotificationService,
    private readonly templateSeedService: TemplateSeedService,
    private readonly userSiteService: UserSiteService,
    private readonly tenantService: TenantService,
    private readonly configService: ConfigService,
  ) {}

  @Get()
  @Version('1')
  @RequirePermission('user', 'read')
  @ApiOperation({ summary: 'Get all users in the current company' })
  @ApiOkResponse({
    description: 'List of users retrieved successfully',
    type: [UserResponseDto],
  })
  async getUsers(
    @CurrentUser() currentUser: CurrentUserData,
    @Query() queryDto: QueryUserDto,
    @Req() req?: TenantAwareRequest,
  ): Promise<UserResponseDto[]> {
    const roles: string[] = (req as any)?.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit companyId, otherwise fetch all users (global view)
    // Non-super-admin users are strictly scoped to their own company
    const targetCompanyId = isSuperAdmin
      ? queryDto.companyId
      : currentUser.companyId;

    const users = await this.userService.findAll(
      targetCompanyId,
      {
        role: queryDto.role,
        status: queryDto.status,
      },
    );
    return plainToInstance(UserResponseDto, users, {
      excludeExtraneousValues: true,
    });
  }

  @Post()
  @Version('1')
  @RequirePermission('user', 'create')
  @ApiOperation({ summary: 'Create a user in the current company' })
  @ApiOkResponse({
    description: 'User created successfully',
    type: UserResponseDto,
  })
  async createUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Body() dto: CreateUserDto,
    @Req() req?: TenantAwareRequest,
  ): Promise<UserResponseDto> {
    const roles: string[] = (req as any)?.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit companyId, otherwise fall back to tenant companyId
    const targetCompanyId = isSuperAdmin && dto.companyId
      ? dto.companyId
      : currentUser.companyId;

    const user = await this.userService.createUserFromDto(
      targetCompanyId,
      {
        email: dto.email,
        password: dto.password,
        firstName: dto.firstName,
        lastName: dto.lastName,
        villaNumber: dto.villaNumber,
        villaNumbers: dto.villaNumbers,
        status: dto.status,
        employeeId: dto.employeeId,
        designation: dto.designation,
        joiningDate: dto.joiningDate,
        emergencyContactName: dto.emergencyContactName,
        emergencyContactPhone: dto.emergencyContactPhone,
        notes: dto.notes,
        roleId: dto.roleId,
        departmentId: dto.departmentId,
      },
    );

    // Automatically assign user to site for ALL users except SUPER_ADMIN
    // This ensures users can log in without manual site assignment
    const userRoles = await this.userService.getUserRoles(targetCompanyId, user.id);
    const isUserSuperAdmin = userRoles.some(
      (r) => r.name.toUpperCase() === 'SUPER_ADMIN',
    );

    // Declare siteIdToAssign in outer scope so it's available for email sending logic
    let siteIdToAssign: string | undefined = dto.siteId;

    // Skip site assignment for SUPER_ADMIN users (they can login without site context)
    if (!isUserSuperAdmin) {

      // If no siteId provided, try to determine one:
      // 1. Use current user's site (if available)
      // 2. Fall back to first active site in company
      if (!siteIdToAssign) {
        // Try current user's site first
        const currentUserSiteId = currentUser.siteId;
        if (currentUserSiteId) {
          siteIdToAssign = currentUserSiteId;
        } else {
          // Fall back to first active site in the company
          const sites = await this.tenantService.listSites(targetCompanyId);
          const activeSite = sites.find((s) => s.isActive);
          if (activeSite) {
            siteIdToAssign = activeSite.id;
            console.log(
              `[UserController] No siteId provided, using first active site: ${activeSite.code} (${activeSite.id})`,
            );
          }
        }
      }

      // Assign user to site (mandatory for non-SUPER_ADMIN users)
      if (siteIdToAssign) {
        try {
          await this.userSiteService.assignUserToSite(
            targetCompanyId,
            user.id,
            siteIdToAssign,
          );
          console.log(
            `[UserController] Automatically assigned user ${user.id} to site ${siteIdToAssign}`,
          );
        } catch (error) {
          // Site assignment is mandatory - fail user creation if it fails
          const errorMessage =
            error instanceof Error ? error.message : String(error);
          console.error(
            `[UserController] Failed to assign user to site: ${errorMessage}`,
          );
          throw new BadRequestException(
            `Failed to assign user to site: ${errorMessage}. User creation aborted.`,
          );
        }
      } else {
        // No site available - this is a critical error for non-SUPER_ADMIN users
        throw new BadRequestException(
          `Cannot create user: No site available for assignment. ` +
            `Please provide a siteId or ensure the company has at least one active site.`,
        );
      }
    } else {
      console.log(
        `[UserController] Skipping site assignment for SUPER_ADMIN user ${user.id}`,
      );
    }

    // Send credentials via email if requested (side effect handled in controller)
    if (dto.sendCredentialsViaEmail) {
      // Ensure email template exists
      await this.templateSeedService.seedEmailTemplates(targetCompanyId);

      // Get company code (let enrichment method handle if not found)
      let companyCode: string | undefined;
      try {
        const company = await this.tenantService.getCompanyById(targetCompanyId);
        companyCode = company.code;
      } catch (error) {
        console.warn(`Company not found for companyId: ${targetCompanyId}`);
        // Don't set companyCode - let enrichment method fetch it
      }

      // Get site code if siteId is available (let enrichment method handle if not found)
      let siteCode: string | undefined;
      if (siteIdToAssign) {
        try {
          const site = await this.tenantService.getSiteById(siteIdToAssign);
          siteCode = site.code;
        } catch (error) {
          // If site not found, don't set siteCode - let enrichment method handle it
          console.warn(`Site not found for siteId: ${siteIdToAssign}`);
        }
      }

      // Get frontend URL (without any query parameters)
      let loginUrl = '';
      try {
        const frontendUrl = this.configService.get<string>('FRONTEND_URL');
        if (frontendUrl) {
          // Only use the frontend URL without any appended parameters
          loginUrl = frontendUrl;
        }
      } catch (error) {
        console.error('Failed to get frontend URL:', error);
        // Continue without login URL if generation fails
      }

      // Prepare variables object - only include companyCode and siteCode if they have values
      const variables: Record<string, unknown> = {
        firstName: user.firstName || 'User',
        email: user.email,
        password: dto.password,
        loginUrl: loginUrl,
        recipient: {
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
        },
      };

      // Only add companyCode and siteCode if they have values
      // Otherwise, let the enrichment method fetch them
      if (companyCode) {
        variables.companyCode = companyCode;
      }
      if (siteCode) {
        variables.siteCode = siteCode;
      }
      // Pass siteId so enrichment can fetch siteCode if needed
      if (siteIdToAssign) {
        variables.siteId = siteIdToAssign;
      }

      // Send email using template system
      await this.notificationService.publishEvent({
        type: 'user_created',
        companyId: targetCompanyId,
        recipientUserId: user.id,
        severity: NotificationSeverity.INFO,
        templateCode: 'user_created',
        variables,
        channels: ['email'],
      });
    }

    const userWithVillas = await this.userService.getUserWithVillas(
      targetCompanyId,
      user.id,
    );

    return plainToInstance(UserResponseDto, userWithVillas, {
      excludeExtraneousValues: true,
    });
  }

  @Get('technicians')
  @Version('1')
  @RequirePermission('user', 'read')
  @ApiOperation({ 
    summary: 'Get list of technicians',
    description: 'Returns a list of active users with technician, maintenance, or staff roles for assignment. Technicians are independent - no filtering by team, site, or department. Returns all technicians for the company.'
  })
  @ApiOkResponse({
    description: 'List of technicians retrieved successfully',
    type: [UserResponseDto],
  })
  async getTechnicians(
    @CurrentUser() currentUser: CurrentUserData,
    @Query('siteId') siteId?: string, // Optional, deprecated - technicians are independent, not filtered by site
  ): Promise<UserResponseDto[]> {
    // siteId parameter is accepted for backward compatibility but ignored
    // Technicians are loaded independently without any filters (team, site, department)
    const technicians = await this.userService.findTechnicians(
      currentUser.companyId,
      siteId,
    );
    return plainToInstance(UserResponseDto, technicians, {
      excludeExtraneousValues: true,
    });
  }

  @Get('me')
  @Version('1')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiOkResponse({
    description: 'Current user profile retrieved successfully',
    type: UserResponseDto,
  })
  async getCurrentUser(
    @CurrentUser() currentUser: CurrentUserData,
  ): Promise<UserResponseDto> {
    const userWithVillas = await this.userService.getUserWithVillas(
      currentUser.companyId,
      currentUser.userId,
    );
    
    // Debug: Log the raw user data
    console.log('🔍 Raw user data:', {
      firstName: userWithVillas.firstName,
      lastName: userWithVillas.lastName,
      phoneNumber: userWithVillas.phoneNumber,
      alternatePhoneNumber: userWithVillas.alternatePhoneNumber,
      leaseExpiryDate: userWithVillas.leaseExpiryDate,
    });
    
    const dto = plainToInstance(UserResponseDto, userWithVillas, {
      excludeExtraneousValues: true,
      exposeDefaultValues: true,
    });
    
    // Debug: Log the transformed DTO
    console.log('🔍 Transformed DTO:', {
      firstName: dto.firstName,
      lastName: dto.lastName,
      phoneNumber: dto.phoneNumber,
      alternatePhoneNumber: dto.alternatePhoneNumber,
      leaseExpiryDate: dto.leaseExpiryDate,
    });
    
    return dto;
  }

  @Get(':id')
  @Version('1')
  @RequirePermission('user', 'read')
  @ApiOperation({ summary: 'Get a user by id in the current company' })
  @ApiOkResponse({
    description: 'User retrieved successfully',
    type: UserResponseDto,
  })
  async getUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
    @Req() req?: TenantAwareRequest,
  ): Promise<UserResponseDto> {
    const roles: string[] = (req as any)?.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit companyId via x-company-id header
    // Check header directly since middleware might override it with JWT companyId
    const headerCompanyId = req?.headers?.['x-company-id'] as string | undefined;
    
    console.log('[getUser] Debug info:', {
      userId: id,
      isSuperAdmin,
      headerCompanyId,
      currentUserCompanyId: currentUser.companyId,
      reqCompanyId: req?.companyId,
    });

    const targetCompanyId = isSuperAdmin && headerCompanyId
      ? headerCompanyId
      : currentUser.companyId;

    console.log('[getUser] Using companyId:', targetCompanyId);

    let user = await this.userService.findById(targetCompanyId, id);
    
    // For SUPER_ADMIN, if user not found in specified company, try searching globally (by ID only)
    if (!user && isSuperAdmin) {
      console.log('[getUser] User not found in specified company, searching globally for SUPER_ADMIN');
      user = await this.userService.findByIdWithoutCompany(id);
    }
    
    if (!user) {
      console.log('[getUser] User not found:', { targetCompanyId, userId: id, isSuperAdmin });
      throw new NotFoundException('User not found');
    }
    return plainToInstance(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }

  @Put(':id')
  @Version('1')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Update a user in the current company' })
  @ApiOkResponse({
    description: 'User updated successfully',
    type: UserResponseDto,
  })
  async updateUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
    @Body() dto: UpdateUserDto,
  ): Promise<UserResponseDto> {
    const user = await this.userService.updateUserFromDto(
      currentUser.companyId,
      id,
      {
        email: dto.email,
        firstName: dto.firstName,
        lastName: dto.lastName,
        status: dto.status,
        villaNumber: dto.villaNumber,
        villaNumbers: dto.villaNumbers,
        roleId: dto.roleId,
        departmentId: dto.departmentId,
      },
    );
    return plainToInstance(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }

  @Patch(':id/activate')
  @Version('1')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Activate a user' })
  @ApiOkResponse({
    description: 'User activated successfully',
    type: UserResponseDto,
  })
  async activateUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
  ): Promise<UserResponseDto> {
    const user = await this.userService.activate(currentUser.companyId, id);
    return plainToInstance(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }

  @Patch(':id/deactivate')
  @Version('1')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Deactivate a user' })
  @ApiOkResponse({
    description: 'User deactivated successfully',
    type: UserResponseDto,
  })
  async deactivateUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
  ): Promise<UserResponseDto> {
    const user = await this.userService.deactivate(currentUser.companyId, id);
    return plainToInstance(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }

  @Post(':id/reset-password')
  @Version('1')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Reset password for a user' })
  @ApiOkResponse({
    description: 'Password reset successfully',
  })
  async resetPassword(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
    @Body() dto: ResetPasswordDto,
  ): Promise<{ message: string }> {
    await this.userService.resetPassword(
      currentUser.companyId,
      id,
      dto.newPassword,
    );
    return { message: 'Password reset successfully' };
  }

  @Post('me/change-password')
  @Version('1')
  @ApiOperation({ summary: 'Change password for current user' })
  @ApiOkResponse({
    description: 'Password changed successfully',
  })
  async changePassword(
    @CurrentUser() currentUser: CurrentUserData,
    @Body() dto: ChangePasswordDto,
  ): Promise<{ message: string }> {
    await this.userService.changePassword(
      currentUser.companyId,
      currentUser.userId,
      dto.currentPassword,
      dto.newPassword,
    );
    return { message: 'Password changed successfully' };
  }

  @Post(':id/roles')
  @Version('1')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Assign a role to a user' })
  @ApiOkResponse({
    description: 'Role assigned successfully',
  })
  async assignRole(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') userId: string,
    @Body() body: { roleId: string },
  ): Promise<{ message: string }> {
    await this.userService.assignRole(
      currentUser.companyId,
      userId,
      body.roleId,
    );
    return { message: 'Role assigned successfully' };
  }

  @Delete(':id/roles/:roleId')
  @Version('1')
  @RequirePermission('user', 'update')
  @ApiOperation({ summary: 'Remove a role from a user' })
  @ApiOkResponse({
    description: 'Role removed successfully',
  })
  async removeRole(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') userId: string,
    @Param('roleId') roleId: string,
  ): Promise<{ message: string }> {
    await this.userService.removeRole(
      currentUser.companyId,
      userId,
      roleId,
    );
    return { message: 'Role removed successfully' };
  }

  @Delete(':id')
  @Version('1')
  @RequirePermission('user', 'delete')
  @ApiOperation({ summary: 'Delete a user (soft delete - marks as deleted)' })
  @ApiOkResponse({
    description: 'User deleted successfully',
    type: UserResponseDto,
  })
  async deleteUser(
    @CurrentUser() currentUser: CurrentUserData,
    @Param('id') id: string,
  ): Promise<UserResponseDto> {
    // Soft delete - marks user as deleted with deletedAt timestamp
    const user = await this.userService.delete(currentUser.companyId, id);
    return plainToInstance(UserResponseDto, user, {
      excludeExtraneousValues: true,
    });
  }
}


