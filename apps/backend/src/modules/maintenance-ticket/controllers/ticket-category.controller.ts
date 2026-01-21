import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  Version,
} from '@nestjs/common';
import { TicketCategoryService } from '../services/ticket-category.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';
import { CurrentUser, CurrentUserData } from '../../iam/decorators/current-user.decorator';
import { RolesGuard, RequireRoles } from '../guards/roles.guard';
import { UserRole } from '../enums/user-role.enum';
import { ApiResponseUtil } from '../../../shared/utils/api-response.util';

@Controller('ticket-categories')
@UseGuards(RolesGuard)
export class TicketCategoryController {
  constructor(private readonly categoryService: TicketCategoryService) {}

  @Post()
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  async create(
    @CurrentUser() user: CurrentUserData,
    @Body() createDto: CreateCategoryDto,
  ) {
    const category = await this.categoryService.create(
      user.companyId,
      user.userId,
      createDto,
    );
    return ApiResponseUtil.created(category, 'Category created successfully');
  }

  @Get()
  @Version('1')
  async findAll(
    @CurrentUser() user: CurrentUserData,
    @Query('active_only') activeOnly?: string,
  ) {
    const active = activeOnly !== 'false';
    const categories = await this.categoryService.findAll(user.companyId, active);
    return ApiResponseUtil.success(categories, 'Categories retrieved successfully');
  }

  @Get('root')
  @Version('1')
  async findRootCategories(
    @CurrentUser() user: CurrentUserData,
    @Query('active_only') activeOnly?: string,
  ) {
    const active = activeOnly !== 'false';
    const categories = await this.categoryService.findRootCategories(
      user.companyId,
      active,
    );
    return ApiResponseUtil.success(categories, 'Root categories retrieved successfully');
  }

  @Get(':id')
  @Version('1')
  async findOne(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const category = await this.categoryService.findOne(user.companyId, id);
    return ApiResponseUtil.success(category, 'Category retrieved successfully');
  }

  @Get('code/:code')
  @Version('1')
  async findByCode(
    @CurrentUser() user: CurrentUserData,
    @Param('code') code: string,
  ) {
    const category = await this.categoryService.findByCode(user.companyId, code);
    return ApiResponseUtil.success(category, 'Category retrieved successfully');
  }

  @Put(':id')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  async update(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
    @Body() updateDto: UpdateCategoryDto,
  ) {
    const category = await this.categoryService.update(
      user.companyId,
      id,
      updateDto,
    );
    return ApiResponseUtil.success(category, 'Category updated successfully');
  }

  @Delete(':id')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async delete(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    await this.categoryService.delete(user.companyId, id);
    return ApiResponseUtil.noContent('Category deleted successfully');
  }

  @Post(':id/deactivate')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async deactivate(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const category = await this.categoryService.deactivate(user.companyId, id);
    return ApiResponseUtil.success(category, 'Category deactivated successfully');
  }

  @Post(':id/activate')
  @Version('1')
  @RequireRoles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  async activate(
    @CurrentUser() user: CurrentUserData,
    @Param('id') id: string,
  ) {
    const category = await this.categoryService.activate(user.companyId, id);
    return ApiResponseUtil.success(category, 'Category activated successfully');
  }
}

