//
//  NDAnimationGroupPool.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _ND_ANIMATION_GROUP_POOL_H_
#define _ND_ANIMATION_GROUP_POOL_H_

#include "NDAnimationGroup.h"

class NDAnimationGroupPool : public cocos2d::CCObject 
{
public:
	static NDAnimationGroupPool* defaultPool();
	static void purgeDefaultPool();

	NDAnimationGroup* addObjectWithSpr(const char*sprFile);
	NDAnimationGroup* addObjectWithSceneAnimationId(int SceneAnimationId);
	NDAnimationGroup* addObjectWithModelId(int ModelId);

	void removeObjectWithSpr(const char* sprFile);
	void removeObjectWithSceneAnimationId(int SceneAnimationId);
	void Recyle();

private:
	CCMutableDictionary<std::string, NDAnimationGroup*> *m_animationGroups;
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

#endif
