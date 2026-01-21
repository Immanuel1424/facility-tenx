import { Controller, Get, Version, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../auth/decorators/public.decorator';
import { TenantService } from './tenant.service';

@ApiTags('public-lookup')
@Controller('public/lookup')
export class PublicLookupController {
  constructor(private readonly tenantService: TenantService) {}

  @Public()
  @Get('companies')
  @Version('1')
  @ApiOperation({
    summary: 'Public: Get list of companies without authentication',
    description:
      'Returns a simplified list of all companies for pre-login flows like company selection. Includes id, code, and name.',
  })
  @ApiOkResponse({
    description: 'List of companies retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string', format: 'uuid' },
          code: { type: 'string', example: 'ALOS' },
          name: { type: 'string', example: 'Villa Maintenance Company' },
        },
      },
    },
  })
  async getPublicCompanies(): Promise<Array<{ id: string; code: string; name: string }>> {
    const companies = await this.tenantService.listCompanies();
    // Return simplified format for dropdowns
    // Filter out SYSTEM company from public lookup for security
    return companies
      .filter((company) => company.code !== 'SYSTEM')
      .map((company) => ({
        id: company.id,
        code: company.code,
        name: company.name,
      }));
  }

  @Public()
  @Get('villas')
  @Version('1')
  @ApiOperation({
    summary: 'Public: Get list of villas (sites) without authentication',
    description:
      'Returns a simplified list of all sites/villas for pre-login flows like site selection. Includes id, code, and name.',
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
  async getPublicVillas(@Query('companyId') companyId?: string): Promise<Array<{ id: string; code: string; name: string }>> {
    const sites = await this.tenantService.listSites(companyId);
    // Return simplified format for dropdowns
    return sites.map((site) => ({
      id: site.id,
      code: site.code,
      name: site.name,
    }));
  }
}


