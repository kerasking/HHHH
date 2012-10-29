/*
 *  HarvestEvent.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "HarvestEvent.h"
#include "NDPlayer.h"
#include "NDMapMgr.h"
#include "NDMapLayer.h"
#include "ItemImage.h"
#include "NDUtility.h"
#include "define.h"
#include <sstream>

IMPLEMENT_CLASS(HarvestEvent, NDNode)

HarvestEvent::HarvestEvent()
{
	m_picItem = NULL;
	
	m_lbNum = NULL;
	
	m_sizeContainer = CGSizeZero;
	
	m_sizeChildren = CGSizeZero;
	
	m_iFrameCount = m_iTotalFrameCount = 0;
	
	m_fOffset = 0.0f;
}

HarvestEvent::~HarvestEvent()
{
	SAFE_DELETE(m_picItem);
	SAFE_DELETE(m_lbNum);
}

void HarvestEvent::Initialization(int iItemIconIndex, int iNum, CGSize container)
{
	NDNode::Initialization();
	
	m_picItem = ItemImage::GetItem(iItemIconIndex);
	
	std::stringstream ss; ss << " +" << iNum;
	
	m_lbNum = new NDUILabel;
	m_lbNum->Initialization();
	m_lbNum->SetFontSize(13);
	m_lbNum->SetText(ss.str().c_str());
	m_lbNum->SetFrameRect(CGRectZero);
	
	m_sizeContainer = container;
	
	if (m_picItem) 
	{
		m_sizeChildren = m_picItem->GetSize();
	}
	
	CGSize sizelb = getStringSize(ss.str().c_str(), 13);
	
	m_sizeChildren.width += sizelb.width;
	m_sizeChildren.height += sizelb.height;
	
	m_sizeChildren.width /= 2;
	m_sizeChildren.height /= 2;
}

void HarvestEvent::draw(int iX, int iY, bool bVisible)
{
	if (m_iFrameCount > 0) m_iFrameCount--;
	
	if (m_iFrameCount == 0 || !bVisible) return;
	
	iX -= m_sizeChildren.width;
	iY -= (m_iTotalFrameCount - m_iFrameCount) * m_fOffset+m_sizeChildren.height;
	
	if (m_picItem) 
	{
		CGSize sizePic = m_picItem->GetSize();
		m_picItem->DrawInRect(CGRectMake(iX, iY+320-m_sizeContainer.height, sizePic.width, sizePic.height));
		
		iX += sizePic.width;
	}
	
	if (m_lbNum) 
	{
		m_lbNum->SetFrameRect(CGRectMake(iX, iY+320-m_sizeContainer.height, m_sizeChildren.width * 2, m_sizeChildren.height * 2));
		m_lbNum->draw();
	}
}

void HarvestEvent::SetFramesAndLen(unsigned int iFrames, float fLen)
{
	m_iFrameCount = m_iTotalFrameCount = iFrames;
	
	m_fOffset = fLen / iFrames;
}

bool HarvestEvent::IsFinish()
{
	return m_iFrameCount == 0;
}

///////////////////////////////////////////////

HarvestEventMgr::HarvestEventMgr()
{
	//m_timer = NULL;
}

HarvestEventMgr::~HarvestEventMgr()
{
	//CloseTime();
	for_vec(m_vecEvent, vec_harvest_event_it)
	{
		delete *it;
	}
	m_vecEvent.clear();
}

void HarvestEventMgr::AddHarvestEvent(int iItemIcon, int iNum)
{	
	HarvestEvent *event = new HarvestEvent;
	event->Initialization(iItemIcon, iNum, NDMapMgrObj.m_sizeMap);
	event->SetFramesAndLen(20, 30);
	
	//if (!m_timer) 
//	{
//		m_timer = new NDTimer;
//		m_timer->SetTimer(this, 666, 1.0f/60.f);
//	}
	
	m_vecEventAdd.push_back(event);
}

void HarvestEventMgr::OnTimer(OBJID tag)
{
	for (vec_harvest_event_it it = m_vecEvent.begin(); it != m_vecEvent.end();) 
	{
		HarvestEvent *event = *it;
		if(event->IsFinish())
		{
			delete event;
			m_vecEvent.erase(it);
			continue;
		}
		
		it++;
	}
		
	//if (!m_vecEventAdd.empty()) 
//	{
//		std::copy_backward(m_vecEventAdd.begin(), m_vecEventAdd.end(), m_vecEvent.end());
//	}

	for_vec(m_vecEventAdd, vec_harvest_event_it)
	{
		m_vecEvent.push_back(*it);
	}
	m_vecEventAdd.clear();
	
	if (m_vecEvent.empty()) 
	{
		//CloseTime();
		return;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	
	bool bVisible = player.GetParent() == NULL ? false : (player.GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)));
	
	CGPoint pos = CGPointZero;
	
	if (bVisible) 
	{
		pos = player.GetPosition();
		pos.y -= player.getGravityY();
	}
	
	for_vec(m_vecEvent, vec_harvest_event_it)
	{
		(*it)->draw(pos.x, pos.y, bVisible);
	}
}

//void HarvestEventMgr::CloseTime()
//{
//	if (m_timer) 
//	{
//		m_timer->KillTimer(this, 666);
//		delete m_timer;
//		m_timer = NULL;
//	}
//}




