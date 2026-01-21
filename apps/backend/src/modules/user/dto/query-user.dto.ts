import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsEnum, IsUUID } from 'class-validator';
import { UserStatus } from '../../iam/entities/user.entity';

export class QueryUserDto {
  @ApiPropertyOptional({ description: 'Filter by role name' })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiPropertyOptional({ description: 'Filter by user status', enum: UserStatus })
  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;

  @ApiPropertyOptional({ 
    description: 'Company ID to filter users (SUPER_ADMIN only). If not provided, uses authenticated user\'s company.',
    format: 'uuid'
  })
  @IsOptional()
  @IsUUID()
  companyId?: string;
}

