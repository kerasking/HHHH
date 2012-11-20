//
//  NDDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDDirector.h"
#include "ccMacros.h"
#include "CCEGLView.h"
#include "CCTexture2D.h"
#include "CCTextureCache.h"
#include "CCTouchDispatcher.h"
#include "NDPicture.h"
#include "NDAnimationGroupPool.h"
#include "define.h"
#include "CCTransition.h"

using namespace cocos2d;

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDDirector, NDObject)

static NDDirector* gs_pkNDDirectorDefaultDirector = NULL;

NDDirector::NDDirector()
{
	NDAsssert(gs_pkNDDirectorDefaultDirector == NULL);

	m_pkDirector = CCDirector::sharedDirector();
	m_pkSetViewRectNode = NULL;
	m_bResetViewRect = false;
	m_pkTransitionSceneWait = NULL;
	m_eTransitionSceneType = eTransitionSceneNone;
}

NDDirector::~NDDirector()
{
	SAFE_DELETE (m_pkTransitionSceneWait);

	SAFE_RELEASE( m_pkDirector );

	gs_pkNDDirectorDefaultDirector = NULL;
}

NDDirector* NDDirector::DefaultDirector()
{
	if (gs_pkNDDirectorDefaultDirector == NULL)
	{
		gs_pkNDDirectorDefaultDirector = new NDDirector();
	}
	return gs_pkNDDirectorDefaultDirector;
}

void NDDirector::RemoveDelegate(NDObject* receiver)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;

		if (obj == receiver)
		{
			m_delegates.erase(iter);
			break;
		}
	}
}

void NDDirector::TransitionAnimateComplete()
{
	if (!m_pkTransitionSceneWait)
	{
		return;
	}

	switch (m_eTransitionSceneType)
	{
	case eTransitionSceneReplace:
		ReplaceScene (m_pkTransitionSceneWait);
		break;
	case eTransitionScenePush:
		PushScene(m_pkTransitionSceneWait);
		break;
	case eTransitionScenePop:
		PopScene(NULL, false);
	default:
		break;
	}

	m_pkTransitionSceneWait = NULL;
}

void NDDirector::SetTransitionScene(NDScene *scene, TransitionSceneType type)
{
	m_pkTransitionSceneWait = scene;

	m_eTransitionSceneType = type;

	m_pkDirector->pushScene(CCTransitionFade::transitionWithDuration(1.2f, (CCScene *)scene->m_ccNode));
	//[m_director pushScene:[CCTransitionFadeTR transitionWithDuration:1.2f scene:(CCScene *)scene->m_ccNode]];

	/*
	 static bool right = true;
	 if (right)
	 [m_director pushScene:[CCMoveInRTransition transitionWithDuration:0.6f scene:(CCScene *)scene->m_ccNode]];
	 else
	 [m_director pushScene:[CCMoveInLTransition transitionWithDuration:0.6f scene:(CCScene *)scene->m_ccNode]];

	 right = !right;
	 */
}


void NDDirector::RunScene(NDScene* scene)
{
// 	//@zwq
// 	if (m_pkDirector->getRunningScene())
// 	{
// 		m_kScenesStack.push_back(scene);
// 		m_pkDirector->replaceScene((CCScene *) scene->m_ccNode);
// 	}
// 	else
// 	{
// 		m_kScenesStack.push_back(scene);
// 		m_pkDirector->runWithScene((CCScene *) scene->m_ccNode);
// 	}

	m_kScenesStack.push_back(scene);
	m_pkDirector->runWithScene((CCScene *) scene->m_ccNode);
}

void NDDirector::ReplaceScene(NDScene* pkScene, bool bAnimate/*=false*/)
{
// 	if (bAnimate) 
// 	{
// 		SetTransitionScene(pkScene, eTransitionSceneReplace);
// 
// 		return;
// 	}

	if (m_kScenesStack.size() > 0)
		{
			//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
			this->BeforeDirectorPopScene(m_kScenesStack.back(), true);
	
			NDScene* pkScene = m_kScenesStack.back();
	
			if (pkScene)
			{
				delete pkScene;
			}
	
			m_kScenesStack.pop_back();
	
			this->AfterDirectorPopScene(true);
		}
	
	BeforeDirectorPushScene(pkScene);
	m_kScenesStack.push_back(pkScene);
	m_pkDirector->replaceScene((CCScene *) pkScene->m_ccNode);
	//RunScene(pkScene);
	AfterDirectorPushScene(pkScene);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
}

void NDDirector::PushScene(NDScene* scene, bool bAnimate/*=false*/)
{
// 	if (bAnimate) 
// 	{
// 		SetTransitionScene(scene, eTransitionScenePush);
// 
// 		return;
// 	}

	this->BeforeDirectorPushScene(scene);

	m_kScenesStack.push_back(scene);
	m_pkDirector->pushScene((CCScene *) scene->m_ccNode);

	this->AfterDirectorPushScene(scene);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
}

