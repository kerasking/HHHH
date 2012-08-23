//
//  NDAnimationGroupPool.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDAnimationGroupPool.h"
#include "NDPath.h"
#include "JavaMethod.h"
#include "Utility.h"

using namespace NDEngine;
using namespace cocos2d;

static NDAnimationGroupPool *NDAnimationGroupPool_DefaultPool = NULL;

NDAnimationGroupPool::NDAnimationGroupPool()
: m_animationGroups(NULL)
{
	NDAsssert(NDAnimationGroupPool_DefaultPool == NULL);
	m_animationGroups = new CCMutableDictionary<std::string, NDAnimationGroup*>();
}

NDAnimationGroupPool::~NDAnimationGroupPool()
{
	CC_SAFE_RELEASE(m_animationGroups);
}

NDAnimationGroupPool* NDAnimationGroupPool::defaultPool()
{
	if (!NDAnimationGroupPool_DefaultPool)
	{
		NDAnimationGroupPool_DefaultPool = new NDAnimationGroupPool;
	}
	
	return NDAnimationGroupPool_DefaultPool;
}

void NDAnimationGroupPool::purgeDefaultPool()
{
	CC_SAFE_RELEASE_NULL(NDAnimationGroupPool_DefaultPool);
}

NDAnimationGroup* NDAnimationGroupPool::addObjectWithSpr(const char*sprFile)
{
	NDAnimationGroup *group = NULL;
	
	group = m_animationGroups->objectForKey(sprFile);

	if (!group) 
	{
		group = new NDAnimationGroup;
		group->initWithSprFile(sprFile);

		if (group) 
		{
			m_animationGroups->setObject(group, sprFile);
			//[group release];
		}		
	}
	else 
	{
		group->retain();
	}

	return group;
}

NDAnimationGroup* NDAnimationGroupPool::addObjectWithModelId(int ModelId)
{	
	char sprFile[256] = {0};
	sprintf(sprFile, "%smodel_%d.spr", NDPath::GetAnimationPath().c_str(), ModelId);
	return this->addObjectWithSpr(sprFile);
}

NDAnimationGroup* NDAnimationGroupPool::addObjectWithSceneAnimationId(int SceneAnimationId)
{	
	char sprFile[256] = {0};
	sprintf(sprFile, "%sscene_ani_%d.spr", NDPath::GetAnimationPath().c_str(), SceneAnimationId);
	return this->addObjectWithSpr(sprFile);
}

void NDAnimationGroupPool::removeObjectWithSpr(const char* sprFile)
{
	m_animationGroups->removeObjectForKey(sprFile);
}

void NDAnimationGroupPool::removeObjectWithSceneAnimationId(int SceneAnimationId)
{
	char sprFile[256] = {0};
	sprintf(sprFile, "%sscene_ani_%d.spr", NDPath::GetAnimationPath().c_str(), SceneAnimationId);
	this->removeObjectWithSpr(sprFile);
}

void NDAnimationGroupPool::Recyle()
{
	if (NULL == m_animationGroups)
	{
		return;
	}
	
	std::vector<std::string> allKeys = m_animationGroups->allKeys();
	
	if (allKeys.empty())
	{
		return;
	}
	
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	std::vector<std::string> recyle;
	
	for (unsigned int i = 0; i < allKeys.size(); i++) 
	{
		std::string	key = allKeys[i];

		NDAnimationGroup *anigroup = m_animationGroups->objectForKey(key);

		if (NULL == anigroup)
		{
			continue;
		}
		
		if (1 >= anigroup->retainCount())
		{
			recyle.push_back(key);
		}
	}

	for (unsigned int i = 0; i < recyle.size(); i++)
	{
		m_animationGroups->removeObjectForKey(recyle[i]);
	}

	//[pool release];
}
