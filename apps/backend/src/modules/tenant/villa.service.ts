import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Villa } from './entities/villa.entity';
import { User } from '../iam/entities/user.entity';
import { VillaTypeConfigService } from './villa-type-config.service';

export interface CreateVillaDto {
  villaNumber: string;
  villaCode?: string;
  siteId?: string;
  spaceId?: string;
  ownerName?: string;
  tenantName?: string;
  contactPhone?: string;
  contactEmail?: string;
  block?: string;
  street?: string;
  city?: string;
  pinCode?: string;
  makaniNumber?: string;
  poBox?: string;
  isActive?: boolean;
  isOccupied?: boolean;
  floorCount?: number;
  bedroomCount?: number;
  bathroomCount?: number;
  areaSqm?: number;
  villaType?: string;
  buildingName?: string;
  openFrom?: Date | string;
  unitNo?: string;
  unitName?: string;
  primaryView?: string;
  unitCategory?: string;
  floor?: string;
  parkingSlotNumber?: string;
  meterNumber?: string;
  waterMeterNumber?: string;
  measure?: string;
  externalArea?: string;
  remarks?: string;
}

export interface UpdateVillaDto extends Partial<CreateVillaDto> {}

@Injectable()
export class VillaService {
  constructor(
    @InjectRepository(Villa)
    private readonly villaRepo: Repository<Villa>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly villaTypeConfigService: VillaTypeConfigService,
  ) {}

  async findAll(companyId: string): Promise<Villa[]> {
    const villas = await this.villaRepo.find({
      where: { companyId },
      order: { villaNumber: 'ASC' },
      relations: ['site', 'space'],
    });

    // Ensure occupancy status is accurate by checking actual user assignments
    await this.ensureOccupancyAccuracy(companyId, villas);

    return villas;
  }

  async findActive(companyId: string): Promise<Villa[]> {
    return this.villaRepo.find({
      where: { companyId, isActive: true },
      order: { villaNumber: 'ASC' },
    });
  }

  async findAvailable(companyId: string): Promise<Villa[]> {
    // Get all active villas that are not occupied
    const activeVillas = await this.villaRepo.find({
      where: { companyId, isActive: true, isOccupied: false },
      order: { villaNumber: 'ASC' },
    });

    // Get all villa numbers that are already assigned to users
    const usersWithVillas = await this.userRepo.find({
      where: { companyId },
      select: ['villaNumber', 'villaNumbers'],
    });

    const assignedVillaNumbers = new Set<string>();
    usersWithVillas.forEach((user) => {
      if (user.villaNumber) {
        assignedVillaNumbers.add(user.villaNumber.toString());
      }
      if (user.villaNumbers && Array.isArray(user.villaNumbers)) {
        user.villaNumbers.forEach((num) => assignedVillaNumbers.add(num.toString()));
      }
    });

    // Filter out villas that are assigned to users
    return activeVillas.filter(
      (villa) => !assignedVillaNumbers.has(villa.villaNumber),
    );
  }

  async findOne(companyId: string, id: string): Promise<Villa> {
    const villa = await this.villaRepo.findOne({
      where: { companyId, id },
      relations: ['site', 'space'],
    });

    if (!villa) {
      throw new NotFoundException(`Villa with ID ${id} not found`);
    }

    // Ensure occupancy status is accurate by checking actual user assignments
    await this.ensureOccupancyAccuracy(companyId, [villa]);

    return villa;
  }

  async findByVillaNumber(companyId: string, villaNumber: string): Promise<Villa | null> {
    return this.villaRepo.findOne({
      where: { companyId, villaNumber },
    });
  }

  async create(companyId: string, dto: CreateVillaDto): Promise<Villa> {
    // Check for duplicate villa number
    const existing = await this.findByVillaNumber(companyId, dto.villaNumber);
    if (existing) {
      throw new ConflictException(`Villa number ${dto.villaNumber} already exists`);
    }

    // Auto-fill defaults from villa type configuration if villa type is provided
    // Only fill if the field is not already provided (allow manual override)
    const defaults = dto.villaType
      ? await this.villaTypeConfigService.getDefaults(companyId, dto.villaType)
      : null;

    const villa = this.villaRepo.create({
      companyId,
      ...dto,
      // Auto-fill defaults only if not provided in DTO
      bedroomCount: dto.bedroomCount ?? defaults?.defaultBedroomCount,
      floorCount: dto.floorCount ?? defaults?.defaultFloorCount,
      areaSqm: dto.areaSqm ?? defaults?.defaultAreaSqm,
    });

    return this.villaRepo.save(villa);
  }

  async update(companyId: string, id: string, dto: UpdateVillaDto): Promise<Villa> {
    const villa = await this.findOne(companyId, id);

    // If villa number is being changed, check for duplicates
    if (dto.villaNumber && dto.villaNumber !== villa.villaNumber) {
      const existing = await this.findByVillaNumber(companyId, dto.villaNumber);
      if (existing) {
        throw new ConflictException(`Villa number ${dto.villaNumber} already exists`);
      }
    }

    Object.assign(villa, dto);
    return this.villaRepo.save(villa);
  }

  async delete(companyId: string, id: string): Promise<void> {
    const villa = await this.findOne(companyId, id);
    await this.villaRepo.remove(villa);
  }

  async deactivate(companyId: string, id: string): Promise<Villa> {
    const villa = await this.findOne(companyId, id);
    villa.isActive = false;
    return this.villaRepo.save(villa);
  }

  async activate(companyId: string, id: string): Promise<Villa> {
    const villa = await this.findOne(companyId, id);
    villa.isActive = true;
    return this.villaRepo.save(villa);
  }

