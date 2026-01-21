import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
  Version,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { 
  ApiBearerAuth, 
  ApiOperation, 
  ApiParam, 
  ApiTags,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiNotFoundResponse,
  ApiBadRequestResponse,
  ApiConflictResponse,
} from '@nestjs/swagger';
import { TenantService } from './tenant.service';
import { UserSiteService } from './services/user-site.service';
import { CreateCompanyDto } from './dto/create-company.dto';
import { UpdateCompanyDto } from './dto/update-company.dto';
import { CreateSiteDto } from './dto/create-site.dto';
import { UpdateSiteDto } from './dto/update-site.dto';
import { CreateSpaceCategoryDto } from './dto/create-space-category.dto';
import { UpdateSpaceCategoryDto } from './dto/update-space-category.dto';
import { TenantGuard } from '../../shared/guards/tenant.guard';
import { JwtAuthGuard } from '../../modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../shared/guards/roles.guard';
import { Roles } from '../../shared/decorators/roles.decorator';
import { CurrentTenant } from '../../shared/decorators/current-tenant.decorator';
import { TenantAwareRequest } from '../../shared/middleware/tenant-resolution.middleware';
import { UserResponseDto } from '../user/dto/user-response.dto';
import { plainToInstance } from 'class-transformer';

@ApiTags('tenant')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard, RolesGuard)
@Controller('tenants')
export class TenantController {
  constructor(
    private readonly tenantService: TenantService,
    private readonly userSiteService: UserSiteService,
  ) {}

