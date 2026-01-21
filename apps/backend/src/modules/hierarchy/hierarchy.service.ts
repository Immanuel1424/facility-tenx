import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HierarchyNode } from './entities/hierarchy-node.entity';
import { CreateHierarchyNodeDto } from './dto/create-hierarchy-node.dto';

@Injectable()
export class HierarchyService {
  constructor(
    @InjectRepository(HierarchyNode)
    private readonly hierarchyRepository: Repository<HierarchyNode>,
  ) {}

  async createNode(
    companyId: string,
    dto: CreateHierarchyNodeDto,
  ): Promise<HierarchyNode> {
    const node = this.hierarchyRepository.create({
      ...dto,
      companyId,
    });
    return this.hierarchyRepository.save(node);
  }

  async getSubtree(companyId: string, rootId: string): Promise<HierarchyNode[]> {
    return this.hierarchyRepository.find({
      where: { companyId, parentId: rootId },
    });
  }
}


