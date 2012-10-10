/*
 *  HarvestEvent.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _HARVEST_EVENT_H_
#define _HARVEST_EVENT_H_

#include "NDUILabel.h"
#include "NDPicture.h"
#include "Singleton.h"
#include "NDTimer.h"
#include <vector>

using namespace NDEngine;

class HarvestEvent :
public NDNode
{
	DECLARE_CLASS(HarvestEvent)
public:
	HarvestEvent();
	~HarvestEvent();
	
	void Initialization(int iItemIconIndex, int iNum, CGSize container); hide
	
	void draw(int iX, int iY, bool bVisible); hide
	
	void SetFramesAndLen(unsigned int iFrames, float fLen);
	
	bool IsFinish();
	
private:
	NDPicture *m_picItem;
	NDUILabel *m_lbNum;
	CGSize m_sizeContainer;
	CGSize m_sizeChildren;
	int m_iFrameCount, m_iTotalFrameCount;
	float m_fOffset;
};

///////////////////////////////////////////////

class HarvestEventMgr :
public TSingleton<HarvestEventMgr>
//public ITimerCallback
{
public:
	HarvestEventMgr();
	~HarvestEventMgr();
	
	void AddHarvestEvent(int iItemIcon, int iNum);
	
	//void OnTimer(OBJID tag);// override ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	
private:
	//void CloseTime();
private:
	typedef std::vector<HarvestEvent*> vec_harvest_event;
	typedef vec_harvest_event::iterator vec_harvest_event_it;
	
	//NDTimer *m_timer;
	vec_harvest_event m_vecEvent, m_vecEventAdd;
};

#define HarvestEventMgrObj HarvestEventMgr::GetSingleton()

#endif // _HARVEST_EVENT_H_