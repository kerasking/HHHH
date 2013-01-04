#import <Foundation/Foundation.h>

/*!
 * @abstract parameters passed to the device.
 */
@interface MBGRemoteNotificationPayload : NSObject {
    NSInteger    _badge;
    NSString     *_message;
    NSString     *_sound;
    NSDictionary *_extras;
}
/*!
 * @abstract If the notification is sent to an iOS device, this number is used
 *      to badge the application icon.  If no badge is included, no numeric badge will be sent.  Including this
 *      field for target Android devices has no affect and does not count toward payload size constraints.
 */
@property (nonatomic, assign) NSInteger badge;
/*!
 * @abstract UTF-8 message body
 */
@property (nonatomic, retain) NSString *message;
/*!
 * @abstract If the notification is sent to an iOS device, this is the name of
 *      the sound file in the application bundle.  If the sound file doesn't exist, or "default" is specified as
 *      the value, the default alert sound is played.  Including this field for target Android devices has no
 *      affect and does not count toward payload size constraints.
 */
@property (nonatomic, retain) NSString *sound;
/*!
 * @abstract Custom 1 level hash of key/value parameters defined by the developer.
 *      Note; the string key for each item in this section cannot contain any of the payload's defined key values.
 */
@property (nonatomic, retain) NSDictionary *extras;

/*!
 * @abstract instantiates the object
 */
+(id)payload;

+(id)payloadWith:(NSString*)message;

-(NSString*)toDebug:(NSInteger)indent;
@end
