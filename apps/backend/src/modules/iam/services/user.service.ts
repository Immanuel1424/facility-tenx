import { Injectable, NotFoundException, BadRequestException, Inject, forwardRef, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, IsNull, Not } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { plainToInstance } from 'class-transformer';
import { User, UserStatus, AuthProvider } from '../entities/user.entity';
import { UserRole } from '../entities/user-role.entity';
import { Role } from '../entities/role.entity';
import { VillaService } from '../../tenant/villa.service';

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(UserRole)
    private readonly userRoleRepository: Repository<UserRole>,
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
    @Inject(forwardRef(() => VillaService))
    private readonly villaService: VillaService,
  ) {}

  async findByEmail(companyId: string, email: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { 
        companyId, 
        email,
        deletedAt: IsNull(), // Only find active users (exclude soft-deleted)
      },
      relations: ['userRoles', 'userRoles.role'],
    });
  }

  async findById(companyId: string, userId: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { companyId, id: userId },
      relations: ['userRoles', 'userRoles.role'],
    });
  }

  /**
   * Find user by ID without company filter (for SUPER_ADMIN only)
   */
  async findByIdWithoutCompany(userId: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { id: userId },
      relations: ['userRoles', 'userRoles.role'],
    });
  }

  async findByExternalId(
    companyId: string,
    externalId: string,
    provider: AuthProvider,
  ): Promise<User | null> {
    return this.userRepository.findOne({
      where: { companyId, externalId, authProvider: provider },
      relations: ['userRoles', 'userRoles.role'],
    });
  }

  async validatePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  async createLocalUser(
    companyId: string,
    email: string,
    password: string,
    firstName?: string,
    lastName?: string,
    villaNumber?: string,
    villaNumbers?: string[],
    status?: UserStatus,
    metadata?: {
      employeeId?: string;
      designation?: string;
      joiningDate?: Date;
      emergencyContactName?: string;
      emergencyContactPhone?: string;
      notes?: string;
      [key: string]: unknown;
    },
  ): Promise<User> {
    // Check if email already exists (only active users)
    const existing = await this.findByEmail(companyId, email);
    if (existing) {
      throw new BadRequestException('User with this email already exists');
    }

    // Optional: Log if soft-deleted user exists with same email (for audit purposes)
    const deletedUser = await this.userRepository.findOne({
      where: {
        companyId,
        email,
        deletedAt: Not(IsNull()),
      },
    });
    if (deletedUser) {
      this.logger.warn(
        `New user created with email ${email} previously used by soft-deleted user ${deletedUser.id} (company: ${companyId})`,
      );
    }

    // Combine legacy single number and new array
    let allVillaNumbers: string[] = [];
    if (villaNumbers && villaNumbers.length > 0) {
      allVillaNumbers = [...villaNumbers];
    } else if (villaNumber) {
      allVillaNumbers = [villaNumber];
    }
    
    // Ensure uniqueness within the list
    allVillaNumbers = [...new Set(allVillaNumbers)];

    // Sync primary villa number
    const primaryVillaNumber = allVillaNumbers.length > 0 ? allVillaNumbers[0] : null;

    // Check if primary villa number is already assigned (using legacy unique index)
    if (primaryVillaNumber) {
      const existingVilla = await this.userRepository.findOne({
        where: { companyId, villaNumber: primaryVillaNumber },
      });
      if (existingVilla) {
        throw new BadRequestException(
          `Villa number ${primaryVillaNumber} is already assigned to another user`,
        );
      }
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const user = this.userRepository.create({
      companyId,
      email,
      passwordHash,
      firstName,
      lastName,
      villaNumber: primaryVillaNumber ?? undefined,
      villaNumbers: allVillaNumbers.length > 0 ? allVillaNumbers : undefined,
      status: status ?? UserStatus.ACTIVE,
      authProvider: AuthProvider.LOCAL,
      providerMetadata: metadata && Object.keys(metadata).length > 0 ? metadata : undefined,
    });

    const savedUser = await this.userRepository.save(user);

    // Sync villa occupancy status when user is created with villa number
    if (primaryVillaNumber) {
      await this.syncVillaOccupancy(companyId, primaryVillaNumber, true);
    }

    return savedUser;
  }

  async createOrUpdateOidcUser(
    companyId: string,
    externalId: string,
    provider: AuthProvider,
    email: string,
    metadata: {
      firstName?: string;
      lastName?: string;
      emailVerified?: boolean;
      [key: string]: unknown;
    },
  ): Promise<User> {
    let user = await this.findByExternalId(companyId, externalId, provider);

    if (user) {
      user.email = email;
      user.firstName = metadata.firstName || user.firstName;
      user.lastName = metadata.lastName || user.lastName;
      user.providerMetadata = metadata;
      user.lastLoginAt = new Date();
      return this.userRepository.save(user);
    }

    user = this.userRepository.create({
      companyId,
      email,
      externalId,
      authProvider: provider,
      firstName: metadata.firstName,
      lastName: metadata.lastName,
      providerMetadata: metadata,
      status: UserStatus.ACTIVE,
      lastLoginAt: new Date(),
    });

    return this.userRepository.save(user);
  }

  async assignRole(
    companyId: string,
    userId: string,
    roleId: string,
  ): Promise<UserRole> {
    const role = await this.roleRepository.findOne({
      where: { companyId, id: roleId },
    });

    if (!role) {
      throw new NotFoundException(`Role ${roleId} not found`);
    }

    const existing = await this.userRoleRepository.findOne({
      where: { companyId, userId, roleId },
    });

    if (existing) {
      return existing;
    }

    const userRole = this.userRoleRepository.create({
      companyId,
      userId,
      roleId,
    });

    return this.userRoleRepository.save(userRole);
  }

  async getUserRoles(companyId: string, userId: string): Promise<Role[]> {
    const userRoles = await this.userRoleRepository.find({
      where: { companyId, userId },
      relations: ['role'],
    });

    return userRoles.map((ur) => ur.role);
  }

  async updateLastLogin(companyId: string, userId: string): Promise<void> {
    await this.userRepository.update(
      { companyId, id: userId },
      { lastLoginAt: new Date() },
    );
  }

  async findTechnicians(companyId: string, siteId?: string): Promise<User[]> {
    // siteId parameter is kept for backward compatibility but is not used
    // Technicians are independent and not filtered by site, team, or department
    const queryBuilder = this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.userRoles', 'userRole')
      .leftJoinAndSelect('userRole.role', 'role')
      .where('user.companyId = :companyId', { companyId })
      .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
      .andWhere(
        "(role.name ILIKE :technicianRole OR role.name ILIKE :maintenanceRole OR role.name ILIKE :staffRole)",
        {
          technicianRole: '%TECHNICIAN%',
          maintenanceRole: '%MAINTENANCE%',
          staffRole: '%STAFF%',
        },
      );

    // Technicians are independent - no filtering by siteId, team, or department
    // Returns all active technicians with technician/maintenance/staff roles for the company

    return queryBuilder
      .orderBy('user.firstName', 'ASC')
      .addOrderBy('user.lastName', 'ASC')
      .getMany();
  }

  async findAdmins(companyId: string): Promise<User[]> {
    const queryBuilder = this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.userRoles', 'userRole')
      .leftJoinAndSelect('userRole.role', 'role')
      .where('user.companyId = :companyId', { companyId })
      .andWhere('user.status = :status', { status: UserStatus.ACTIVE })
      .andWhere('user.deleted_at IS NULL')
      .andWhere('role.name = :adminRole', { adminRole: 'ADMIN' });

    return queryBuilder
      .orderBy('user.firstName', 'ASC')
      .addOrderBy('user.lastName', 'ASC')
      .getMany();
  }

  async findAll(
    companyId?: string,
    filters?: { role?: string; status?: string },
  ): Promise<User[]> {
    const queryBuilder = this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.userRoles', 'userRole')
      .leftJoinAndSelect('userRole.role', 'role');

    if (companyId) {
      queryBuilder.where('user.companyId = :companyId', { companyId });
    }

    // Always exclude deleted users (users with deleted_at set) - never show them
    queryBuilder.andWhere('user.deleted_at IS NULL');

    // Apply status filter if provided
    if (filters?.status) {
      queryBuilder.andWhere('user.status = :status', {
        status: filters.status,
      });
    }
    // If no status filter provided, return all non-deleted users
    // (active + inactive + suspended)

    if (filters?.role) {
      queryBuilder.andWhere('role.name = :roleName', {
        roleName: filters.role,
      });
    }

    return queryBuilder
      .orderBy('user.createdAt', 'DESC')
      .getMany();
  }

  async update(
    companyId: string,
    userId: string,
    userData: Partial<User>,
  ): Promise<User> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Check email uniqueness if email is being changed
    if (userData.email && userData.email !== user.email) {
      const existing = await this.findByEmail(companyId, userData.email);
      if (existing) {
        throw new BadRequestException('User with this email already exists');
      }
    }

    // Track old villa number for occupancy sync
    const oldVillaNumber = user.villaNumber;

    // Check villa number uniqueness if villa number is being changed
    if (
      userData.villaNumber !== undefined &&
      userData.villaNumber !== user.villaNumber
    ) {
      const existingVilla = await this.userRepository.findOne({
        where: { companyId, villaNumber: userData.villaNumber },
      });
      if (existingVilla && existingVilla.id !== userId) {
        throw new BadRequestException(
          `Villa number ${userData.villaNumber} is already assigned to another user`,
        );
      }
    }

    Object.assign(user, userData);
    const savedUser = await this.userRepository.save(user);

    // Sync villa occupancy status when villa number changes
    const newVillaNumber = user.villaNumber;
    if (oldVillaNumber !== newVillaNumber) {
      // Set old villa as vacant if it was assigned
      if (oldVillaNumber) {
        await this.syncVillaOccupancy(companyId, oldVillaNumber, false);
      }
      // Set new villa as occupied if assigned
      if (newVillaNumber) {
        await this.syncVillaOccupancy(companyId, newVillaNumber, true);
      }
    }

    return savedUser;
  }

  async activate(companyId: string, userId: string): Promise<User> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    user.status = UserStatus.ACTIVE;
    return this.userRepository.save(user);
  }

  async deactivate(companyId: string, userId: string): Promise<User> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    user.status = UserStatus.INACTIVE;
    return this.userRepository.save(user);
  }

  async delete(companyId: string, userId: string): Promise<User> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Track villa number before deletion to sync occupancy
    const villaNumber = user.villaNumber;

    // Mark as deleted by setting deletedAt timestamp
    // Keep status as INACTIVE to distinguish from regular inactive users
    user.status = UserStatus.INACTIVE;
    user.deletedAt = new Date();
    const savedUser = await this.userRepository.save(user);

    // Set villa as vacant when user is deleted
    if (villaNumber) {
      await this.syncVillaOccupancy(companyId, villaNumber, false);
    }

    return savedUser;
  }

  async resetPassword(
    companyId: string,
    userId: string,
    newPassword: string,
  ): Promise<void> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);
    user.passwordHash = passwordHash;
    await this.userRepository.save(user);
  }

  async changePassword(
    companyId: string,
    userId: string,
    currentPassword: string,
    newPassword: string,
  ): Promise<void> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.authProvider !== AuthProvider.LOCAL) {
      throw new BadRequestException(
        'Password change is only allowed for local accounts',
      );
    }

    const isMatch = await bcrypt.compare(currentPassword, user.passwordHash || '');
    if (!isMatch) {
      throw new BadRequestException('Current password is incorrect');
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);
    user.passwordHash = passwordHash;
    await this.userRepository.save(user);
  }

  async removeRole(
    companyId: string,
    userId: string,
    roleId: string,
  ): Promise<void> {
    const userRole = await this.userRoleRepository.findOne({
      where: { companyId, userId, roleId },
    });

    if (userRole) {
      await this.userRoleRepository.remove(userRole);
    }
  }

  async removeAllRoles(companyId: string, userId: string): Promise<void> {
    const userRoles = await this.userRoleRepository.find({
      where: { companyId, userId },
    });

    if (userRoles.length > 0) {
      await this.userRoleRepository.remove(userRoles);
    }
  }

  async assignDepartment(
    companyId: string,
    userId: string,
    departmentId: string,
  ): Promise<void> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    user.departmentId = departmentId;
    await this.userRepository.save(user);
  }

  async removeDepartment(companyId: string, userId: string): Promise<void> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    user.departmentId = undefined;
    await this.userRepository.save(user);
  }

  /**
   * Parse user status from string to UserStatus enum
   */
  private parseUserStatus(status?: string): UserStatus | undefined {
    if (!status) return undefined;
    const statusUpper = status.toUpperCase();
    if (Object.values(UserStatus).includes(statusUpper as UserStatus)) {
      return statusUpper as UserStatus;
    }
    return undefined;
  }

  /**
   * Build user metadata object from DTO
   */
  private buildUserMetadata(dto: {
    employeeId?: string;
    designation?: string;
    joiningDate?: Date;
    emergencyContactName?: string;
    emergencyContactPhone?: string;
    notes?: string;
  }): Record<string, unknown> | undefined {
    const metadata: Record<string, unknown> = {};
    if (dto.employeeId) metadata.employeeId = dto.employeeId;
    if (dto.designation) metadata.designation = dto.designation;
    if (dto.joiningDate) metadata.joiningDate = dto.joiningDate;
    if (dto.emergencyContactName) metadata.emergencyContactName = dto.emergencyContactName;
    if (dto.emergencyContactPhone) metadata.emergencyContactPhone = dto.emergencyContactPhone;
    if (dto.notes) metadata.notes = dto.notes;
    return Object.keys(metadata).length > 0 ? metadata : undefined;
  }

  /**
   * Get user villas from user_villas join table
   */
  async getUserVillas(
    companyId: string,
    userId: string,
  ): Promise<Array<{
    id: string;
    villaNumber: string;
    villaCode?: string | null;
    name?: string | null;
  }>> {
    const rawVillas: Array<{
      id: string;
      villa_number: string;
      villa_code: string | null;
      name: string | null;
    }> = await this.userRepository.query(
      `
        SELECT DISTINCT v.id,
               v.villa_number,
               v.villa_code,
               v.tenant_name AS name
        FROM user_villas uv
        JOIN villas v
          ON v.id = uv.villa_id
         AND v.company_id = uv.company_id
        WHERE uv.company_id = $1
          AND uv.user_id = $2
      `,
      [companyId, userId],
    );

    return rawVillas.map((v) => ({
      id: v.id,
      villaNumber: v.villa_number,
      villaCode: v.villa_code,
      name: v.name,
    }));
  }

  /**
   * Get user with villas information
   */
  async getUserWithVillas(
    companyId: string,
    userId: string,
  ): Promise<User & {
    villas?: Array<{
      id: string;
      villaNumber: string;
      villaCode?: string | null;
      name?: string | null;
    }>;
  }> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const villas = await this.getUserVillas(companyId, userId);
    return {
      ...user,
      villas: villas.length > 0 ? villas : undefined,
    };
  }

  /**
   * Normalize villa numbers array (combine single and array, ensure uniqueness)
   */
  private normalizeVillaNumbers(
    villaNumber?: string,
    villaNumbers?: string[],
  ): string[] {
    let allVillaNumbers: string[] = [];
    if (villaNumbers && villaNumbers.length > 0) {
      allVillaNumbers = [...villaNumbers];
    } else if (villaNumber) {
      allVillaNumbers = [villaNumber];
    }
    return [...new Set(allVillaNumbers)];
  }

  /**
   * Create user from DTO with all business logic
   */
  async createUserFromDto(
    companyId: string,
    dto: {
      email: string;
      password: string;
      firstName?: string;
      lastName?: string;
      villaNumber?: string;
      villaNumbers?: string[];
      status?: string;
      employeeId?: string;
      designation?: string;
      joiningDate?: Date;
      emergencyContactName?: string;
      emergencyContactPhone?: string;
      notes?: string;
      roleId?: string;
      departmentId?: string;
    },
  ): Promise<User> {
    // Parse status enum
    const userStatus = this.parseUserStatus(dto.status);

    // Build metadata object
    const metadata = this.buildUserMetadata({
      employeeId: dto.employeeId,
      designation: dto.designation,
      joiningDate: dto.joiningDate,
      emergencyContactName: dto.emergencyContactName,
      emergencyContactPhone: dto.emergencyContactPhone,
      notes: dto.notes,
    });

    // Create user
    const user = await this.createLocalUser(
      companyId,
      dto.email,
      dto.password,
      dto.firstName,
      dto.lastName,
      dto.villaNumber,
      dto.villaNumbers,
      userStatus,
      metadata,
    );

    // Assign role if provided
    if (dto.roleId) {
      await this.assignRole(companyId, user.id, dto.roleId);
    }

    // Assign department if provided
    if (dto.departmentId) {
      await this.assignDepartment(companyId, user.id, dto.departmentId);
    }

    return user;
  }

  /**
   * Update user from DTO with all business logic
   */
  async updateUserFromDto(
    companyId: string,
    userId: string,
    dto: {
      email?: string;
      firstName?: string;
      lastName?: string;
      status?: UserStatus;
      villaNumber?: string;
      villaNumbers?: string[];
      roleId?: string;
      departmentId?: string | null;
    },
  ): Promise<User> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Update basic fields
    if (dto.email !== undefined) user.email = dto.email;
    if (dto.firstName !== undefined) user.firstName = dto.firstName;
    if (dto.lastName !== undefined) user.lastName = dto.lastName;
    if (dto.status !== undefined) user.status = dto.status;

    // Handle villa assignment - support both single and multiple villas
    if (dto.villaNumbers !== undefined || dto.villaNumber !== undefined) {
      const allVillaNumbers = this.normalizeVillaNumbers(
        dto.villaNumber,
        dto.villaNumbers,
      );

      // Sync primary villa number (first in array)
      const primaryVillaNumber = allVillaNumbers.length > 0 ? allVillaNumbers[0] : null;
      user.villaNumber = primaryVillaNumber ?? undefined;
      user.villaNumbers = allVillaNumbers.length > 0 ? allVillaNumbers : undefined;
    }

    // The update() method will handle villa occupancy sync automatically
    await this.update(companyId, userId, user);

    // Update role if provided
    if (dto.roleId !== undefined) {
      // Remove existing roles and assign new one
      await this.removeAllRoles(companyId, userId);
      if (dto.roleId) {
        await this.assignRole(companyId, userId, dto.roleId);
      }
    }

    // Update department if provided
    if (dto.departmentId !== undefined) {
      if (dto.departmentId) {
        await this.assignDepartment(companyId, userId, dto.departmentId);
      } else {
        await this.removeDepartment(companyId, userId);
      }
    }

    return this.findById(companyId, userId) as Promise<User>;
  }
  /**
   * Get all allowed villa numbers for a user
   * Combines logic from:
   * 1. user_villas join table
   * 2. villaNumbers JSON array
   * 3. villaNumber legacy column
   */
  async getAllowedVillaNumbers(
    companyId: string,
    userId: string,
  ): Promise<string[]> {
    const user = await this.findById(companyId, userId);
    if (!user) {
      return [];
    }

    // 1. Get from join table
    const rows: Array<{ villaNumber: string | null }> =
      await this.userRepository.query(
        `
        SELECT DISTINCT v.villa_number AS "villaNumber"
        FROM user_villas uv
        JOIN villas v
          ON v.id = uv.villa_id
         AND v.company_id = uv.company_id
        WHERE uv.company_id = $1
          AND uv.user_id = $2
      `,
        [companyId, userId],
      );

    const dbNumbers = rows
      .map((row) => row.villaNumber)
      .filter(
        (value): value is string => value !== null && value !== undefined,
      );

    const allNumbers = new Set<string>(dbNumbers);

    // 2. Get from JSON array
    if (user.villaNumbers && Array.isArray(user.villaNumbers)) {
      user.villaNumbers.forEach((n) => {
        if (n != null && n !== '') {
          allNumbers.add(String(n));
        }
      });
    }

    // 3. Get from legacy single column
    if (user.villaNumber != null && user.villaNumber !== '') {
      allNumbers.add(String(user.villaNumber));
    }

    return Array.from(allNumbers);
  }

  /**
   * Sync villa occupancy status based on tenant assignment
   * This ensures villa.isOccupied reflects whether a tenant is assigned
   */
  private async syncVillaOccupancy(
    companyId: string,
    villaNumber: string,
    isOccupied: boolean,
  ): Promise<void> {
    try {
      const villa = await this.villaService.findByVillaNumber(companyId, villaNumber);
      if (villa && villa.isOccupied !== isOccupied) {
        await this.villaService.update(companyId, villa.id, { isOccupied });
      }
    } catch (error) {
      // Log error but don't fail user operation if villa sync fails
      // Villa might not exist yet, or there might be a temporary issue
      console.error(
        `Failed to sync villa occupancy for villa ${villaNumber}:`,
        error,
      );
    }
  }
}

