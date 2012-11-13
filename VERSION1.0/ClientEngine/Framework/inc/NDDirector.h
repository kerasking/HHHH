//
//  NDDirector.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	－－介绍－－
//	导演对象是整个流程的代表，他负责游戏全过程的场景切换。
//	导演对象接受场景的要求，按照预先设计好的流程来终止、压栈、激活当前场景，引导下一个场景。
//	导演对象在初始化的时候默认为游戏配置了一种方案，
//	游戏开发过程中可通过导演类提供的接口更改配置。
//	导演通常只有一个。
#ifndef __NDDirector_H
#define __NDDirector_H

#include "NDScene.h"
#include "NDObject.h"
#include <vector>
#include "CCDirector.h"
#include "CCEGLView.h"
#include "NDNode.h"
#include "CCTouchDispatcher.h"

#define FONT_SCALE (NDDirector::DefaultDirector()->GetScaleFactor())

NS_NDENGINE_BGN

class NDDirector;
class NDDirectorDelegate
{
public:

//
//		注意：使用以下委托方法时请用AddDelegate添加委托对象和RemoveDelegate删除委托对象
//
//		函数：BeforeDirectorPopScene
//		作用：当场景被弹除栈之前被框架内部调用
//		参数：director导演对象指针，scene即将被弹出的场景，cleanScene该场景是否被释放
//		返回值：无
	virtual void BeforeDirectorPopScene(NDDirector* director, NDScene* scene,
			bool cleanScene)
	{
	}
//		
//		函数：AfterDirectorPopScene
//		作用：当场景被弹除栈之后被框架内部调用
//		参数：director导演对象指针，cleanScene否被释放了
//		返回值：无
	virtual void AfterDirectorPopScene(NDDirector* director, bool cleanScene)
	{
	}
//		
//		函数：BeforeDirectorPushScene
//		作用：当场景被压入栈之前被框架内部调用
//		参数：director导演对象指针，scene将被压入的场景
//		返回值：无
	virtual void BeforeDirectorPushScene(NDDirector* director, NDScene* scene)
	{
	}
//		
//		函数：AfterDirectorPushScene
//		作用：当场景被压入栈之后被框架内部调用
//		参数：director导演对象指针，scene被压入的场景
//		返回值：无
	virtual void AfterDirectorPushScene(NDDirector* director, NDScene* scene)
	{
	}
};

class NDDirector: public NDObject
{
DECLARE_CLASS(NDDirector)
public:
	NDDirector();
	~NDDirector();

public:
//		
//		函数：DefaultDirector
//		作用：单例静态方法，成员方法的访问请都通过该接口先。
//		参数：无
//		返回值：本对象指针
	static NDDirector* DefaultDirector();
//		
//		函数：Initialization
//		作用：导演对象在使用之初需要初始化一次用于完成游戏配置，该方法在整个程序中只被调用一次
//		参数：无
//		返回值：无
	void Initialization() {}
//		
//		函数：RunScene
//		作用：运行场景，该场景是游戏的第一个场景；在做游戏场景切换的时候不要使用该方法
//		参数：scene场景
//		返回值：无
	void RunScene(NDScene* scene);
//		
//		函数：ReplaceScene
//		作用：替换场景，用于场景变更；使用该方法必须确保游戏中有场景正在运行，第一个场景不会被替换，只会被压入栈底
//		参数：scene
//		返回值：无
	void ReplaceScene(NDScene* pkScene, bool bAnimate = false);
//		
//		函数：PushScene
//		作用：压入场景，用于场景变更；
//		参数：scene场景
//		返回值：无
	void PushScene(NDScene* scene, bool bAnimate = false);
//	
//		函数：PopScene
//		作用：弹出场景，并负责清理内存，用于场景变更；游戏中至少存在两个场景的情况下才会生效
//		参数：无
//		返回值：true成功, false失败
	bool PopScene(NDScene* scene = NULL, bool bAnimate = false);

//		
//		函数：PopScene(bool cleanUp)
//		作用：弹出场景，用于场景变更；游戏中至少存在两个场景的情况下才会生效
//		参数：cleanUp如果为true则清理内存，否则不清理内存
//		返回值：true成功, false失败
	bool PopScene(bool cleanUp);
//		
//		函数：GetRunningScene
//		作用：获取当前正在运行的场景
//		参数：无
//		返回值：失败返回null
	NDScene* GetRunningScene();
//		
//		函数：GetRunningScene
//		作用：获取内存中的指定场景
//		参数：runtimeClass 指定类型的场景
//		返回值：失败返回null		
	NDScene* GetScene(const NDRuntimeClass* runtimeClass);
//		
//		函数：Pause
//		作用：暂停运行当前场景
//		参数：无
//		返回值：无
	void Pause() { m_pkDirector->pause(); }
//		
//		函数：Resume
//		作用：恢复运行当前场景
//		参数：无
//		返回值：无
	void Resume() { m_pkDirector->resume(); }

