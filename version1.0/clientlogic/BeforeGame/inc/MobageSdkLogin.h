/*
 *  MobageSdkLogin.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MBGPlatform.h"

@interface MobageSdkLogin : NSObject<MBGPlatformDelegate>
{
}

- (void)LoginWithUser;

@end