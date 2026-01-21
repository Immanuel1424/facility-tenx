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
exports.CreateSiteDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateSiteDto {
}
exports.CreateSiteDto = CreateSiteDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        maxLength: 20,
        minLength: 3,
        description: 'Unique site code (uppercase letters and hyphens, 3-20 chars). If not provided, will be auto-generated from site name.',
        example: 'WIPRO-CHE'
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(3, { message: 'Site code must be at least 3 characters long' }),
    (0, class_validator_1.MaxLength)(20, { message: 'Site code must not exceed 20 characters' }),
    (0, class_validator_1.Matches)(/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/, { message: 'Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.' }),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "code", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        maxLength: 255,
        description: 'Site name',
        example: 'New York Headquarters'
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(255),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: 'Whether this site is a parent site. If false, parentSiteId must be provided.',
        example: true
    }),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], CreateSiteDto.prototype, "isParent", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'Parent site ID. Required if isParent is false.',
        example: '123e4567-e89b-12d3-a456-426614174000',
        format: 'uuid'
    }),
    (0, class_validator_1.ValidateIf)((o) => !o.isParent),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "parentSiteId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'Whether to create an admin user for this site. Defaults to true.',
        example: true,
        default: true
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsBoolean)(),
    __metadata("design:type", Boolean)
], CreateSiteDto.prototype, "createAdmin", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'Email for the site admin user. Required if createAdmin is true.',
        example: 'admin@example.com'
    }),
    (0, class_validator_1.ValidateIf)((o) => o.createAdmin !== false),
    (0, class_validator_1.IsEmail)({}, { message: 'Admin email must be a valid email address' }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "adminEmail", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'Password for the site admin user. Required if createAdmin is true.',
        example: 'Admin@2025!',
        minLength: 8
    }),
    (0, class_validator_1.ValidateIf)((o) => o.createAdmin !== false),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(8, { message: 'Admin password must be at least 8 characters long' }),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "adminPassword", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'First name for the site admin user.',
        example: 'John',
        maxLength: 100
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "adminFirstName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'Last name for the site admin user.',
        example: 'Doe',
        maxLength: 100
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "adminLastName", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: 'Company ID for site creation (SUPER_ADMIN only). If not provided, uses authenticated user\'s company.',
        format: 'uuid'
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsUUID)(),
    __metadata("design:type", String)
], CreateSiteDto.prototype, "companyId", void 0);