  @Post('companies')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ summary: 'Create company for current tenant' })
  async createCompany(
    @Body() dto: CreateCompanyDto,
  ) {
    // Companies are top-level entities, no tenant scoping required
    return this.tenantService.createCompany(dto);
  }

  @Get('companies')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ summary: 'List all companies' })
  async listCompanies(): Promise<import('./entities/company.entity').Company[]> {
    // Companies are top-level entities, no tenant scoping required
    return this.tenantService.listCompanies();
  }

  @Get('companies/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ summary: 'Get company by ID' })
  @ApiParam({ 
    name: 'id', 
    description: 'Company UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Company retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string' },
        name: { type: 'string' },
        description: { type: 'string', nullable: true },
        logoUrl: { type: 'string', nullable: true },
        timezone: { type: 'string', nullable: true },
        currency: { type: 'string', nullable: true },
        isActive: { type: 'boolean' },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Company not found' })
  async getCompanyById(@Param('id') id: string) {
    return this.tenantService.getCompanyById(id);
  }

  @Patch('companies/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ summary: 'Update company' })
  @ApiParam({ 
    name: 'id', 
    description: 'Company UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Company updated successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string' },
        name: { type: 'string' },
        description: { type: 'string', nullable: true },
        logoUrl: { type: 'string', nullable: true },
        timezone: { type: 'string', nullable: true },
        currency: { type: 'string', nullable: true },
        isActive: { type: 'boolean' },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiBadRequestResponse({ description: 'Invalid input or validation error' })
  @ApiNotFoundResponse({ description: 'Company not found' })
  @ApiConflictResponse({ description: 'Company code already exists' })
  async updateCompany(
    @Param('id') id: string,
    @Body() dto: UpdateCompanyDto,
  ) {
    return this.tenantService.updateCompany(id, dto);
  }

  @Post('companies/:companyId/roles/default')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({
    summary: 'Create default roles for an existing company',
    description:
      'Creates default roles (ADMIN, TENANT, TECHNICIAN, SITE_COORDINATOR, SUPERVISOR) for an existing company. Only creates roles that do not already exist.',
  })
  @ApiParam({
    name: 'companyId',
    description: 'Company UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiOkResponse({
    description: 'Default roles created successfully',
    schema: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          example: 'Default roles created successfully for company',
        },
        companyId: { type: 'string', format: 'uuid' },
      },
    },
  })
  @ApiNotFoundResponse({ description: 'Company not found' })
  async createDefaultRolesForCompany(
    @Param('companyId') companyId: string,
  ): Promise<{ message: string; companyId: string }> {
    await this.tenantService.createDefaultRolesForCompany(companyId);
    return {
      message: 'Default roles created successfully for company',
      companyId,
    };
  }

  @Delete('companies/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({
    summary: 'Delete company',
    description:
      'Deletes a company. Cannot delete companies that have sites. All sites must be deleted or reassigned first.',
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Company UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Company deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Company deleted successfully' }
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Company not found' })
  @ApiBadRequestResponse({ description: 'Cannot delete company with sites' })
  async deleteCompany(@Param('id') id: string) {
    await this.tenantService.deleteCompany(id);
    return { message: 'Company deleted successfully' };
  }

  @Post('sites')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ 
    summary: 'Create a new site',
    description: 'Creates a new site. Code can be auto-generated from name if not provided. Parent sites cannot have a parentSiteId, child sites must have a valid parentSiteId.'
  })
  @ApiCreatedResponse({ 
    description: 'Site created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
        code: { type: 'string', example: 'NEWYO', description: 'Site code (3-5 uppercase letters)' },
        name: { type: 'string', example: 'New York Headquarters' },
        isParent: { type: 'boolean', example: true },
        parentSiteId: { type: 'string', format: 'uuid', nullable: true },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiBadRequestResponse({ description: 'Invalid input or validation error' })
  @ApiConflictResponse({ description: 'Site code already exists' })
  async createSite(
    @Body() dto: CreateSiteDto,
    @Req() req: TenantAwareRequest,
  ) {
    const roles: string[] = (req as any)?.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit companyId, otherwise fall back to tenant companyId
    const targetCompanyId = isSuperAdmin && dto.companyId
      ? dto.companyId
      : req.companyId;

    return this.tenantService.createSite(dto, targetCompanyId);
  }

  @Get('sites')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ 
    summary: 'List all sites',
    description: 'Returns a list of all sites with their parent and child relationships. Sites are ordered by code.'
  })
  @ApiOkResponse({ 
    description: 'List of sites retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string', example: 'NEWYO' },
          name: { type: 'string', example: 'New York Headquarters' },
          isParent: { type: 'boolean', example: true },
          parentSite: { 
            type: 'object',
            nullable: true,
            properties: {
              id: { type: 'string', format: 'uuid' },
              code: { type: 'string' },
              name: { type: 'string' },
            }
          },
          childSites: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                id: { type: 'string', format: 'uuid' },
                code: { type: 'string' },
                name: { type: 'string' },
              }
            }
          },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        }
      }
    }
  })
  async listSites(
    @Query('companyId') companyId?: string,
    @Req() req?: TenantAwareRequest,
  ): Promise<import('./entities/site.entity').Site[]> {
    const roles: string[] = (req as any)?.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    // SUPER_ADMIN can optionally pass an explicit companyId, otherwise fetch all sites (global view)
    if (isSuperAdmin) {
      return this.tenantService.listSites(companyId);
    }

    // Non-super-admin users (ADMIN, MANAGER, etc.) must be strictly scoped to their own company
    const tenantCompanyId = req?.companyId;
    if (!tenantCompanyId) {
      throw new BadRequestException('Tenant company context is required');
    }

    // Ignore query param for non-super-admins to prevent cross-company access
    return this.tenantService.listSites(tenantCompanyId);
  }

  @Get('companies/:companyId/sites')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ 
    summary: 'List sites for a specific company',
    description: 'Returns a list of all sites for the specified company, ordered by code.'
  })
  @ApiParam({ 
    name: 'companyId', 
    description: 'Company UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'List of sites retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string', example: 'NEWYO' },
          name: { type: 'string', example: 'New York Headquarters' },
          isParent: { type: 'boolean', example: true },
          parentSite: { 
            type: 'object',
            nullable: true,
            properties: {
              id: { type: 'string', format: 'uuid' },
              code: { type: 'string' },
              name: { type: 'string' },
            }
          },
          childSites: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                id: { type: 'string', format: 'uuid' },
                code: { type: 'string' },
                name: { type: 'string' },
              }
            }
          },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        }
      }
    }
  })
  async listSitesForCompany(
    @Param('companyId') companyId: string,
    @Req() req?: TenantAwareRequest,
  ) {
    const roles: string[] = (req as any)?.user?.roles ?? [];
    const isSuperAdmin = roles.some(
      (role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN',
    );

    if (!isSuperAdmin) {
      const tenantCompanyId = req?.companyId;
      if (!tenantCompanyId) {
        throw new BadRequestException('Tenant company context is required');
      }
      if (tenantCompanyId !== companyId) {
        throw new ForbiddenException(
          'You are not allowed to access sites for another company',
        );
      }
    }

    return this.tenantService.listSites(companyId);
  }

  @Get('sites/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ 
    summary: 'Get site by ID',
    description: 'Retrieves a single site by its UUID, including parent and child site relationships.'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Site UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Site retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string', example: 'NEWYO' },
        name: { type: 'string', example: 'New York Headquarters' },
        isParent: { type: 'boolean', example: true },
        parentSite: { 
          type: 'object',
          nullable: true,
          properties: {
            id: { type: 'string', format: 'uuid' },
            code: { type: 'string' },
            name: { type: 'string' },
          }
        },
        childSites: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string', format: 'uuid' },
              code: { type: 'string' },
              name: { type: 'string' },
            }
          }
        },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Site not found' })
  async getSiteById(@Param('id') id: string) {
    return this.tenantService.getSiteById(id);
  }

  @Patch('sites/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ 
    summary: 'Update site',
    description: 'Updates site properties. All fields are optional. When changing isParent from true to false, parentSiteId must be provided. Prevents circular references and validates parent-child relationships.'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Site UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Site updated successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string', example: 'UPDAT' },
        name: { type: 'string', example: 'Updated Site Name' },
        isParent: { type: 'boolean', example: true },
        parentSite: { 
          type: 'object',
          nullable: true,
          properties: {
            id: { type: 'string', format: 'uuid' },
            code: { type: 'string' },
            name: { type: 'string' },
          }
        },
        childSites: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string', format: 'uuid' },
              code: { type: 'string' },
              name: { type: 'string' },
            }
          }
        },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiBadRequestResponse({ description: 'Invalid input, validation error, or business rule violation' })
  @ApiNotFoundResponse({ description: 'Site not found' })
  @ApiConflictResponse({ description: 'Site code already exists' })
  async updateSite(
    @Param('id') id: string,
    @Body() dto: UpdateSiteDto,
  ) {
    return this.tenantService.updateSite(id, dto);
  }

  @Delete('sites/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ 
    summary: 'Delete site',
    description: 'Deletes a site. Cannot delete sites that have child sites. Child sites must be deleted or reassigned first.'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Site UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Site deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Site deleted successfully' }
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Site not found' })
  @ApiBadRequestResponse({ description: 'Cannot delete site with child sites' })
  async deleteSite(@Param('id') id: string) {
    await this.tenantService.deleteSite(id);
    return { message: 'Site deleted successfully' };
  }

  // Space Category CRUD endpoints

  @Post('space-categories')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ 
    summary: 'Create space category',
    description: 'Creates a new space category for categorizing spaces within sites. Code will be auto-generated from name if not provided (3-5 uppercase letters).'
  })
  @ApiCreatedResponse({ 
    description: 'Space category created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
        code: { type: 'string', example: 'OFFIC', description: 'Category code (3-5 uppercase letters)' },
        name: { type: 'string', example: 'Office Space' },
        description: { type: 'string', nullable: true, example: 'Standard office workspace' },
        isActive: { type: 'boolean', example: true },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiBadRequestResponse({ description: 'Invalid input or validation error' })
  @ApiConflictResponse({ description: 'Space category code already exists' })
  async createSpaceCategory(@Body() dto: CreateSpaceCategoryDto) {
    return this.tenantService.createSpaceCategory(dto);
  }

  @Get('space-categories')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ 
    summary: 'List all space categories',
    description: 'Returns a list of all space categories, ordered by code.'
  })
  @ApiOkResponse({ 
    description: 'List of space categories retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string', example: 'OFFIC' },
          name: { type: 'string', example: 'Office Space' },
          description: { type: 'string', nullable: true },
          isActive: { type: 'boolean', example: true },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        }
      }
    }
  })
  async listSpaceCategories(): Promise<import('./entities/space-category.entity').SpaceCategory[]> {
    return this.tenantService.listSpaceCategories();
  }

  @Get('space-categories/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER')
  @ApiOperation({ 
    summary: 'Get space category by ID',
    description: 'Retrieves a single space category by its UUID.'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Space category UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Space category retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string', example: 'OFFIC' },
        name: { type: 'string', example: 'Office Space' },
        description: { type: 'string', nullable: true },
        isActive: { type: 'boolean', example: true },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Space category not found' })
  async getSpaceCategoryById(@Param('id') id: string) {
    return this.tenantService.getSpaceCategoryById(id);
  }

  @Patch('space-categories/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ 
    summary: 'Update space category',
    description: 'Updates space category properties. All fields are optional.'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Space category UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Space category updated successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string', example: 'OFFIC' },
        name: { type: 'string', example: 'Updated Office Space' },
        description: { type: 'string', nullable: true },
        isActive: { type: 'boolean', example: true },
        createdAt: { type: 'string', format: 'date-time' },
        updatedAt: { type: 'string', format: 'date-time' },
      }
    }
  })
  @ApiBadRequestResponse({ description: 'Invalid input or validation error' })
  @ApiNotFoundResponse({ description: 'Space category not found' })
  @ApiConflictResponse({ description: 'Space category code already exists' })
  async updateSpaceCategory(
    @Param('id') id: string,
    @Body() dto: UpdateSpaceCategoryDto,
  ) {
    return this.tenantService.updateSpaceCategory(id, dto);
  }

  @Delete('space-categories/:id')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({ 
    summary: 'Delete space category',
    description: 'Deletes a space category.'
  })
  @ApiParam({ 
    name: 'id', 
    description: 'Space category UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String
  })
  @ApiOkResponse({ 
    description: 'Space category deleted successfully',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Space category deleted successfully' }
      }
    }
  })
  @ApiNotFoundResponse({ description: 'Space category not found' })
  async deleteSpaceCategory(@Param('id') id: string) {
    await this.tenantService.deleteSpaceCategory(id);
    return { message: 'Space category deleted successfully' };
  }

  // Space endpoints
  @Get('spaces')
  @ApiOperation({
    summary: 'List all spaces',
    description: 'Returns a list of all active spaces, optionally filtered by site or space category.',
  })
  @ApiOkResponse({
    description: 'List of spaces retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string', example: 'OFF-101' },
          name: { type: 'string', example: 'Office 101' },
          siteId: { type: 'string', format: 'uuid', nullable: true },
          spaceCategoryId: { type: 'string', format: 'uuid', nullable: true },
          description: { type: 'string', nullable: true },
          isActive: { type: 'boolean' },
        },
      },
    },
  })
  async listSpaces(
    @Query('siteId') siteId?: string,
    @Query('spaceCategoryId') spaceCategoryId?: string,
    @Req() req?: TenantAwareRequest,
  ) {
    return this.tenantService.listSpaces(req!.companyId!, siteId, spaceCategoryId);
  }

  @Get('spaces/:id')
  @ApiOperation({
    summary: 'Get space by ID',
    description: 'Retrieves a single space by its UUID.',
  })
  @ApiParam({
    name: 'id',
    description: 'Space UUID',
    type: 'string',
    format: 'uuid',
  })
  @ApiOkResponse({
    description: 'Space retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string', format: 'uuid' },
        code: { type: 'string', example: 'OFF-101' },
        name: { type: 'string', example: 'Office 101' },
        siteId: { type: 'string', format: 'uuid', nullable: true },
        spaceCategoryId: { type: 'string', format: 'uuid', nullable: true },
        description: { type: 'string', nullable: true },
        isActive: { type: 'boolean' },
      },
    },
  })
  @ApiNotFoundResponse({ description: 'Space not found' })
  async getSpaceById(@Param('id') id: string, @Req() req?: TenantAwareRequest) {
    return this.tenantService.getSpaceById(req!.companyId!, id);
  }

  @Post('sites/:siteId/users/:userId')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({
    summary: 'Assign a user to a site',
    description:
      'Assigns an existing user to a site. Users must be assigned to at least one site to login (unless SUPER_ADMIN).',
  })
  @ApiParam({
    name: 'siteId',
    description: 'Site UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiParam({
    name: 'userId',
    description: 'User UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiOkResponse({
    description: 'User assigned to site successfully',
    schema: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          example: 'User assigned to site successfully',
        },
        siteId: { type: 'string', format: 'uuid' },
        userId: { type: 'string', format: 'uuid' },
      },
    },
  })
  @ApiNotFoundResponse({
    description: 'Site or user not found',
  })
  async assignUserToSite(
    @Param('siteId') siteId: string,
    @Param('userId') userId: string,
    @Req() req?: TenantAwareRequest,
  ): Promise<{ message: string; siteId: string; userId: string }> {
    await this.userSiteService.assignUserToSite(
      req!.companyId!,
      userId,
      siteId,
    );
    return {
      message: 'User assigned to site successfully',
      siteId,
      userId,
    };
  }

  @Delete('sites/:siteId/users/:userId')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({
    summary: 'Remove a user from a site',
    description:
      'Removes a user from a site. User will no longer be able to login to this site.',
  })
  @ApiParam({
    name: 'siteId',
    description: 'Site UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiParam({
    name: 'userId',
    description: 'User UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiOkResponse({
    description: 'User removed from site successfully',
    schema: {
      type: 'object',
      properties: {
        message: {
          type: 'string',
          example: 'User removed from site successfully',
        },
      },
    },
  })
  @ApiNotFoundResponse({
    description: 'User-site assignment not found',
  })
  async removeUserFromSite(
    @Param('siteId') siteId: string,
    @Param('userId') userId: string,
    @Req() req?: TenantAwareRequest,
  ): Promise<{ message: string }> {
    await this.userSiteService.removeUserFromSite(
      req!.companyId!,
      userId,
      siteId,
    );
    return {
      message: 'User removed from site successfully',
    };
  }

  @Get('sites/:siteId/users')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'SITE_COORDINATOR')
  @ApiOperation({
    summary: 'Get all users assigned to a site',
    description: 'Returns a list of all users assigned to the specified site.',
  })
  @ApiParam({
    name: 'siteId',
    description: 'Site UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiOkResponse({
    description: 'List of users assigned to site',
    type: [UserResponseDto],
  })
  async getSiteUsers(
    @Param('siteId') siteId: string,
    @Req() req?: TenantAwareRequest,
  ): Promise<UserResponseDto[]> {
    const users = await this.userSiteService.getSiteUsers(
      req!.companyId!,
      siteId,
    );
    return plainToInstance(UserResponseDto, users, {
      excludeExtraneousValues: true,
    });
  }

  @Get('users/:userId/sites')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN')
  @ApiOperation({
    summary: 'Get all sites assigned to a user',
    description:
      'Returns a list of all sites that the specified user is assigned to.',
  })
  @ApiParam({
    name: 'userId',
    description: 'User UUID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: String,
  })
  @ApiOkResponse({
    description: 'List of sites assigned to user',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string' },
          name: { type: 'string' },
          companyId: { type: 'string', format: 'uuid' },
          isActive: { type: 'boolean' },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        },
      },
    },
  })
  async getUserSites(
    @Param('userId') userId: string,
    @Req() req?: TenantAwareRequest,
  ) {
    return this.userSiteService.getUserSites(req!.companyId!, userId);
  }
}


