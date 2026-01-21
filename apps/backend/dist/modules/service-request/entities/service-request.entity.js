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
Object.defineProperty(exports, "__esModule", { value: true });
exports.ServiceRequest = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const service_request_status_transition_entity_1 = require("./service-request-status-transition.entity");
const site_entity_1 = require("../../tenant/entities/site.entity");
const user_entity_1 = require("../../iam/entities/user.entity");
let ServiceRequest = class ServiceRequest extends tenant_base_entity_1.TenantBaseEntity {
};
exports.ServiceRequest = ServiceRequest;
__decorate([
    (0, typeorm_1.Index)(),
    (0, typeorm_1.Column)({ type: 'varchar', length: 64, unique: true }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "requestNumber", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', name: 'site_id', nullable: true }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "siteId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => site_entity_1.Site, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'site_id' }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "site", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', name: 'parent_request_id', nullable: true }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "parentRequestId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => ServiceRequest, (request) => request.children, {
        nullable: true,
    }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "parent", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => ServiceRequest, (request) => request.parent),
    __metadata("design:type", Array)
], ServiceRequest.prototype, "children", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 255 }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "title", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 64 }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "category", void 0);
__decorate([
    (0, typeorm_1.Index)(),
    (0, typeorm_1.Column)({ type: 'varchar', length: 64 }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 64 }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "priority", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', name: 'assigned_team_id', nullable: true }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "assignedTeamId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', name: 'assigned_technician_id', nullable: true }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "assignedTechnicianId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => user_entity_1.User, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'assigned_technician_id' }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "assignedTechnician", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'timestamp with time zone', name: 'sla_due_at', nullable: true }),
    __metadata("design:type", Object)
], ServiceRequest.prototype, "slaDueAt", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'boolean', name: 'is_escalated', default: false }),
    __metadata("design:type", Boolean)
], ServiceRequest.prototype, "isEscalated", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 50, nullable: true, name: 'villa_code' }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "villaCode", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 64, nullable: true }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "type", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true, name: 'space_id' }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "spaceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 64, nullable: true, name: 'sub_category' }),
    __metadata("design:type", String)
], ServiceRequest.prototype, "subCategory", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', nullable: true }),
    __metadata("design:type", Array)
], ServiceRequest.prototype, "attachments", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => service_request_status_transition_entity_1.ServiceRequestStatusTransition, (transition) => transition.serviceRequest),
    __metadata("design:type", Array)
], ServiceRequest.prototype, "transitions", void 0);
exports.ServiceRequest = ServiceRequest = __decorate([
    (0, typeorm_1.Entity)({ name: 'service_requests' })
], ServiceRequest);
