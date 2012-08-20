//
//  NDTouch.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDTouch.h"
#include "NDDirector.h"
#include "CCTouchDispatcher.h"
#include "ccMacros.h"

using namespace cocos2d;

namespace NDEngine
{
	IMPLEMENT_CLASS(NDTouch, NDObject)
	
	NDTouch::NDTouch()
	{
		m_tapCount = 0;
		m_location = CGPointMake(0, 0);
		m_previousLocation = CGPointMake(0, 0);
	}
	
	NDTouch::~NDTouch()
	{
	}
	
	unsigned int NDTouch::GetTapCount()
	{
		return m_tapCount;
	}
	
	CGPoint NDTouch::GetLocation()
	{
		return m_location;
	}
	
	CGPoint NDTouch::GetPreviousLocation()
	{
		return m_previousLocation;
	}
	
	void NDTouch::Initialization(CCTouch *touch)
	{
		//m_tapCount = touch->getTapCount();
		//m_location = [touch locationInView:[[CCDirector sharedDirector] openGLView]];
		//m_previousLocation = [touch previousLocationInView:[[CCDirector sharedDirector] openGLView]];
		// todo(zjh)
		//m_location = CCTouchDispatcher::sharedDispatcher()->GetCurPos();
		//m_previousLocation = CCTouchDispatcher::sharedDispatcher()->GetPrePos();
		if( CC_CONTENT_SCALE_FACTOR() == 1 )
		{

		}
		else
		{
			m_location.x=m_location.x*2;
			m_location.y=m_location.y*2;
			m_previousLocation.x=m_previousLocation.x*2;
			m_previousLocation.y=m_previousLocation.y*2;
		}	
		m_location = CGPointMake(m_location.y , NDDirector::DefaultDirector()->GetWinSize().height - m_location.x ); 

		m_previousLocation = CGPointMake(m_previousLocation.y , NDDirector::DefaultDirector()->GetWinSize().height - m_previousLocation.x);
	}
	
	void NDTouch::Initialization(unsigned int tapCount, CGPoint location, CGPoint previousLocation)
	{
		m_tapCount = tapCount;
		m_location = location;
		m_previousLocation = previousLocation;
	}
}