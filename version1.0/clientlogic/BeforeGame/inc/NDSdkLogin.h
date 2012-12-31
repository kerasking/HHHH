/*
 *  NDSdkLogin.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#include "ccPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>

@interface NDSdkLogin : NSObject
{

}

- (void)LoginWithUser;
- (void)LoginWith;
#endif

@end