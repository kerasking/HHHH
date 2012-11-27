/*
 *  NDTimer.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __ND_TIMER_H__
#define __ND_TIMER_H__

#include "basedefine.h"
#include <map>
#include "cocos2d.h"

using namespace cocos2d;

class ITimerCallback
{
public:
	virtual void OnTimer(OBJID tag) = 0;
};

class Timer: public CCObject
{
	CC_SYNTHESIZE(int, m_nTag, Tag)
	CC_SYNTHESIZE(ITimerCallback*, m_TimerCallback, TimerCallback)

public:
	Timer();
	void onTimer(float elapsed);
};

class NDTimer
{
public:
	NDTimer();
	~NDTimer();

	void SetTimer(ITimerCallback* timerCallback, OBJID tag, float interval);
	void KillTimer(ITimerCallback* timerCallback, OBJID tag);

protected:
	CCScheduler* GetScheduler();

private:
	struct IMP_CALLBACK
	{
		IMP_CALLBACK()
		{
			timerCallback = NULL;
			tag = 0;
		}

		ITimerCallback* timerCallback;
		OBJID tag;

		bool operator <(const IMP_CALLBACK& cbImp) const
		{
			return timerCallback < cbImp.timerCallback ? true : tag < cbImp.tag;
		}
	};

	typedef std::map<IMP_CALLBACK, Timer*> MAP_TIMER;

	MAP_TIMER m_mapTimer;
};

#endif
