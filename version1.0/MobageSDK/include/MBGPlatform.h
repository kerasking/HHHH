/**
 * Mobage Social Platform APIs
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIWindow.h>
#import "MBGError.h"
#import "MBGSocialPeople.h"
#import "MBGSocialAppdata.h"
#import "MBGSocialBlacklist.h"
#import "MBGSocialProfanity.h"
#import "MBGSocialAuth.h"

/*!
 * @abstract Region Type
 */
enum MBG_REGION {
	MBG_REGION_US, //unsupported for now
	MBG_REGION_JP,  
	MBG_REGION_CN, //unsupported for now
    MBG_REGION_TW //unsupported for now
};

/*!
 * @abstract Server Type
 */
enum MBG_SERVER_TYPE {
	MBG_SANDBOX,
	MBG_PRODUCTION
};

# pragma mark -

/*!
 * @abstract Delegate interface for Login, notifying completion of showing Mobage's splash screen 
 */
@protocol MBGPlatformDelegate <NSObject>
/*! */
-(void) onLoginComplete:(NSString *)userId;
/*! */
-(void) onLoginRequired;
/*! */
-(void) onLoginError:(MBGError *)error;
/*! */
-(void) onSplashComplete;
@end

# pragma mark -

/*!
 * @abstract Main class for controlling the mobage SDK. Includes:
 * <br /> - Application activity control
 * <br /> - Login 
 * <br /> - Splash screen control 
 * <br /> - Tick(asynchronous operation handle) control 
 */
@interface MBGPlatform: NSObject<MBGPlatformDelegate>
{
	id<MBGPlatformDelegate> _delegate;
    UIWindow *_gameWindow;

    UIViewController *_rootViewController;
}

@property(nonatomic, assign) id<MBGPlatformDelegate> delegate;
@property(nonatomic, assign) UIWindow *gameWindow;
@property(nonatomic, assign) UIViewController *rootViewController;


/*!
 * @abstract gets an instance of this singleton
 */
+ (MBGPlatform*) sharedPlatform;

/*!
 * @abstract initializes the mobage platform sdk
 */
+ (void) initialize:(NSInteger)region
		 serverType:(NSInteger)server
		 consumerKey:(NSString *)key
	  consumerSecret:(NSString *)secret
			  appId:(NSString *)appId;

/*!
 * @abstract tick method to handle async operation.
 */
+ (void) tick;

/*!
 * @abstract register tick method with timer
 */
+ (void) registerTick;

/*!
 * @abstract returns version of SDK
 */
+ (NSString *) getSDKVersion;

/*!
 * @abstract notify mobage sdk that application will be paused. this method should be called in applicationWillResignActive 
 */
+(void)pause;

/*!
 * @abstract notify mobage sdk that application has been resumed. this method should be called in applicationDidBecomeActive
 */
+(void)resume;

/*!
 * @abstract notify mobage sdk that application will be stopped. this method should be called in applicationWillTerminate
 */
+(void)stop;

/*!
 * @abstract Asks the delegate to open a resource identified by URL.
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/*!
 * @abstract hides Mobage's splash screen 
 */
- (void) hideSplashScreen;

/*!
 * @abstract checks login status
 */
- (void) checkLoginStatus;

/*!
 * @abstract shows login dialog
 */
- (void) showLoginDialog;

/*!
 * @abstract shows logout dialog
 */
+ (void) showLogoutDialog:( void (^)( ) )successCB 
				 onCancel:( void (^)( ) )cancelCB;


/*!
 * @get server type:production or sandbox
 */
+(BOOL) isProductionEnv;

/*!
 * @setDelegate
 */
- (void) setDelegate:(id)delegate withWindow:(UIWindow *) gameWindow withRootViewController:(UIViewController *) controller;

/*!
 * @abstract notifies the mobage sdk of a successful application registration with Apple Push Service (APS).
 */
+(void)registerForRemoteNotification:(NSData*)deviceToken;
@end

