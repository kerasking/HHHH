#import <Foundation/Foundation.h>
#import "MBGRemoteNotificationPayload.h"

/*!
 * @abstract Information about the response from server.
 */
@interface MBGRemoteNotificationResponse : NSObject {
    NSString                     *_respId;
    MBGRemoteNotificationPayload *_payload;
    NSString                     *_publishedTimestamp;
}
/*!
 * @abstract Unique identifier for the remote notification.
 */
@property (nonatomic, retain) NSString *respId;
/*!
 * @abstract payload value specified in the send() method.
 */
@property (nonatomic, retain) MBGRemoteNotificationPayload *payload;
/*!
 * @abstract ISO 8601 Timestamp when the Mobage API server received the request.
 */
@property (nonatomic, retain) NSString *publishedTimestamp;


+(id)response;

+(id)responseWith:(NSString*)respId
          payload:(MBGRemoteNotificationPayload*)payload
publishedTimestamp:(NSString*)publishedTimestamp;

-(NSString*)description;
@end
