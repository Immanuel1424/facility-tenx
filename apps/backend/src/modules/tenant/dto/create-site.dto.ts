import { IsString, IsUUID, MaxLength, MinLength, IsOptional, IsBoolean, ValidateIf, Matches, IsEmail } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSiteDto {
  @ApiPropertyOptional({ 
    maxLength: 20, 
    minLength: 3,
    description: 'Unique site code (uppercase letters and hyphens, 3-20 chars). If not provided, will be auto-generated from site name.',
    example: 'WIPRO-CHE'
  })
  @IsOptional()
  @IsString()
  @MinLength(3, { message: 'Site code must be at least 3 characters long' })
  @MaxLength(20, { message: 'Site code must not exceed 20 characters' })
  @Matches(/^[A-Z][A-Z0-9-]*[A-Z0-9]$|^[A-Z]$/, { message: 'Site code must contain only uppercase letters (A-Z), numbers (0-9), and hyphens (-). Must start and end with a letter or number.' })
  code?: string;

  @ApiProperty({ 
    maxLength: 255, 
    description: 'Site name',
    example: 'New York Headquarters'
  })
  @IsString()
  @MaxLength(255)
  name!: string;

  @ApiProperty({ 
    description: 'Whether this site is a parent site. If false, parentSiteId must be provided.',
    example: true
  })
  @IsBoolean()
  isParent!: boolean;

  @ApiPropertyOptional({ 
    description: 'Parent site ID. Required if isParent is false.',
    example: '123e4567-e89b-12d3-a456-426614174000',
    format: 'uuid'
  })
  @ValidateIf((o) => !o.isParent)
  @IsUUID()
  parentSiteId?: string;

  @ApiPropertyOptional({ 
    description: 'Whether to create an admin user for this site. Defaults to true.',
    example: true,
    default: true
  })
  @IsOptional()
  @IsBoolean()
  createAdmin?: boolean;

  @ApiPropertyOptional({ 
    description: 'Email for the site admin user. Required if createAdmin is true.',
    example: 'admin@example.com'
  })
  @ValidateIf((o) => o.createAdmin !== false)
  @IsEmail({}, { message: 'Admin email must be a valid email address' })
  @IsString()
  adminEmail?: string;

  @ApiPropertyOptional({ 
    description: 'Password for the site admin user. Required if createAdmin is true.',
    example: 'Admin@2025!',
    minLength: 8
  })
  @ValidateIf((o) => o.createAdmin !== false)
  @IsString()
  @MinLength(8, { message: 'Admin password must be at least 8 characters long' })
  adminPassword?: string;

  @ApiPropertyOptional({ 
    description: 'First name for the site admin user.',
    example: 'John',
    maxLength: 100
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  adminFirstName?: string;

  @ApiPropertyOptional({ 
    description: 'Last name for the site admin user.',
    example: 'Doe',
    maxLength: 100
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  adminLastName?: string;

  @ApiPropertyOptional({ 
    description: 'Company ID for site creation (SUPER_ADMIN only). If not provided, uses authenticated user\'s company.',
    format: 'uuid'
  })
  @IsOptional()
  @IsUUID()
  companyId?: string;
}


