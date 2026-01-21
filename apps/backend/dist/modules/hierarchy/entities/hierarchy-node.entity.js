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
exports.HierarchyNode = void 0;
const typeorm_1 = require("typeorm");
const tenant_base_entity_1 = require("../../../shared/database/tenant-base.entity");
let HierarchyNode = class HierarchyNode extends tenant_base_entity_1.TenantBaseEntity {
};
exports.HierarchyNode = HierarchyNode;
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 100 }),
    __metadata("design:type", String)
], HierarchyNode.prototype, "type", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 255 }),
    __metadata("design:type", String)
], HierarchyNode.prototype, "name", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'varchar', length: 255, nullable: true }),
    __metadata("design:type", String)
], HierarchyNode.prototype, "externalId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'uuid', nullable: true }),
    __metadata("design:type", String)
], HierarchyNode.prototype, "parentId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => HierarchyNode, (node) => node.children, {
        nullable: true,
        onDelete: 'CASCADE',
    }),
    __metadata("design:type", HierarchyNode)
], HierarchyNode.prototype, "parent", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => HierarchyNode, (node) => node.parent),
    __metadata("design:type", Array)
], HierarchyNode.prototype, "children", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'jsonb', nullable: true }),
    __metadata("design:type", Object)
], HierarchyNode.prototype, "metadata", void 0);
exports.HierarchyNode = HierarchyNode = __decorate([
    (0, typeorm_1.Entity)('hierarchy_nodes'),
    (0, typeorm_1.Index)(['companyId', 'type']),
    (0, typeorm_1.Index)(['companyId', 'externalId'])
], HierarchyNode);
