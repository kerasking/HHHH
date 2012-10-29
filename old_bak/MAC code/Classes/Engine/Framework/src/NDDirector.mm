//
//  NDDirector.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDDirector.h"
#import "ccMacros.h"
#import "NDAnimationGroupPool.h"
#import "NDMapDataPool.h"
#import "EAGLView.h"
#import "CCTexture2D.h"
#import "GameSceneLoading.h"
#import "CCTextureCache.h"
#import "cpLog.h"
#import "NDBaseTransitionScene.h"
#import "CCTouchDispatcher.h"
#import "NDMapData.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDDirector, NDObject)
	
	static NDDirector* NDDirector_defaultDirector = NULL;
	
	NDDirector::NDDirector()
	{
		NDAsssert(NDDirector_defaultDirector == NULL);
		
		CC_DIRECTOR_INIT();
		m_director = [CCDirector sharedDirector];
		m_setViewRectNode = NULL;
		m_resetViewRect = false;
		
		m_TransitionSceneWait = NULL;
		
		m_TransitionSceneType = eTransitionSceneNone;
		m_fXScaleFactor = 1.0f;
		m_fYScaleFactor	= 1.0f;
		m_bEnableRetinaDisplay	= false;
	}
	
	NDDirector::~NDDirector()
	{
		if (m_TransitionSceneWait) 
		{
			delete m_TransitionSceneWait;
		}
		
		[m_director release];
		[window release];
		NDDirector_defaultDirector = NULL;
	}
	
	
	NDDirector* NDDirector::DefaultDirector()
	{
		if (NDDirector_defaultDirector == NULL) 
		{		
			NDDirector_defaultDirector = new NDDirector();
		}
		return NDDirector_defaultDirector;
	}
	
	void NDDirector::Initialization()
	{	
		[m_director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
		
		EAGLView *view = [m_director openGLView];
		[view setMultipleTouchEnabled:NO];
		if ( YES == [m_director enableRetinaDisplay: true] )
		{
			m_bEnableRetinaDisplay	= true;
		}
		[m_director setAnimationInterval:1.0f / 50 ];
		
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];	
		
		//#if ND_DEBUG_STATE == 1
			m_director.displayFPS = YES;
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
			NDObject* obj = (NDObject*)*iter;
			if (obj == receiver) 
			{
				m_delegates.erase(iter);
				break;
			}
		}
	}
	
	void NDDirector::TransitionAnimateComplete()
	{
		if (!m_TransitionSceneWait) return;
		
		switch (m_TransitionSceneType) {
			case eTransitionSceneReplace:
				ReplaceScene(m_TransitionSceneWait);
				break;
			case eTransitionScenePush:
				PushScene(m_TransitionSceneWait);
				break;
			case eTransitionScenePop:
				PopScene(NULL, false);
			default:
				break;
		}
		
		m_TransitionSceneWait = NULL;
	}
	
	void NDDirector::SetTransitionScene(NDScene *scene, TransitionSceneType type)
	{
		m_TransitionSceneWait = scene;
		
		m_TransitionSceneType = type;
		
		//[m_director pushScene:[CCTransitionFadeTR transitionWithDuration:1.2f scene:(CCScene *)scene->m_ccNode]];
		[m_director pushScene:[CCTransitionFade transitionWithDuration:1.2f scene:(CCScene *)scene->m_ccNode]];
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
		[[CCTouchDispatcher sharedDispatcher] setDispatchEvents: (enable ? YES : NO) ];
	}
	
	void NDDirector::RunScene(NDScene* scene)
	{		
		m_scenesStack.push_back(scene);		
		[m_director runWithScene:(CCScene *)scene->m_ccNode];
	}
	
	void NDDirector::ReplaceScene(NDScene* scene, bool bAnimate/*=false*/)
	{	
		if (bAnimate) 
		{
			SetTransitionScene(scene, eTransitionSceneReplace);
			
			return;
		}
		
		if (m_scenesStack.size() > 0) 
		{
			NDLog(@"===============================当前场景栈大小[%u]", m_scenesStack.size());
			this->BeforeDirectorPopScene(m_scenesStack.back(), true);
			
			delete m_scenesStack.back();
			m_scenesStack.pop_back();
			
			this->AfterDirectorPopScene(true);			
		}
		
		this->BeforeDirectorPushScene(scene);
        
        NDLog(@"111111===================当前场景栈大小[%u]", m_scenesStack.size());
		
		m_scenesStack.push_back(scene);
		
		[m_director replaceScene:(CCScene *)scene->m_ccNode];
				
		this->AfterDirectorPushScene(scene);
		
		NDLog(@"===============================当前场景栈大小[%u]", m_scenesStack.size());
	}
	
	void NDDirector::PushScene(NDScene* scene, bool bAnimate/*=false*/)
	{
		if (bAnimate) 
		{
			SetTransitionScene(scene, eTransitionScenePush);
			
			return;
		}
		
		this->BeforeDirectorPushScene(scene);
		
		m_scenesStack.push_back(scene);		
		[m_director pushScene:(CCScene *)scene->m_ccNode];		
		
		this->AfterDirectorPushScene(scene);
		
		NDLog(@"===============================当前场景栈大小[%u]", m_scenesStack.size());
	}
	
	bool NDDirector::PopScene(NDScene* scene/*=NULL*/, bool bAnimate/*=false*/)
	{
		if (bAnimate && m_scenesStack.size() >= 2) 
		{
			SetTransitionScene(m_scenesStack[m_scenesStack.size()-2], eTransitionScenePop);
			
			return true;
		}
		
		return this->PopScene(true);
	}
	
	bool NDDirector::PopScene(bool cleanUp)
	{		
		if (m_scenesStack.size() < 2) 
		{
			return false;
		}
		
		this->BeforeDirectorPopScene(this->GetRunningScene(), cleanUp);
		
		NDLog(@"===============================当前场景栈大小[%u]", m_scenesStack.size());
		
		if (cleanUp) 
		{
			delete m_scenesStack.back();
		}			
		m_scenesStack.pop_back();		
		[m_director popScene];
		
		this->AfterDirectorPopScene(cleanUp);
		
		NDLog(@"===============================当前场景栈大小[%u]", m_scenesStack.size());
		
		return true;
	}
	
	void NDDirector::PurgeCachedData()
	{		
		NDPicturePool::PurgeDefaultPool();
		[[CCTextureCache sharedTextureCache] removeAllTextures];
		[NDAnimationGroupPool purgeDefaultPool];
	}
	
	void NDDirector::Pause()
	{
		[m_director pause];
	}
	
	void NDDirector::Resume()
	{
		[m_director resume];
	}
	
	void NDDirector::StopAnimation()
	{
		[m_director stopAnimation];
	}
	
	void NDDirector::StartAnimation()
	{
		[m_director startAnimation];
	}
	
	void NDDirector::Stop()
	{
		[m_director end];
		
		while (m_scenesStack.begin() != m_scenesStack.end()) 
		{
			delete m_scenesStack.back();		
			m_scenesStack.pop_back();
		}
	}
	
	bool NDDirector::isPaused()
	{
		return (bool)m_director.isPaused;
	}
	
	NDScene* NDDirector::GetScene(const NDRuntimeClass* runtimeClass)
	{
		for (size_t i = 0; i < m_scenesStack.size(); i++) {
			NDScene* scene = m_scenesStack.at(i);
			if (scene->IsKindOfClass(runtimeClass)) {
				return scene;
			}
		}
		return NULL;
	}
	
	NDScene* NDDirector::GetRunningScene()
	{
		if (m_scenesStack.size() > 0) 
		{
			return m_scenesStack.back();
		}
		return NULL;	
	}
	
	void NDDirector::SetDisplayFPS(bool bDisplayed)
	{
		[m_director setDisplayFPS:bDisplayed];
	}
	
	CGSize NDDirector::GetWinSize()
	{
		return [m_director winSizeInPixels];
	}
	
	CGSize NDDirector::GetWinPoint()
	{
		return [m_director winSize];
	}
    
	void NDDirector::SetViewRect(CGRect rect, NDNode* node)
	{
		if (m_TransitionSceneWait) {
			return;
		}
		CGSize winSize = [m_director winSizeInPixels];
		
		glEnable(GL_SCISSOR_TEST);
		//		if (m_TransitionSceneWait)
		//			glScissor(winSize.width - rect.origin.x - rect.size.width, 
		//					  winSize.height - rect.origin.y - rect.size.height, 
		//					  rect.size.width, rect.size.height);
		//		else
		ccDeviceOrientation cor = [[CCDirector sharedDirector] deviceOrientation];
		if (UIDeviceOrientationLandscapeLeft == cor)
		{
			glScissor(winSize.height - rect.origin.y - rect.size.height, 
					  winSize.width - rect.origin.x - rect.size.width, 
					  rect.size.height, rect.size.width);
		}else if (UIDeviceOrientationLandscapeRight == cor)
		{
			glScissor(rect.origin.y, rect.origin.x, 
					  rect.size.height, rect.size.width);
		}
		
		m_setViewRectNode = node;
		m_resetViewRect = true;
	}
	
	void NDDirector::ResumeViewRect(NDNode* drawingNode)
	{		
		if (!m_resetViewRect) 
		{
			return;
		}
		
		if (m_setViewRectNode) 
		{			
			if (drawingNode == m_setViewRectNode) 
			{
				return;
			}
			
			if (drawingNode->IsChildOf(m_setViewRectNode))
			{
				return;
			}
		}
		
		DisibleScissor();
	}
	
	void NDDirector::DisibleScissor()
	{
		glDisable(GL_SCISSOR_TEST);
		m_setViewRectNode = NULL;
		m_resetViewRect = false;
	}
	
	void NDDirector::BeforeDirectorPopScene(NDScene* scene, bool cleanScene)
	{
		std::vector<NDObject*>::iterator iter;
		for (iter = m_delegates.begin(); iter != m_delegates.end(); iter++) 
		{
			NDObject* obj = (NDObject*)*iter;
			NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*> (obj);
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
			NDObject* obj = (NDObject*)*iter;
			NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*> (obj);
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
			NDObject* obj = (NDObject*)*iter;
			NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*> (obj);
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
			NDObject* obj = (NDObject*)*iter;
			NDDirectorDelegate* delegate = dynamic_cast<NDDirectorDelegate*> (obj);
			if (delegate) 
			{
				delegate->AfterDirectorPushScene(this, scene);
			}			
		}
	}
	
	NDScene* NDDirector::GetSceneByTag(int nSceneTag)
	{
		for (size_t i = 0; i < m_scenesStack.size(); i++) {
			NDScene* scene = m_scenesStack.at(i);
			if (scene->GetTag() == nSceneTag) {
				return scene;
			}
		}
		return NULL;
	}
	
	float NDDirector::GetScaleFactor()
	{
		//CGSize size	= this->GetWinSize();
		//return size.width / 480;
        return CC_CONTENT_SCALE_FACTOR();
	}
	
	float NDDirector::GetScaleFactorY()
	{
		//CGSize size	= this->GetWinSize();
		//return size.height / 320;
        return CC_CONTENT_SCALE_FACTOR();

	}
	
	bool NDDirector::IsEnableRetinaDisplay()
	{
		return m_bEnableRetinaDisplay;
	}
}