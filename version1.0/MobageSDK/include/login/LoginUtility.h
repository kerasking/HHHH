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

@property (nonatomic, retain) UIWindow* mainWindow;
@property (nonatomic, retain) UIView* welcomeView;

@property (nonatomic, retain) NSMutableSet* viewSets;

//about user id, user name, refractor it as class later
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* gameId;
@property (nonatomic, retain) NSString* affCode;
@property UIInterfaceOrientation restoreOrient;

+ (LoginUtility*) shareInstance;

- (NSMutableSet *) getViewSets;

- (void) ssoLogOut;

+ (BOOL) isIPad;
+ (NSString *) get_mac;
+ (NSString *) platform;
+ (NSString *) platformString;
+ (NSString *) getOsVersion;

+ (NSString *) get_home_page;
+ (NSString *) getHomePageNoSSL;
+ (NSString *) get_host;
+ (NSString *) get_unique_id;

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
