/**
 * Social.JP.Service
 */

#import <Foundation/Foundation.h>

/*!
 * @abstract Document Type
 */
enum MBG_DOCUMENT_TYPE {
	/*! Legal page for application */
	MBG_LEGAL,
	/*! Agreement page for application */
	MBG_AGREEMENT,
	/*! Contact page for application */
	MBG_CONTACT
};

/*!
 * @abstract 
 * @discussion 
 */
@interface MBGSocialCNService : NSObject
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

