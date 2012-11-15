/**
 * Social.Common.Profanity
 */
#import <Foundation/Foundation.h>
#import "MBGError.h"
/*!
 * @abstract Provides an interface to check games for profanity.
 */
@interface MBGSocialProfanity : NSObject

/*!
 * @abstract Checks a text string for profanity.
 * @discussion <code>checkProfanity()</code> checks a text string to determine if it contains profanity.
 * This function only checks to see if a string contains profanity. It does not perform any cleanup.
 * The server handles locale and language automatically.
 * @param text The string to check for profanity.
 * @param successCB Returns any profane words or phrases in the text parameter
 * @param errorCB The callback interface that handles errors.
 * and/or any error code and description to the callback function.
 * The result of checking is <code>true</code> or <code>false</code>.
 * If the result is <code>false</code>, the text string contains profanity.
 */
+(void)checkProfanity:(NSString*)text 
			onSuccess:( void (^)( bool profanity ) )successCB 
			  onError:( void (^)( MBGError* error ) )errorCB;
@end
