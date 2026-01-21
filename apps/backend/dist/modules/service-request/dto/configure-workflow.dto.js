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
exports.ConfigureWorkflowDto = exports.WorkflowSlaRuleConfigDto = exports.WorkflowTransitionConfigDto = exports.WorkflowStatusConfigDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
class WorkflowStatusConfigDto {
}
exports.WorkflowStatusConfigDto = WorkflowStatusConfigDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'open' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(64),
    __metadata("design:type", String)
], WorkflowStatusConfigDto.prototype, "code", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'Open' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(128),
    __metadata("design:type", String)
], WorkflowStatusConfigDto.prototype, "label", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: '#4caf50' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], WorkflowStatusConfigDto.prototype, "color", void 0);
class WorkflowTransitionConfigDto {
}
exports.WorkflowTransitionConfigDto = WorkflowTransitionConfigDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'open' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(64),
    __metadata("design:type", String)
], WorkflowTransitionConfigDto.prototype, "from", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'in_progress' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(64),
    __metadata("design:type", String)
], WorkflowTransitionConfigDto.prototype, "to", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Optional condition key, evaluated in domain layer' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], WorkflowTransitionConfigDto.prototype, "conditionKey", void 0);
class WorkflowSlaRuleConfigDto {
}
exports.WorkflowSlaRuleConfigDto = WorkflowSlaRuleConfigDto;
__decorate([
    (0, swagger_1.ApiProperty)({ example: 'priority=high' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(128),
    __metadata("design:type", String)
], WorkflowSlaRuleConfigDto.prototype, "matcher", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ example: 4, description: 'SLA in business hours' }),
    (0, class_validator_1.IsNotEmpty)(),
    __metadata("design:type", Number)
], WorkflowSlaRuleConfigDto.prototype, "slaHours", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ example: 1, description: 'Warn before SLA breach (hours)' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], WorkflowSlaRuleConfigDto.prototype, "warnBeforeHours", void 0);
class ConfigureWorkflowDto {
}
exports.ConfigureWorkflowDto = ConfigureWorkflowDto;
__decorate([
    (0, swagger_1.ApiProperty)({ maxLength: 64 }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(64),
    __metadata("design:type", String)
], ConfigureWorkflowDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Category this workflow applies to, or global if omitted' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(64),
    __metadata("design:type", String)
], ConfigureWorkflowDto.prototype, "category", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: [WorkflowStatusConfigDto] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ArrayMinSize)(1),
    __metadata("design:type", Array)
], ConfigureWorkflowDto.prototype, "statuses", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ type: [WorkflowTransitionConfigDto] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ArrayMinSize)(1),
    __metadata("design:type", Array)
], ConfigureWorkflowDto.prototype, "transitions", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ type: [WorkflowSlaRuleConfigDto] }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsArray)(),
    __metadata("design:type", Array)
], ConfigureWorkflowDto.prototype, "slaRules", void 0);