  /**
   * Sync villa occupancy status based on actual user assignments
   * This ensures isOccupied reflects whether tenants are actually assigned
   */
  async syncVillaOccupancy(companyId: string, villaNumber: string): Promise<void> {
    const villa = await this.findByVillaNumber(companyId, villaNumber);
    if (!villa) {
      return;
    }

    // Check if any user has this villa number assigned
    const usersWithVilla = await this.userRepo.find({
      where: [
        { companyId, villaNumber },
        {
          companyId,
          villaNumbers: villaNumber as any, // TypeORM JSONB array contains check
        },
      ],
    });

    // Also check villaNumbers JSONB array using raw query for proper JSONB contains
    const usersWithVillaInArray = await this.userRepo
      .createQueryBuilder('user')
      .where('user.companyId = :companyId', { companyId })
      .andWhere('user.villaNumbers @> :villaNumber', {
        villaNumber: JSON.stringify([villaNumber]),
      })
      .getMany();

    const allUsers = [...new Set([...usersWithVilla, ...usersWithVillaInArray])];
    const isOccupied = allUsers.length > 0;

    if (villa.isOccupied !== isOccupied) {
      villa.isOccupied = isOccupied;
      await this.villaRepo.save(villa);
    }
  }

  /**
   * Sync occupancy status for all villas in a company
   * Useful for fixing existing data that may be out of sync
   */
  async syncAllVillaOccupancy(companyId: string): Promise<{
    total: number;
    updated: number;
    errors: number;
  }> {
    const villas = await this.villaRepo.find({
      where: { companyId },
    });

    let updated = 0;
    let errors = 0;

    // Get all users with villa assignments
    const users = await this.userRepo.find({
      where: { companyId },
      select: ['villaNumber', 'villaNumbers'],
    });

    // Build a set of all assigned villa numbers
    const assignedVillaNumbers = new Set<string>();
    users.forEach((user) => {
      if (user.villaNumber) {
        assignedVillaNumbers.add(user.villaNumber.toString());
      }
      if (user.villaNumbers && Array.isArray(user.villaNumbers)) {
        user.villaNumbers.forEach((num) => {
          if (num) {
            assignedVillaNumbers.add(num.toString());
          }
        });
      }
    });

    // Update each villa
    for (const villa of villas) {
      try {
        const shouldBeOccupied = assignedVillaNumbers.has(villa.villaNumber);
        if (villa.isOccupied !== shouldBeOccupied) {
          villa.isOccupied = shouldBeOccupied;
          await this.villaRepo.save(villa);
          updated++;
        }
      } catch (error) {
        console.error(
          `Error syncing villa ${villa.villaNumber}:`,
          error,
        );
        errors++;
      }
    }

    return {
      total: villas.length,
      updated,
      errors,
    };
  }

  /**
   * Ensure villa occupancy accuracy by checking actual user assignments
   * This is a safety net to ensure API responses are always correct
   * even if database values are temporarily out of sync
   * Also populates tenant information from User table when villa is occupied
   */
  private async ensureOccupancyAccuracy(
    companyId: string,
    villas: Villa[],
  ): Promise<void> {
    if (villas.length === 0) {
      return;
    }

    // Get all users with villa assignments for this company
    // Include tenant information fields
    const users = await this.userRepo.find({
      where: { companyId },
      select: [
        'id',
        'villaNumber',
        'villaNumbers',
        'firstName',
        'lastName',
        'phoneNumber',
        'email',
      ],
    });

    // Build map of villa number to user(s) for quick lookup
    const villaToUserMap = new Map<string, User[]>();
    users.forEach((user) => {
      // Handle single villa number
      if (user.villaNumber) {
        const villaNum = user.villaNumber.toString();
        if (!villaToUserMap.has(villaNum)) {
          villaToUserMap.set(villaNum, []);
        }
        villaToUserMap.get(villaNum)!.push(user);
      }
      // Handle multiple villa numbers
      if (user.villaNumbers && Array.isArray(user.villaNumbers)) {
        user.villaNumbers.forEach((num) => {
          if (num) {
            const villaNum = num.toString();
            if (!villaToUserMap.has(villaNum)) {
              villaToUserMap.set(villaNum, []);
            }
            villaToUserMap.get(villaNum)!.push(user);
          }
        });
      }
    });

    // Update villa objects in memory (don't save to DB to avoid unnecessary writes)
    // This ensures the API response is correct even if DB is temporarily out of sync
    villas.forEach((villa) => {
      const assignedUsers = villaToUserMap.get(villa.villaNumber) || [];
      const shouldBeOccupied = assignedUsers.length > 0;

      if (villa.isOccupied !== shouldBeOccupied) {
        // Update in memory for this response
        villa.isOccupied = shouldBeOccupied;
        // Optionally sync to DB in background (non-blocking)
        this.syncVillaOccupancy(companyId, villa.villaNumber).catch((error) => {
          console.error(
            `Failed to sync villa ${villa.villaNumber} occupancy:`,
            error,
          );
        });
      }

      // Populate tenant information from User table when villa is occupied
      if (shouldBeOccupied && assignedUsers.length > 0) {
        // Use the first user (primary tenant) if multiple users are assigned
        const primaryUser = assignedUsers[0];
        
        // Populate tenant name from firstName and lastName
        if (primaryUser.firstName || primaryUser.lastName) {
          const fullName = [
            primaryUser.firstName,
            primaryUser.lastName,
          ]
            .filter(Boolean)
            .join(' ')
            .trim();
          if (fullName) {
            villa.tenantName = fullName;
          }
        }

        // Populate contact phone
        if (primaryUser.phoneNumber) {
          villa.contactPhone = primaryUser.phoneNumber;
        }

        // Populate contact email
        if (primaryUser.email) {
          villa.contactEmail = primaryUser.email;
        }
      }
    });
  }
}

