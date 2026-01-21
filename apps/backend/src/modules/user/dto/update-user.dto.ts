import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsOptional, IsString, MaxLength, IsEnum, IsDateString, IsArray } from 'class-validator';
import { UserStatus } from '../../iam/entities/user.entity';

export class UpdateUserDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsEmail()
  @MaxLength(255)
  email?: string;

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

  @ApiPropertyOptional({ enum: UserStatus })
  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;

  @ApiPropertyOptional({ description: 'Role ID to assign to user' })
  @IsOptional()
  @IsString()
  roleId?: string;

  @ApiPropertyOptional({ description: 'Department ID to assign to user' })
  @IsOptional()
  @IsString()
  departmentId?: string;
}

