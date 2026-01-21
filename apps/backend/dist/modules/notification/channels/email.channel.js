"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var EmailChannel_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmailChannel = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const notification_channel_enum_1 = require("../enums/notification-channel.enum");
const client_ses_1 = require("@aws-sdk/client-ses");
let EmailChannel = EmailChannel_1 = class EmailChannel {
    constructor(configService) {
        this.configService = configService;
        this.type = notification_channel_enum_1.NotificationChannel.EMAIL;
        this.logger = new common_1.Logger(EmailChannel_1.name);
        const accessKeyId = this.configService.get('AWS_SES_ACCESS_KEY_ID') ||
            this.configService.get('AWS_ACCESS_KEY_ID');
        const secretAccessKey = this.configService.get('AWS_SES_SECRET_ACCESS_KEY') ||
            this.configService.get('AWS_SECRET_ACCESS_KEY');
        const region = this.configService.get('AWS_SES_REGION') || 'ap-south-1';
        if (!accessKeyId || !secretAccessKey) {
            this.logger.warn('AWS SES credentials not found. Email sending will fail. Please configure AWS_SES_ACCESS_KEY_ID and AWS_SES_SECRET_ACCESS_KEY in .env');
        }
        this.sesClient = new client_ses_1.SESClient({
            region,
            credentials: {
                accessKeyId: accessKeyId || '',
                secretAccessKey: secretAccessKey || '',
            },
        });
        const fromEmailConfig = this.configService.get('AWS_SES_FROM_EMAIL') ||
            this.configService.get('EMAIL_FROM') ||
            'no-reply-dev@helixsense.com';
        this.fromName =
            this.configService.get('AWS_SES_FROM_NAME') ||
                this.configService.get('EMAIL_FROM_NAME') ||
                'Helixsense';
        if (fromEmailConfig.includes('<')) {
            const match = fromEmailConfig.match(/^(.+?)\s*<(.+?)>$/);
            if (match) {
                this.fromName = match[1].trim();
                this.fromEmail = match[2].trim();
            }
            else {
                this.fromEmail = fromEmailConfig;
            }
        }
        else {
            this.fromEmail = fromEmailConfig;
        }
        this.logger.log(`AWS SES EmailChannel initialized successfully. Region: ${region}, From: ${this.fromName} <${this.fromEmail}>`);
    }
    async send(payload) {
        try {
            let recipientEmail = payload.to;
            let recipientName;
            if (payload.to.includes('<')) {
                const match = payload.to.match(/^(.+?)\s*<(.+?)>$/);
                if (match) {
                    recipientName = match[1].trim();
                    recipientEmail = match[2].trim();
                }
            }
            const emailParams = {
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
            const command = new client_ses_1.SendEmailCommand(emailParams);
            const response = await this.sesClient.send(command);
            this.logger.log(`Email sent to ${payload.to}. Message ID: ${response.MessageId || 'N/A'}`);
            return { success: true };
        }
        catch (error) {
            const errorMsg = error instanceof Error
                ? `Failed to send email to ${payload.to}: ${error.message}`
                : `Failed to send email to ${payload.to}: Unknown error`;
            this.logger.error(errorMsg, error);
            return { success: false, errorMessage: errorMsg };
        }
    }
    formatAsHtml(text) {
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
};
exports.EmailChannel = EmailChannel;
exports.EmailChannel = EmailChannel = EmailChannel_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], EmailChannel);
