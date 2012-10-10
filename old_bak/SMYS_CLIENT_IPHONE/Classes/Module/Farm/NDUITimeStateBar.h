/*
 *  NDUITimeStateBar.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_UI_TIME_STATE_BAR_H_
#define _ND_UI_TIME_STATE_BAR_H_

#include "GameUIAttrib.h"
#include "NDTimer.h"

class NDUITimeStateBar;

class NDUITimeStateBarDelegate
{
public:
	virtual void OnTimeStateBarFinish(NDUITimeStateBar* statebar){};
};

class NDUITimeStateBar : 
public NDUIStateBar//,
//public ITimerCallback
{
DECLARE_CLASS(NDUITimeStateBar)

public:
	NDUITimeStateBar();
	~NDUITimeStateBar();
	void Initialization(); override
	void SetTime(unsigned long rest, unsigned long total);
	void SetFinishText(std::string text);
	void OnTimer(OBJID tag); override
	void ReduceRestTime(unsigned long add);
	void SetNormalColors(ccColor4B stateColor, ccColor4B slideColor);
	void SetFinishColors(ccColor4B stateColor, ccColor4B slideColor);
private:
	NDTimer *m_timer;
	
	unsigned long m_restime, m_totaltime;
	//NSTimeInterval m_begintime;
	std::string m_strFinish;
	bool m_bFinish;
	ccColor4B m_stateFinishColor, m_slideFinishColor;
};

#endif // _ND_UI_TIME_STATE_BAR_H_
