/**
 * Social.Common.Service
 */

#import <Foundation/Foundation.h>
#import "MBGBalanceButton.h"
#import "MBGBalanceImage.h"

/*!
 * @abstract Social features using UI Components
 * @discussion 
 */
@interface MBGSocialService : NSObject
{
    
}

/*!
 * @abstract launch portal application
 * @param dismissCB The callback interface to notify dismissing alert dialog
 */
+ (void) launchPortalApp:( void (^)( ) )dismissCB;

/*!
 * @abstract open home page
 * @param 
 */
+ (void) openHomePage;

/*!
 * @abstract shows User Profile Page of Mobage 
 * @param 
 */
+ (void) openUserProfile:(NSString *)userId;

/*!
 * @abstract shows friend picker Dialog
 * @param pickedCB The callback interface to notify that some users have been picked.
 * @param inviteSentCB The callback interface to notify that some users have been invited.
 * @param dismissCB The callback interface to notify dismissing Webview dialog
 */
+ (void) openFriendPicker:(NSInteger) maxFriendsToSelect
				onPicked:( void (^)( NSArray* userIds ) )pickedCB
				onInviteSent:( void (^)( NSArray* userIds ) )inviteSentCB
				onDismiss:( void (^)( ) )dismissCB;

/*!
 * @abstract shows Bank dialog to purchase game currency
 * @param dismissCB The callback interface to notify dismissing Webview dialog
 */
+ (void) showBankUI:(void (^)())dismissCB;

/*!
 * @abstract gets the Button object which extends UIButon to show virtual currency balance and navigate to Bank UI
 * @param rect CGRect rectangle to draw
 */
+ (MBGBalanceButton *)getBalanceButton:(CGRect)rect;

/*!
 * @abstract gets the ImageView object which extends UIImageView to show virtual currency balance
 * @param rect CGRect rectangle to draw
 * @param color UIColor to draw
 * @param size integer value to specify font size 
 */
+ (MBGBalanceImage *)getBalanceImage:(CGRect)rect
							   color:(UIColor *)color
							fontSize:(NSInteger)size;

@end

