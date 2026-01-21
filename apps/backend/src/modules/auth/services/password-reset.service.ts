import {
  Injectable,
  NotFoundException,
  BadRequestException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, IsNull } from 'typeorm';
import { PasswordResetToken } from '../entities/password-reset-token.entity';
import { UserService } from '../../iam/services/user.service';
import { EmailService } from './email.service';
import * as crypto from 'crypto';

@Injectable()
export class PasswordResetService {
  private readonly OTP_EXPIRY_MINUTES = 10;
  private readonly MAX_ATTEMPTS = 5;
  private readonly TOKEN_EXPIRY_HOURS = 1;

  constructor(
    @InjectRepository(PasswordResetToken)
    private readonly passwordResetTokenRepository: Repository<PasswordResetToken>,
    private readonly userService: UserService,
    private readonly emailService: EmailService,
  ) {}

  /**
   * Generate a 6-digit OTP
   */
  private generateOtp(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Generate a secure random token
   */
  private generateToken(): string {
    return crypto.randomBytes(32).toString('hex');
  }

  /**
   * Initiate password reset - send OTP to user's email
   */
  async initiatePasswordReset(
    companyId: string,
    email: string,
    ipAddress?: string,
  ): Promise<{ message: string }> {
    // Find user by email
    const user = await this.userService.findByEmail(companyId, email);

    // For security, don't reveal if user exists or not
    // Always return success message
    if (!user) {
      // Still return success to prevent email enumeration
      return {
        message:
          'If an account with that email exists, a password reset code has been sent.',
      };
    }

    // Check if user has local auth (can reset password)
    if (user.authProvider !== 'local' || !user.passwordHash) {
      return {
        message:
          'If an account with that email exists, a password reset code has been sent.',
      };
    }

    // Revoke any existing unused tokens for this user
    await this.passwordResetTokenRepository.update(
      {
        companyId,
        userId: user.id,
        usedAt: IsNull(),
      },
      {
        usedAt: new Date(),
      },
    );

    // Generate OTP and token
    const otp = this.generateOtp();
    const token = this.generateToken();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + this.OTP_EXPIRY_MINUTES);

    // Create password reset token
    const passwordResetToken = this.passwordResetTokenRepository.create({
      companyId,
      userId: user.id,
      email: user.email,
      otp,
      token,
      expiresAt,
      ipAddress,
      attempts: 0,
    });

    await this.passwordResetTokenRepository.save(passwordResetToken);

    // Send OTP email
    await this.emailService.sendPasswordResetOtp(user.email, otp, user.firstName);

    return {
      message:
        'If an account with that email exists, a password reset code has been sent.',
    };
  }

  /**
   * Verify OTP
   */
  async verifyOtp(
    companyId: string,
    email: string,
    otp: string,
  ): Promise<{ token: string; message: string }> {
    // Find user
    const user = await this.userService.findByEmail(companyId, email);
    if (!user) {
      throw new UnauthorizedException('Invalid OTP');
    }

    // Find valid token
    const resetToken = await this.passwordResetTokenRepository.findOne({
      where: {
        companyId,
        userId: user.id,
        email: user.email,
        usedAt: IsNull(),
      },
      order: {
        createdAt: 'DESC',
      },
    });

    if (!resetToken) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    // Check if expired
    if (resetToken.expiresAt < new Date()) {
      throw new UnauthorizedException('OTP has expired. Please request a new one.');
    }

    // Check attempts
    if (resetToken.attempts >= this.MAX_ATTEMPTS) {
      throw new UnauthorizedException(
        'Maximum verification attempts exceeded. Please request a new OTP.',
      );
    }

    // Verify OTP
    if (resetToken.otp !== otp) {
      // Increment attempts
      resetToken.attempts += 1;
      await this.passwordResetTokenRepository.save(resetToken);

      const remainingAttempts = this.MAX_ATTEMPTS - resetToken.attempts;
      throw new UnauthorizedException(
        `Invalid OTP. ${remainingAttempts > 0 ? `${remainingAttempts} attempt(s) remaining.` : 'Please request a new OTP.'}`,
      );
    }

    // Generate new token for password reset (longer expiry)
    const newToken = this.generateToken();
    const tokenExpiresAt = new Date();
    tokenExpiresAt.setHours(tokenExpiresAt.getHours() + this.TOKEN_EXPIRY_HOURS);

    // Mark OTP as used and create new token entry
    resetToken.usedAt = new Date();
    await this.passwordResetTokenRepository.save(resetToken);

    // Create new token for password reset
    const passwordResetToken = this.passwordResetTokenRepository.create({
      companyId,
      userId: user.id,
      email: user.email,
      otp: '', // No OTP needed for token-based reset
      token: newToken,
      expiresAt: tokenExpiresAt,
      attempts: 0,
    });

    await this.passwordResetTokenRepository.save(passwordResetToken);

    return {
      token: newToken,
      message: 'OTP verified successfully',
    };
  }

  /**
   * Reset password using token
   */
  async resetPassword(
    companyId: string,
    email: string,
    token: string,
    newPassword: string,
  ): Promise<{ message: string }> {
    // Find user
    const user = await this.userService.findByEmail(companyId, email);
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Find valid token
    const resetToken = await this.passwordResetTokenRepository.findOne({
      where: {
        companyId,
        userId: user.id,
        email: user.email,
        token,
        usedAt: IsNull(),
      },
      order: {
        createdAt: 'DESC',
      },
    });

    if (!resetToken) {
      throw new UnauthorizedException('Invalid or expired reset token');
    }

    // Check if expired
    if (resetToken.expiresAt < new Date()) {
      throw new UnauthorizedException('Reset token has expired. Please request a new one.');
    }

    // Reset password
    await this.userService.resetPassword(companyId, user.id, newPassword);

    // Mark token as used
    resetToken.usedAt = new Date();
    await this.passwordResetTokenRepository.save(resetToken);

    // Send confirmation email
    await this.emailService.sendPasswordResetConfirmation(
      user.email,
      user.firstName,
    );

    return {
      message: 'Password has been reset successfully',
    };
  }

  /**
   * Clean up expired tokens (should be called periodically)
   */
  async cleanupExpiredTokens(): Promise<void> {
    const expiredDate = new Date();
    expiredDate.setHours(expiredDate.getHours() - 24); // Keep for 24 hours after expiry

    await this.passwordResetTokenRepository.delete({
      expiresAt: LessThan(expiredDate),
    });
  }
}

