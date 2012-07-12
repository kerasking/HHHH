//
//  NDAnimationGroupPool.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_ANIMATION_GROUP_POOL_H_
#define _ND_ANIMATION_GROUP_POOL_H_

#include "NDAnimationGroup.h"
#include "CCMutableDictionary.h"

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
	cocos2d::CCMutableDictionary<std::string, NDAnimationGroup*> *m_animationGroups;

private:
	NDAnimationGroupPool();
public:
	~NDAnimationGroupPool();
};

#endif
