import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Role } from '../entities/role.entity';
import { CreateRoleDto } from '../dto/create-role.dto';
import { UpdateRoleDto } from '../dto/update-role.dto';

@Injectable()
export class RoleService {
  constructor(
    @InjectRepository(Role)
    private readonly roleRepository: Repository<Role>,
  ) {}

  async findAll(companyId: string): Promise<Role[]> {
    return this.roleRepository.find({
      where: { companyId },
      relations: ['parentRole'],
      order: { hierarchyLevel: 'DESC', name: 'ASC' },
    });
  }

  async findOne(companyId: string, id: string): Promise<Role> {
    const role = await this.roleRepository.findOne({
      where: { companyId, id },
      relations: ['parentRole', 'rolePermissions', 'rolePermissions.permission'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${id} not found`);
    }

    return role;
  }

  async create(companyId: string, dto: CreateRoleDto): Promise<Role> {
    // Use snake_case fields (always snake_case)
    const hierarchyLevel = dto.hierarchy_level ?? 0;
    const parentRoleId = dto.parent_role_id;

    // Check if role name already exists for this company
    const existing = await this.roleRepository.findOne({
      where: { companyId, name: dto.name },
    });

    if (existing) {
      throw new BadRequestException(
        `Role with name "${dto.name}" already exists`,
      );
    }

    // Validate parent role if provided
    if (parentRoleId) {
      const parentRole = await this.roleRepository.findOne({
        where: { companyId, id: parentRoleId },
      });

      if (!parentRole) {
        throw new NotFoundException(
          `Parent role with ID ${parentRoleId} not found`,
        );
      }
    }

    const role = this.roleRepository.create({
      companyId,
      name: dto.name,
      description: dto.description,
      hierarchyLevel,
      parentRoleId,
    });

    return this.roleRepository.save(role);
  }

  async update(
    companyId: string,
    id: string,
    dto: UpdateRoleDto,
  ): Promise<Role> {
    const role = await this.findOne(companyId, id);

    // Check if name change would conflict
    if (dto.name && dto.name !== role.name) {
      const existing = await this.roleRepository.findOne({
        where: { companyId, name: dto.name },
      });

      if (existing) {
        throw new BadRequestException(
          `Role with name "${dto.name}" already exists`,
        );
      }
    }

    // Validate parent role if provided
    if (dto.parentRoleId && dto.parentRoleId !== role.parentRoleId) {
      if (dto.parentRoleId === id) {
        throw new BadRequestException('Role cannot be its own parent');
      }

      const parentRole = await this.roleRepository.findOne({
        where: { companyId, id: dto.parentRoleId },
      });

      if (!parentRole) {
        throw new NotFoundException(
          `Parent role with ID ${dto.parentRoleId} not found`,
        );
      }

      // Check for circular references
      const wouldCreateCycle = await this.wouldCreateCycle(
        companyId,
        id,
        dto.parentRoleId,
      );
      if (wouldCreateCycle) {
        throw new BadRequestException(
          'Setting this parent role would create a circular reference',
        );
      }
    }

    Object.assign(role, {
      name: dto.name ?? role.name,
      description: dto.description !== undefined ? dto.description : role.description,
      hierarchyLevel: dto.hierarchyLevel ?? role.hierarchyLevel,
      parentRoleId: dto.parentRoleId !== undefined ? dto.parentRoleId : role.parentRoleId,
    });

    return this.roleRepository.save(role);
  }

  async delete(companyId: string, id: string): Promise<void> {
    const role = await this.findOne(companyId, id);

    // Check if role has child roles
    const childRoles = await this.roleRepository.find({
      where: { companyId, parentRoleId: id },
    });

    if (childRoles.length > 0) {
      throw new BadRequestException(
        `Cannot delete role: it has ${childRoles.length} child role(s). Please reassign or delete child roles first.`,
      );
    }

    await this.roleRepository.remove(role);
  }

  private async wouldCreateCycle(
    companyId: string,
    roleId: string,
    parentRoleId: string,
  ): Promise<boolean> {
    let currentParentId: string | null = parentRoleId;

    while (currentParentId) {
      if (currentParentId === roleId) {
        return true;
      }

      const parent = await this.roleRepository.findOne({
        where: { companyId, id: currentParentId },
      });

      if (!parent || !parent.parentRoleId) {
        break;
      }

      currentParentId = parent.parentRoleId;
    }

    return false;
  }
}

