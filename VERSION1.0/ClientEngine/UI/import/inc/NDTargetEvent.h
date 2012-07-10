/*
 *  NDTargetEvent.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#pragma once 

enum TARGET_EVENT
{
	TE_NONE = 0,
	
	TE_TOUCH_BTN_CLICK = 1,
	
	TE_TOUCH_BTN_DRAG_OUT = 2,
	
	TE_TOUCH_BTN_DRAG_OUT_COMPLETE = 3,
	
	TE_TOUCH_BTN_DRAG_IN = 4,
	
	TE_TOUCH_SC_VIEW_IN_BEGIN = 5,
	
	TE_TOUCH_CHECK_CLICK = 6,
	
	TE_TOUCH_RADIO_GROUP = 7,
	
	TE_TOUCH_EDIT_RETURN = 8,
	TE_TOUCH_EDIT_TEXT_CHANGE = 9,
	TE_TOUCH_EDIT_INPUT_FINISH =10,
	
	TE_TOUCH_BTN_DOUBLE_CLICK = 11,
	// ...
	TE_END,
};