import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsInt, IsOptional, MaxLength, Min, IsUUID } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateRoleDto {
  @ApiProperty({ maxLength: 100, example: 'Manager' })
  @IsString()
  @MaxLength(100)
  name!: string;

  @ApiPropertyOptional({ example: 'Manager role with department-level access' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 50, default: 0 })
  @IsOptional()
  @Transform(({ obj }) => {
    // Always use snake_case
    return obj.hierarchy_level ?? obj.hierarchyLevel;
  })
  @IsInt()
  @Min(0)
  hierarchy_level?: number;

  @ApiPropertyOptional({ description: 'Parent role ID for hierarchical roles' })
  @IsOptional()
  @Transform(({ obj }) => {
    // Always use snake_case
    return obj.parent_role_id ?? obj.parentRoleId;
  })
  @IsString()
  parent_role_id?: string;

  @ApiPropertyOptional({ 
    description: 'Company ID for role creation (SUPER_ADMIN only). If not provided, uses authenticated user\'s company.',
    format: 'uuid'
  })
  @IsOptional()
  @Transform(({ obj }) => {
    // Always use snake_case
    return obj.company_id ?? obj.companyId;
  })
  @IsUUID()
  company_id?: string;
}

