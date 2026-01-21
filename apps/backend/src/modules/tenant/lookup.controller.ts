import {
  Controller,
  Get,
  Query,
  UseGuards,
  Version,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
  ApiTags,
  ApiQuery,
} from '@nestjs/swagger';
import { TenantGuard } from '../../shared/guards/tenant.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../shared/guards/roles.guard';
import { Roles } from '../../shared/decorators/roles.decorator';
import { CurrentUser } from '../iam/decorators/current-user.decorator';
import { CurrentUserData } from '../iam/decorators/current-user.decorator';
import { TenantService } from './tenant.service';
import { UserService } from '../iam/services/user.service';
import { VillaTypeConfigService } from './villa-type-config.service';
import { CityLocationService } from './services/city-location.service';

@ApiTags('lookup')
@ApiBearerAuth('access-token')
@UseGuards(JwtAuthGuard, TenantGuard, RolesGuard)
@Controller('lookup')
export class LookupController {
  constructor(
    private readonly tenantService: TenantService,
    private readonly userService: UserService,
    private readonly villaTypeConfigService: VillaTypeConfigService,
    private readonly cityLocationService: CityLocationService,
  ) {}

  @Get('villas')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER', 'USER')
  @ApiOperation({
    summary: 'Get list of villas (sites)',
    description:
      'Returns a simplified list of all sites/villas for dropdown selection. Includes id, code, and name.',
  })
  @ApiOkResponse({
    description: 'List of villas retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string', example: 'VIL01' },
          name: { type: 'string', example: 'Villa 1' },
        },
      },
    },
  })
  async getVillas(
    @CurrentUser() currentUser: CurrentUserData,
  ): Promise<Array<{ id: string; code: string; name: string }>> {
    // Scope villas/sites list to the current user's company to prevent cross-company leakage
    const sites = await this.tenantService.listSites(currentUser.companyId);
    // Return simplified format for dropdowns
    return sites.map((site) => ({
      id: site.id,
      code: site.code,
      name: site.name,
    }));
  }

  @Get('technicians')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER', 'USER')
  @ApiOperation({
    summary: 'Get list of technicians',
    description:
      'Returns a simplified list of active technicians for dropdown selection. Includes id, name, email, and initials.',
  })
  @ApiQuery({
    name: 'siteId',
    required: false,
    description: 'Optional site ID to filter technicians by site',
    type: String,
  })
  @ApiOkResponse({
    description: 'List of technicians retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          email: { type: 'string' },
          firstName: { type: 'string', nullable: true },
          lastName: { type: 'string', nullable: true },
          fullName: { type: 'string' },
          initials: { type: 'string' },
        },
      },
    },
  })
  async getTechnicians(
    @CurrentUser() currentUser: CurrentUserData,
    @Query('siteId') siteId?: string,
  ): Promise<Array<{
    id: string;
    email: string;
    firstName?: string;
    lastName?: string;
    fullName: string;
    initials: string;
  }>> {
    const technicians = await this.userService.findTechnicians(
      currentUser.companyId,
      siteId,
    );

    // Return simplified format with computed fields for dropdowns
    return technicians.map((tech) => {
      const firstName = tech.firstName || '';
      const lastName = tech.lastName || '';
      const fullName = [firstName, lastName]
        .filter((n) => n.trim().length > 0)
        .join(' ')
        .trim() || tech.email;

      // Generate initials
      const firstInitial = firstName.length > 0 ? firstName[0].toUpperCase() : '';
      const lastInitial = lastName.length > 0 ? lastName[0].toUpperCase() : '';
      const initials =
        firstInitial && lastInitial
          ? `${firstInitial}${lastInitial}`
          : tech.email.substring(0, 2).toUpperCase();

      return {
        id: tech.id,
        email: tech.email,
        firstName: tech.firstName,
        lastName: tech.lastName,
        fullName,
        initials,
      };
    });
  }

  @Get('villa-types')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER', 'USER')
  @ApiOperation({
    summary: 'Get list of villa types with default values',
    description:
      'Returns all active villa type configurations with their default bedroom count, floor count, and area. Used for dropdowns and auto-filling villa forms.',
  })
  @ApiOkResponse({
    description: 'List of villa types retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          villaType: { type: 'string', example: '1BHK' },
          displayName: { type: 'string', nullable: true, example: '1 Bedroom Hall Kitchen' },
          defaultBedroomCount: { type: 'number', nullable: true, example: 1 },
          defaultFloorCount: { type: 'number', nullable: true, example: 1 },
          defaultAreaSqm: { type: 'number', nullable: true, example: 50.5 },
          displayOrder: { type: 'number', example: 0 },
        },
      },
    },
  })
  async getVillaTypes(
    @CurrentUser() currentUser: CurrentUserData,
  ): Promise<Array<{
    id: string;
    villaType: string;
    displayName?: string;
    defaultBedroomCount?: number;
    defaultFloorCount?: number;
    defaultAreaSqm?: number;
    displayOrder: number;
  }>> {
    const configs = await this.villaTypeConfigService.findAll(
      currentUser.companyId,
      false, // Only active
    );

    return configs.map((config) => ({
      id: config.id,
      villaType: config.villaType,
      displayName: config.displayName ?? undefined,
      defaultBedroomCount: config.defaultBedroomCount ?? undefined,
      defaultFloorCount: config.defaultFloorCount ?? undefined,
      defaultAreaSqm: config.defaultAreaSqm
        ? Number(config.defaultAreaSqm)
        : undefined,
      displayOrder: config.displayOrder,
    }));
  }

  @Get('cities')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER', 'USER')
  @ApiOperation({
    summary: 'Get list of cities',
    description:
      'Returns all active cities for dropdown selection. Used in villa address forms.',
  })
  @ApiOkResponse({
    description: 'List of cities retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string', example: 'Dubai' },
          code: { type: 'string', nullable: true, example: 'DXB' },
          country: { type: 'string', nullable: true, example: 'UAE' },
          region: { type: 'string', nullable: true, example: 'Dubai' },
          locationDescription: { type: 'string', nullable: true, example: 'coast' },
          displayOrder: { type: 'number', example: 0 },
        },
      },
    },
  })
  async getCities(): Promise<Array<{
    id: string;
    name: string;
    code?: string;
    country?: string;
    region?: string;
    locationDescription?: string;
    displayOrder: number;
  }>> {
    const cities = await this.cityLocationService.findAllCities();
    return cities.map((city) => ({
      id: city.id,
      name: city.name,
      code: city.code ?? undefined,
      country: city.country ?? undefined,
      region: city.region ?? undefined,
      locationDescription: city.locationDescription ?? undefined,
      displayOrder: city.displayOrder,
    }));
  }

  @Get('locations')
  @Version('1')
  @Roles('SUPER_ADMIN', 'ADMIN', 'MANAGER', 'USER')
  @ApiOperation({
    summary: 'Get list of locations',
    description:
      'Returns all active locations (areas/neighborhoods) for dropdown selection. Can be filtered by cityId. Used in villa address forms.',
  })
  @ApiQuery({
    name: 'cityId',
    required: false,
    description: 'Optional city ID to filter locations by city',
    type: String,
  })
  @ApiOkResponse({
    description: 'List of locations retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          cityId: { type: 'string', format: 'uuid' },
          name: { type: 'string', example: 'Downtown Dubai' },
          code: { type: 'string', nullable: true, example: 'DTD' },
          country: { type: 'string', nullable: true, example: 'UAE' },
          region: { type: 'string', nullable: true, example: 'Dubai' },
          cityName: { type: 'string', nullable: true, example: 'Dubai' },
          displayOrder: { type: 'number', example: 0 },
        },
      },
    },
  })
  async getLocations(
    @Query('cityId') cityId?: string,
  ): Promise<Array<{
    id: string;
    cityId: string;
    name: string;
    code?: string;
    country?: string;
    region?: string;
    cityName?: string;
    displayOrder: number;
  }>> {
    const locations = cityId
      ? await this.cityLocationService.findLocationsByCity(cityId)
      : await this.cityLocationService.findAllLocations();

    return locations.map((location) => ({
      id: location.id,
      cityId: location.cityId,
      name: location.name,
      code: location.code ?? undefined,
      country: location.city?.country ?? undefined,
      region: location.city?.region ?? undefined,
      cityName: location.city?.name ?? undefined,
      displayOrder: location.displayOrder,
    }));
  }
}

