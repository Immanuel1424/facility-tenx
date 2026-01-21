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
exports.Site = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
const company_entity_1 = require("./company.entity");
const user_site_entity_1 = require("./user-site.entity");
let Site = class Site extends tenant_base_entity_1.TenantBaseEntity {
};
exports.Site = Site;
__decorate([
    (0, typeorm_1.ManyToOne)(() => company_entity_1.Company, (company) => company.sites, { nullable: false }),
    (0, typeorm_1.JoinColumn)({ name: 'company_id' }),
    __metadata("design:type", company_entity_1.Company)
], Site.prototype, "company", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 20 }),
    __metadata("design:type", String)
], Site.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 255 }),
    __metadata("design:type", String)
], Site.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], Site.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 500, nullable: true }),
    __metadata("design:type", String)
], Site.prototype, "address", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 100, nullable: true }),
    __metadata("design:type", String)
], Site.prototype, "city", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 100, nullable: true }),
    __metadata("design:type", String)
], Site.prototype, "country", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'boolean', name: 'is_parent', default: true }),
    __metadata("design:type", Boolean)
], Site.prototype, "isParent", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'boolean', name: 'is_active', default: true }),
    __metadata("design:type", Boolean)
], Site.prototype, "isActive", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => Site, (site) => site.childSites, { nullable: true }),
    (0, typeorm_1.JoinColumn)({ name: 'parent_site_id' }),
    __metadata("design:type", Site)
], Site.prototype, "parentSite", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => Site, (site) => site.parentSite),
    __metadata("design:type", Array)
], Site.prototype, "childSites", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => user_site_entity_1.UserSite, (userSite) => userSite.site),
    __metadata("design:type", Array)
], Site.prototype, "userSites", void 0);
exports.Site = Site = __decorate([
    (0, typeorm_1.Entity)({ name: 'sites' }),
    (0, typeorm_1.Index)(['companyId', 'code'], { unique: true }),
    (0, typeorm_1.Index)(['companyId', 'isActive'])
], Site);
