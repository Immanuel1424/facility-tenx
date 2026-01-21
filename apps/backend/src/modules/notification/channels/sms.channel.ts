import { Injectable } from '@nestjs/common';
import {
  ChannelSendPayload,
  ChannelSendResult,
  NotificationChannelAdapter,
} from './notification-channel.interface';
import { NotificationChannel } from '../enums/notification-channel.enum';

@Injectable()
export class SmsChannel implements NotificationChannelAdapter {
  readonly type = NotificationChannel.SMS;

  async send(payload: ChannelSendPayload): Promise<ChannelSendResult> {
    // TODO: integrate with SMS provider (e.g. Twilio)
    void payload;
    return { success: true };
  }
}


