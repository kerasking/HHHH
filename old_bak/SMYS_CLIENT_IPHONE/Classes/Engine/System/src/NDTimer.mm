/*
 *  NDTimer.cpp
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "NDTimer.h"
#import "CCScheduler.h"

@interface Timer : NSObject
{
	int tag;
	ITimerCallback* timerCallback;
}

@property(nonatomic, assign) int tag;
@property(nonatomic, assign) ITimerCallback* timerCallback;

-(void) onTimer: (ccTime) elapsed;

@end

@implementation Timer

@synthesize tag, timerCallback;

-(void) onTimer: (ccTime) elapsed
{
	if (timerCallback)
	{
		timerCallback->OnTimer(tag);
	}
}

@end

NDTimer::NDTimer()
{
	
}

NDTimer::~NDTimer()
{
	CCScheduler *sch = [CCScheduler sharedScheduler];
	MAP_TIMER::iterator it = m_mapTimer.begin();
	for (; it != m_mapTimer.end(); it++)
	{
		Timer *timer = it->second;
		[sch unscheduleSelector:@selector(onTimer:) forTarget:timer];
		[timer release];
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
			CCScheduler *sch = [CCScheduler sharedScheduler];
			Timer *timer = [[Timer alloc] init];
			timer.tag = tag;
			timer.timerCallback = timerCallback;
			[sch scheduleSelector:@selector(onTimer:) forTarget:timer interval:interval paused:NO];
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
		CCScheduler *sch = [CCScheduler sharedScheduler];
		Timer *timer = it->second;
		[sch unscheduleSelector:@selector(onTimer:) forTarget:timer];
		[timer release];
		m_mapTimer.erase(it);
	}
}