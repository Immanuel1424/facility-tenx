import { NotificationSeverity } from '../enums/notification-severity.enum';

export interface NotificationEvent {
  readonly type: string;
  readonly companyId: string;
  readonly recipientUserId?: string;
  readonly severity: NotificationSeverity;
  readonly templateCode: string;
  readonly variables: Record<string, unknown>;
  readonly channels?: string[];
}


