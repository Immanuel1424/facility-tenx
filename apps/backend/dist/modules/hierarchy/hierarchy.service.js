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
exports.HierarchyService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const hierarchy_node_entity_1 = require("./entities/hierarchy-node.entity");
let HierarchyService = class HierarchyService {
    constructor(hierarchyRepository) {
        this.hierarchyRepository = hierarchyRepository;
    }
    async createNode(companyId, dto) {
        const node = this.hierarchyRepository.create({
            ...dto,
            companyId,
        });
        return this.hierarchyRepository.save(node);
    }
    async getSubtree(companyId, rootId) {
        return this.hierarchyRepository.find({
            where: { companyId, parentId: rootId },
        });
    }
};
exports.HierarchyService = HierarchyService;
exports.HierarchyService = HierarchyService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(hierarchy_node_entity_1.HierarchyNode)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], HierarchyService);
