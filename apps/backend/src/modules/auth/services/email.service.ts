import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  SESClient,
  SendEmailCommand,
  SendEmailCommandInput,
  SendRawEmailCommand,
} from '@aws-sdk/client-ses';
import * as fs from 'fs/promises';
import * as path from 'path';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private readonly sesClient: SESClient;
  private readonly fromEmail: string;
  private readonly fromName: string;
  private readonly appName: string;

  constructor(private readonly configService: ConfigService) {
    // Initialize AWS SES configuration
    const accessKeyId =
      this.configService.get<string>('AWS_SES_ACCESS_KEY_ID') ||
      this.configService.get<string>('AWS_ACCESS_KEY_ID');
    const secretAccessKey =
      this.configService.get<string>('AWS_SES_SECRET_ACCESS_KEY') ||
      this.configService.get<string>('AWS_SECRET_ACCESS_KEY');
    const region =
      this.configService.get<string>('AWS_SES_REGION') || 'ap-south-1';

    if (!accessKeyId || !secretAccessKey) {
      this.logger.warn(
        'AWS SES credentials not found. Email sending will fail. Please configure AWS_SES_ACCESS_KEY_ID and AWS_SES_SECRET_ACCESS_KEY in .env',
      );
    }

    this.sesClient = new SESClient({
      region,
      credentials: {
        accessKeyId: accessKeyId || '',
        secretAccessKey: secretAccessKey || '',
      },
    });

    const fromEmailConfig =
      this.configService.get<string>('AWS_SES_FROM_EMAIL') ||
      this.configService.get<string>('EMAIL_FROM') ||
      'no-reply-dev@helixsense.com';

    this.fromName =
      this.configService.get<string>('AWS_SES_FROM_NAME') ||
      this.configService.get<string>('EMAIL_FROM_NAME') ||
      'Helixsense';

    this.appName =
      this.configService.get<string>('APP_NAME') || 'Helixsense';

    // Parse fromEmail to extract name and email if in format "Name <email@example.com>"
    if (fromEmailConfig.includes('<')) {
      const match = fromEmailConfig.match(/^(.+?)\s*<(.+?)>$/);
      if (match) {
        this.fromName = match[1].trim();
        this.fromEmail = match[2].trim();
      } else {
        this.fromEmail = fromEmailConfig;
      }
    } else {
      this.fromEmail = fromEmailConfig;
    }

    this.logger.log(
      `AWS SES EmailService initialized successfully. Region: ${region}, From: ${this.fromName} <${this.fromEmail}>`,
    );
  }

  /**
   * Send password reset OTP email
   */
  async sendPasswordResetOtp(
    email: string,
    otp: string,
    firstName?: string,
  ): Promise<void> {
    const subject = `${this.appName} - Password Reset Code`;
    const html = this.getPasswordResetOtpTemplate(otp, firstName);
    const text = this.getPasswordResetOtpText(otp, firstName);

    try {
      const emailParams: SendEmailCommandInput = {
        Source: this.fromName
          ? `${this.fromName} <${this.fromEmail}>`
          : this.fromEmail,
        Destination: {
          ToAddresses: [email],
        },
        Message: {
          Subject: {
            Data: subject,
            Charset: 'UTF-8',
          },
          Body: {
            Html: {
              Data: html,
              Charset: 'UTF-8',
            },
            Text: {
              Data: text,
              Charset: 'UTF-8',
            },
          },
        },
      };

      const command = new SendEmailCommand(emailParams);
      const response = await this.sesClient.send(command);

      this.logger.log(
        `Password reset OTP sent to ${email}. Message ID: ${response.MessageId || 'N/A'}`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Failed to send password reset OTP to ${email}:`, error);
      
      // In development, log the OTP instead of failing
      if (process.env.NODE_ENV !== 'production') {
        this.logger.warn(`[DEV] Password reset OTP for ${email}: ${otp}`);
      }
      // Don't throw - allow the flow to continue even if email fails
      // In production, you might want to throw or queue for retry
    }
  }

  /**
   * Send password reset confirmation email
   */
  async sendPasswordResetConfirmation(
    email: string,
    firstName?: string,
  ): Promise<void> {
    const subject = `${this.appName} - Password Reset Successful`;
    const html = this.getPasswordResetConfirmationTemplate(firstName);
    const text = this.getPasswordResetConfirmationText(firstName);

    try {
      const emailParams: SendEmailCommandInput = {
        Source: this.fromName
          ? `${this.fromName} <${this.fromEmail}>`
          : this.fromEmail,
        Destination: {
          ToAddresses: [email],
        },
        Message: {
          Subject: {
            Data: subject,
            Charset: 'UTF-8',
          },
          Body: {
            Html: {
              Data: html,
              Charset: 'UTF-8',
            },
            Text: {
              Data: text,
              Charset: 'UTF-8',
            },
          },
        },
      };

      const command = new SendEmailCommand(emailParams);
      const response = await this.sesClient.send(command);

      this.logger.log(
        `Password reset confirmation sent to ${email}. Message ID: ${response.MessageId || 'N/A'}`,
      );
    } catch (error: unknown) {
      this.logger.error(
        `Failed to send password reset confirmation to ${email}:`,
        error,
      );
      // Don't throw - confirmation email failure shouldn't block the flow
    }
  }

  /**
   * Get password reset OTP plain text version
   */
  private getPasswordResetOtpText(otp: string, firstName?: string): string {
    const greeting = firstName ? `Hello ${firstName},` : 'Hello,';
    return `
${greeting}

You have requested to reset your password. Use the following code to verify your identity:

${otp}

This code will expire in 10 minutes.

If you didn't request this password reset, please ignore this email.

This is an automated message from ${this.appName}. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get password reset OTP email template
   */
  private getPasswordResetOtpTemplate(otp: string, firstName?: string): string {
    const greeting = firstName ? `Hello ${firstName},` : 'Hello,';
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Password Reset Code</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #007be5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${this.appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Password Reset</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>${greeting}</p>
    <p>You have requested to reset your password. Use the following code to verify your identity:</p>
    <div style="background-color: #fff; border: 2px solid #007be5; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0;">
      <h2 style="margin: 0; color: #007be5; font-size: 32px; letter-spacing: 8px;">${otp}</h2>
    </div>
    <p style="color: #666; font-size: 14px;">This code will expire in 10 minutes.</p>
    <p style="color: #666; font-size: 14px;">If you didn't request this password reset, please ignore this email.</p>
    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${this.appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Get password reset confirmation plain text version
   */
  private getPasswordResetConfirmationText(firstName?: string): string {
    const greeting = firstName ? `Hello ${firstName},` : 'Hello,';
    return `
${greeting}

Your password has been successfully reset.

If you did not make this change, please contact support immediately.

This is an automated message from ${this.appName}. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get password reset confirmation email template
   */
  private getPasswordResetConfirmationTemplate(firstName?: string): string {
    const greeting = firstName ? `Hello ${firstName},` : 'Hello,';
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Password Reset Successful</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #28a745; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">${this.appName}</h1>
    <p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Password Reset Successful</p>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>${greeting}</p>
    <p>Your password has been successfully reset.</p>
    <p>If you did not make this change, please contact support immediately.</p>
    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${this.appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Send user credentials email (for new user creation)
   */
  async sendUserCredentials(
    email: string,
    password: string,
    firstName?: string,
    loginUrl?: string,
  ): Promise<void> {
    const subject = `${this.appName} - Your Account Credentials`;
    const html = this.getUserCredentialsTemplate(email, password, firstName, loginUrl);
    const text = this.getUserCredentialsText(email, password, firstName, loginUrl);

    try {
      const emailParams: SendEmailCommandInput = {
        Source: this.fromName
          ? `${this.fromName} <${this.fromEmail}>`
          : this.fromEmail,
        Destination: {
          ToAddresses: [email],
        },
        Message: {
          Subject: {
            Data: subject,
            Charset: 'UTF-8',
          },
          Body: {
            Html: {
              Data: html,
              Charset: 'UTF-8',
            },
            Text: {
              Data: text,
              Charset: 'UTF-8',
            },
          },
        },
      };

      const command = new SendEmailCommand(emailParams);
      const response = await this.sesClient.send(command);

      this.logger.log(
        `User credentials sent to ${email}. Message ID: ${response.MessageId || 'N/A'}`,
      );
    } catch (error: unknown) {
      this.logger.error(`Failed to send user credentials to ${email}:`, error);
      // Don't throw - email failure shouldn't block user creation
      // In production, you might want to throw or queue for retry
    }
  }

  /**
   * Get user credentials plain text version
   */
  private getUserCredentialsText(
    email: string,
    password: string,
    firstName?: string,
    loginUrl?: string,
  ): string {
    const greeting = firstName ? `Hello ${firstName},` : 'Hello,';
    const loginInfo = loginUrl
      ? `\n\nLogin URL: ${loginUrl}`
      : '';
    return `
${greeting}

Your account has been created. Please use the following credentials to log in:

Email: ${email}
Password: ${password}${loginInfo}

For security reasons, we recommend that you change your password after your first login.

If you did not request this account, please contact support immediately.

This is an automated message from ${this.appName}. Please do not reply to this email.
    `.trim();
  }

  /**
   * Get user credentials email template
   */
  private getUserCredentialsTemplate(
    email: string,
    password: string,
    firstName?: string,
    loginUrl?: string,
  ): string {
    const greeting = firstName ? `Hello ${firstName},` : 'Hello,';
    const loginButton = loginUrl
      ? `<div style="text-align: center; margin: 30px 0;">
           <a href="${loginUrl}" style="display: inline-block; padding: 12px 30px; background-color: #007be5; color: white; text-decoration: none; border-radius: 5px; font-weight: bold;">Login to Your Account</a>
         </div>`
      : '';
    return `
<!DOCTYPE html>
<html>
<head></head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your Account Credentials</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #007be5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">Welcome to ${this.appName}!</h1>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    <p>${greeting}</p>
    <p>Your account has been created. Please use the following credentials to log in:</p>
    
    <div style="background-color: #fff; border: 2px solid #007be5; border-radius: 8px; padding: 20px; margin: 20px 0;">
      <table style="width: 100%; border-collapse: collapse;">
        <tr>
          <td style="padding: 8px 0; font-weight: bold; width: 100px;">Email:</td>
          <td style="padding: 8px 0;">${email}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0; font-weight: bold;">Password:</td>
          <td style="padding: 8px 0;">
            <span style="font-family: monospace; font-size: 16px; font-weight: bold; letter-spacing: 2px; color: #007be5;">${password}</span>
          </td>
        </tr>
      </table>
    </div>

    ${loginButton}

    <div style="background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 8px; padding: 15px; margin: 20px 0;">
      <p style="margin: 0; color: #856404;">
        <strong>Security Notice:</strong> For security reasons, we recommend that you change your password after your first login.
      </p>
    </div>

    <p style="color: #666; font-size: 14px;">If you did not request this account, please contact support immediately.</p>
    
    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message from ${this.appName}. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Send email with attachments
   */
  async sendEmailWithAttachments(
    to: string,
    subject: string,
    htmlBody: string,
    textBody: string,
    attachments: Array<{
      filename: string;
      path: string;
      contentType?: string;
    }>,
  ): Promise<void> {
    try {
      // Read and encode attachments
      const attachmentParts: string[] = [];
      const boundary = `----=_Part_${Date.now()}_${Math.random().toString(36).substring(7)}`;

      for (const attachment of attachments) {
        try {
          const filePath = path.isAbsolute(attachment.path)
            ? attachment.path
            : path.join(process.cwd(), attachment.path);
          
          const fileBuffer = await fs.readFile(filePath);
          const base64Content = fileBuffer.toString('base64');
          const contentType = attachment.contentType || 'application/octet-stream';

          attachmentParts.push(
            `--${boundary}\r\n` +
            `Content-Type: ${contentType}; name="${attachment.filename}"\r\n` +
            `Content-Disposition: attachment; filename="${attachment.filename}"\r\n` +
            `Content-Transfer-Encoding: base64\r\n\r\n` +
            `${base64Content}\r\n`,
          );
        } catch (error: unknown) {
          const errorMessage = error instanceof Error ? error.message : 'Unknown error';
          this.logger.warn(`Failed to read attachment ${attachment.filename}: ${errorMessage}`);
          // Continue with other attachments
        }
      }

      // Construct MIME message
      const mimeMessage =
        `From: ${this.fromName ? `${this.fromName} <${this.fromEmail}>` : this.fromEmail}\r\n` +
        `To: ${to}\r\n` +
        `Subject: ${subject}\r\n` +
        `MIME-Version: 1.0\r\n` +
        `Content-Type: multipart/mixed; boundary="${boundary}"\r\n\r\n` +
        `--${boundary}\r\n` +
        `Content-Type: text/html; charset=UTF-8\r\n` +
        `Content-Transfer-Encoding: 7bit\r\n\r\n` +
        `${htmlBody}\r\n\r\n` +
        `--${boundary}\r\n` +
        `Content-Type: text/plain; charset=UTF-8\r\n` +
        `Content-Transfer-Encoding: 7bit\r\n\r\n` +
        `${textBody}\r\n\r\n` +
        attachmentParts.join('') +
        `--${boundary}--\r\n`;

      const command = new SendRawEmailCommand({
        RawMessage: {
          Data: Buffer.from(mimeMessage),
        },
      });

      const response = await this.sesClient.send(command);

      this.logger.log(
        `Email with attachments sent to ${to}. Message ID: ${response.MessageId || 'N/A'}`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Failed to send email with attachments to ${to}:`, error);
      throw new Error(`Failed to send email: ${errorMessage}`);
    }
  }

  /**
   * Send a generic email (without attachments)
   */
  async sendEmail(
    to: string,
    subject: string,
    htmlBody: string,
    textBody: string,
  ): Promise<void> {
    try {
      const emailParams: SendEmailCommandInput = {
        Source: this.fromName
          ? `${this.fromName} <${this.fromEmail}>`
          : this.fromEmail,
        Destination: {
          ToAddresses: [to],
        },
        Message: {
          Subject: {
            Data: subject,
            Charset: 'UTF-8',
          },
          Body: {
            Html: {
              Data: htmlBody,
              Charset: 'UTF-8',
            },
            Text: {
              Data: textBody,
              Charset: 'UTF-8',
            },
          },
        },
      };

      const command = new SendEmailCommand(emailParams);
      const response = await this.sesClient.send(command);

      this.logger.log(
        `Email sent to ${to}. Message ID: ${response.MessageId || 'N/A'}`,
      );
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(`Failed to send email to ${to}:`, error);
      throw new Error(`Failed to send email: ${errorMessage}`);
    }
  }
}

