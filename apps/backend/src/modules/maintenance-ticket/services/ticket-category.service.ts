import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { TicketCategory } from '../entities/ticket-category.entity';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';
import {
  ResourceNotFoundException,
  DuplicateResourceException,
} from '../../../shared/exceptions/business.exception';

@Injectable()
export class TicketCategoryService {
  constructor(
    @InjectRepository(TicketCategory)
    private readonly categoryRepository: Repository<TicketCategory>,
  ) {}

  /**
   * Extract base code from category name (uppercase letters and numbers, max 50 chars)
   */
  private extractBaseCodeFromName(name: string): string {
    // Extract only letters and numbers, convert to uppercase
    const alphanumeric = name.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
    // Take first 50 characters, minimum 3
    if (alphanumeric.length < 3) {
      return 'CAT';
    }
    return alphanumeric.substring(0, Math.min(50, alphanumeric.length));
  }

  /**
   * Generate unique category code (max 50 characters)
   */
  private async generateCategoryCode(
    baseCode: string,
    companyId: string,
  ): Promise<string> {
    // Start with the base code
    let code = baseCode;
    let suffix = '';

    // Try base code first
    let existingCategory = await this.categoryRepository.findOne({
      where: { code, companyId },
    });

    if (!existingCategory) {
      return code;
    }

    // If base code exists, try appending numbers (1, 2, 3, ...)
    const availableLength = 50 - baseCode.length;

    if (availableLength >= 1) {
      for (let i = 1; i < 10000; i++) {
        suffix = i.toString();
        const newCode = baseCode + suffix;

        if (newCode.length <= 50) {
          existingCategory = await this.categoryRepository.findOne({
            where: { code: newCode, companyId },
          });

          if (!existingCategory) {
            return newCode;
          }
        } else {
          break;
        }
      }
    }

    // If still not unique, try with shorter base and longer suffix
    if (baseCode.length >= 10) {
      const shorterBase = baseCode.substring(0, baseCode.length - 1);
      for (let i = 1; i < 10000; i++) {
        suffix = i.toString();
        const newCode = shorterBase + suffix;

        if (newCode.length <= 50) {
          existingCategory = await this.categoryRepository.findOne({
            where: { code: newCode, companyId },
          });

          if (!existingCategory) {
            return newCode;
          }
        } else {
          break;
        }
      }
    }

    // Last resort: generate random alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let attempts = 0;
    while (attempts < 1000) {
      code = '';
      for (let i = 0; i < Math.min(50, baseCode.length + 5); i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }

      existingCategory = await this.categoryRepository.findOne({
        where: { code, companyId },
      });

      if (!existingCategory) {
        return code;
      }
      attempts++;
    }

    throw new BadRequestException(
      'Unable to generate unique category code. Please provide a code manually.',
    );
  }

  async create(
    companyId: string,
    userId: string,
    createDto: CreateCategoryDto,
  ): Promise<TicketCategory> {
    // Generate code if not provided
    let categoryCode: string;
    if (createDto.code) {
      categoryCode = createDto.code.toUpperCase().trim();
      // Validate code format (alphanumeric, hyphens, underscores)
      if (!/^[A-Z0-9_-]+$/.test(categoryCode)) {
        throw new BadRequestException(
          'Category code must contain only uppercase letters, numbers, hyphens, and underscores',
        );
      }
      if (categoryCode.length < 1 || categoryCode.length > 50) {
        throw new BadRequestException(
          'Category code must be between 1 and 50 characters long',
        );
      }

      // Check for duplicate code within company (only needed for manually provided codes)
      const existing = await this.categoryRepository.findOne({
        where: { companyId, code: categoryCode },
      });

      if (existing) {
        throw new DuplicateResourceException('Category', 'code', categoryCode);
      }
    } else {
      // Auto-generate code from name (already ensures uniqueness)
      const baseCode = this.extractBaseCodeFromName(createDto.name);
      categoryCode = await this.generateCategoryCode(baseCode, companyId);
    }

    // Validate parent category if provided
    if (createDto.parent_category_id) {
      const parentCategory = await this.categoryRepository.findOne({
        where: { id: createDto.parent_category_id, companyId },
      });

      if (!parentCategory) {
        throw new ResourceNotFoundException('Parent category', createDto.parent_category_id);
      }
    }

    const category = this.categoryRepository.create({
      companyId,
      code: categoryCode,
      name: createDto.name,
      description: createDto.description,
      parentCategoryId: createDto.parent_category_id,
      displayOrder: createDto.display_order ?? 0,
      icon: createDto.icon,
      colorCode: createDto.color_code,
      defaultSlaHours: createDto.default_sla_hours,
      defaultDepartmentId: createDto.default_department_id,
      createdById: userId,
    });

    return this.categoryRepository.save(category);
  }