bool NDDirector::PopScene(NDScene* scene/*=NULL*/, bool bAnimate/*=false*/)
{
// 	if (bAnimate && m_kScenesStack.size() >= 2) 
// 	{
// 		SetTransitionScene(m_kScenesStack[m_kScenesStack.size()-2], eTransitionScenePop);
// 
// 		return true;
// 	}

	return this->PopScene(true);
}

bool NDDirector::PopScene(bool cleanUp)
{
	if (m_kScenesStack.size() < 2)
	{
		return false;
	}

	this->BeforeDirectorPopScene(this->GetRunningScene(), cleanUp);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());

	if (cleanUp)
	{
		delete m_kScenesStack.back();
	}
	m_kScenesStack.pop_back();
	m_pkDirector->popScene();

	this->AfterDirectorPopScene(cleanUp);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());

	return true;
}

void NDDirector::PurgeCachedData()
{
	NDPicturePool::PurgeDefaultPool();
	CCTextureCache::sharedTextureCache()->removeAllTextures();
	NDAnimationGroupPool::purgeDefaultPool();
}

void NDDirector::Stop()
{
	m_pkDirector->end();

	while (m_kScenesStack.begin() != m_kScenesStack.end())
	{
		delete m_kScenesStack.back();
		m_kScenesStack.pop_back();
	}
}

NDScene* NDDirector::GetScene(const NDRuntimeClass* runtimeClass)
{
	for (size_t i = 0; i < m_kScenesStack.size(); i++)
	{
		NDScene* scene = m_kScenesStack.at(i);

		if (scene->IsKindOfClass(runtimeClass))
		{
			return scene;
		}
	}
	return NULL;
}

NDScene* NDDirector::GetRunningScene()
{
	if (m_kScenesStack.size() > 0)
	{
		return m_kScenesStack.back();
	}

	return NULL;
}

void NDDirector::SetViewRect(CCRect kRect, NDNode* pkNode)
{
	if (m_pkTransitionSceneWait)
	{
		return;
	}

	CCSize kWinSize = m_pkDirector->getWinSizeInPixels();

#if 1 //@check
	glEnable (GL_SCISSOR_TEST);

// 	glScissor(kWinSize.height - kRect.origin.y - kRect.size.height,
// 			kWinSize.width - kRect.origin.x - kRect.size.width, kRect.size.height,
// 			kRect.size.width);
	
	glScissor(	kRect.origin.x,
				kWinSize.height - (kRect.origin.y + kRect.size.height),
	 			kRect.size.width, 
				kRect.size.height );

#endif

	/***
	*	这里略有不同，但是可以接受，因为Mac上是调用UIDevice.h中的，这里不需要。
	*
	*	@author 郭浩
	*/

	m_pkSetViewRectNode = pkNode;
	m_bResetViewRect = true;
}

void NDDirector::ResumeViewRect(NDNode* drawingNode)
{
	if (!m_bResetViewRect)
	{
		return;
	}

	if (m_pkSetViewRectNode)
	{
		if (drawingNode == m_pkSetViewRectNode)
		{
			return;
		}

		if (drawingNode->IsChildOf(m_pkSetViewRectNode))
		{
			return;
		}
	}

	DisibleScissor();
}

void NDDirector::DisibleScissor()
{
	glDisable (GL_SCISSOR_TEST);
	m_pkSetViewRectNode = NULL;
	m_bResetViewRect = false;
}

void NDDirector::BeforeDirectorPopScene(NDScene* scene, bool cleanScene)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->BeforeDirectorPopScene(this, scene, cleanScene);
		}
	}
}

void NDDirector::AfterDirectorPopScene(bool cleanScene)
{
	std::vector<NDObject*>::iterator iter;
	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->AfterDirectorPopScene(this, cleanScene);
		}
	}
}

void NDDirector::BeforeDirectorPushScene(NDScene* scene)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->BeforeDirectorPushScene(this, scene);
		}
	}
}

void NDDirector::AfterDirectorPushScene(NDScene* scene)
{
	std::vector<NDObject*>::iterator iter;

	for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++)
	{
		NDObject* obj = (NDObject*) *iter;
		NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*>(obj);

		if (delegate)
		{
			delegate->AfterDirectorPushScene(this, scene);
		}
	}
}

NDScene* NDDirector::GetSceneByTag(int nSceneTag)
{
	for (size_t i = 0; i < m_kScenesStack.size(); i++)
	{
		NDScene* scene = m_kScenesStack.at(i);
		if (scene->GetTag() == nSceneTag)
		{
			return scene;
		}
	}
	return NULL;
}

NS_NDENGINE_END
