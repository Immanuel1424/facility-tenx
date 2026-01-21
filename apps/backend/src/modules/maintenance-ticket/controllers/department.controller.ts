import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  UseGuards,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Department } from '../entities/department.entity';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RolesGuard, RequireRoles } from '../guards/roles.guard';
import { UserRole } from '../enums/user-role.enum';
import { IsString, IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

class CreateDepartmentDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;

  @IsString()
  @IsOptional()
  description?: string;
}

class UpdateDepartmentDto {
  @IsString()
  @IsOptional()
  @MaxLength(100)
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;
}

@Controller('departments')
@UseGuards(RolesGuard)
export class DepartmentController {
  constructor(
    @InjectRepository(Department)
    private readonly departmentRepository: Repository<Department>,
  ) {}

  @Post()
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  async create(
    @CurrentUser() user: CurrentUserData,
    @Body() createDto: CreateDepartmentDto,
  ) {
    const department = this.departmentRepository.create({
      companyId: user.companyId,
      name: createDto.name,
      description: createDto.description,
      isActive: true,
    });

    return this.departmentRepository.save(department);
  }

  @Get()
  @RequireRoles(
    UserRole.TENANT,
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async findAll(@CurrentUser() user: CurrentUserData) {
    return this.departmentRepository.find({
      where: { companyId: user.companyId, isActive: true },
      order: { name: 'ASC' },
    });
  }

  @Get(':id')
  @RequireRoles(
    UserRole.TENANT,
    UserRole.ADMIN,
    UserRole.SITE_COORDINATOR,
    UserRole.SUPERVISOR,
    UserRole.TECHNICIAN,
  )
  async findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const department = await this.departmentRepository.findOne({
      where: { id, companyId: user.companyId },
    });

    if (!department) {
      throw new NotFoundException('Department not found');
    }

    return department;
  }

  @Put(':id')
  @RequireRoles(UserRole.ADMIN, UserRole.SITE_COORDINATOR)
  async update(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() updateDto: UpdateDepartmentDto,
  ) {
    const department = await this.departmentRepository.findOne({
      where: { id, companyId: user.companyId },
    });

    if (!department) {
      throw new NotFoundException('Department not found');
    }

    if (updateDto.name) {
      department.name = updateDto.name;
    }
    if (updateDto.description !== undefined) {
      department.description = updateDto.description;
    }

    return this.departmentRepository.save(department);
  }
}

