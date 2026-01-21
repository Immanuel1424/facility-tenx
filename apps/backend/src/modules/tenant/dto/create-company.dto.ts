import {
  IsString,
  MaxLength,
  IsOptional,
  IsBoolean,
  IsUrl,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCompanyDto {
  @ApiProperty({ maxLength: 100, description: 'Unique company code' })
  @IsString()
  @MaxLength(100)
  code!: string;

  @ApiProperty({ maxLength: 255, description: 'Company name' })
  @IsString()
  @MaxLength(255)
  name!: string;

  @ApiPropertyOptional({
    description: 'Company description',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    maxLength: 255,
    description: 'Company logo URL',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  logoUrl?: string;

  @ApiPropertyOptional({
    maxLength: 100,
    description: 'Company timezone (e.g., UTC, America/New_York)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  timezone?: string;

  @ApiPropertyOptional({
    maxLength: 10,
    description: 'Company currency code (e.g., USD, EUR, AED)',
  })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  currency?: string;

  @ApiPropertyOptional({
    description: 'Whether the company is active',
    default: true,
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}


