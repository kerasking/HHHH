/*
 *  NDUIAnimation.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-2.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUIAnimation.h"

IMPLEMENT_CLASS(NDUIAnimation, NDObject)

NDUIAnimation::NDUIAnimation()
{
	m_doubleTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	
	timer.SetTimer(this, 1, 0.03f);
}

NDUIAnimation::~NDUIAnimation()
{
	DelAllAnimation();
	
	timer.KillTimer(this, 1);
}

void NDUIAnimation::OnTimer(OBJID tag)
{
	double oldTimeStamp = m_doubleTimeStamp;
	m_doubleTimeStamp = [NSDate timeIntervalSinceReferenceDate];
	Update( m_doubleTimeStamp - oldTimeStamp );
}

unsigned int NDUIAnimation::GetAnimationKey(NDUINode* node, CGSize range/*=CGSizeZero*/)
{
	if (!node) return -1;
	
	unsigned int key = m_idFactory.GetID();
	
	UIAnimationInfo* p = new UIAnimationInfo;
	
	p->uiID = key;
	
	p->node = node;
	
	p->range = range;
	
	p->orginScrRect = node->GetFrameRect();
	
	if (range.width == 0.0f && range.height == 0.0f) {
		p->range = p->orginScrRect.size;
	}
	
	m_data.insert(datamap_pair(key, p));
	
	return key;
}

bool NDUIAnimation::DelAnimation(unsigned int key)
{
	datamap_it it = m_data.find(key);
	
	if (it != m_data.end()) 
	{
		delete it->second;
		
		m_idFactory.ReturnID(it->first);
		
		m_data.erase(it);
		
		return true;
	}
	
	it = m_dataRun.find(key);
	
	if (it != m_dataRun.end()) 
	{
		it->second->node->EnableEvent(true);
		
		delete it->second;
		
		m_idFactory.ReturnID(it->first);
		
		m_dataRun.erase(it);
		
		return true;
	}
	
	return false;
}

bool NDUIAnimation::DelAllAnimation()
{
	for (datamap_it it = m_data.begin(); it != m_data.end(); it++) 
	{
		delete it->second;
	}
	
	m_data.clear();
	
	for (datamap_it it = m_dataRun.begin(); it != m_dataRun.end(); it++) 
	{
		it->second->node->EnableEvent(true);
		delete it->second;
	}
	
	m_dataRun.clear();
	
	m_idFactory.reset();
	
	return true;
}


bool NDUIAnimation::AddAnimation(unsigned int key, CGPoint fromPosition, CGPoint toPosition, float needTime)
{
	datamap_it it = m_data.find(key);
	
	if (it == m_data.end()) return false;
	
	UIAnimationInfo& info = *(it->second);
	
	if (!info.sequence.AddAnimation(fromPosition, toPosition, needTime)) return false;
	
	return true;
}

bool NDUIAnimation::AddAnimation(unsigned int key, UIAnimationMove move, float needTime)
{
	datamap_it it = m_data.find(key);
	
	if (it == m_data.end()) return false;
	
	UIAnimationInfo& info = *(it->second);
	
	if (!info.sequence.AddAnimation(move, needTime)) return false;
	
	return true;
}

bool NDUIAnimation::playerAnimation(unsigned int key)
{
	datamap_it it = m_data.find(key);
	
	if (it == m_data.end()) return false;

	UIAnimationInfo& info = *(it->second);
	
	if (!info.StartUIAnimation())
	{
		info.StopUIAnimation();
		return false;
	}
	
	info.node->EnableEvent(false);
	
	m_dataRun.insert(datamap_pair(it->first, it->second));
	
	m_data.erase(it);
	
	return true;
}

bool NDUIAnimation::playerAllAnimation()
{
	std::vector<unsigned int> delKey;
	
	bool sucess = false;
	
	for (datamap_it it = m_data.begin(); it != m_data.end(); it++) 
	{
		UIAnimationInfo& info = *(it->second);
		
		if (!info.StartUIAnimation())
		{
			info.StopUIAnimation();
			
			continue;
		}
		
		info.node->EnableEvent(false);
		
		m_dataRun.insert(datamap_pair(it->first, it->second));
		
		delKey.push_back(it->first);
		
		sucess = true;
	}
	
	for_vec(delKey, std::vector<unsigned int>::iterator)
	{
		m_data.erase(*it);
	}
	
	return sucess;
}

/*
bool NDUIAnimation::StopAnimation(unsigned int key)
{
	datamap_it it = m_dataRun.find(key);
	
	if (it == m_dataRun.end()) return false;
	
	it->second->StopUIAnimation();
		
	m_data.insert(datamap_pair(it->first, it->second));
		
	m_dataRun.erase(it);

	return true;
}

bool NDUIAnimation::StopAllAnimation()
{
	for (datamap_it it = m_dataRun.begin(); it != m_dataRun.end(); it++) 
	{
		UIAnimationInfo& info = *(it->second);
		
		info.StopUIAnimation();
		
		m_data.insert(datamap_pair(it->first, it->second));
	}
	
	m_dataRun.clear();
	
	return true;
}
*/

void NDUIAnimation::Update(float dt)
{
	std::vector<unsigned int> delKey;
	
	for (datamap_it it = m_dataRun.begin(); it != m_dataRun.end(); it++) 
	{
		UIAnimationInfo& info = *(it->second);
		
		if( !info.Run(dt) )
		{
			info.StopUIAnimation();
			
			info.node->EnableEvent(true);
			
			m_data.insert(datamap_pair(it->first, it->second));
			
			delKey.push_back(it->first);
		}
	}
	
	for_vec(delKey, std::vector<unsigned int>::iterator)
	{
		m_dataRun.erase(*it);
	}
}