	void StopAnimation() { m_pkDirector->stopAnimation(); }
	void StartAnimation() { m_pkDirector->startAnimation(); }

//		
//		函数：Stop
//		作用：停止游戏
//		参数：无
//		返回值：无
	void Stop();
//		
//		函数：PurgeCachedData
//		作用：清理游戏中所有的缓存数据，一般在游戏结束时调用
//		参数：无
//		返回值：无
	void PurgeCachedData();
//		
//		函数：SetDisplayFPS
//		作用：显示游戏运行时的帧数
//		参数：bDisplayed如果true显示，否则不显示
//		返回值：无
	void SetDisplayFPS(bool bDisplayed) { m_pkDirector->setDisplayStats(bDisplayed); }

//		
//		函数：isPaused
//		作用：判断游戏是否处于暂停状态
//		参数：无
//		返回值：true是 false否
	bool isPaused() { return m_pkDirector->isPaused(); }

//@dirty
//		
//		函数：GetWinSize
//		作用：获取屏幕大小
//		参数：无
//		返回值：屏幕大小
	CCSize GetWinSize() 
	{
		return m_pkDirector->getWinSizeInPixels();
		//return m_pkDirector->getWinSize();
	}

	CCSize GetWinSizeInPixels()
	{
		return m_pkDirector->getWinSizeInPixels();
	}

//@dirty
//		函数：GetWinPoint
//		作用：获取屏幕点大小
//		参数：无
//		返回值：屏幕点大小
	CCSize GetWinPoint() 
	{
		return m_pkDirector->getWinSize();
	}
//
//		函数：SetViewRect
//		作用：设置节点的绘制区域，一旦设置了节点的绘制区域，则子节点的绘制区域也不会超过该区域范围；
//			 如果使用该方法通常时在draw方法里调用；慎用。
//		参数：rect相对于屏幕的区域，node被设置绘制区域的节点
//		返回值：无
	void SetViewRect(CGRect kRect, NDNode* pkNode);
//		
//		函数：ResumeViewRect
//		作用：恢复初始绘制区域
//		参数：drawingNode当前帧正在访问的节点，如果drawingNode是被设置绘制区域的节点或者其子节点，则恢复无效
//		返回值：无	
	void ResumeViewRect(NDNode* drawingNode);
//		
//		函数：AddDelegate
//		作用：添加对象委托，注意：对象注册完委托，释放时请注销RemoveDelegate()
//		参数：receiver委托事件接收者
//		返回值：无	
	void AddDelegate(NDObject* receiver) { m_delegates.push_back(receiver); }
//		
//		函数：RemoveDelegate
//		作用：注销对象的委托
//		参数：receiver委托事件接收者
//		返回值：无	
	void RemoveDelegate(NDObject* receiver);

	void TransitionAnimateComplete();

	void EnableDispatchEvent(bool enable) {
		CCDirector::sharedDirector()->getTouchDispatcher()->setDispatchEvents( enable );
	}

	NDScene* GetSceneByTag(int nSceneTag);

	float GetScaleFactor() { return m_pkDirector->getContentScaleFactor(); }
//	float GetScaleFactorY() { CCDirector::sharedDirector()->getContentScaleFactor(); }

	bool IsEnableRetinaDisplay() { return CCEGLView::sharedOpenGLView()->isRetinaEnabled(); }

	void DisibleScissor();

	//UIWindow * GetWindow() { return window; } 这个UIWindow怎么处理? 郭浩

private:

	typedef enum
	{
		eTransitionSceneNone,
		eTransitionSceneReplace,
		eTransitionScenePush,
		eTransitionScenePop
	} TransitionSceneType;

	void SetTransitionScene(NDScene *scene, TransitionSceneType type);

private:
	cocos2d::CCDirector* m_pkDirector;
	std::vector<NDScene*> m_kScenesStack;
	NDNode* m_pkSetViewRectNode;
	bool m_bResetViewRect;
	std::vector<NDObject*> m_delegates;

	void SetDelegate(NDObject* pkReceiver) {}
	NDObject* GetDelegate() { return NULL; }

	void BeforeDirectorPopScene(NDScene* scene, bool cleanScene);
	void AfterDirectorPopScene(bool cleanScene);
	void BeforeDirectorPushScene(NDScene* scene);
	void AfterDirectorPushScene(NDScene* scene);

// 	float m_fXScaleFactor;			///< 这俩变量压根就没用上啊！何解？ 郭浩
// 	float m_fYScaleFactor;			///< 这俩变量压根就没用上啊！何解？ 郭浩
	
	NDScene* m_pkTransitionSceneWait;
	TransitionSceneType m_eTransitionSceneType;
};

NS_NDENGINE_END

#endif
