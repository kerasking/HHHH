//
//  NDTouch.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDTouch.h"
#include "NDDirector.h"
#include "CCTouchDispatcher.h"
#include "ccMacros.h"
#include "UsePointPls.h"

using namespace cocos2d;

namespace NDEngine
{
	IMPLEMENT_CLASS(NDTouch, NDObject)
	
	NDTouch::NDTouch()
	{
		m_tapCount = 0;
		m_location = CCPointMake(0, 0);
		m_previousLocation = CCPointMake(0, 0);
	}
	
	NDTouch::~NDTouch()
	{
	}
	
	unsigned int NDTouch::GetTapCount()
	{
		return m_tapCount;
	}
	
	CCPoint NDTouch::GetLocation()
	{
		return m_location;
	}
	
	CCPoint NDTouch::GetPreviousLocation()
	{
		return m_previousLocation;
	}
	
	void NDTouch::Initialization(CCTouch *touch)
	{
		m_location = CCDirector::sharedDirector()->getTouchDispatcher()->getCurPos();
		m_previousLocation = CCDirector::sharedDirector()->getTouchDispatcher()->getPrePos();

		//ND这套统一使用Pixel
		ConvertUtil::convertToPixelCoord( m_location );
		ConvertUtil::convertToPixelCoord( m_previousLocation );
	}
	
	void NDTouch::Initialization(unsigned int tapCount, CCPoint location, CCPoint previousLocation)
	{
		m_tapCount = tapCount;
		m_location = location;
		m_previousLocation = previousLocation;
	}
}