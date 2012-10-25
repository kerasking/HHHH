/*
 *  CCTextureCacheExt.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGImage.h>
#import "CCTextureCache.h"

@class CCTexture2D;

@interface CCTextureCache (ChangeColor)

-(CCTexture2D*) addColorImage: (NSString*)imageName;

@end

@interface CCTextureCache (Memory)

-(void) Recyle;

- (int) Statistics:(BOOL)bNotPrintLog;
@end