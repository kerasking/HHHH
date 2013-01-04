/**
 * Social.Common.RemoteNotification
 */

#import <Foundation/Foundation.h>
#import "MBGError.h"
#import "MBGRemoteNotificationPayload.h"
#import "MBGRemoteNotificationResponse.h"

/*!
 * @abstract 
 * Mobage provides a Common API for the sending of remote notifications to others within the Mobage Service.
 * The messages are sent and received by games using NativeSDK's network-based notification capabilities.
 * The Mobage platform service acts an intermediary to enqueue and send remote messages.
 * <br />
 * <code>RemoteNotification</code> Sends a remote notification (push message) to a user's device.
 * This API can be used to send a message to a single user within a given application.  Broadcast notifications
 * can be sent via the server's HTTP REST endpoints, but only when game server's OAuth tokens.
 */
@interface MBGSocialRemoteNotification : NSObject {
}

/*!
 * @abstract 
 * Sends a remote notification to another user who is also playing a Mobage-enabled game. This API covers only
 * the "user to user" remote notification. This API is not currently rate limited, but Mobage reserves the
 * right to throttle or suspend accounts sending excessive remote notifications.
 */
+(void)send:(NSString*)recipientId data:(MBGRemoteNotificationPayload*)data onSuccess:(void (^)(MBGRemoteNotificationResponse* resp))successCB onError:(void (^)(MBGError* error))errorCB;

/*!
 * @abstract 
 */
+(void)getRemoteNotificationsEnabled:(void (^)(bool canBeNotified))successCB
                             onError:(void (^)(MBGError* error))errorCB;
/*!
 * @abstract 
 */
+(void)setRemoteNotificationsEnabled:(bool)enabled
                           onSuccess:(void (^)(void))successCB
                             onError:(void (^)(MBGError* error))errorCB;
@end
