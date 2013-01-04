//
//  LoginUtility.h
//
//  Copyright 2012 DeNA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobageReachability.h"
#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"


@interface LoginUtility : NSObject<UIAlertViewDelegate> 
{
    
}

@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, retain) UIWindow* mainWindow;
@property (nonatomic, retain) UIView* welcomeView;

//about user id, user name, refractor it as class later
@property (nonatomic, copy) NSString* userId;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* gameId;
@property (nonatomic, copy) NSString* affCode;

+ (LoginUtility*) shareInstance;

- (void) ssoLogOut;

+ (BOOL) isIPad;

+ (NSString *) platform;
+ (NSString *) platformString;
+ (NSString *) getOsVersion;
+ (NSString *) getMacAddress;
+ (NSString *) getUniqueIdentifier;
+ (NSString *) getAdvertisingIdentifier;
+ (NSString *) getIdentifierForVendor;

+ (NSString *) getHostDomain;
+ (NSString *) getHostBaseUrl;
+ (NSString *) getIapApiUrl;
+ (NSString *) getHomePage;

- (NSString *) checkNetworkStatus;

+ (NSString *) md5 : (NSString *) str;
+ (NSString *)encodeBase64WithString:(NSString *)strData;
+ (NSString *)decodeBase64WithString:(NSString *)strBase64;

- (void) viewToFront:(UIView *) view;
- (void) viewToBack:(UIView *) view;

- (void) viewToFrontFromRight:(UIView *) view;
- (void) viewToFrontFromLeft:(UIView *) view;
- (void) viewToFrontFade:(UIView *) view;
- (void) popWelcomeView:(NSString*)name;
@end
