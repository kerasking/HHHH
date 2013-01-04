/**
 * Social.JP.Service
 */

#import <Foundation/Foundation.h>
#import "MBGSocialCNService.h"

/*!
 * @abstract 
 * @discussion 
 */
@interface MBGSocialTWService : NSObject
{
}


/*!
 * @abstract opens document UI for designated documentType.
 * @discussion 
 * @param documentType Type of document to open (MBG_LEGAL , MBG_AGREEMENT , MBG_CONTACT)
 * @param dismissCB callback object for when the document is dismissed.
 *
 */
+ (void) openDocument:(int) documentType onDismiss:(void (^)())dismissCB;

@end

