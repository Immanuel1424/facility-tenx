import {
  IsString,
  IsOptional,
  IsUUID,
  IsBoolean,
  IsInt,
  MaxLength,
  Min,
  Matches,
} from 'class-validator';
import { Expose } from 'class-transformer';

export class UpdateCategoryDto {
  @Expose()
  @IsString()
  @MaxLength(100)
  @IsOptional()
  name?: string;

  @Expose()
  @IsString()
  @IsOptional()
  description?: string;

  @Expose()
  @IsUUID()
  @IsOptional()
  parent_category_id?: string;

  @Expose()
  @IsInt()
  @Min(0)
  @IsOptional()
  display_order?: number;

  @Expose()
  @IsBoolean()
  @IsOptional()
  is_active?: boolean;

  @Expose()
  @IsString()
  @MaxLength(50)
  @IsOptional()
  icon?: string;

  @Expose()
  @IsString()
  @Matches(/^#[0-9A-Fa-f]{6}$/, {
    message: 'color_code must be a valid hex color (e.g., #FF5733)',
  })
  @IsOptional()
  color_code?: string;

  @Expose()
  @IsInt()
  @Min(1)
  @IsOptional()
  default_sla_hours?: number;

  @Expose()
  @IsUUID()
  @IsOptional()
  default_department_id?: string;
}

