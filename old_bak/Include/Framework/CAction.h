/*
动作基础类
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/
#ifndef __ACTIONS_CCACTION_H__
#define __ACTIONS_CCACTION_H__
#include <stdio.h> 
#include "IActionDelegate.h"


#ifdef _WIN32
#include <Windows.h>
#include <float.h>
typedef __int64 int64_t;
#else// unix

#include <inttypes.h>
#include <float.h>

typedef long LONG;
typedef unsigned short WORD;
typedef unsigned int DWORD;
typedef unsigned char BYTE;
#endif

#ifndef NULL
#define NULL 0
#endif//NULL
//
//enum {
//	//! Default tag
//	ActionTagInvalid = -1,
//};

/** 
@brief Base class for CAction objects.
动作类关系图:
CAction(动作基类)
	CSpeed(设置速度的动作)
	CFiniteTimeAction(有限时间)
		CActionInterval(延时动作)
			CAnimate(动画)
			CPlace(放置)
			CSequence(序列动作:顺序执行多个动作)
			CSpawn(同步:同时执行多个动作)
			CRepeat(重复有限次数)
			CRepeatForever(重复一直循环)
			CReverseTime
			CDelayTime(延时)
			CFadeIn(从无到有),CFadeOut(从有到无),CFadeTo(透明值变到) [透明变化]
			CProgressFromTo(进度变化范围),CProgressTo(进度变化到) [进度变化动作]
			CTintBy(变化了),CTintTo(变化到) [颜色变化]
			CRotateBy(自旋转了),CRotateTo(旋转到) [自旋转角度动作<暂时只能围绕精灵的中心点自旋转>]
			CActionEase(加速度曲线动作)
				CEaseRateAction(加速度变化动作)
					CEaseIn(由慢至快),CEaseOut(由快至慢)
				CEaseExponentialIn(由慢至快),CEaseExponentialOut(由快至慢),CEaseExponentialInOut(由慢至快再由快至慢)[指数型曲线动作]
				CEaseSineIn(由慢至快),CEaseSineOut(由快至慢),CEaseSineInOut(由慢至快再由快至慢) [呈正弦曲线动作的加速度]
				CEaseElastic(心电图型动作)
					CCEaseElasticIn(由慢至快),CEaseElasticOut(由快至慢) [心电图型动作]
				CEaseBounce(股市型动作)
					CEaseBounceIn(由慢至快),CEaseBounceOut(由快至慢),CEaseBounceInOut(由慢至快再由快至慢) [股市型动作]
				CEaseBackIn(由慢至快),CEaseBackOut(由快至慢),CEaseBackInOut(由慢至快再由快至慢) [速度渐变动作]
		CActionInstant(瞬时动作)
			CShow(显示),CHide(隐藏)
			CToggleVisibility(可见切换)
			CFlipX(水平翻转),CFlipY(垂直翻转)
			CCallFunc(函数调用)
				CCallFuncN(执行带一个IActionDelegate*参数的函数)
					CCallFuncND(执行带两个参数(IActionDelegate*,void*)的函数)
*/
//动作类基类
class CAction  :public CObject
{
public:
    CAction(void);
	virtual ~CAction(void);

	//释放(减少该动作的引用计数)
	//virtual void Release(void);

	////保持(增加该动作的引用计数)
	//virtual void Retain(void);
public:

	//! return true if the action has finished
	//动作是否结束
	virtual bool IsDone(void);

	//! called before the action start. It will also set the target.
	//绑定一个精灵
	virtual void StartWithTarget(IActionDelegate *pTarget);//

	/** 
	called after the action has finished. It will set the 'target' to nil.
    IMPORTANT: You should never call "[action stop]" manually. Instead, use: "target->stopAction(action);"
	*/
	//停止动作
    virtual void Stop(void);

	//! called every frame with it's delta time. DON'T override unless you know what you are doing.
	//动作执行一个时间片
	virtual void Step(fTime dt);

