import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ChannelSendPayload,
  ChannelSendResult,
  NotificationChannelAdapter,
} from './notification-channel.interface';
import { NotificationChannel } from '../enums/notification-channel.enum';
import {
  SESClient,
  SendEmailCommand,
  SendEmailCommandInput,
} from '@aws-sdk/client-ses';

@Injectable()
export class EmailChannel implements NotificationChannelAdapter {
  readonly type = NotificationChannel.EMAIL;
  private readonly logger = new Logger(EmailChannel.name);
  private readonly sesClient: SESClient;
  private readonly fromEmail: string;
  private readonly fromName: string;

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
      `AWS SES EmailChannel initialized successfully. Region: ${region}, From: ${this.fromName} <${this.fromEmail}>`,
    );
  }

  async send(payload: ChannelSendPayload): Promise<ChannelSendResult> {
    try {
      // Extract recipient email and name if provided in format "Name <email@example.com>"
      let recipientEmail = payload.to;
      let recipientName: string | undefined;

      if (payload.to.includes('<')) {
        const match = payload.to.match(/^(.+?)\s*<(.+?)>$/);
        if (match) {
          recipientName = match[1].trim();
          recipientEmail = match[2].trim();
        }
      }

      const emailParams: SendEmailCommandInput = {
        Source: this.fromName
          ? `${this.fromName} <${this.fromEmail}>`
          : this.fromEmail,
        Destination: {
          ToAddresses: [recipientEmail],
        },
        Message: {
          Subject: {
            Data: payload.subject || 'Notification',
            Charset: 'UTF-8',
          },
          Body: {
            Html: {
              Data: this.formatAsHtml(payload.body),
              Charset: 'UTF-8',
            },
            Text: {
              Data: payload.body,
              Charset: 'UTF-8',
            },
          },
        },
      };

      const command = new SendEmailCommand(emailParams);
      const response = await this.sesClient.send(command);

      this.logger.log(
        `Email sent to ${payload.to}. Message ID: ${response.MessageId || 'N/A'}`,
      );

      return { success: true };
    } catch (error: unknown) {
      const errorMsg =
        error instanceof Error
          ? `Failed to send email to ${payload.to}: ${error.message}`
          : `Failed to send email to ${payload.to}: Unknown error`;
      this.logger.error(errorMsg, error);
      return { success: false, errorMessage: errorMsg };
    }
  }

  /**
   * Convert plain text to basic HTML format
   */
  private formatAsHtml(text: string): string {
    // Convert line breaks to <br> tags and escape HTML
    const escaped = text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
    
    const html = escaped.replace(/\n/g, '<br>');
    
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
  <div style="background-color: #007be5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
    <h1 style="margin: 0;">Notification</h1>
  </div>
  <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
    ${html}
    <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
    <p style="color: #999; font-size: 12px; text-align: center;">This is an automated message. Please do not reply to this email.</p>
  </div>
</body>
</html>
    `.trim();
  }
}


