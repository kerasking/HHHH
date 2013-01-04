//
//  MobageNotificationQueue.h
//  MyNativeTest
//
//  Created by panzaofeng on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MobageNotificationTypes.h"

@class MobageNotification;

@interface MobageNotificationQueue : NSObject<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL notificationQueueReady;
@property (nonatomic) MobageNotificationDisplayPosition displayPosition;

+ (MobageNotificationQueue*)shareInstance;

-(void)generateLoginNotificationWithNickname:(NSString*)nickname;
-(void)generateNotificationWithText:(NSString*)text;
-(void)generateNotificationWithText:(NSString*)text openUrl:(NSString*)url;
@end
