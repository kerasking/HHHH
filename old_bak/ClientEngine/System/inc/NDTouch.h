//
//  NDTouch.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef __NDTouch_H
#define __NDTouch_H

#include "NDObject.h"

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
		CGPoint GetLocation();
		CGPoint GetPreviousLocation();
		//－－－end
		
	public:
		void Initialization(CCTouch *touch);
		void Initialization(unsigned int tapCount, CGPoint location, CGPoint previousLocation);
		
	private:
		unsigned int m_tapCount;
		CGPoint m_location;
		CGPoint m_previousLocation;
		
	};
}


#endif