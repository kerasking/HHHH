//
//  NDAnimationGroupPool.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NDAnimationGroup.h"

@interface NDAnimationGroupPool : NSObject 
{
	NSMutableDictionary *m_animationGroups;
}

+ (NDAnimationGroupPool *)defaultPool;
+ (void)purgeDefaultPool;

- (NDAnimationGroup *)addObjectWithSpr:(NSString *)sprFile;
- (NDAnimationGroup *)addObjectWithSceneAnimationId:(int)SceneAnimationId;
- (NDAnimationGroup *)addObjectWithModelId:(int)ModelId;

- (void)removeObjectWithSpr:(NSString *)sprFile;
- (void)removeObjectWithSceneAnimationId:(int)SceneAnimationId;
- (void)Recyle;

@end
