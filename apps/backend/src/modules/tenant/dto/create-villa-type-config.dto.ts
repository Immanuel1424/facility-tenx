import {
  IsString,
  IsInt,
  IsNumber,
  IsBoolean,
  IsOptional,
  MaxLength,
  Min,
  ValidateIf,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateVillaTypeConfigDto {
  @ApiProperty({
    description: 'Villa type code (e.g., 1BHK, 2BHK, Studio, Duplex)',
    example: '1BHK',
    maxLength: 50,
  })
  @IsString()
  @MaxLength(50)
  villaType!: string;

  @ApiPropertyOptional({
    description: 'Display name for the villa type (e.g., "1 Bedroom Hall Kitchen")',
    example: '1 Bedroom Hall Kitchen',
    maxLength: 255,
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  displayName?: string;

  @ApiPropertyOptional({
    description: 'Default bedroom count. Auto-filled when creating a villa with this type.',
    example: 1,
    minimum: 0,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  defaultBedroomCount?: number;

  @ApiPropertyOptional({
    description: 'Default floor count. Auto-filled when creating a villa with this type.',
    example: 1,
    minimum: 0,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  defaultFloorCount?: number;

  @ApiPropertyOptional({
    description: 'Default area in square meters. Auto-filled when creating a villa with this type.',
    example: 50.5,
    minimum: 0,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  defaultAreaSqm?: number;

  @ApiPropertyOptional({
    description: 'Display order for dropdowns/lists. Lower numbers appear first.',
    example: 0,
    default: 0,
  })
  @IsOptional()
  @IsInt()
  displayOrder?: number;

  @ApiPropertyOptional({
    description: 'Whether this configuration is active',
    example: true,
    default: true,
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({
    description: 'Additional metadata (JSON object)',
    example: { description: 'Standard 1 bedroom apartment', amenities: ['parking', 'balcony'] },
  })
  @IsOptional()
  metadata?: Record<string, unknown>;
}

