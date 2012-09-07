/*
 *  NDMapLayerLogic.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _ND_MAP_LAYER_LOGIC_H_
#define _ND_MAP_LAYER_LOGIC_H_

#include "NDMapLayer.h"
#include "NDUIDialog.h"
#include "NDTimer.h"

namespace NDEngine
{
class NDMapLayerLogic: public NDMapLayer, public NDUIDialogDelegate
{
	DECLARE_CLASS (NDMapLayerLogic)
public:
	NDMapLayerLogic();
	~NDMapLayerLogic();
public:
	void DidFinishLaunching();

	bool isAutoFight();
	bool TouchBegin(NDTouch* touch);
	bool TouchEnd(NDTouch* touch);
	void TouchCancelled(NDTouch* touch);
	bool TouchMoved(NDTouch* touch);
	void Update(unsigned long ulDiff);
	void OnTimer(OBJID uiTag);
private:
	NDTimer m_kTimer;
	double m_dTimeStamp;
	bool m_bLongTouch;
	CGPoint m_kPosTouch;
	bool m_bPathing;

private:
	void SetLongTouch(bool bSet);
	bool IsLongTouch();
	void SetPathing(bool bPathing);
	bool IsPathing();
};
}

#endif // _ND_MAP_LAYER_LOGIC_H_
