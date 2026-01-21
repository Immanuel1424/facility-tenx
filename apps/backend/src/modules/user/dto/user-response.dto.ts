import { ApiProperty } from '@nestjs/swagger';
import { Exclude, Expose, Transform } from 'class-transformer';
import { UserStatus, AuthProvider } from '../../iam/entities/user.entity';

@Exclude()
export class UserResponseDto {
  @Expose()
  @ApiProperty()
  id!: string;

  @Expose()
  @ApiProperty()
  email!: string;

  @Expose()
  @ApiProperty({ nullable: true, name: 'first_name' })
  firstName?: string;

  @Expose()
  @ApiProperty({ nullable: true, name: 'last_name' })
  lastName?: string;

  @Expose()
  @ApiProperty({ nullable: true, description: 'Phone number', name: 'phone_number' })
  phoneNumber?: string;

  @Expose()
  @ApiProperty({ nullable: true, description: 'Alternate phone number', name: 'alternate_phone_number' })
  alternatePhoneNumber?: string;

  @Expose()
  @ApiProperty({ nullable: true, description: 'Lease expiry date', name: 'lease_expiry_date' })
  leaseExpiryDate?: Date;

  @Expose()
  @ApiProperty({ nullable: true, description: 'Villa number for tenant users', name: 'villa_number' })
  villaNumber?: string;

  @Expose()
  @ApiProperty({
    required: false,
    description: 'List of villas linked to this user (multi-villa support)',
    type: () => [Object],
  })
  villas?: Array<{
    id: string;
    villaNumber: string;
    villaCode?: string | null;
    name?: string | null;
  }>;

  @Expose()
  @ApiProperty({ nullable: true, description: 'Department ID for internal users', name: 'department_id' })
  departmentId?: string;

  @Expose()
  @ApiProperty({ enum: UserStatus })
  status!: UserStatus;

  @Expose()
  @ApiProperty({ enum: AuthProvider, name: 'auth_provider' })
  authProvider!: AuthProvider;

  @Expose()
  @ApiProperty({ nullable: true, name: 'last_login_at' })
  lastLoginAt?: Date;

  @Expose()
  @ApiProperty({ name: 'created_at' })
  createdAt!: Date;

  @Expose()
  @ApiProperty({ name: 'updated_at' })
  updatedAt!: Date;

  @Expose()
  @ApiProperty({
    required: false,
    description: 'List of role names assigned to the user',
    type: () => [String],
  })
  @Transform(({ obj }) => {
    // Transform userRoles array to simple role names array
    if (obj.userRoles && Array.isArray(obj.userRoles)) {
      return obj.userRoles
        .map((ur: { role?: { name?: string } }) => ur?.role?.name)
        .filter((name: string | undefined): name is string => name !== undefined);
    }
    return [];
  })
  roles?: string[];
}

