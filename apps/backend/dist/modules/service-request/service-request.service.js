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
exports.ServiceRequestService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const service_request_entity_1 = require("./entities/service-request.entity");
const service_request_status_transition_entity_1 = require("./entities/service-request-status-transition.entity");
const service_request_workflow_entity_1 = require("./entities/service-request-workflow.entity");
const issue_sub_category_entity_1 = require("./entities/issue-sub-category.entity");
const query_service_request_dto_1 = require("./dto/query-service-request.dto");
let ServiceRequestService = class ServiceRequestService {
    constructor(requestRepo, transitionRepo, workflowRepo, issueSubCategoryRepo) {
        this.requestRepo = requestRepo;
        this.transitionRepo = transitionRepo;
        this.workflowRepo = workflowRepo;
        this.issueSubCategoryRepo = issueSubCategoryRepo;
    }
    async create(companyId, dto) {
        const workflow = await this.findApplicableWorkflow(companyId, dto.category);
        const initialStatus = this.getInitialStatus(workflow);
        const request = this.requestRepo.create({
            companyId,
            requestNumber: await this.generateRequestNumber(companyId),
            title: dto.title,
            description: dto.description ?? null,
            category: dto.category,
            priority: dto.priority,
            status: initialStatus,
            siteId: dto.siteId ?? null,
            parentRequestId: dto.parentRequestId ?? null,
            assignedTeamId: dto.assignedTeamId ?? null,
            assignedTechnicianId: dto.assignedTechnicianId ?? null,
            villaCode: dto.villaCode ?? null,
            type: dto.type ?? null,
            spaceId: dto.spaceId ?? null,
            subCategory: dto.subCategory ?? null,
            attachments: dto.attachments ?? null,
            slaDueAt: this.calculateSlaDueAt(workflow, dto.priority),
        });
        return this.requestRepo.save(request);
    }
    async findAll(companyId, query) {
        const { page = 1, limit = 20, status, category, priority, siteId, assignedTechnicianId, assignedTeamId, search, sortBy = query_service_request_dto_1.SortField.CREATED_AT, sortOrder = query_service_request_dto_1.SortOrder.DESC, } = query;
        const statusCountsQuery = this.requestRepo
            .createQueryBuilder('sr')
            .select('LOWER(sr.status)', 'status')
            .addSelect('COUNT(*)', 'count')
            .where('sr.companyId = :companyId', { companyId })
            .groupBy('LOWER(sr.status)');
        if (category) {
            statusCountsQuery.andWhere('sr.category = :category', { category });
        }
        if (priority) {
            const priorities = priority.split(',').map(p => p.trim().toLowerCase());
            if (priorities.length === 1) {
                statusCountsQuery.andWhere('LOWER(sr.priority) = LOWER(:priority)', { priority: priorities[0] });
            }
            else {
                statusCountsQuery.andWhere('LOWER(sr.priority) IN (:...priorities)', { priorities });
            }
        }
        if (siteId) {
            statusCountsQuery.andWhere('sr.siteId = :siteId', { siteId });
        }
        if (assignedTechnicianId) {
            statusCountsQuery.andWhere('sr.assignedTechnicianId = :assignedTechnicianId', {
                assignedTechnicianId,
            });
        }
        if (assignedTeamId) {
            statusCountsQuery.andWhere('sr.assignedTeamId = :assignedTeamId', {
                assignedTeamId,
            });
        }
        if (search) {
            statusCountsQuery.andWhere('(sr.title ILIKE :search OR sr.description ILIKE :search OR sr.requestNumber ILIKE :search)', { search: `%${search}%` });
        }
        const rawCounts = await statusCountsQuery.getRawMany();
        const statusCounts = { all: 0 };
        for (const row of rawCounts) {
            const statusKey = (row.status || 'unknown').toLowerCase().replace(/ /g, '_');
            statusCounts[statusKey] = parseInt(row.count, 10);
            statusCounts.all += parseInt(row.count, 10);
        }
        const queryBuilder = this.requestRepo
            .createQueryBuilder('sr')
            .leftJoinAndSelect('sr.site', 'site')
            .leftJoinAndSelect('sr.assignedTechnician', 'tech')
            .where('sr.companyId = :companyId', { companyId });
        if (status) {
            const statuses = status.split(',').map(s => s.trim().toLowerCase());
            if (statuses.length === 1) {
                queryBuilder.andWhere('LOWER(sr.status) = LOWER(:status)', { status: statuses[0] });
            }
            else {
                queryBuilder.andWhere('LOWER(sr.status) IN (:...statuses)', { statuses });
            }
        }
        if (category) {
            queryBuilder.andWhere('sr.category = :category', { category });
        }
        if (priority) {
            const priorities = priority.split(',').map(p => p.trim().toLowerCase());
            if (priorities.length === 1) {
                queryBuilder.andWhere('LOWER(sr.priority) = LOWER(:priority)', { priority: priorities[0] });
            }
            else {
                queryBuilder.andWhere('LOWER(sr.priority) IN (:...priorities)', { priorities });
            }
        }
        if (siteId) {
            queryBuilder.andWhere('sr.siteId = :siteId', { siteId });
        }
        if (assignedTechnicianId) {
            queryBuilder.andWhere('sr.assignedTechnicianId = :assignedTechnicianId', {
                assignedTechnicianId,
            });
        }
        if (assignedTeamId) {
            queryBuilder.andWhere('sr.assignedTeamId = :assignedTeamId', {
                assignedTeamId,
            });
        }
        if (search) {
            queryBuilder.andWhere('(sr.title ILIKE :search OR sr.description ILIKE :search OR sr.requestNumber ILIKE :search)', { search: `%${search}%` });
        }
        const sortFieldMap = {
            [query_service_request_dto_1.SortField.CREATED_AT]: 'sr.createdAt',
            [query_service_request_dto_1.SortField.UPDATED_AT]: 'sr.updatedAt',
            [query_service_request_dto_1.SortField.TITLE]: 'sr.title',
            [query_service_request_dto_1.SortField.STATUS]: 'sr.status',
            [query_service_request_dto_1.SortField.PRIORITY]: 'sr.priority',
            [query_service_request_dto_1.SortField.REQUEST_NUMBER]: 'sr.requestNumber',
        };
        queryBuilder.orderBy(sortFieldMap[sortBy], sortOrder);
        const skip = (page - 1) * limit;
        queryBuilder.skip(skip).take(limit);
        const [data, total] = await queryBuilder.getManyAndCount();
        const mappedData = data.map((sr) => {
            const tech = sr.assignedTechnician;
            const technicianName = tech
                ? [tech.firstName, tech.lastName]
                    .filter((n) => n && n.trim().length > 0)
                    .join(' ')
                    .trim() || tech.email
                : null;
            return {
                ...sr,
                siteName: sr.site?.name ?? null,
                technicianName,
            };
        });
        return {
            data: mappedData,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
            statusCounts,
        };
    }
    async findOne(companyId, id) {
        const request = await this.requestRepo.findOne({
            where: { id, companyId },
            relations: ['site', 'assignedTechnician'],
        });
        if (!request) {
            throw new common_1.NotFoundException('Service request not found');
        }
        const tech = request.assignedTechnician;
        const technicianName = tech
            ? [tech.firstName, tech.lastName]
                .filter((n) => n && n.trim().length > 0)
                .join(' ')
                .trim() || tech.email
            : null;
        return {
            ...request,
            siteName: request.site?.name ?? null,
            technicianName,
        };
    }
    async update(companyId, id, dto) {
        const request = await this.findOne(companyId, id);
        const updated = Object.assign(request, {
            title: dto.title ?? request.title,
            description: typeof dto.description === 'undefined' ? request.description : dto.description,
            category: dto.category ?? request.category,
            priority: dto.priority ?? request.priority,
            siteId: typeof dto.siteId === 'undefined' ? request.siteId : dto.siteId,
            parentRequestId: typeof dto.parentRequestId === 'undefined' ? request.parentRequestId : dto.parentRequestId,
            assignedTeamId: typeof dto.assignedTeamId === 'undefined' ? request.assignedTeamId : dto.assignedTeamId,
            assignedTechnicianId: typeof dto.assignedTechnicianId === 'undefined'
                ? request.assignedTechnicianId
                : dto.assignedTechnicianId,
        });
        return this.requestRepo.save(updated);
    }
    async changeStatus(companyId, id, userId, dto) {
        const request = await this.findOne(companyId, id);
        const workflow = await this.findApplicableWorkflow(companyId, request.category);
        if (!this.canTransition(workflow, request.status, dto.toStatus)) {
            throw new common_1.BadRequestException(`Invalid status transition from ${request.status} to ${dto.toStatus}`);
        }
        const previousStatus = request.status;
        request.status = dto.toStatus;
        request.slaDueAt = this.calculateSlaDueAt(workflow, request.priority);
        const saved = await this.requestRepo.save(request);
        const transition = this.transitionRepo.create({
            serviceRequest: saved,
            fromStatus: previousStatus,
            toStatus: dto.toStatus,
            changedByUserId: dto.overrideUserId ?? userId,
            reason: dto.reason ?? null,
        });
        await this.transitionRepo.save(transition);
        return saved;
    }
    async configureWorkflow(companyId, dto) {
        const whereCondition = dto.category
            ? { companyId, category: dto.category, name: dto.name }
            : { companyId, category: (0, typeorm_2.IsNull)(), name: dto.name };
        const existing = await this.workflowRepo.findOne({
            where: whereCondition,
        });
        const entity = existing ??
            this.workflowRepo.create({
                companyId,
                name: dto.name,
                category: dto.category ?? null,
            });
        entity.statuses = dto.statuses.map((s) => ({
            code: s.code,
            label: s.label,
            color: s.color,
        }));
        entity.transitions = dto.transitions.map((t) => ({
            from: t.from,
            to: t.to,
            conditionKey: t.conditionKey,
        }));
        entity.slaRules = dto.slaRules
            ? dto.slaRules.map((r) => ({
                matcher: r.matcher,
                slaHours: r.slaHours,
                warnBeforeHours: r.warnBeforeHours,
            }))
            : null;
        return this.workflowRepo.save(entity);
    }
    async getWorkflow(companyId, category) {
        const specific = category
            ? await this.workflowRepo.findOne({ where: { companyId, category } })
            : null;
        if (specific) {
            return specific;
        }
        return this.workflowRepo.findOne({ where: { companyId, category: (0, typeorm_2.IsNull)() } });
    }
    async findApplicableWorkflow(companyId, category) {
        const workflow = await this.getWorkflow(companyId, category);
        if (!workflow) {
            throw new common_1.BadRequestException(`No workflow configured for category ${category}`);
        }
        return workflow;
    }
    getInitialStatus(workflow) {
        const first = Array.isArray(workflow.statuses) ? workflow.statuses[0] : undefined;
        if (!first || typeof first.code !== 'string') {
            throw new common_1.BadRequestException('Workflow is misconfigured: missing initial status');
        }
        return first.code;
    }
    async generateRequestNumber(companyId) {
        const count = await this.requestRepo.count({ where: { companyId } });
        const sequence = count + 1;
        return `SR-${companyId.substring(0, 4).toUpperCase()}-${sequence.toString().padStart(6, '0')}`;
    }
    canTransition(workflow, from, to) {
        const transitions = Array.isArray(workflow.transitions) ? workflow.transitions : [];
        return transitions.some((t) => typeof t.from === 'string' &&
            typeof t.to === 'string' &&
            t.from === from &&
            t.to === to);
    }
    calculateSlaDueAt(workflow, priority) {
        const rules = Array.isArray(workflow.slaRules) ? workflow.slaRules : [];
        const matched = rules.find((r) => typeof r.matcher === 'string' &&
            r.matcher.toLowerCase() === `priority=${priority}`.toLowerCase());
        const hours = matched && typeof matched.slaHours === 'number' ? matched.slaHours : null;
        if (!hours) {
            return null;
        }
        const now = new Date();
        now.setHours(now.getHours() + hours);
        return now;
    }
    async getIssueSubCategories(companyId, category) {
        return this.issueSubCategoryRepo.find({
            where: { companyId, category, isActive: true },
            order: { name: 'ASC' },
        });
    }
};
exports.ServiceRequestService = ServiceRequestService;
exports.ServiceRequestService = ServiceRequestService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(service_request_entity_1.ServiceRequest)),
    __param(1, (0, typeorm_1.InjectRepository)(service_request_status_transition_entity_1.ServiceRequestStatusTransition)),
    __param(2, (0, typeorm_1.InjectRepository)(service_request_workflow_entity_1.ServiceRequestWorkflow)),
    __param(3, (0, typeorm_1.InjectRepository)(issue_sub_category_entity_1.IssueSubCategory)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], ServiceRequestService);
