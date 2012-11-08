/*
 *  NDTimer.cpp
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDTimer.h"
#include "CCScheduler.h"
#include "CCDirector.h"

using namespace cocos2d;

Timer::Timer()
{
}

void Timer::onTimer(float elapsed)
{
	if (m_TimerCallback)
	{
		m_TimerCallback->OnTimer(m_nTag);
	}
}

NDTimer::NDTimer()
{

}

CCScheduler* NDTimer::GetScheduler()
{
	return CCDirector::sharedDirector()->getScheduler();
}

NDTimer::~NDTimer()
{
	CCScheduler *sch = GetScheduler();
	MAP_TIMER::iterator it = m_mapTimer.begin();
	for (; it != m_mapTimer.end(); it++)
	{
		Timer *timer = it->second;
		sch->unscheduleSelector(schedule_selector(Timer::onTimer), timer);
		timer->release();
	}
}

void NDTimer::SetTimer(ITimerCallback* timerCallback, OBJID tag, float interval)
{
	if (timerCallback && interval > 0)
	{
		IMP_CALLBACK cbImp;
		cbImp.tag = tag;
		cbImp.timerCallback = timerCallback;

		if (m_mapTimer.count(cbImp) <= 0)
		{
			CCScheduler *sch = GetScheduler();
			Timer *timer = new Timer;
			timer->setTag(tag);
			timer->setTimerCallback(timerCallback);
			sch->scheduleSelector(schedule_selector(Timer::onTimer), timer,
					interval, false);
			m_mapTimer[cbImp] = timer;
		}
	}
}

void NDTimer::KillTimer(ITimerCallback* timerCallback, OBJID tag)
{
	IMP_CALLBACK cbImp;
	cbImp.tag = tag;
	cbImp.timerCallback = timerCallback;

	MAP_TIMER::iterator it = m_mapTimer.find(cbImp);

	if (it != m_mapTimer.end())
	{
		CCScheduler *sch = GetScheduler();
		Timer *timer = it->second;
		sch->unscheduleSelector(schedule_selector(Timer::onTimer), timer);
		timer->release();
		m_mapTimer.erase(it);
	}
}