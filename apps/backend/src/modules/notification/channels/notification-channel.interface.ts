import { NotificationChannel } from '../enums/notification-channel.enum';

export interface ChannelSendPayload {
  readonly to: string;
  readonly subject?: string;
  readonly body: string;
  readonly metadata?: Record<string, unknown>;
}

export interface ChannelSendResult {
  readonly success: boolean;
  readonly errorMessage?: string;
}

export interface NotificationChannelAdapter {
  readonly type: NotificationChannel;
  send(payload: ChannelSendPayload): Promise<ChannelSendResult>;
}


