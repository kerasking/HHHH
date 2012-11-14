//
//  NDTouch.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
#ifndef __NDTouch_H
#define __NDTouch_H

#include "NDObject.h"
#include "CCTouch.h"

namespace NDEngine
{
	class NDTouch : public NDObject 
	{
		DECLARE_CLASS(NDTouch)
	public:
		NDTouch();
		~NDTouch();
	public:
		//以下方法供逻辑层使用－－－begin
		//......
		unsigned int GetTapCount();
		cocos2d::CCPoint GetLocation();
		cocos2d::CCPoint GetPreviousLocation();
		//－－－end
		
	public:
		void Initialization(cocos2d::CCTouch *touch);
		void Initialization(unsigned int tapCount, cocos2d::CCPoint location, cocos2d::CCPoint previousLocation);
		
	private:
		unsigned int m_tapCount;
		cocos2d::CCPoint m_location;
		cocos2d::CCPoint m_previousLocation;
		
	};
}


#endif