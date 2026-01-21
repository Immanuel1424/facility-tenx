import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsString,
  IsOptional,
  MinLength,
  MaxLength,
  IsArray,
  IsDateString,
  IsBoolean,
  IsUUID,
} from 'class-validator';

export class CreateUserDto {
  @ApiProperty()
  @IsEmail()
  @MaxLength(255)
  email!: string;

  @ApiProperty({ description: 'Password (minimum 8 characters)' })
  @IsString()
  @MinLength(8)
  password!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(100)
  firstName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(100)
  lastName?: string;
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phoneNumber?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(20)
  alternatePhoneNumber?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  leaseExpiryDate?: Date;
  @ApiPropertyOptional({ description: 'Villa number for tenant users' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  villaNumber?: string;

  @ApiPropertyOptional({ description: 'List of villa numbers for tenant users' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  villaNumbers?: string[];

  @ApiPropertyOptional({ description: 'Role ID to assign to user' })
  @IsOptional()
  @IsString()
  roleId?: string;

  @ApiPropertyOptional({ description: 'Department ID to assign to user' })
  @IsOptional()
  @IsString()
  departmentId?: string;

  @ApiPropertyOptional({ description: 'Send credentials via email to the user' })
  @IsOptional()
  @IsBoolean()
  sendCredentialsViaEmail?: boolean;

  @ApiPropertyOptional({ description: 'Force user to change password on first login' })
  @IsOptional()
  @IsBoolean()
  forcePasswordChangeOnFirstLogin?: boolean;

  @ApiPropertyOptional({ description: 'User status (active, inactive, suspended)', enum: ['active', 'inactive', 'suspended'] })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: 'Employee ID/Staff ID for internal users' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  employeeId?: string;

  @ApiPropertyOptional({ description: 'Job title/designation for internal users' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  designation?: string;

  @ApiPropertyOptional({ description: 'Joining/hire date for internal users' })
  @IsOptional()
  @IsDateString()
  joiningDate?: Date;

  @ApiPropertyOptional({ description: 'Emergency contact name' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  emergencyContactName?: string;

  @ApiPropertyOptional({ description: 'Emergency contact phone number' })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  emergencyContactPhone?: string;

  @ApiPropertyOptional({ description: 'Admin notes/comments about the user' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  notes?: string;

  @ApiPropertyOptional({ 
    description: 'Company ID for user creation (SUPER_ADMIN only). If not provided, uses authenticated user\'s company.',
    format: 'uuid'
  })
  @IsOptional()
  @IsUUID()
  companyId?: string;

  @ApiPropertyOptional({ 
    description: 'Site ID to assign user to. If not provided and user has TENANT role, will use current user\'s site.',
    format: 'uuid'
  })
  @IsOptional()
  @IsUUID()
  siteId?: string;
}


