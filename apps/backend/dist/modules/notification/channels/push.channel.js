"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var PushChannel_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PushChannel = void 0;
const common_1 = require("@nestjs/common");
const notification_channel_enum_1 = require("../enums/notification-channel.enum");
const user_device_service_1 = require("../../iam/services/user-device.service");
let PushChannel = PushChannel_1 = class PushChannel {
    constructor(userDeviceService) {
        this.userDeviceService = userDeviceService;
        this.logger = new common_1.Logger(PushChannel_1.name);
        this.firebaseAdmin = null;
        this.type = notification_channel_enum_1.NotificationChannel.PUSH;
        this.initializeFirebase();
    }
    async initializeFirebase() {
        try {
            const admin = await Promise.resolve().then(() => __importStar(require('firebase-admin')));
            if (!admin.apps.length) {
                const projectId = process.env.FIREBASE_PROJECT_ID;
                const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
                const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
                if (!projectId || !privateKey || !clientEmail) {
                    this.logger.warn('Firebase Admin not initialized: Missing FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, or FIREBASE_CLIENT_EMAIL');
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
            }
            else {
                this.firebaseAdmin = admin;
            }
        }
        catch (error) {
            this.logger.error('Failed to initialize Firebase Admin:', error);
        }
    }
    async send(payload) {
        if (!this.firebaseAdmin) {
            return {
                success: false,
                errorMessage: 'Firebase Admin not initialized. Please configure FIREBASE_* environment variables.',
            };
        }
        try {
            const userId = payload.to;
            if (!userId) {
                return {
                    success: false,
                    errorMessage: 'User ID is required for push notifications',
                };
            }
            const companyId = payload.metadata?.['companyId'];
            if (!companyId) {
                return {
                    success: false,
                    errorMessage: 'Company ID is required for push notifications',
                };
            }
            const fcmTokens = await this.userDeviceService.getActiveTokensForUser(companyId, userId);
            if (fcmTokens.length === 0) {
                this.logger.debug(`No active FCM tokens found for user ${userId}`);
                return {
                    success: false,
                    errorMessage: 'No active FCM tokens found for user',
                };
            }
            const message = {
                notification: {
                    title: payload.subject || 'Notification',
                    body: payload.body,
                },
                data: payload.metadata
                    ? Object.fromEntries(Object.entries(payload.metadata).map(([key, value]) => [
                        key,
                        typeof value === 'string' ? value : JSON.stringify(value),
                    ]))
                    : undefined,
            };
            if (fcmTokens.length === 1) {
                message.token = fcmTokens[0];
                const response = await this.firebaseAdmin.messaging().send(message);
                this.logger.debug(`Push notification sent successfully: ${response}`);
            }
            else {
                const multicastMessage = {
                    ...message,
                    tokens: fcmTokens,
                };
                const response = await this.firebaseAdmin
                    .messaging()
                    .sendEachForMulticast(multicastMessage);
                this.logger.debug(`Push notifications sent: ${response.successCount} success, ${response.failureCount} failed`);
                if (response.failureCount > 0) {
                    response.responses.forEach((resp, index) => {
                        if (!resp.success && resp.error) {
                            const errorCode = resp.error.code;
                            if (errorCode === 'messaging/invalid-registration-token' ||
                                errorCode === 'messaging/registration-token-not-registered') {
                                this.userDeviceService
                                    .unregisterDevice(companyId, userId, fcmTokens[index])
                                    .catch((err) => this.logger.error(`Failed to deactivate invalid token: ${err}`));
                            }
                        }
                    });
                }
            }
            return {
                success: true,
            };
        }
        catch (error) {
            this.logger.error('Failed to send push notification:', error);
            return {
                success: false,
                errorMessage: error instanceof Error ? error.message : 'Unknown error',
            };
        }
    }
};
exports.PushChannel = PushChannel;
exports.PushChannel = PushChannel = PushChannel_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [user_device_service_1.UserDeviceService])
], PushChannel);
