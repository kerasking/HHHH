/**
 * Social.Common.Auth
 */
#import <Foundation/Foundation.h>
#import "MBGError.h"

/*!
 * @abstract Gets a verifier code.
 * @discussion Games call <code>Auth.authorizeToken()</code> if the game server is using the Mobage REST API.
 * For more information, refer Mobage REST API section of the developer's guide.
 */
@interface MBGSocialAuth : NSObject

/*!
 * @abstract Authorizes a temporary credential and returns a verification code.
 * @param token The temporary credential identifier
 * @param successCB The callback interface that handles the verification code
 * @param errorCB The callback interface that handles errors.
 *
 */
+ (void) authorizeToken : (NSString*) token
			   onSuccess:( void (^)( NSString* verifier) )successCB 
				 onError:( void (^)( MBGError* error ) )errorCB;

@end
