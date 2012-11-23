//
//  NDDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDDirector.h"
#include "ccMacros.h"
// #include "NDAnimationGroupPool.h"
// #include "NDMapDataPool.h"
#include "CCEGLView.h"
#include "CCTexture2D.h"
#include "CCTextureCache.h"
#include "CCTouchDispatcher.h"
//#include "NDMapData.h"
#include "NDPicture.h"
#include "NDAnimationGroupPool.h"
#include "globaldef.h"
#include "NDDebugOpt.h"
#include "NDBaseDirector.h"

using namespace cocos2d;

namespace NDEngine
{
IMPLEMENT_CLASS(NDDirector, NDObject)

static NDDirector* gs_pkNDDirectorDefaultDirector = NULL;

NDDirector::NDDirector()
{
	//NDAsssert(gs_pkNDDirectorDefaultDirector == NULL);	///< 这里加Assert干嘛？？？？？？ 郭浩

	//CC_DIRECTOR_INIT();
	m_pkDirector = NDBaseDirector::sharedDirector();
	m_pkSetViewRectNode = NULL;
	m_bResetViewRect = false;
	m_fXScaleFactor = 1.0f;
	m_fYScaleFactor = 1.0f;

	m_bEnableRetinaDisplay = false;

	m_pkTransitionSceneWait = NULL;

	m_eTransitionSceneType = eTransitionSceneNone;

	NDLog("End NDDirector constructed function,m_pkDirector value is %d",(int)m_pkDirector);
}

NDDirector::~NDDirector()
{
	if (m_pkTransitionSceneWait)
	{
		delete m_pkTransitionSceneWait;
	}

	m_pkDirector->release();
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

void NDDirector::Initialization()
{
	NDLog("Entry NDDirector::Initialization(),the m_pkDirector = %d",(int)m_pkDirector);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

	CCEGLView* pkEGLView = CCEGLView::sharedOpenGLViewPtr();

	NDLog("pkEGLView's address is %d",(int)pkEGLView);

	m_pkDirector->setOpenGLView(pkEGLView);

#else

	CCEGLView& kEGLView = CCEGLView::sharedOpenGLView();

	NDLog("kEGLView's address is %d",(int)&kEGLView);

	m_pkDirector->setOpenGLView(&kEGLView);

#endif

	NDLog("end m_pkDirector->setOpenGLView(&CCEGLView::sharedOpenGLView());");

	m_pkDirector->setDeviceOrientation(kCCDeviceOrientationLandscapeLeft);

	NDLog("end m_pkDirector->setDeviceOrientation(kCCDeviceOrientationLandscapeLeft);");

	CC_GLVIEW* pkView = m_pkDirector->getOpenGLView();

	NDLog("end pkView get value,the value is %d",(int)pkView);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	//view->setMultipleTouchEnabled(false);
#endif
	
	if (m_pkDirector->enableRetinaDisplay(true))
	{
		m_bEnableRetinaDisplay = true;
	}

	NDLog("end m_pkDirector->enableRetinaDisplay(true)");

	m_pkDirector->setAnimationInterval(1.0f / 24.0f); //@zwq

	CCTexture2D::setDefaultAlphaPixelFormat (kTexture2DPixelFormat_RGBA8888);

	//#if ND_DEBUG_STATE == 1
	m_pkDirector->setDisplayFPS(true);

	NDLog("end m_pkDirector->setDisplayFPS(true)");

	//#else
	//m_director.displayFPS = NO;
	//#endif
}

void NDDirector::AddDelegate(NDObject* receiver)
{
	m_delegates.push_back(receiver);
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
// 		m_TransitionSceneWait = scene;
// 		
// 		m_TransitionSceneType = type;
// 		
// 		[m_director pushScene:[CCTransitionFadeTR transitionWithDuration:1.2f scene:(CCScene *)scene->m_ccNode]];

	/*
	 static bool right = true;
	 if (right)
	 [m_director pushScene:[CCMoveInRTransition transitionWithDuration:0.6f scene:(CCScene *)scene->m_ccNode]];
	 else
	 [m_director pushScene:[CCMoveInLTransition transitionWithDuration:0.6f scene:(CCScene *)scene->m_ccNode]];

	 right = !right;
	 */
}

void NDDirector::EnableDispatchEvent(bool enable)
{
	CCTouchDispatcher::sharedDispatcher()->setDispatchEvents(
			enable ? true : false);
}

void NDDirector::RunScene(NDScene* scene)
{
	NDLog("entry RunScene(NDScene* scene)");

	//@zwq
	if (m_pkDirector->getRunningScene())
	{
		m_kScenesStack.push_back(scene);
		m_pkDirector->replaceScene((CCScene *) scene->m_ccNode);
	}
	else
	{
		m_kScenesStack.push_back(scene);
		m_pkDirector->runWithScene((CCScene *) scene->m_ccNode);
	}

	NDLog("Leave RunScene(NDScene* scene)");
}

void NDDirector::ReplaceScene(NDScene* pkScene, bool bAnimate/*=false*/)
{
// 		if (bAnimate) 
// 		{
// 			SetTransitionScene(scene, eTransitionSceneReplace);
// 			
// 			return;
// 		}

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
	
//	BeforeDirectorPushScene(pkScene);

	RunScene(pkScene);

//	AfterDirectorPushScene(pkScene);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
}

void NDDirector::PushScene(NDScene* scene, bool bAnimate/*=false*/)
{
// 		if (bAnimate) 
// 		{
// 			SetTransitionScene(scene, eTransitionScenePush);
// 			
// 			return;
// 		}

	this->BeforeDirectorPushScene(scene);

	m_kScenesStack.push_back(scene);
	m_pkDirector->pushScene((CCScene *) scene->m_ccNode);

	this->AfterDirectorPushScene(scene);

	//NDLog("===============================当前场景栈大小[%u]", m_scenesStack.size());
}

bool NDDirector::PopScene(NDScene* scene/*=NULL*/, bool bAnimate/*=false*/)
{
// 		if (bAnimate && m_scenesStack.size() >= 2) 
// 		{
// 			SetTransitionScene(m_scenesStack[m_scenesStack.size()-2], eTransitionScenePop);
// 			
// 			return true;
// 		}

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

void NDDirector::Pause()
{
	m_pkDirector->pause();
}

void NDDirector::Resume()
{
	m_pkDirector->resume();
}

void NDDirector::StopAnimation()
{
	m_pkDirector->stopAnimation();
}

void NDDirector::StartAnimation()
{
	m_pkDirector->startAnimation();
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

bool NDDirector::isPaused()
{
	return (bool) m_pkDirector->isPaused();
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
	NDLog("Entry NDDirector::GetRunningScene()");

	if (m_kScenesStack.size() > 0)
	{
		NDLog("return m_kScenesStack.back();");
		return m_kScenesStack.back();
	}

	NDError("m_kScenesStack == 0,None scene");
	return NULL;
}

void NDDirector::SetDisplayFPS(bool bDisplayed)
{
	m_pkDirector->setDisplayFPS(bDisplayed);
}

CGSize NDDirector::GetWinSize()
{
	return m_pkDirector->getWinSizeInPixels();
}

void NDDirector::SetViewRect(CGRect kRect, NDNode* pkNode)
{
	if (m_pkTransitionSceneWait)
	{
		return;
	}

	CGSize kWinSize = m_pkDirector->getWinSizeInPixels();

	glEnable (GL_SCISSOR_TEST);

	glScissor(kWinSize.height - kRect.origin.y - kRect.size.height,
			kWinSize.width - kRect.origin.x - kRect.size.width, kRect.size.height,
			kRect.size.width);

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

float NDDirector::GetScaleFactor()
{
	return m_pkDirector->getContentScaleFactor();
}

cocos2d::CCSize NDDirector::GetWinPoint()
{
	return m_pkDirector->getWinSize();
}

float NDDirector::GetScaleFactorY()
{
	return CC_CONTENT_SCALE_FACTOR();
}

bool NDDirector::IsEnableRetinaDisplay()
{
	return m_bEnableRetinaDisplay;
}

void NDDirector::SetDelegate( NDObject* pkReceiver )
{

}

NDObject* NDDirector::GetDelegate()
{
	return NULL;
}

}