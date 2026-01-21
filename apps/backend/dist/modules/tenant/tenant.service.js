"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TenantService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const company_entity_1 = require("./entities/company.entity");
const site_entity_1 = require("./entities/site.entity");
const space_category_entity_1 = require("./entities/space-category.entity");
const space_entity_1 = require("./entities/space.entity");
const user_site_entity_1 = require("./entities/user-site.entity");
const user_service_1 = require("../iam/services/user.service");
const role_service_1 = require("../iam/services/role.service");
let TenantService = class TenantService {
    constructor(companyRepository, siteRepository, spaceCategoryRepository, spaceRepository, userSiteRepository, userService, roleService) {
        this.companyRepository = companyRepository;
        this.siteRepository = siteRepository;
        this.spaceCategoryRepository = spaceCategoryRepository;
        this.spaceRepository = spaceRepository;
        this.userSiteRepository = userSiteRepository;
        this.userService = userService;
        this.roleService = roleService;
    }
    async createCompany(dto) {
        const existingCompany = await this.companyRepository.findOne({
            where: { code: dto.code },
        });
        if (existingCompany) {
            throw new common_1.ConflictException(`Company with code '${dto.code}' already exists`);
        }
        const company = this.companyRepository.create({
            code: dto.code,
            name: dto.name,
            description: dto.description,
            logoUrl: dto.logoUrl,
            timezone: dto.timezone,
            currency: dto.currency,
            isActive: dto.isActive ?? true,
        });
        const savedCompany = await this.companyRepository.save(company);
        try {
            await this._createDefaultRoles(savedCompany.id);
        }
        catch (error) {
            console.error(`Failed to create default roles for company ${savedCompany.id}:`, error);
        }
        return savedCompany;
    }
    async listCompanies() {
        return this.companyRepository.find({
            order: { name: 'ASC' },
        });
    }
    async getCompanyById(id) {
        const company = await this.companyRepository.findOne({
            where: { id },
            relations: ['sites'],
        });
        if (!company) {
            throw new common_1.NotFoundException(`Company with id ${id} not found`);
        }
        return company;
    }
    async getCompanyByCode(code) {
        const company = await this.companyRepository.findOne({
            where: { code },
            relations: ['sites'],
        });
        if (!company) {
            throw new common_1.NotFoundException(`Company with code '${code}' not found`);
        }
        return company;
    }
    async updateCompany(id, dto) {
        const company = await this.getCompanyById(id);
        if (dto.code && dto.code !== company.code) {
            const existingCompany = await this.companyRepository.findOne({
                where: { code: dto.code },
            });
            if (existingCompany) {
                throw new common_1.ConflictException(`Company with code '${dto.code}' already exists`);
            }
        }
        if (dto.code !== undefined)
            company.code = dto.code;
        if (dto.name !== undefined)
            company.name = dto.name;
        if (dto.description !== undefined)
            company.description = dto.description;
        if (dto.logoUrl !== undefined)
            company.logoUrl = dto.logoUrl;
        if (dto.timezone !== undefined)
            company.timezone = dto.timezone;
        if (dto.currency !== undefined)
            company.currency = dto.currency;
        if (dto.isActive !== undefined)
            company.isActive = dto.isActive;
        return this.companyRepository.save(company);
    }
    async deleteCompany(id) {
        const company = await this.getCompanyById(id);
        if (company.sites && company.sites.length > 0) {
            throw new common_1.BadRequestException(`Cannot delete company with id ${id}. It has ${company.sites.length} site(s). Please delete or reassign all sites first.`);
        }
        await this.companyRepository.remove(company);
    }
    extractBaseCodeFromName(name) {
        const letters = name.replace(/[^A-Za-z]/g, '').toUpperCase();
        if (letters.length < 3) {
            return 'SITE';
        }
        return letters.substring(0, Math.min(5, letters.length));
    }
    async generateSiteCode(baseCode, companyId) {
        let code = baseCode;
        let suffix = '';
        const whereClause = { code };
        if (companyId)
            whereClause.companyId = companyId;
        let existingSite = await this.siteRepository.findOne({ where: whereClause });
        if (!existingSite) {
            return code;
        }
        const availableLength = 5 - baseCode.length;
        if (availableLength >= 1) {
            for (let i = 0; i < 26; i++) {
                suffix = String.fromCharCode(65 + i);
                code = baseCode.substring(0, Math.min(4, baseCode.length)) + suffix;
                if (code.length <= 5) {
                    const checkWhere = { code };
                    if (companyId)
                        checkWhere.companyId = companyId;
                    existingSite = await this.siteRepository.findOne({ where: checkWhere });
                    if (!existingSite) {
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
                    const checkWhere = { code };
                    if (companyId)
                        checkWhere.companyId = companyId;
                    existingSite = await this.siteRepository.findOne({ where: checkWhere });
                    if (!existingSite) {
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
                    const checkWhere = { code };
                    if (companyId)
                        checkWhere.companyId = companyId;
                    existingSite = await this.siteRepository.findOne({ where: checkWhere });
                    if (!existingSite) {
                        return code;
                    }
                }
            }
        }
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        let attempts = 0;
        while (attempts < 1000) {
            code = '';
            for (let i = 0; i < 5; i++) {
                code += chars.charAt(Math.floor(Math.random() * chars.length));
            }
            const checkWhere = { code };
            if (companyId)
                checkWhere.companyId = companyId;
            existingSite = await this.siteRepository.findOne({ where: checkWhere });
            if (!existingSite) {
                return code;
            }
            attempts++;
        }
        throw new common_1.BadRequestException('Unable to generate unique site code. Please provide a code manually.');
    }
    async createSite(dto, companyId) {
        if (!dto.isParent && !dto.parentSiteId) {
            throw new common_1.BadRequestException('parentSiteId is required when isParent is false');
        }
        if (dto.isParent && dto.parentSiteId) {
            throw new common_1.BadRequestException('parentSiteId should not be provided when isParent is true');
        }
        let siteCode;
        if (dto.code) {
            if (!/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/.test(dto.code)) {
                throw new common_1.BadRequestException('Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.');
            }
            if (dto.code.length < 3 || dto.code.length > 20) {
                throw new common_1.BadRequestException('Site code must be between 3 and 20 characters long');
            }
            siteCode = dto.code;
            const whereClause = { code: siteCode };
            if (companyId)
                whereClause.companyId = companyId;
            const existingSite = await this.siteRepository.findOne({ where: whereClause });
            if (existingSite) {
                throw new common_1.ConflictException(`Site with code '${siteCode}' already exists`);
            }
        }
        else {
            const baseCode = this.extractBaseCodeFromName(dto.name);
            siteCode = await this.generateSiteCode(baseCode, companyId);
        }
        let parentSite = undefined;
        if (!dto.isParent && dto.parentSiteId) {
            const foundParent = await this.siteRepository.findOne({
                where: { id: dto.parentSiteId },
            });
            if (!foundParent) {
                throw new common_1.NotFoundException(`Parent site with id ${dto.parentSiteId} not found`);
            }
            if (!foundParent.isParent) {
                throw new common_1.BadRequestException(`Site with id ${dto.parentSiteId} is not a parent site.`);
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
        if (dto.createAdmin !== false && companyId) {
            if (!dto.adminEmail || !dto.adminPassword) {
                throw new common_1.BadRequestException('adminEmail and adminPassword are required when createAdmin is true');
            }
            const adminUser = await this.userService.createLocalUser(companyId, dto.adminEmail, dto.adminPassword, dto.adminFirstName, dto.adminLastName);
            let roles = await this.roleService.findAll(companyId);
            let adminRole = roles.find((r) => r.name.toUpperCase() === 'ADMIN');
            if (!adminRole) {
                adminRole = await this.roleService.create(companyId, {
                    name: 'ADMIN',
                    description: 'Administrator role with full access to company and site resources',
                    hierarchy_level: 100,
                });
            }
            await this.userService.assignRole(companyId, adminUser.id, adminRole.id);
            const userSite = this.userSiteRepository.create({
                companyId,
                userId: adminUser.id,
                siteId: savedSite.id,
            });
            await this.userSiteRepository.save(userSite);
        }
        return savedSite;
    }
    async listSites(companyId) {
        const whereClause = {};
        if (companyId)
            whereClause.companyId = companyId;
        return this.siteRepository.find({
            where: whereClause,
            relations: ['parentSite', 'childSites'],
            order: { code: 'ASC' },
        });
    }
    async getSiteById(id) {
        const site = await this.siteRepository.findOne({
            where: { id },
            relations: ['parentSite', 'childSites', 'company'],
        });
        if (!site) {
            throw new common_1.NotFoundException(`Site with id ${id} not found`);
        }
        return site;
    }
    async getSiteByCode(siteCode, companyId) {
        const whereClause = { code: siteCode };
        if (companyId) {
            whereClause.companyId = companyId;
        }
        const site = await this.siteRepository.findOne({
            where: whereClause,
            relations: ['parentSite', 'childSites', 'company'],
        });
        if (!site) {
            throw new common_1.NotFoundException(`Site with code '${siteCode}' not found`);
        }
        return site;
    }
    async updateSite(id, dto) {
        const site = await this.siteRepository.findOne({
            where: { id },
            relations: ['parentSite', 'childSites'],
        });
        if (!site) {
            throw new common_1.NotFoundException(`Site with id ${id} not found`);
        }
        if (dto.code !== undefined) {
            if (!/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/.test(dto.code)) {
                throw new common_1.BadRequestException('Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.');
            }
            if (dto.code.length < 3 || dto.code.length > 20) {
                throw new common_1.BadRequestException('Site code must be between 3 and 20 characters long');
            }
            const whereClause = { code: dto.code };
            if (site.companyId)
                whereClause.companyId = site.companyId;
            const existingSite = await this.siteRepository.findOne({ where: whereClause });
            if (existingSite && existingSite.id !== id) {
                throw new common_1.ConflictException(`Site with code '${dto.code}' already exists`);
            }
            site.code = dto.code;
        }
        if (dto.name !== undefined) {
            site.name = dto.name;
        }
        if (dto.isParent !== undefined) {
            if (dto.isParent && !site.isParent) {
                const childSites = await this.siteRepository
                    .createQueryBuilder('site')
                    .where('site.parentSiteId = :siteId', { siteId: site.id })
                    .getMany();
                if (childSites.length > 0) {
                    throw new common_1.BadRequestException('Cannot convert a site with child sites to a parent site.');
                }
                site.isParent = true;
                site.parentSite = undefined;
            }
            else if (!dto.isParent && site.isParent) {
                if (!dto.parentSiteId) {
                    throw new common_1.BadRequestException('parentSiteId is required when changing a parent site to a child site');
                }
                const parentSite = await this.siteRepository.findOne({
                    where: { id: dto.parentSiteId },
                });
                if (!parentSite) {
                    throw new common_1.NotFoundException(`Parent site with id ${dto.parentSiteId} not found`);
                }
                if (!parentSite.isParent) {
                    throw new common_1.BadRequestException(`Site with id ${dto.parentSiteId} is not a parent site.`);
                }
                if (parentSite.id === id) {
                    throw new common_1.BadRequestException('A site cannot be its own parent');
                }
                const isDescendant = await this.isDescendantOf(id, dto.parentSiteId);
                if (isDescendant) {
                    throw new common_1.BadRequestException('Cannot set parent: would create circular reference');
                }
                site.isParent = false;
                site.parentSite = parentSite;
            }
        }
        if (dto.parentSiteId !== undefined && dto.isParent !== true) {
            if (dto.isParent === false || site.isParent === false) {
                const parentSite = await this.siteRepository.findOne({
                    where: { id: dto.parentSiteId },
                });
                if (!parentSite) {
                    throw new common_1.NotFoundException(`Parent site with id ${dto.parentSiteId} not found`);
                }
                if (!parentSite.isParent) {
                    throw new common_1.BadRequestException(`Site with id ${dto.parentSiteId} is not a parent site.`);
                }
                if (parentSite.id === id) {
                    throw new common_1.BadRequestException('A site cannot be its own parent');
                }
                const isDescendant = await this.isDescendantOf(id, dto.parentSiteId);
                if (isDescendant) {
                    throw new common_1.BadRequestException('Cannot set parent: would create circular reference');
                }
                site.parentSite = parentSite;
            }
            else {
                throw new common_1.BadRequestException('parentSiteId can only be set when isParent is false');
            }
        }
        return this.siteRepository.save(site);
    }
    async isDescendantOf(siteId, ancestorId) {
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
    async deleteSite(id) {
        const site = await this.siteRepository.findOne({
            where: { id },
            relations: ['childSites'],
        });
        if (!site) {
            throw new common_1.NotFoundException(`Site with id ${id} not found`);
        }
        const childSites = site.childSites ?? [];
        if (childSites.length > 0) {
            throw new common_1.BadRequestException(`Cannot delete site with id ${id}: it has ${childSites.length} child site(s).`);
        }
        await this.siteRepository.remove(site);
    }
    extractBaseCodeFromCategoryName(name) {
        const letters = name.replace(/[^A-Za-z]/g, '').toUpperCase();
        if (letters.length < 3) {
            return 'CAT';
        }
        return letters.substring(0, Math.min(5, letters.length));
    }
    async generateSpaceCategoryCode(baseCode) {
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
        throw new common_1.BadRequestException('Unable to generate unique space category code.');
    }
    async createSpaceCategory(dto) {
        let categoryCode;
        if (dto.code) {
            if (!/^[A-Z]+$/.test(dto.code)) {
                throw new common_1.BadRequestException('Space category code must contain only uppercase letters (A-Z)');
            }
            if (dto.code.length < 3 || dto.code.length > 5) {
                throw new common_1.BadRequestException('Space category code must be between 3 and 5 characters long');
            }
            categoryCode = dto.code;
            const existingCategory = await this.spaceCategoryRepository.findOne({
                where: { code: categoryCode },
            });
            if (existingCategory) {
                throw new common_1.ConflictException(`Space category with code '${categoryCode}' already exists`);
            }
        }
        else {
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
    async listSpaceCategories() {
        return this.spaceCategoryRepository.find({
            order: { code: 'ASC' },
        });
    }
    async getSpaceCategoryById(id) {
        const category = await this.spaceCategoryRepository.findOne({
            where: { id },
        });
        if (!category) {
            throw new common_1.NotFoundException(`Space category with id ${id} not found`);
        }
        return category;
    }
    async updateSpaceCategory(id, dto) {
        const category = await this.spaceCategoryRepository.findOne({
            where: { id },
        });
        if (!category) {
            throw new common_1.NotFoundException(`Space category with id ${id} not found`);
        }
        if (dto.code !== undefined) {
            if (!/^[A-Z]+$/.test(dto.code)) {
                throw new common_1.BadRequestException('Space category code must contain only uppercase letters (A-Z)');
            }
            if (dto.code.length < 3 || dto.code.length > 5) {
                throw new common_1.BadRequestException('Space category code must be between 3 and 5 characters long');
            }
            const existingCategory = await this.spaceCategoryRepository.findOne({
                where: { code: dto.code },
            });
            if (existingCategory && existingCategory.id !== id) {
                throw new common_1.ConflictException(`Space category with code '${dto.code}' already exists`);
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
    async deleteSpaceCategory(id) {
        const category = await this.spaceCategoryRepository.findOne({
            where: { id },
        });
        if (!category) {
            throw new common_1.NotFoundException(`Space category with id ${id} not found`);
        }
        await this.spaceCategoryRepository.remove(category);
    }
    async listSpaces(companyId, siteId, spaceCategoryId) {
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
    async getSpaceById(companyId, id) {
        const space = await this.spaceRepository.findOne({
            where: { id, companyId },
        });
        if (!space) {
            throw new common_1.NotFoundException(`Space with id ${id} not found`);
        }
        return space;
    }
    async _createDefaultRoles(companyId) {
        const existingRoles = await this.roleService.findAll(companyId);
        const existingRoleNames = existingRoles.map((role) => role.name.toUpperCase());
        const defaultRoles = [
            {
                name: 'ADMIN',
                description: 'Administrator with full system access',
                hierarchyLevel: 100,
            },
            {
                name: 'SITE_COORDINATOR',
                description: 'Site Coordinator - View all, assign department, schedule',
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
            if (existingRoleNames.includes(roleConfig.name.toUpperCase())) {
                continue;
            }
            try {
                const roleDto = {
                    name: roleConfig.name,
                    description: roleConfig.description,
                    hierarchy_level: roleConfig.hierarchyLevel,
                    parent_role_id: undefined,
                    company_id: undefined,
                };
                await this.roleService.create(companyId, roleDto);
            }
            catch (error) {
                console.error(`Failed to create role ${roleConfig.name} for company ${companyId}:`, error);
            }
        }
    }
    async createDefaultRolesForCompany(companyId) {
        const company = await this.getCompanyById(companyId);
        if (!company) {
            throw new common_1.NotFoundException(`Company with id ${companyId} not found`);
        }
        await this._createDefaultRoles(companyId);
    }
};
exports.TenantService = TenantService;
exports.TenantService = TenantService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(company_entity_1.Company)),
    __param(1, (0, typeorm_1.InjectRepository)(site_entity_1.Site)),
    __param(2, (0, typeorm_1.InjectRepository)(space_category_entity_1.SpaceCategory)),
    __param(3, (0, typeorm_1.InjectRepository)(space_entity_1.Space)),
    __param(4, (0, typeorm_1.InjectRepository)(user_site_entity_1.UserSite)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        user_service_1.UserService,
        role_service_1.RoleService])
], TenantService);
