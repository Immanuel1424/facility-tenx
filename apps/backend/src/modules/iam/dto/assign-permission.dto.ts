import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUUID } from 'class-validator';

export class AssignPermissionDto {
  @ApiProperty({ description: 'Permission ID to assign to the role' })
  @IsString()
  @IsUUID()
  permissionId!: string;
}

