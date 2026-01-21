import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Company } from './entities/company.entity';
import { Site } from './entities/site.entity';
import { SpaceCategory } from './entities/space-category.entity';
import { Space } from './entities/space.entity';
import { UserSite } from './entities/user-site.entity';
import { CreateCompanyDto } from './dto/create-company.dto';
import { UpdateCompanyDto } from './dto/update-company.dto';
import { CreateSiteDto } from './dto/create-site.dto';
import { UpdateSiteDto } from './dto/update-site.dto';
import { CreateSpaceCategoryDto } from './dto/create-space-category.dto';
import { UpdateSpaceCategoryDto } from './dto/update-space-category.dto';
import { UserService } from '../iam/services/user.service';
import { RoleService } from '../iam/services/role.service';
import { CreateRoleDto } from '../iam/dto/create-role.dto';

@Injectable()
export class TenantService {
  constructor(
    @InjectRepository(Company)
    private readonly companyRepository: Repository<Company>,
    @InjectRepository(Site)
    private readonly siteRepository: Repository<Site>,
    @InjectRepository(SpaceCategory)
    private readonly spaceCategoryRepository: Repository<SpaceCategory>,
    @InjectRepository(Space)
    private readonly spaceRepository: Repository<Space>,
    @InjectRepository(UserSite)
    private readonly userSiteRepository: Repository<UserSite>,
    private readonly userService: UserService,
    private readonly roleService: RoleService,
  ) {}

  /**
   * Create a new company (companies are top-level entities, not tenant-scoped)
   */
  async createCompany(dto: CreateCompanyDto): Promise<Company> {
    // Check if a company with the same code already exists
    const existingCompany = await this.companyRepository.findOne({
      where: { code: dto.code },
    });

    if (existingCompany) {
      throw new ConflictException(`Company with code '${dto.code}' already exists`);
    }

    const company = this.companyRepository.create({
      code: dto.code,
      name: dto.name,
      description: dto.description,
      logoUrl: dto.logoUrl,
      timezone: dto.timezone,
      currency: dto.currency,
      isActive: dto.isActive ?? true, // Default to true if not provided
    });
    
    const savedCompany = await this.companyRepository.save(company);

    // Automatically create default roles for the new company
    try {
      await this._createDefaultRoles(savedCompany.id);
    } catch (error) {
      // Log error but don't fail company creation if role creation fails
      console.error(
        `Failed to create default roles for company ${savedCompany.id}:`,
        error,
      );
    }

    return savedCompany;
  }

  /**
   * List all companies
   */
  async listCompanies(): Promise<Company[]> {
    return this.companyRepository.find({
      order: { name: 'ASC' },
    });
  }

  /**
   * Get company by ID
   */
  async getCompanyById(id: string): Promise<Company> {
    const company = await this.companyRepository.findOne({
      where: { id },
      relations: ['sites'],
    });

    if (!company) {
      throw new NotFoundException(`Company with id ${id} not found`);
    }

    return company;
  }

  /**
   * Get company by code
   */
  async getCompanyByCode(code: string): Promise<Company> {
    const company = await this.companyRepository.findOne({
      where: { code },
      relations: ['sites'],
    });

    if (!company) {
      throw new NotFoundException(`Company with code '${code}' not found`);
    }

    return company;
  }

  /**
   * Update company
   */
  async updateCompany(id: string, dto: UpdateCompanyDto): Promise<Company> {
    const company = await this.getCompanyById(id);

    // Check if code change would conflict
    if (dto.code && dto.code !== company.code) {
      const existingCompany = await this.companyRepository.findOne({
        where: { code: dto.code },
      });

      if (existingCompany) {
        throw new ConflictException(`Company with code '${dto.code}' already exists`);
      }
    }

    // Update fields
    if (dto.code !== undefined) company.code = dto.code;
    if (dto.name !== undefined) company.name = dto.name;
    if (dto.description !== undefined) company.description = dto.description;
    if (dto.logoUrl !== undefined) company.logoUrl = dto.logoUrl;
    if (dto.timezone !== undefined) company.timezone = dto.timezone;
    if (dto.currency !== undefined) company.currency = dto.currency;
    if (dto.isActive !== undefined) company.isActive = dto.isActive;

    return this.companyRepository.save(company);
  }