	/** 
	called once per frame. time a value between 0 and 1

	For example: 
	- 0 means that the action just started
	- 0.5 means that the action is in the middle
	- 1 means that the action is over
	*/
	//更新动作
	virtual void Update(fTime time);
	
	//获取执行动作的精灵
	inline IActionDelegate* GetTarget(void);
	
	/** The action will modify the target properties. */
	//设置要控制的精灵对象
	inline void SetTarget(IActionDelegate *pTarget);
	
	//获取初始的精灵对象
	inline IActionDelegate* GetOriginalTarget(void); 
	
	/** Set the original target, since target can be nil.
	Is the target that were used to run the action. Unless you are doing something complex, like CActionManager, you should NOT call this method.
	The target is 'assigned', it is not 'retained'.
	
	*/
	//设置要初始的精灵对象
	inline void SetOriginalTarget(IActionDelegate *pOriginalTarget) { m_pOriginalTarget = pOriginalTarget; }

	//获取标签号
	int GetTag(void);

	//设置标签号
	void SetTag(int nTag);

public:
	/** Allocates and initializes the action */
	static CAction* Action();

protected:
	IActionDelegate	*m_pOriginalTarget;//初始的精灵(结束后执行动作的精灵会置空)
	/** The "target".
	The target will be set with the 'StartWithTarget' method.
	When the 'stop' method is called, target will be set to nil.
	The target is 'assigned', it is not 'retained'.
	*/
	IActionDelegate	*m_pTarget;//执行动作的精灵
	/** The action tag. An identifier of the action */
	int 	m_nTag;//标签号(默认-1)
	unsigned int m_uReference;//该动作的引用计数(用来自动删除)
};

/** 
@brief 
 Base class actions that do have a finite time duration.
 Possible actions:
   - An action with a duration of 0 seconds
   - An action with a duration of 35.5 seconds

 Infinite time actions are valid
 有限时间的动作
 */
class  CFiniteTimeAction : public CAction
{
public:
	CFiniteTimeAction()
		: m_fDuration(0)
	{}
	virtual ~CFiniteTimeAction(){}

    //! get duration in seconds of the action
	//获取该动作的持续时间
	fTime GetDuration(void);

	//! set duration in seconds of the action
	//设置该动作的持续时间
	void SetDuration(fTime duration);

	/** returns a reversed action */
	virtual CFiniteTimeAction* Reverse(void);//动作的返回
protected:
	//! duration in seconds
	fTime m_fDuration;//已花时间
};

class CActionInterval;

/** 
 @brief Changes the speed of an action, making it take longer (speed>1)
 or less (speed<1) time.
 Useful to simulate 'slow motion' or 'fast forward' effect.
 @warning This action can't be Sequenceable because it is not an CCIntervalAction
 设置速度的动作(修改了内部的持续时间)
 */
class  CSpeed : public CAction
{
public:
	CSpeed()
		: m_fSpeed(0.0)
		, m_pInnerAction(NULL)
	{}
	virtual ~CSpeed(void);

	float GetSpeed(void);

	/** alter the speed of the inner function in runtime */
	void SetSpeed(float fSpeed);

	/** initializes the action */
	bool InitWithAction(CActionInterval *pAction, float fRate);

// 	virtual CObject* copyWithZone(CCZone *pZone);
	virtual void StartWithTarget(IActionDelegate* pTarget);
	virtual void Stop();
	virtual void Step(fTime dt);
	virtual bool IsDone(void);
	virtual CActionInterval* Reverse(void);

	void SetInnerAction(CActionInterval *pAction);

	CActionInterval* GetInnerAction();

public:
	/** creates the action */
	static CSpeed* ActionWithAction(CActionInterval *pAction, float fRate);
    
protected:
	float m_fSpeed;
	CActionInterval *m_pInnerAction;
};



#endif // __ACTIONS_CCACTION_H__
