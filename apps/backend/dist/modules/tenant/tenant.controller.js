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
exports.TenantController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const tenant_service_1 = require("./tenant.service");
const user_site_service_1 = require("./services/user-site.service");
const create_company_dto_1 = require("./dto/create-company.dto");
const update_company_dto_1 = require("./dto/update-company.dto");
const create_site_dto_1 = require("./dto/create-site.dto");
const update_site_dto_1 = require("./dto/update-site.dto");
const create_space_category_dto_1 = require("./dto/create-space-category.dto");
const update_space_category_dto_1 = require("./dto/update-space-category.dto");
const tenant_guard_1 = require("../../shared/guards/tenant.guard");
const jwt_auth_guard_1 = require("../../modules/auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../../shared/guards/roles.guard");
const roles_decorator_1 = require("../../shared/decorators/roles.decorator");
const user_response_dto_1 = require("../user/dto/user-response.dto");
const class_transformer_1 = require("class-transformer");
let TenantController = class TenantController {
    constructor(tenantService, userSiteService) {
        this.tenantService = tenantService;
        this.userSiteService = userSiteService;
    }
    async createCompany(dto) {
        return this.tenantService.createCompany(dto);
    }
    async listCompanies() {
        return this.tenantService.listCompanies();
    }
    async getCompanyById(id) {
        return this.tenantService.getCompanyById(id);
    }
    async updateCompany(id, dto) {
        return this.tenantService.updateCompany(id, dto);
    }
    async createDefaultRolesForCompany(companyId) {
        await this.tenantService.createDefaultRolesForCompany(companyId);
        return {
            message: 'Default roles created successfully for company',
            companyId,
        };
    }
    async deleteCompany(id) {
        await this.tenantService.deleteCompany(id);
        return { message: 'Company deleted successfully' };
    }
    async createSite(dto, req) {
        const roles = req?.user?.roles ?? [];
        const isSuperAdmin = roles.some((role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN');
        const targetCompanyId = isSuperAdmin && dto.companyId
            ? dto.companyId
            : req.companyId;
        return this.tenantService.createSite(dto, targetCompanyId);
    }
    async listSites(companyId, req) {
        const roles = req?.user?.roles ?? [];
        const isSuperAdmin = roles.some((role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN');
        if (isSuperAdmin) {
            return this.tenantService.listSites(companyId);
        }
        const tenantCompanyId = req?.companyId;
        if (!tenantCompanyId) {
            throw new common_1.BadRequestException('Tenant company context is required');
        }
        return this.tenantService.listSites(tenantCompanyId);
    }
    async listSitesForCompany(companyId, req) {
        const roles = req?.user?.roles ?? [];
        const isSuperAdmin = roles.some((role) => typeof role === 'string' && role.toUpperCase().trim() === 'SUPER_ADMIN');
        if (!isSuperAdmin) {
            const tenantCompanyId = req?.companyId;
            if (!tenantCompanyId) {
                throw new common_1.BadRequestException('Tenant company context is required');
            }
            if (tenantCompanyId !== companyId) {
                throw new common_1.ForbiddenException('You are not allowed to access sites for another company');
            }
        }
        return this.tenantService.listSites(companyId);
    }
    async getSiteById(id) {
        return this.tenantService.getSiteById(id);
    }
    async updateSite(id, dto) {
        return this.tenantService.updateSite(id, dto);
    }
    async deleteSite(id) {
        await this.tenantService.deleteSite(id);
        return { message: 'Site deleted successfully' };
    }
    async createSpaceCategory(dto) {
        return this.tenantService.createSpaceCategory(dto);
    }
    async listSpaceCategories() {
        return this.tenantService.listSpaceCategories();
    }
    async getSpaceCategoryById(id) {
        return this.tenantService.getSpaceCategoryById(id);
    }
    async updateSpaceCategory(id, dto) {
        return this.tenantService.updateSpaceCategory(id, dto);
    }
    async deleteSpaceCategory(id) {
        await this.tenantService.deleteSpaceCategory(id);
        return { message: 'Space category deleted successfully' };
    }
    async listSpaces(siteId, spaceCategoryId, req) {
        return this.tenantService.listSpaces(req.companyId, siteId, spaceCategoryId);
    }
    async getSpaceById(id, req) {
        return this.tenantService.getSpaceById(req.companyId, id);
    }
    async assignUserToSite(siteId, userId, req) {
        await this.userSiteService.assignUserToSite(req.companyId, userId, siteId);
        return {
            message: 'User assigned to site successfully',
            siteId,
            userId,
        };
    }
    async removeUserFromSite(siteId, userId, req) {
        await this.userSiteService.removeUserFromSite(req.companyId, userId, siteId);
        return {
            message: 'User removed from site successfully',
        };
    }
    async getSiteUsers(siteId, req) {
        const users = await this.userSiteService.getSiteUsers(req.companyId, siteId);
        return (0, class_transformer_1.plainToInstance)(user_response_dto_1.UserResponseDto, users, {
            excludeExtraneousValues: true,
        });
    }
    async getUserSites(userId, req) {
        return this.userSiteService.getUserSites(req.companyId, userId);
    }
};
exports.TenantController = TenantController;
__decorate([
    (0, common_1.Post)('companies'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({ summary: 'Create company for current tenant' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_company_dto_1.CreateCompanyDto]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "createCompany", null);
__decorate([
    (0, common_1.Get)('companies'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({ summary: 'List all companies' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "listCompanies", null);
__decorate([
    (0, common_1.Get)('companies/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({ summary: 'Get company by ID' }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Company UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Company not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "getCompanyById", null);
__decorate([
    (0, common_1.Patch)('companies/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({ summary: 'Update company' }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Company UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Invalid input or validation error' }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Company not found' }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Company code already exists' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_company_dto_1.UpdateCompanyDto]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "updateCompany", null);
__decorate([
    (0, common_1.Post)('companies/:companyId/roles/default'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Create default roles for an existing company',
        description: 'Creates default roles (ADMIN, TENANT, TECHNICIAN, SITE_COORDINATOR, SUPERVISOR) for an existing company. Only creates roles that do not already exist.',
    }),
    (0, swagger_1.ApiParam)({
        name: 'companyId',
        description: 'Company UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Company not found' }),
    __param(0, (0, common_1.Param)('companyId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "createDefaultRolesForCompany", null);
__decorate([
    (0, common_1.Delete)('companies/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Delete company',
        description: 'Deletes a company. Cannot delete companies that have sites. All sites must be deleted or reassigned first.',
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Company UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Company deleted successfully',
        schema: {
            type: 'object',
            properties: {
                message: { type: 'string', example: 'Company deleted successfully' }
            }
        }
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Company not found' }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Cannot delete company with sites' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "deleteCompany", null);
__decorate([
    (0, common_1.Post)('sites'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Create a new site',
        description: 'Creates a new site. Code can be auto-generated from name if not provided. Parent sites cannot have a parentSiteId, child sites must have a valid parentSiteId.'
    }),
    (0, swagger_1.ApiCreatedResponse)({
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
    }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Invalid input or validation error' }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Site code already exists' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_site_dto_1.CreateSiteDto, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "createSite", null);
__decorate([
    (0, common_1.Get)('sites'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({
        summary: 'List all sites',
        description: 'Returns a list of all sites with their parent and child relationships. Sites are ordered by code.'
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    __param(0, (0, common_1.Query)('companyId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "listSites", null);
__decorate([
    (0, common_1.Get)('companies/:companyId/sites'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({
        summary: 'List sites for a specific company',
        description: 'Returns a list of all sites for the specified company, ordered by code.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'companyId',
        description: 'Company UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    __param(0, (0, common_1.Param)('companyId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "listSitesForCompany", null);
__decorate([
    (0, common_1.Get)('sites/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get site by ID',
        description: 'Retrieves a single site by its UUID, including parent and child site relationships.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Site UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Site not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "getSiteById", null);
__decorate([
    (0, common_1.Patch)('sites/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Update site',
        description: 'Updates site properties. All fields are optional. When changing isParent from true to false, parentSiteId must be provided. Prevents circular references and validates parent-child relationships.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Site UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Invalid input, validation error, or business rule violation' }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Site not found' }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Site code already exists' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_site_dto_1.UpdateSiteDto]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "updateSite", null);
__decorate([
    (0, common_1.Delete)('sites/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Delete site',
        description: 'Deletes a site. Cannot delete sites that have child sites. Child sites must be deleted or reassigned first.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Site UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Site deleted successfully',
        schema: {
            type: 'object',
            properties: {
                message: { type: 'string', example: 'Site deleted successfully' }
            }
        }
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Site not found' }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Cannot delete site with child sites' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "deleteSite", null);
__decorate([
    (0, common_1.Post)('space-categories'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Create space category',
        description: 'Creates a new space category for categorizing spaces within sites. Code will be auto-generated from name if not provided (3-5 uppercase letters).'
    }),
    (0, swagger_1.ApiCreatedResponse)({
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
    }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Invalid input or validation error' }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Space category code already exists' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_space_category_dto_1.CreateSpaceCategoryDto]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "createSpaceCategory", null);
__decorate([
    (0, common_1.Get)('space-categories'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({
        summary: 'List all space categories',
        description: 'Returns a list of all space categories, ordered by code.'
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "listSpaceCategories", null);
__decorate([
    (0, common_1.Get)('space-categories/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'MANAGER'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get space category by ID',
        description: 'Retrieves a single space category by its UUID.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Space category UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Space category not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "getSpaceCategoryById", null);
__decorate([
    (0, common_1.Patch)('space-categories/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Update space category',
        description: 'Updates space category properties. All fields are optional.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Space category UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiBadRequestResponse)({ description: 'Invalid input or validation error' }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Space category not found' }),
    (0, swagger_1.ApiConflictResponse)({ description: 'Space category code already exists' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_space_category_dto_1.UpdateSpaceCategoryDto]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "updateSpaceCategory", null);
__decorate([
    (0, common_1.Delete)('space-categories/:id'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Delete space category',
        description: 'Deletes a space category.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Space category UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String
    }),
    (0, swagger_1.ApiOkResponse)({
        description: 'Space category deleted successfully',
        schema: {
            type: 'object',
            properties: {
                message: { type: 'string', example: 'Space category deleted successfully' }
            }
        }
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Space category not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "deleteSpaceCategory", null);
__decorate([
    (0, common_1.Get)('spaces'),
    (0, swagger_1.ApiOperation)({
        summary: 'List all spaces',
        description: 'Returns a list of all active spaces, optionally filtered by site or space category.',
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    __param(0, (0, common_1.Query)('siteId')),
    __param(1, (0, common_1.Query)('spaceCategoryId')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "listSpaces", null);
__decorate([
    (0, common_1.Get)('spaces/:id'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get space by ID',
        description: 'Retrieves a single space by its UUID.',
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Space UUID',
        type: 'string',
        format: 'uuid',
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({ description: 'Space not found' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "getSpaceById", null);
__decorate([
    (0, common_1.Post)('sites/:siteId/users/:userId'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Assign a user to a site',
        description: 'Assigns an existing user to a site. Users must be assigned to at least one site to login (unless SUPER_ADMIN).',
    }),
    (0, swagger_1.ApiParam)({
        name: 'siteId',
        description: 'Site UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiParam)({
        name: 'userId',
        description: 'User UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({
        description: 'Site or user not found',
    }),
    __param(0, (0, common_1.Param)('siteId')),
    __param(1, (0, common_1.Param)('userId')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "assignUserToSite", null);
__decorate([
    (0, common_1.Delete)('sites/:siteId/users/:userId'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Remove a user from a site',
        description: 'Removes a user from a site. User will no longer be able to login to this site.',
    }),
    (0, swagger_1.ApiParam)({
        name: 'siteId',
        description: 'Site UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiParam)({
        name: 'userId',
        description: 'User UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    (0, swagger_1.ApiNotFoundResponse)({
        description: 'User-site assignment not found',
    }),
    __param(0, (0, common_1.Param)('siteId')),
    __param(1, (0, common_1.Param)('userId')),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "removeUserFromSite", null);
__decorate([
    (0, common_1.Get)('sites/:siteId/users'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN', 'SITE_COORDINATOR'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get all users assigned to a site',
        description: 'Returns a list of all users assigned to the specified site.',
    }),
    (0, swagger_1.ApiParam)({
        name: 'siteId',
        description: 'Site UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiOkResponse)({
        description: 'List of users assigned to site',
        type: [user_response_dto_1.UserResponseDto],
    }),
    __param(0, (0, common_1.Param)('siteId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "getSiteUsers", null);
__decorate([
    (0, common_1.Get)('users/:userId/sites'),
    (0, common_1.Version)('1'),
    (0, roles_decorator_1.Roles)('SUPER_ADMIN', 'ADMIN'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get all sites assigned to a user',
        description: 'Returns a list of all sites that the specified user is assigned to.',
    }),
    (0, swagger_1.ApiParam)({
        name: 'userId',
        description: 'User UUID',
        example: '123e4567-e89b-12d3-a456-426614174000',
        type: String,
    }),
    (0, swagger_1.ApiOkResponse)({
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
    }),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TenantController.prototype, "getUserSites", null);
exports.TenantController = TenantController = __decorate([
    (0, swagger_1.ApiTags)('tenant'),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, tenant_guard_1.TenantGuard, roles_guard_1.RolesGuard),
    (0, common_1.Controller)('tenants'),
    __metadata("design:paramtypes", [tenant_service_1.TenantService,
        user_site_service_1.UserSiteService])
], TenantController);
