/*   进度条动作类
 	Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/
#ifndef __ACTION_CCPROGRESS_TIMER_H__
#define __ACTION_CCPROGRESS_TIMER_H__

#include "CActionInterval.h"

/**
@brief Progress to percentage
进度变化到的进度动作,从左到右/从上到下显示图片出来
@Warning:暂时不能和动画动作同时运行
执行动作前,设置进度动作的类型CSprite::SetProgressType(ProgressType type)
*/
class CProgressTo : public CActionInterval
{
public:
	/** Initializes with a duration and a percent */
	bool InitWithDuration(fTime duration, float fPercent);

//	virtual CCObject* copyWithZone(CCZone *pZone);
	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** Creates and initializes with a duration and a percent */
	static CProgressTo* ActionWithDuration(fTime duration, float fPercent=100.f/*必须填0-100*/);

protected:
	float m_fTo;
	float m_fFrom;
};

/**
@brief Progress from a percentage to another percentage
进度变化范围的动作
*/
class CProgressFromTo : public CActionInterval
{
public:
	/** Initializes the action with a duration, a "from" percentage and a "to" percentage */
    bool InitWithDuration(fTime duration, float fFromPercentage, float fToPercentage);

//	virtual CCObject* copyWithZone(CCZone *pZone);
	virtual CActionInterval* Reverse(void);
	virtual void StartWithTarget(IActionDelegate *pTarget);
	virtual void Update(fTime time);

public:
	/** Creates and initializes the action with a duration, a "from" percentage and a "to" percentage */
	//设置进度动作范围
	static CProgressFromTo* ActionWithDuration(fTime duration/*持续时间*/, float fFromPercentage/*开始的进度0-100*/, float fToPercentage/*结束的进度0-100*/);

protected:
	float m_fTo;
	float m_fFrom;
};


#endif // __ACTION_CCPROGRESS_TIMER_H__
