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
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { VillaTypeConfigService } from './villa-type-config.service';
import { CreateVillaTypeConfigDto } from './dto/create-villa-type-config.dto';
import { UpdateVillaTypeConfigDto } from './dto/update-villa-type-config.dto';
import { CurrentUser } from '../iam/decorators/current-user.decorator';
import { RequirePermission } from '../iam/decorators/require-permission.decorator';
import { VillaTypeConfig } from './entities/villa-type-config.entity';

@ApiTags('Villa Type Configuration')
@ApiBearerAuth()
@Controller('villa-type-configs')
export class VillaTypeConfigController {
  constructor(
    private readonly configService: VillaTypeConfigService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'Get all villa type configurations',
    description:
      'Returns all active villa type configurations for the company, sorted by display order. Use includeInactive=true to include inactive configs.',
  })
  @ApiQuery({
    name: 'includeInactive',
    required: false,
    type: Boolean,
    description: 'Include inactive configurations',
  })
  @RequirePermission('villa_type_configs', 'read')
  async findAll(
    @CurrentUser('companyId') companyId: string,
    @Query('includeInactive') includeInactive?: string,
  ): Promise<VillaTypeConfig[]> {
    return this.configService.findAll(
      companyId,
      includeInactive === 'true',
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get villa type configuration by ID' })
  @RequirePermission('villa_type_configs', 'read')
  async findOne(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ): Promise<VillaTypeConfig> {
    return this.configService.findOne(companyId, id);
  }

  @Post()
  @ApiOperation({
    summary: 'Create a new villa type configuration',
    description:
      'Creates a new configuration for a villa type with default values. These defaults will be auto-filled when creating villas with this type.',
  })
  @RequirePermission('villa_type_configs', 'create')
  async create(
    @CurrentUser('companyId') companyId: string,
    @Body() dto: CreateVillaTypeConfigDto,
  ): Promise<VillaTypeConfig> {
    return this.configService.create(companyId, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update a villa type configuration' })
  @RequirePermission('villa_type_configs', 'update')
  async update(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
    @Body() dto: UpdateVillaTypeConfigDto,
  ): Promise<VillaTypeConfig> {
    return this.configService.update(companyId, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a villa type configuration' })
  @RequirePermission('villa_type_configs', 'delete')
  async delete(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ): Promise<void> {
    await this.configService.delete(companyId, id);
  }

  @Post(':id/deactivate')
  @ApiOperation({
    summary: 'Deactivate a villa type configuration',
    description:
      'Deactivates a configuration. Inactive configs won\'t appear in dropdowns but existing villas remain valid.',
  })
  @RequirePermission('villa_type_configs', 'update')
  async deactivate(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ): Promise<VillaTypeConfig> {
    return this.configService.deactivate(companyId, id);
  }

  @Post(':id/activate')
  @ApiOperation({ summary: 'Activate a villa type configuration' })
  @RequirePermission('villa_type_configs', 'update')
  async activate(
    @CurrentUser('companyId') companyId: string,
    @Param('id') id: string,
  ): Promise<VillaTypeConfig> {
    return this.configService.activate(companyId, id);
  }
}

