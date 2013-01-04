/**
 * MBGAppPatch.h
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MBG_APP_PATCHING_ENABLED 1

#if MBG_APP_PATCHING_ENABLED
@interface MBGAppPatch : NSObject <UIApplicationDelegate>
@end

#endif