import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength, IsNotEmpty, IsEmail } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({ description: 'New password (minimum 8 characters)' })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  newPassword!: string;
}

export class ForgotPasswordDto {
  @ApiProperty({ description: 'User email address' })
  @IsString()
  @IsNotEmpty()
  @IsEmail()
  email!: string;
}

