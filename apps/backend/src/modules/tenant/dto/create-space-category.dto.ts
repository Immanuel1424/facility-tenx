import { IsString, MaxLength, IsOptional, IsBoolean, Matches, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSpaceCategoryDto {
  @ApiPropertyOptional({ 
    maxLength: 5, 
    minLength: 3,
    description: 'Unique space category code (letters only, uppercase, 3-5 chars). If not provided, will be auto-generated from category name.',
    example: 'OFFIC'
  })
  @IsOptional()
  @IsString()
  @MinLength(3, { message: 'Space category code must be at least 3 characters long' })
  @MaxLength(5, { message: 'Space category code must not exceed 5 characters' })
  @Matches(/^[A-Z]+$/, { message: 'Space category code must contain only uppercase letters (A-Z)' })
  code?: string;

  @ApiProperty({ 
    maxLength: 255, 
    description: 'Space category name',
    example: 'Office Space'
  })
  @IsString()
  @MaxLength(255)
  name!: string;

  @ApiPropertyOptional({ 
    description: 'Space category description',
    example: 'Standard office workspace'
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ 
    description: 'Whether the category is active',
    example: true,
    default: true
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