  /**
   * Delete company
   */
  async deleteCompany(id: string): Promise<void> {
    const company = await this.getCompanyById(id);

    // Check if company has sites
    if (company.sites && company.sites.length > 0) {
      throw new BadRequestException(
        `Cannot delete company with id ${id}. It has ${company.sites.length} site(s). Please delete or reassign all sites first.`,
      );
    }

    await this.companyRepository.remove(company);
  }

  /**
   * Extract base code from site name (first 3-5 uppercase letters, max 5 chars)
   */
  private extractBaseCodeFromName(name: string): string {
    // Extract only letters and convert to uppercase
    const letters = name.replace(/[^A-Za-z]/g, '').toUpperCase();
    // Take first 3-5 characters, minimum 3, maximum 5
    if (letters.length < 3) {
      return 'SITE';
    }
    return letters.substring(0, Math.min(5, letters.length));
  }

  /**
   * Generate unique site code (max 5 characters, letters only)
   */
  private async generateSiteCode(baseCode: string, companyId?: string): Promise<string> {
    // Start with the base code (3-5 characters)
    let code = baseCode;
    let suffix = '';

    // Try base code first
    const whereClause: { code: string; companyId?: string } = { code };
    if (companyId) whereClause.companyId = companyId;

    let existingSite = await this.siteRepository.findOne({ where: whereClause });

    if (!existingSite) {
      return code;
    }

    // If base code exists, try appending letters (A, B, C, ...)
    const availableLength = 5 - baseCode.length;
    
    if (availableLength >= 1) {
      for (let i = 0; i < 26; i++) {
        suffix = String.fromCharCode(65 + i);
        code = baseCode.substring(0, Math.min(4, baseCode.length)) + suffix;
        
        if (code.length <= 5) {
          const checkWhere: { code: string; companyId?: string } = { code };
          if (companyId) checkWhere.companyId = companyId;
          existingSite = await this.siteRepository.findOne({ where: checkWhere });
          
          if (!existingSite) {
            return code;
          }
        }
      }
    }

    // If still not unique, try with shorter base and longer suffix
    if (baseCode.length >= 4) {
      const shorterBase = baseCode.substring(0, baseCode.length - 1);
      for (let i = 0; i < 26; i++) {
        suffix = String.fromCharCode(65 + i);
        code = shorterBase + suffix;
        
        if (code.length <= 5) {
          const checkWhere: { code: string; companyId?: string } = { code };
          if (companyId) checkWhere.companyId = companyId;
          existingSite = await this.siteRepository.findOne({ where: checkWhere });
          
          if (!existingSite) {
            return code;
          }
        }
      }
    }

    // Fallback: use first 2 chars + 2 letter suffix
    if (baseCode.length >= 2) {
      const shortBase = baseCode.substring(0, 2);
      for (let i = 0; i < 26 * 26; i++) {
        const first = String.fromCharCode(65 + Math.floor(i / 26));
        const second = String.fromCharCode(65 + (i % 26));
        suffix = first + second;
        code = shortBase + suffix;
        
        if (code.length <= 5) {
          const checkWhere: { code: string; companyId?: string } = { code };
          if (companyId) checkWhere.companyId = companyId;
          existingSite = await this.siteRepository.findOne({ where: checkWhere });
          
          if (!existingSite) {
            return code;
          }
        }
      }
    }

    // Last resort: generate random 5-letter code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    let attempts = 0;
    while (attempts < 1000) {
      code = '';
      for (let i = 0; i < 5; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      
      const checkWhere: { code: string; companyId?: string } = { code };
      if (companyId) checkWhere.companyId = companyId;
      existingSite = await this.siteRepository.findOne({ where: checkWhere });
      
      if (!existingSite) {
        return code;
      }
      attempts++;
    }

    throw new BadRequestException('Unable to generate unique site code. Please provide a code manually.');
  }

  async createSite(dto: CreateSiteDto, companyId?: string): Promise<Site> {
    // Validate parent-child relationship
    if (!dto.isParent && !dto.parentSiteId) {
      throw new BadRequestException('parentSiteId is required when isParent is false');
    }

    if (dto.isParent && dto.parentSiteId) {
      throw new BadRequestException('parentSiteId should not be provided when isParent is true');
    }

    // Validate or generate site code
    let siteCode: string;
    if (dto.code) {
      // Validate provided code: uppercase letters, numbers, hyphens; must start and end with letter/number
      if (!/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/.test(dto.code)) {
        throw new BadRequestException('Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.');
      }
      if (dto.code.length < 3 || dto.code.length > 20) {
        throw new BadRequestException('Site code must be between 3 and 20 characters long');
      }
      siteCode = dto.code;

      // Check if code already exists within company scope
      const whereClause: { code: string; companyId?: string } = { code: siteCode };
      if (companyId) whereClause.companyId = companyId;
      
      const existingSite = await this.siteRepository.findOne({ where: whereClause });
      if (existingSite) {
        throw new ConflictException(`Site with code '${siteCode}' already exists`);
      }
    } else {
      // Auto-generate code from site name
      const baseCode = this.extractBaseCodeFromName(dto.name);
      siteCode = await this.generateSiteCode(baseCode, companyId);
    }

    // If this is a child site, validate and find the parent site
    let parentSite: Site | undefined = undefined;
    if (!dto.isParent && dto.parentSiteId) {
      const foundParent = await this.siteRepository.findOne({
        where: { id: dto.parentSiteId },
      });

      if (!foundParent) {
        throw new NotFoundException(`Parent site with id ${dto.parentSiteId} not found`);
      }

      if (!foundParent.isParent) {
        throw new BadRequestException(`Site with id ${dto.parentSiteId} is not a parent site.`);
      }
      
      parentSite = foundParent;
    }

    const site = this.siteRepository.create({
      code: siteCode,
      name: dto.name,
      isParent: dto.isParent,
      companyId,
      parentSite,
    });
    const savedSite = await this.siteRepository.save(site);

    // Create admin user if requested
    if (dto.createAdmin !== false && companyId) {
      if (!dto.adminEmail || !dto.adminPassword) {
        throw new BadRequestException(
          'adminEmail and adminPassword are required when createAdmin is true',
        );
      }

      // Create the admin user
      const adminUser = await this.userService.createLocalUser(
        companyId,
        dto.adminEmail,
        dto.adminPassword,
        dto.adminFirstName,
        dto.adminLastName,
      );

      // Find or create ADMIN role for the company
      let roles = await this.roleService.findAll(companyId);
      let adminRole = roles.find((r) => r.name.toUpperCase() === 'ADMIN');

      if (!adminRole) {
        // Auto-create ADMIN role if it doesn't exist
        adminRole = await this.roleService.create(companyId, {
          name: 'ADMIN',
          description: 'Administrator role with full access to company and site resources',
          hierarchy_level: 100,
        });
      }

      // Assign ADMIN role to the user
      await this.userService.assignRole(companyId, adminUser.id, adminRole.id);

      // Link user to site via UserSite junction table
      const userSite = this.userSiteRepository.create({
        companyId,
        userId: adminUser.id,
        siteId: savedSite.id,
      });
      await this.userSiteRepository.save(userSite);
    }

    return savedSite;
  }

  async listSites(companyId?: string): Promise<Site[]> {
    const whereClause: { companyId?: string } = {};
    if (companyId) whereClause.companyId = companyId;

    return this.siteRepository.find({
      where: whereClause,
      relations: ['parentSite', 'childSites'],
      order: { code: 'ASC' },
    });
  }

  async getSiteById(id: string): Promise<Site> {
    const site = await this.siteRepository.findOne({
      where: { id },
      relations: ['parentSite', 'childSites', 'company'],
    });

    if (!site) {
      throw new NotFoundException(`Site with id ${id} not found`);
    }

    return site;
  }

  /**
   * Get site by code (globally unique or unique within company)
   */
  async getSiteByCode(siteCode: string, companyId?: string): Promise<Site> {
    const whereClause: { code: string; companyId?: string } = { code: siteCode };
    if (companyId) {
      whereClause.companyId = companyId;
    }

    const site = await this.siteRepository.findOne({
      where: whereClause,
      relations: ['parentSite', 'childSites', 'company'],
    });

    if (!site) {
      throw new NotFoundException(`Site with code '${siteCode}' not found`);
    }

    return site;
  }

  async updateSite(id: string, dto: UpdateSiteDto): Promise<Site> {
    const site = await this.siteRepository.findOne({
      where: { id },
      relations: ['parentSite', 'childSites'],
    });

    if (!site) {
      throw new NotFoundException(`Site with id ${id} not found`);
    }

    // Validate code if provided
    if (dto.code !== undefined) {
      // Validate provided code: uppercase letters, numbers, hyphens; must start and end with letter/number
      if (!/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/.test(dto.code)) {
        throw new BadRequestException('Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.');
      }
      if (dto.code.length < 3 || dto.code.length > 20) {
        throw new BadRequestException('Site code must be between 3 and 20 characters long');
      }

      // Check if code already exists (excluding current site)
      const whereClause: { code: string; companyId?: string } = { code: dto.code };
      if (site.companyId) whereClause.companyId = site.companyId;
      
      const existingSite = await this.siteRepository.findOne({ where: whereClause });
      if (existingSite && existingSite.id !== id) {
        throw new ConflictException(`Site with code '${dto.code}' already exists`);
      }

      site.code = dto.code;
    }

    // Update name if provided
    if (dto.name !== undefined) {
      site.name = dto.name;
    }

    // Handle parent-child relationship changes
    if (dto.isParent !== undefined) {
      if (dto.isParent && !site.isParent) {
        const childSites = await this.siteRepository
          .createQueryBuilder('site')
          .where('site.parentSiteId = :siteId', { siteId: site.id })
          .getMany();
        if (childSites.length > 0) {
          throw new BadRequestException('Cannot convert a site with child sites to a parent site.');
        }
        site.isParent = true;
        site.parentSite = undefined;
      } else if (!dto.isParent && site.isParent) {
        if (!dto.parentSiteId) {
          throw new BadRequestException('parentSiteId is required when changing a parent site to a child site');
        }

        const parentSite = await this.siteRepository.findOne({
          where: { id: dto.parentSiteId },
        });

        if (!parentSite) {
          throw new NotFoundException(`Parent site with id ${dto.parentSiteId} not found`);
        }

        if (!parentSite.isParent) {
          throw new BadRequestException(`Site with id ${dto.parentSiteId} is not a parent site.`);
        }

        if (parentSite.id === id) {
          throw new BadRequestException('A site cannot be its own parent');
        }

        const isDescendant = await this.isDescendantOf(id, dto.parentSiteId);
        if (isDescendant) {
          throw new BadRequestException('Cannot set parent: would create circular reference');
        }

        site.isParent = false;
        site.parentSite = parentSite;
      }
    }

    // Update parentSiteId if provided
    if (dto.parentSiteId !== undefined && dto.isParent !== true) {
      if (dto.isParent === false || site.isParent === false) {
        const parentSite = await this.siteRepository.findOne({
          where: { id: dto.parentSiteId },
        });

        if (!parentSite) {
          throw new NotFoundException(`Parent site with id ${dto.parentSiteId} not found`);
        }

        if (!parentSite.isParent) {
          throw new BadRequestException(`Site with id ${dto.parentSiteId} is not a parent site.`);
        }

        if (parentSite.id === id) {
          throw new BadRequestException('A site cannot be its own parent');
        }

        const isDescendant = await this.isDescendantOf(id, dto.parentSiteId);
        if (isDescendant) {
          throw new BadRequestException('Cannot set parent: would create circular reference');
        }

        site.parentSite = parentSite;
      } else {
        throw new BadRequestException('parentSiteId can only be set when isParent is false');
      }
    }

    return this.siteRepository.save(site);
  }

  private async isDescendantOf(siteId: string, ancestorId: string): Promise<boolean> {
    const site = await this.siteRepository.findOne({
      where: { id: siteId },
      relations: ['parentSite'],
    });

    if (!site || !site.parentSite) {
      return false;
    }

    if (site.parentSite.id === ancestorId) {
      return true;
    }

    return this.isDescendantOf(site.parentSite.id, ancestorId);
  }

  async deleteSite(id: string): Promise<void> {
    const site = await this.siteRepository.findOne({
      where: { id },
      relations: ['childSites'],
    });

    if (!site) {
      throw new NotFoundException(`Site with id ${id} not found`);
    }

    // childSites relation is already loaded via TypeORM relations
    const childSites = site.childSites ?? [];

    if (childSites.length > 0) {
      throw new BadRequestException(
        `Cannot delete site with id ${id}: it has ${childSites.length} child site(s).`
      );
    }

    await this.siteRepository.remove(site);
  }

  // Space Category CRUD operations

  private extractBaseCodeFromCategoryName(name: string): string {
    const letters = name.replace(/[^A-Za-z]/g, '').toUpperCase();
    if (letters.length < 3) {
      return 'CAT';
    }
    return letters.substring(0, Math.min(5, letters.length));
  }

  private async generateSpaceCategoryCode(baseCode: string): Promise<string> {
    let code = baseCode;
    let suffix = '';

    let existingCategory = await this.spaceCategoryRepository.findOne({
      where: { code },
    });

    if (!existingCategory) {
      return code;
    }

    const availableLength = 5 - baseCode.length;
    
    if (availableLength >= 1) {
      for (let i = 0; i < 26; i++) {
        suffix = String.fromCharCode(65 + i);
        code = baseCode.substring(0, Math.min(4, baseCode.length)) + suffix;
        
        if (code.length <= 5) {
          existingCategory = await this.spaceCategoryRepository.findOne({
            where: { code },
          });
          
          if (!existingCategory) {
            return code;
          }
        }
      }
    }

    if (baseCode.length >= 4) {
      const shorterBase = baseCode.substring(0, baseCode.length - 1);
      for (let i = 0; i < 26; i++) {
        suffix = String.fromCharCode(65 + i);
        code = shorterBase + suffix;
        
        if (code.length <= 5) {
          existingCategory = await this.spaceCategoryRepository.findOne({
            where: { code },
          });
          
          if (!existingCategory) {
            return code;
          }
        }
      }
    }

    if (baseCode.length >= 2) {
      const shortBase = baseCode.substring(0, 2);
      for (let i = 0; i < 26 * 26; i++) {
        const first = String.fromCharCode(65 + Math.floor(i / 26));
        const second = String.fromCharCode(65 + (i % 26));
        suffix = first + second;
        code = shortBase + suffix;
        
        if (code.length <= 5) {
          existingCategory = await this.spaceCategoryRepository.findOne({
            where: { code },
          });
          
          if (!existingCategory) {
            return code;
          }
        }
      }
    }

    throw new BadRequestException('Unable to generate unique space category code.');
  }

  async createSpaceCategory(dto: CreateSpaceCategoryDto): Promise<SpaceCategory> {
    let categoryCode: string;
    if (dto.code) {
      if (!/^[A-Z]+$/.test(dto.code)) {
        throw new BadRequestException('Space category code must contain only uppercase letters (A-Z)');
      }
      if (dto.code.length < 3 || dto.code.length > 5) {
        throw new BadRequestException('Space category code must be between 3 and 5 characters long');
      }
      categoryCode = dto.code;

      const existingCategory = await this.spaceCategoryRepository.findOne({
        where: { code: categoryCode },
      });
      if (existingCategory) {
        throw new ConflictException(`Space category with code '${categoryCode}' already exists`);
      }
    } else {
      const baseCode = this.extractBaseCodeFromCategoryName(dto.name);
      categoryCode = await this.generateSpaceCategoryCode(baseCode);
    }

    const category = this.spaceCategoryRepository.create({
      code: categoryCode,
      name: dto.name,
      description: dto.description,
      isActive: dto.isActive !== undefined ? dto.isActive : true,
    });

    return this.spaceCategoryRepository.save(category);
  }

  async listSpaceCategories(): Promise<SpaceCategory[]> {
    return this.spaceCategoryRepository.find({
      order: { code: 'ASC' },
    });
  }

  async getSpaceCategoryById(id: string): Promise<SpaceCategory> {
    const category = await this.spaceCategoryRepository.findOne({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException(`Space category with id ${id} not found`);
    }

    return category;
  }

  async updateSpaceCategory(id: string, dto: UpdateSpaceCategoryDto): Promise<SpaceCategory> {
    const category = await this.spaceCategoryRepository.findOne({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException(`Space category with id ${id} not found`);
    }

    if (dto.code !== undefined) {
      if (!/^[A-Z]+$/.test(dto.code)) {
        throw new BadRequestException('Space category code must contain only uppercase letters (A-Z)');
      }
      if (dto.code.length < 3 || dto.code.length > 5) {
        throw new BadRequestException('Space category code must be between 3 and 5 characters long');
      }

      const existingCategory = await this.spaceCategoryRepository.findOne({
        where: { code: dto.code },
      });
      if (existingCategory && existingCategory.id !== id) {
        throw new ConflictException(`Space category with code '${dto.code}' already exists`);
      }

      category.code = dto.code;
    }

    if (dto.name !== undefined) {
      category.name = dto.name;
    }

    if (dto.description !== undefined) {
      category.description = dto.description;
    }

    if (dto.isActive !== undefined) {
      category.isActive = dto.isActive;
    }

    return this.spaceCategoryRepository.save(category);
  }

  async deleteSpaceCategory(id: string): Promise<void> {
    const category = await this.spaceCategoryRepository.findOne({
      where: { id },
    });

    if (!category) {
      throw new NotFoundException(`Space category with id ${id} not found`);
    }

    await this.spaceCategoryRepository.remove(category);
  }

  // Space CRUD operations
  async listSpaces(companyId: string, siteId?: string, spaceCategoryId?: string): Promise<Space[]> {
    const queryBuilder = this.spaceRepository
      .createQueryBuilder('space')
      .where('space.companyId = :companyId', { companyId })
      .andWhere('space.isActive = :isActive', { isActive: true });

    if (siteId) {
      queryBuilder.andWhere('space.siteId = :siteId', { siteId });
    }

    if (spaceCategoryId) {
      queryBuilder.andWhere('space.spaceCategoryId = :spaceCategoryId', { spaceCategoryId });
    }

    return queryBuilder.orderBy('space.name', 'ASC').getMany();
  }

  async getSpaceById(companyId: string, id: string): Promise<Space> {
    const space = await this.spaceRepository.findOne({
      where: { id, companyId },
    });

    if (!space) {
      throw new NotFoundException(`Space with id ${id} not found`);
    }

    return space;
  }

  /**
   * Create default roles for a company (private helper method)
   * Creates: ADMIN, TENANT, TECHNICIAN, SITE_COORDINATOR, SUPERVISOR
   * Idempotent: checks if role exists before creating
   */
  private async _createDefaultRoles(companyId: string): Promise<void> {
    const existingRoles = await this.roleService.findAll(companyId);
    const existingRoleNames = existingRoles.map((role) =>
      role.name.toUpperCase(),
    );

    const defaultRoles: Array<{
      name: string;
      description: string;
      hierarchyLevel: number;
    }> = [
      {
        name: 'ADMIN',
        description: 'Administrator with full system access',
        hierarchyLevel: 100,
      },
      {
        name: 'SITE_COORDINATOR',
        description:
          'Site Coordinator - View all, assign department, schedule',
        hierarchyLevel: 80,
      },
      {
        name: 'SUPERVISOR',
        description: 'Supervisor - Assign technicians, update work status',
        hierarchyLevel: 60,
      },
      {
        name: 'TECHNICIAN',
        description: 'Technician - Update assigned tickets, add work notes',
        hierarchyLevel: 30,
      },
      {
        name: 'TENANT',
        description: 'Tenant - Villa resident',
        hierarchyLevel: 10,
      },
    ];

    for (const roleConfig of defaultRoles) {
      // Skip if role already exists
      if (existingRoleNames.includes(roleConfig.name.toUpperCase())) {
        continue;
      }

      try {
        const roleDto: CreateRoleDto = {
          name: roleConfig.name,
          description: roleConfig.description,
          hierarchy_level: roleConfig.hierarchyLevel,
          parent_role_id: undefined,
          company_id: undefined, // Will use companyId from service method
        };
        await this.roleService.create(companyId, roleDto);
      } catch (error) {
        // Log error but continue creating other roles
        console.error(
          `Failed to create role ${roleConfig.name} for company ${companyId}:`,
          error,
        );
      }
    }
  }

  /**
   * Create default roles for an existing company
   * Public method to allow creating default roles for companies that don't have them
   * @param companyId - The company ID to create roles for
   * @returns Promise<void>
   */
  async createDefaultRolesForCompany(companyId: string): Promise<void> {
    // Verify company exists
    const company = await this.getCompanyById(companyId);
    if (!company) {
      throw new NotFoundException(`Company with id ${companyId} not found`);
    }

    // Create default roles
    await this._createDefaultRoles(companyId);
  }
}
