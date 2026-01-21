import { Injectable, Logger } from '@nestjs/common';
import {
  ChannelSendPayload,
  ChannelSendResult,
  NotificationChannelAdapter,
} from './notification-channel.interface';
import { NotificationChannel } from '../enums/notification-channel.enum';
import { UserDeviceService } from '../../iam/services/user-device.service';

@Injectable()
export class PushChannel implements NotificationChannelAdapter {
  private readonly logger = new Logger(PushChannel.name);
  private firebaseAdmin: any = null;

  readonly type = NotificationChannel.PUSH;

  constructor(private readonly userDeviceService: UserDeviceService) {
    this.initializeFirebase();
  }

  private async initializeFirebase() {
    try {
      // Dynamic import to avoid errors if firebase-admin is not installed
      const admin = await import('firebase-admin');
      
      if (!admin.apps.length) {
        const projectId = process.env.FIREBASE_PROJECT_ID;
        const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
        const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

        if (!projectId || !privateKey || !clientEmail) {
          this.logger.warn(
            'Firebase Admin not initialized: Missing FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, or FIREBASE_CLIENT_EMAIL',
          );
          return;
        }

        admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            privateKey,
            clientEmail,
          }),
        });

        this.firebaseAdmin = admin;
        this.logger.log('Firebase Admin initialized successfully');
      } else {
        this.firebaseAdmin = admin;
      }
    } catch (error) {
      this.logger.error('Failed to initialize Firebase Admin:', error);
    }
  }

  async send(payload: ChannelSendPayload): Promise<ChannelSendResult> {
    if (!this.firebaseAdmin) {
      return {
        success: false,
        errorMessage: 'Firebase Admin not initialized. Please configure FIREBASE_* environment variables.',
      };
    }

    try {
      // Extract user ID from payload.to (for push, 'to' contains userId)
      const userId = payload.to;
      if (!userId) {
        return {
          success: false,
          errorMessage: 'User ID is required for push notifications',
        };
      }

      // Extract companyId from metadata (set by notification service)
      const companyId = payload.metadata?.['companyId'] as string;
      if (!companyId) {
        return {
          success: false,
          errorMessage: 'Company ID is required for push notifications',
        };
      }

      // Get all active FCM tokens for the user
      const fcmTokens = await this.userDeviceService.getActiveTokensForUser(
        companyId,
        userId,
      );

      if (fcmTokens.length === 0) {
        this.logger.debug(`No active FCM tokens found for user ${userId}`);
        return {
          success: false,
          errorMessage: 'No active FCM tokens found for user',
        };
      }

      // Prepare notification message
      const message: any = {
        notification: {
          title: payload.subject || 'Notification',
          body: payload.body,
        },
        data: payload.metadata
          ? Object.fromEntries(
              Object.entries(payload.metadata).map(([key, value]) => [
                key,
                typeof value === 'string' ? value : JSON.stringify(value),
              ]),
            )
          : undefined,
      };

      // Send to all user devices
      if (fcmTokens.length === 1) {
        // Single device - use send()
        message.token = fcmTokens[0];
        const response = await this.firebaseAdmin.messaging().send(message);
        this.logger.debug(`Push notification sent successfully: ${response}`);
      } else {
        // Multiple devices - use sendEachForMulticast()
        const multicastMessage = {
          ...message,
          tokens: fcmTokens,
        };
        const response = await this.firebaseAdmin
          .messaging()
          .sendEachForMulticast(multicastMessage);
        
        this.logger.debug(
          `Push notifications sent: ${response.successCount} success, ${response.failureCount} failed`,
        );

        // Handle failed tokens (deactivate them)
        if (response.failureCount > 0) {
          response.responses.forEach((resp: any, index: number) => {
            if (!resp.success && resp.error) {
              const errorCode = resp.error.code;
              // Deactivate invalid tokens
              if (
                errorCode === 'messaging/invalid-registration-token' ||
                errorCode === 'messaging/registration-token-not-registered'
              ) {
                this.userDeviceService
                  .unregisterDevice(companyId, userId, fcmTokens[index])
                  .catch((err) =>
                    this.logger.error(
                      `Failed to deactivate invalid token: ${err}`,
                    ),
                  );
              }
            }
          });
        }
      }

      return {
        success: true,
      };
    } catch (error) {
      this.logger.error('Failed to send push notification:', error);
      return {
        success: false,
        errorMessage:
          error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}


