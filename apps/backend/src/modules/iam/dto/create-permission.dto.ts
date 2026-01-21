import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, MaxLength } from 'class-validator';

export class CreatePermissionDto {
  @ApiProperty({ maxLength: 100, example: 'user' })
  @IsString()
  @MaxLength(100)
  resource!: string;

  @ApiProperty({ maxLength: 50, example: 'read' })
  @IsString()
  @MaxLength(50)
  action!: string;

  @ApiPropertyOptional({ example: 'Permission to read user data' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ maxLength: 50, example: 'Users' })
  @IsOptional()
  @IsString()
  @MaxLength(50)
  category?: string;
}

