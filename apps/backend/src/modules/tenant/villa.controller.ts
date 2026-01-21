import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { VillaService, CreateVillaDto, UpdateVillaDto } from './villa.service';
import { CurrentUser, CurrentUserData } from '../iam/decorators/current-user.decorator';
import { RequirePermission } from '../iam/decorators/require-permission.decorator';

@ApiTags('Villas')
@ApiBearerAuth()
@Controller('villas')
export class VillaController {
  constructor(private readonly villaService: VillaService) {}

  @Get()
  @ApiOperation({ summary: 'Get all villas' })
  @RequirePermission('villas', 'read')
  async findAll(@CurrentUser('companyId') companyId: string) {
    return this.villaService.findAll(companyId);
  }

  @Get('active')
  @ApiOperation({ summary: 'Get active villas only' })
  @RequirePermission('villas', 'read')
  async findActive(@CurrentUser('companyId') companyId: string) {
    return this.villaService.findActive(companyId);
  }

  @Get('available')
  @ApiOperation({ 
    summary: 'Get available villas for tenant assignment',
    description: 'Returns active villas that are not occupied and not assigned to any user',
  })
  @RequirePermission('villas', 'read')
  async findAvailable(@CurrentUser('companyId') companyId: string) {
    return this.villaService.findAvailable(companyId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get villa by ID' })
  @RequirePermission('villas', 'read')
  async findOne(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ) {
    return this.villaService.findOne(companyId, id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new villa' })
  @RequirePermission('villas', 'create')
  async create(
    @CurrentUser('companyId') companyId: string,
    @Body() dto: CreateVillaDto,
  ) {
    return this.villaService.create(companyId, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a villa' })
  @RequirePermission('villas', 'update')
  async update(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
    @Body() dto: UpdateVillaDto,
  ) {
    return this.villaService.update(companyId, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a villa' })
  @RequirePermission('villas', 'delete')
  async delete(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ) {
    await this.villaService.delete(companyId, id);
  }

  @Post(':id/deactivate')
  @ApiOperation({ summary: 'Deactivate a villa' })
  @RequirePermission('villas', 'update')
  async deactivate(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ) {
    return this.villaService.deactivate(companyId, id);
  }

  @Post(':id/activate')
  @ApiOperation({ summary: 'Activate a villa' })
  @RequirePermission('villas', 'update')
  async activate(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ) {
    return this.villaService.activate(companyId, id);
  }

  @Post('sync-occupancy')
  @ApiOperation({
    summary: 'Sync villa occupancy status',
    description: 'Syncs all villa occupancy statuses based on actual tenant assignments. Useful for fixing data inconsistencies.',
  })
  @RequirePermission('villas', 'update')
  async syncOccupancy(@CurrentUser('companyId') companyId: string) {
    const result = await this.villaService.syncAllVillaOccupancy(companyId);
    return {
      message: 'Villa occupancy synced successfully',
      ...result,
    };
  }
}

