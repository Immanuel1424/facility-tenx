import { Injectable } from '@nestjs/common';
import {
  ChannelSendPayload,
  ChannelSendResult,
  NotificationChannelAdapter,
} from './notification-channel.interface';
import { NotificationChannel } from '../enums/notification-channel.enum';

@Injectable()
export class WhatsappChannel implements NotificationChannelAdapter {
  readonly type = NotificationChannel.WHATSAPP;

  async send(payload: ChannelSendPayload): Promise<ChannelSendResult> {
    // TODO: integrate with WhatsApp provider (e.g. Twilio WhatsApp, WhatsApp Business API)
    void payload;
    return { success: true };
  }
}


