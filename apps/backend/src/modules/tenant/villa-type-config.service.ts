import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VillaTypeConfig } from './entities/villa-type-config.entity';
import { CreateVillaTypeConfigDto } from './dto/create-villa-type-config.dto';
import { UpdateVillaTypeConfigDto } from './dto/update-villa-type-config.dto';

@Injectable()
export class VillaTypeConfigService {
  constructor(
    @InjectRepository(VillaTypeConfig)
    private readonly configRepo: Repository<VillaTypeConfig>,
  ) {}

  /**
   * Get all villa type configurations for a company
   * Returns active configs sorted by display order
   */
  async findAll(companyId: string, includeInactive = false): Promise<VillaTypeConfig[]> {
    const where: any = { companyId };
    if (!includeInactive) {
      where.isActive = true;
    }

    return this.configRepo.find({
      where,
      order: { displayOrder: 'ASC', villaType: 'ASC' },
    });
  }

  /**
   * Get a specific villa type configuration
   */
  async findOne(
    companyId: string,
    id: string,
  ): Promise<VillaTypeConfig> {
    const config = await this.configRepo.findOne({
      where: { companyId, id },
    });

    if (!config) {
      throw new NotFoundException(
        `Villa type configuration with ID ${id} not found`,
      );
    }

    return config;
  }

  /**
   * Get configuration by villa type code
   * Used by VillaService to get defaults when creating villas
   */
  async findByVillaType(
    companyId: string,
    villaType: string,
  ): Promise<VillaTypeConfig | null> {
    return this.configRepo.findOne({
      where: { companyId, villaType, isActive: true },
    });
  }

  /**
   * Get default values for a villa type
   * Returns only the default values, not the full config
   * Used by VillaService for auto-filling
   */
  async getDefaults(
    companyId: string,
    villaType: string,
  ): Promise<{
    defaultBedroomCount?: number;
    defaultFloorCount?: number;
    defaultAreaSqm?: number;
  } | null> {
    const config = await this.findByVillaType(companyId, villaType);
    if (!config) return null;

    return {
      defaultBedroomCount: config.defaultBedroomCount ?? undefined,
      defaultFloorCount: config.defaultFloorCount ?? undefined,
      defaultAreaSqm: config.defaultAreaSqm
        ? Number(config.defaultAreaSqm)
        : undefined,
    };
  }

  /**
   * Create a new villa type configuration
   */
  async create(
    companyId: string,
    dto: CreateVillaTypeConfigDto,
  ): Promise<VillaTypeConfig> {
    // Check for duplicate villa type
    const existing = await this.configRepo.findOne({
      where: { companyId, villaType: dto.villaType },
    });

    if (existing) {
      throw new ConflictException(
        `Villa type configuration for "${dto.villaType}" already exists`,
      );
    }

    const config = this.configRepo.create({
      companyId,
      ...dto,
      displayOrder: dto.displayOrder ?? 0,
      isActive: dto.isActive ?? true,
    });

    return this.configRepo.save(config);
  }

  /**
   * Update a villa type configuration
   */
  async update(
    companyId: string,
    id: string,
    dto: UpdateVillaTypeConfigDto,
  ): Promise<VillaTypeConfig> {
    const config = await this.findOne(companyId, id);

    // If villa type is being changed, check for duplicates
    if (dto.villaType && dto.villaType !== config.villaType) {
      const existing = await this.configRepo.findOne({
        where: { companyId, villaType: dto.villaType },
      });

      if (existing) {
        throw new ConflictException(
          `Villa type configuration for "${dto.villaType}" already exists`,
        );
      }
    }

    Object.assign(config, dto);
    return this.configRepo.save(config);
  }

  /**
   * Delete a villa type configuration
   */
  async delete(companyId: string, id: string): Promise<void> {
    const config = await this.findOne(companyId, id);
    await this.configRepo.remove(config);
  }

  /**
   * Deactivate a configuration (soft delete)
   */
  async deactivate(companyId: string, id: string): Promise<VillaTypeConfig> {
    const config = await this.findOne(companyId, id);
    config.isActive = false;
    return this.configRepo.save(config);
  }

  /**
   * Activate a configuration
   */
  async activate(companyId: string, id: string): Promise<VillaTypeConfig> {
    const config = await this.findOne(companyId, id);
    config.isActive = true;
    return this.configRepo.save(config);
  }
}

