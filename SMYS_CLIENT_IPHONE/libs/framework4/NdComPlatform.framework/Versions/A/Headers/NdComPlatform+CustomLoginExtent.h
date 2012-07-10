//
//  NdComPlatform+CustomLoginExtent.h
//  NdComPlatform_SNS
//
//  Created by chenjianshe on 11-11-1.
//  Copyright 2011 NetDragon WebSoft Inc. All rights reserved.
//

#ifdef ENABLE_NDCP_CUSTOM_LOGIN_EXTENT
#import <Foundation/Foundation.h>
#import "NdComPlatform.h"

@interface NdComPlatform(CustomLoginExtent)

- (void)NdCustomLoginWithUserID:(NSString*)userID andPassword:(NSString*)password;

@end

#endif