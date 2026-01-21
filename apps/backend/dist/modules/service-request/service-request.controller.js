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
exports.ServiceRequestController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const service_request_service_1 = require("./service-request.service");
const create_service_request_dto_1 = require("./dto/create-service-request.dto");
const update_service_request_dto_1 = require("./dto/update-service-request.dto");
const change_status_dto_1 = require("./dto/change-status.dto");
const configure_workflow_dto_1 = require("./dto/configure-workflow.dto");
const query_service_request_dto_1 = require("./dto/query-service-request.dto");
const tenant_guard_1 = require("../../shared/guards/tenant.guard");
const jwt_auth_guard_1 = require("../../modules/auth/guards/jwt-auth.guard");
let ServiceRequestController = class ServiceRequestController {
    constructor(service) {
        this.service = service;
    }
    async create(dto, req) {
        return this.service.create(req.companyId, dto);
    }
    async findAll(query, req) {
        return this.service.findAll(req.companyId, query);
    }
    async findOne(id, req) {
        return this.service.findOne(req.companyId, id);
    }
    async update(id, dto, req) {
        return this.service.update(req.companyId, id, dto);
    }
    async changeStatus(id, dto, req) {
        return this.service.changeStatus(req.companyId, id, req.user.userId, dto);
    }
    async configureWorkflow(dto, req) {
        return this.service.configureWorkflow(req.companyId, dto);
    }
    async getWorkflow(category, req) {
        return this.service.getWorkflow(req.companyId, category);
    }
    async getIssueSubCategories(category, req) {
        if (!category) {
            return [];
        }
        return this.service.getIssueSubCategories(req.companyId, category);
    }
};
exports.ServiceRequestController = ServiceRequestController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Create a new service request' }),
    (0, swagger_1.ApiCreatedResponse)({ description: 'Service request created' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_service_request_dto_1.CreateServiceRequestDto, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({
        summary: 'List service requests for current tenant',
        description: 'Returns paginated list of service requests with filtering and sorting options'
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Paginated list of service requests' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [query_service_request_dto_1.QueryServiceRequestDto, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get details of a service request' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Service request details' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Update a service request' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Updated service request' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_service_request_dto_1.UpdateServiceRequestDto, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "update", null);
__decorate([
    (0, common_1.Patch)(':id/status'),
    (0, swagger_1.ApiOperation)({ summary: 'Change status of a service request' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Service request with updated status' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, change_status_dto_1.ChangeStatusDto, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "changeStatus", null);
__decorate([
    (0, common_1.Post)('workflow'),
    (0, swagger_1.ApiOperation)({
        summary: 'Configure workflow for a tenant',
        description: 'Configures statuses, transitions, and SLA rules for a particular category or global workflow.',
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'Configured workflow' }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [configure_workflow_dto_1.ConfigureWorkflowDto, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "configureWorkflow", null);
__decorate([
    (0, common_1.Get)('workflow/:category?'),
    (0, swagger_1.ApiOperation)({ summary: 'Get workflow configuration' }),
    (0, swagger_1.ApiOkResponse)({ description: 'Workflow configuration for a category or default' }),
    __param(0, (0, common_1.Param)('category')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "getWorkflow", null);
__decorate([
    (0, common_1.Get)('issue-sub-categories'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get issue sub categories',
        description: 'Returns a list of issue sub categories filtered by parent category'
    }),
    (0, swagger_1.ApiOkResponse)({ description: 'List of issue sub categories' }),
    __param(0, (0, common_1.Query)('category')),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], ServiceRequestController.prototype, "getIssueSubCategories", null);
exports.ServiceRequestController = ServiceRequestController = __decorate([
    (0, swagger_1.ApiTags)('service-requests'),
    (0, swagger_1.ApiBearerAuth)('access-token'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, tenant_guard_1.TenantGuard),
    (0, common_1.Controller)('service-requests'),
    __metadata("design:paramtypes", [service_request_service_1.ServiceRequestService])
], ServiceRequestController);
