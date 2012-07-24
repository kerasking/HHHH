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

using namespace cocos2d;

Timer::Timer()
{
}

void Timer::onTimer(ccTime elapsed)
{
	/***
	* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	* all
	*/
// 	if (m_TimerCallback)
// 	{
// 		m_TimerCallback->OnTimer(m_nTag);
// 	}
}

NDTimer::NDTimer()
{
	
}

NDTimer::~NDTimer()
{
	CCScheduler *sch = CCScheduler::sharedScheduler();
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
		cbImp.tag				= tag;
		cbImp.timerCallback		= timerCallback;
		
		if (m_mapTimer.count(cbImp) <= 0)
		{
			CCScheduler *sch = CCScheduler::sharedScheduler();
			Timer *timer = new Timer;
			//timer->setTag(tag);
			//timer->setTimerCallback(timerCallback);
			sch->scheduleSelector(schedule_selector(Timer::onTimer), timer, interval, false);
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
		CCScheduler *sch = CCScheduler::sharedScheduler();
		Timer *timer = it->second;
		sch->unscheduleSelector(schedule_selector(Timer::onTimer), timer);
		timer->release();
		m_mapTimer.erase(it);
	}
}