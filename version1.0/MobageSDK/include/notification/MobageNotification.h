//
//  MobageNotification.h
//  MyNativeTest
//
//  Created by panzaofeng on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MobageNotificationTypes.h"


@interface MobageNotification : NSObject


@property (nonatomic, copy, readonly) NSString* message;

@property (nonatomic, copy, readonly) NSString* openUrl;

@property (readonly) MobageNotificationViewDisplayType displayType;

@property (readonly) NSTimeInterval duration;


+ (id)notificationForLoginWithUsername:(NSString*)username;
+ (id)notificationWithText:(NSString*)text;

+ (id)notificationWithText:(NSString*)text openUrl:(NSString*)url;
@end
