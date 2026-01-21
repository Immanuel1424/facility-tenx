import { IsString, IsUUID, MaxLength, MinLength, IsOptional, IsBoolean, Matches, ValidateIf } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateSiteDto {
  @ApiPropertyOptional({ 
    maxLength: 20, 
    minLength: 3,
    description: 'Unique site code (uppercase letters and hyphens, 3-20 chars)',
    example: 'WIPRO-CHE'
  })
  @IsOptional()
  @IsString()
  @MinLength(3, { message: 'Site code must be at least 3 characters long' })
  @MaxLength(20, { message: 'Site code must not exceed 20 characters' })
  @Matches(/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/, { message: 'Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.' })
  code?: string;

  @ApiPropertyOptional({ 
    maxLength: 255, 
    description: 'Site name',
    example: 'Updated Site Name'
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  name?: string;

  @ApiPropertyOptional({ 
    description: 'Whether this site is a parent site. If false, parentSiteId must be provided.',
    example: true
  })
  @IsOptional()
  @IsBoolean()
  isParent?: boolean;

  @ApiPropertyOptional({ 
    description: 'Parent site ID. Required if isParent is false.',
    example: '123e4567-e89b-12d3-a456-426614174000',
    format: 'uuid'
  })
  @ValidateIf((o) => o.isParent === false)
  @IsOptional()
  @IsUUID()
  parentSiteId?: string;
}

