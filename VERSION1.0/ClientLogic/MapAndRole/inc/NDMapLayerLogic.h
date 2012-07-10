/*
 *  NDMapLayerLogic.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_MAP_LAYER_LOGIC_H_
#define _ND_MAP_LAYER_LOGIC_H_

#include "NDMapLayer.h"
#include "NDUIDialog.h"
#include "NDTimer.h"

namespace NDEngine 
{
	class NDMapLayerLogic : public NDMapLayer,public NDUIDialogDelegate 
	{
		DECLARE_CLASS(NDMapLayerLogic)
	public:
		NDMapLayerLogic();
		~NDMapLayerLogic();
	public:
		void DidFinishLaunching(); override
		
		bool TouchBegin(NDTouch* touch); override
		bool TouchEnd(NDTouch* touch); override
		void TouchCancelled(NDTouch* touch); override
		bool TouchMoved(NDTouch* touch); override
		void Update(unsigned long ulDiff); override
		void OnTimer(OBJID tag); override
	private:
		NDTimer m_timer;
		double m_doubleTimeStamp;
		bool	m_bLongTouch;
		CGPoint m_posTouch;
		bool	m_bPathing;
		
	private:
		void SetLongTouch(bool bSet);
		bool IsLongTouch();
		void SetPathing(bool bPathing);
		bool IsPathing();
	};
}

#endif // _ND_MAP_LAYER_LOGIC_H_

