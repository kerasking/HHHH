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
#include "UtilityInc.h"
#include "ObjectTracker.h"
#include "NDDictionary.h"

using namespace NDEngine;
using namespace cocos2d;

static NDAnimationGroupPool* gs_pkNDAnimationGroupPool_DefaultPool = NULL;

NDAnimationGroupPool::NDAnimationGroupPool() :
m_pkAnimationGroups(NULL)
{
	INC_NDOBJ("NDAnimationGroupPool");
	NDAsssert(gs_pkNDAnimationGroupPool_DefaultPool == NULL);
	m_pkAnimationGroups = new CCDictionary();
}

NDAnimationGroupPool::~NDAnimationGroupPool()
{
	DEC_NDOBJ("NDAnimationGroupPool");
	CC_SAFE_RELEASE (m_pkAnimationGroups);
}

NDAnimationGroupPool* NDAnimationGroupPool::defaultPool()
{
	if (!gs_pkNDAnimationGroupPool_DefaultPool)
	{
		gs_pkNDAnimationGroupPool_DefaultPool = new NDAnimationGroupPool;
	}

	return gs_pkNDAnimationGroupPool_DefaultPool;
}

void NDAnimationGroupPool::purgeDefaultPool()
{
	CC_SAFE_RELEASE_NULL (gs_pkNDAnimationGroupPool_DefaultPool);
}

NDAnimationGroup* NDAnimationGroupPool::addObjectWithSpr(const char*sprFile)
{
	NDAnimationGroup *pkGroup = NULL;

	pkGroup = (NDAnimationGroup*) m_pkAnimationGroups->objectForKey(sprFile);

	if (!pkGroup)
	{
		pkGroup = new NDAnimationGroup;
		pkGroup->initWithSprFile(sprFile);

		if (pkGroup)
		{
			m_pkAnimationGroups->setObject(pkGroup, sprFile);
			//[group release];
		}
	}
	else
	{
		pkGroup->retain();
	}

	return pkGroup;
}

NDAnimationGroup* NDAnimationGroupPool::addObjectWithModelId(int ModelId)
{
	char sprFile[256] =
	{ 0 };
	sprintf(sprFile, "%smodel_%d.spr", NDPath::GetAnimationPath().c_str(),
			ModelId);
	return this->addObjectWithSpr(sprFile);
}

NDAnimationGroup* NDAnimationGroupPool::addObjectWithSceneAnimationId(
		int nSceneAnimationId)
{
	char sprFile[256] =
	{ 0 };
	sprintf(sprFile, "%sscene_ani_%d.spr", NDPath::GetAnimationPath().c_str(),
			nSceneAnimationId);
	return this->addObjectWithSpr(sprFile);
}

void NDAnimationGroupPool::removeObjectWithSpr(const char* sprFile)
{
	m_pkAnimationGroups->removeObjectForKey(sprFile);
}

void NDAnimationGroupPool::removeObjectWithSceneAnimationId(
		int SceneAnimationId)
{
	char sprFile[256] =
	{ 0 };
	sprintf(sprFile, "%sscene_ani_%d.spr", NDPath::GetAnimationPath().c_str(),
			SceneAnimationId);
	this->removeObjectWithSpr(sprFile);
}

void NDAnimationGroupPool::Recyle()
{
	if (NULL == m_pkAnimationGroups)
	{
		return;
	}

	//std::vector < std::string > kAllKeys = m_pkAnimationGroups->allKeys();
	CCArray* kAllKeys = m_pkAnimationGroups->allKeys();

	if (!kAllKeys || kAllKeys->count() == 0)
	{
		return;
	}

	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	std::vector < std::string > kRecyle;

	for (unsigned int i = 0; i < kAllKeys->count(); i++)
	{
		CCString* strKey1 = (CCString*) kAllKeys->objectAtIndex(i);
		std::string strKey = strKey1->getCString();

		NDAnimationGroup *pkAnimationGroup = (NDAnimationGroup*) m_pkAnimationGroups->objectForKey(strKey);

		if (NULL == pkAnimationGroup)
		{
			continue;
		}

		if (1 >= pkAnimationGroup->retainCount())
		{
			kRecyle.push_back(strKey);
		}
	}

	for (unsigned int i = 0; i < kRecyle.size(); i++)
	{
		m_pkAnimationGroups->removeObjectForKey(kRecyle[i]);
	}

	//[pool release];
}

//²âÊÔÓÃ
string NDAnimationGroupPool::dump()
{
	if (!m_pkAnimationGroups) return "";

	string total;
	char line[512] = "";
	int totoal_anims = 0;

	// get all keys
	CCArray* allKeys = m_pkAnimationGroups->allKeys();
	if (!allKeys || allKeys->count() == 0)
	{
		return "";
	}

	// walk through all keys
	std::vector<std::string> kRecyle;
	for (unsigned int i = 0; i < allKeys->count(); i++)
	{
		// get key
		CCString* strKey = (CCString*) allKeys->objectAtIndex(i);
		if (!strKey) continue;

		// get obj
		const std::string& key = strKey->getCString();
		CCObject *obj = m_pkAnimationGroups->objectForKey(key);
		if (!obj) continue;

		// cast anim group
		NDAnimationGroup* animGroup = (NDAnimationGroup*)obj;
		if (animGroup)
		{
			int animCount = animGroup->getAnimations()->count();
			totoal_anims += animCount;

			sprintf( line, "@@ animGroup[%02d]: has %d animations, %s\r\n", i, animCount, key.c_str() );
			total += line;
		}
	}

	sprintf( line, "total %d animGroup, total %d anims\r\n", allKeys->count(), totoal_anims );
	total += line;
	return total;
}