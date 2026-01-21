"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ServiceRequestModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const service_request_entity_1 = require("./entities/service-request.entity");
const service_request_status_transition_entity_1 = require("./entities/service-request-status-transition.entity");
const service_request_workflow_entity_1 = require("./entities/service-request-workflow.entity");
const issue_sub_category_entity_1 = require("./entities/issue-sub-category.entity");
const service_request_service_1 = require("./service-request.service");
const service_request_controller_1 = require("./service-request.controller");
let ServiceRequestModule = class ServiceRequestModule {
};
exports.ServiceRequestModule = ServiceRequestModule;
exports.ServiceRequestModule = ServiceRequestModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forFeature([
                service_request_entity_1.ServiceRequest,
                service_request_status_transition_entity_1.ServiceRequestStatusTransition,
                service_request_workflow_entity_1.ServiceRequestWorkflow,
                issue_sub_category_entity_1.IssueSubCategory,
            ]),
        ],
        controllers: [service_request_controller_1.ServiceRequestController],
        providers: [service_request_service_1.ServiceRequestService],
        exports: [service_request_service_1.ServiceRequestService],
    })
], ServiceRequestModule);