  async findAll(
    companyId: string,
    activeOnly = true,
  ): Promise<TicketCategory[]> {
    const whereClause: Record<string, unknown> = { companyId };

    if (activeOnly) {
      whereClause.isActive = true;
    }

    return this.categoryRepository.find({
      where: whereClause,
      relations: ['subCategories'],
      order: { displayOrder: 'ASC', name: 'ASC' },
    });
  }

  async findRootCategories(
    companyId: string,
    activeOnly = true,
  ): Promise<TicketCategory[]> {
    const whereClause: Record<string, unknown> = {
      companyId,
      parentCategoryId: IsNull(),
    };

    if (activeOnly) {
      whereClause.isActive = true;
    }

    return this.categoryRepository.find({
      where: whereClause,
      relations: ['subCategories'],
      order: { displayOrder: 'ASC', name: 'ASC' },
    });
  }

  async findOne(companyId: string, categoryId: string): Promise<TicketCategory> {
    const category = await this.categoryRepository.findOne({
      where: { id: categoryId, companyId },
      relations: ['subCategories', 'parentCategory'],
    });

    if (!category) {
      throw new ResourceNotFoundException('Category', categoryId);
    }

    return category;
  }

  async findByCode(companyId: string, code: string): Promise<TicketCategory> {
    const category = await this.categoryRepository.findOne({
      where: { code, companyId },
      relations: ['subCategories', 'parentCategory'],
    });

    if (!category) {
      throw new ResourceNotFoundException('Category', code);
    }

    return category;
  }

  async update(
    companyId: string,
    categoryId: string,
    updateDto: UpdateCategoryDto,
  ): Promise<TicketCategory> {
    const category = await this.findOne(companyId, categoryId);

    // Validate parent category if provided
    if (updateDto.parent_category_id) {
      if (updateDto.parent_category_id === categoryId) {
        throw new Error('Category cannot be its own parent');
      }

      const parentCategory = await this.categoryRepository.findOne({
        where: { id: updateDto.parent_category_id, companyId },
      });

      if (!parentCategory) {
        throw new ResourceNotFoundException('Parent category', updateDto.parent_category_id);
      }

      // Check for circular reference
      const isCircular = await this.checkCircularReference(
        companyId,
        categoryId,
        updateDto.parent_category_id,
      );

      if (isCircular) {
        throw new Error('Circular reference detected in category hierarchy');
      }
    }

    if (updateDto.name !== undefined) {
      category.name = updateDto.name;
    }
    if (updateDto.description !== undefined) {
      category.description = updateDto.description;
    }
    if (updateDto.parent_category_id !== undefined) {
      category.parentCategoryId = updateDto.parent_category_id;
    }
    if (updateDto.display_order !== undefined) {
      category.displayOrder = updateDto.display_order;
    }
    if (updateDto.is_active !== undefined) {
      category.isActive = updateDto.is_active;
    }
    if (updateDto.icon !== undefined) {
      category.icon = updateDto.icon;
    }
    if (updateDto.color_code !== undefined) {
      category.colorCode = updateDto.color_code;
    }
    if (updateDto.default_sla_hours !== undefined) {
      category.defaultSlaHours = updateDto.default_sla_hours;
    }
    if (updateDto.default_department_id !== undefined) {
      category.defaultDepartmentId = updateDto.default_department_id;
    }

    return this.categoryRepository.save(category);
  }

  async delete(companyId: string, categoryId: string): Promise<void> {
    const category = await this.findOne(companyId, categoryId);

    // Check if category has subcategories
    if (category.subCategories && category.subCategories.length > 0) {
      throw new Error('Cannot delete category with subcategories');
    }

    await this.categoryRepository.remove(category);
  }

  async deactivate(companyId: string, categoryId: string): Promise<TicketCategory> {
    const category = await this.findOne(companyId, categoryId);
    category.isActive = false;
    return this.categoryRepository.save(category);
  }

  async activate(companyId: string, categoryId: string): Promise<TicketCategory> {
    const category = await this.findOne(companyId, categoryId);
    category.isActive = true;
    return this.categoryRepository.save(category);
  }

  private async checkCircularReference(
    companyId: string,
    categoryId: string,
    newParentId: string,
  ): Promise<boolean> {
    let currentParentId: string | undefined = newParentId;

    while (currentParentId) {
      if (currentParentId === categoryId) {
        return true;
      }

      const parentCategory = await this.categoryRepository.findOne({
        where: { id: currentParentId, companyId },
      });

      currentParentId = parentCategory?.parentCategoryId;
    }

    return false;
  }
}

