import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsInt, IsOptional, MaxLength, Min } from 'class-validator';

export class UpdateRoleDto {
  @ApiPropertyOptional({ maxLength: 100 })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(0)
  hierarchyLevel?: number;

  @ApiPropertyOptional({ description: 'Parent role ID for hierarchical roles' })
  @IsOptional()
  @IsString()
  parentRoleId?: string;
}

