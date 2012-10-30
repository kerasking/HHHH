/*
 *  ScriptUI.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */
#pragma once
#include "NDTargetEvent.h"
#include "ScriptInc.h"
#include "NDUINode.h"


namespace NDEngine {

//#define CGPointMake(x, y) CCPoint((x), (y))
//#define CGSizeMake(width, height) CCSize((width), (height))
//#define CGRectMake(x, y, width, height) CCRect((x), (y), (width), (height))

	void ScriptUiLoad();
	
	bool OnScriptUiEvent(NDUINode* uinode, int targetEvent, int param = 0);
	
	template<typename T>
	bool OnScriptUiEvent(NDUINode* uinode, int targetEvent, T param)
	{
		if (!uinode)
		{
			return false;
		}
		
		LuaObject funcObj;
		
		if (!uinode->GetLuaDelegate(funcObj)
			|| !funcObj.IsFunction())
		{
			return false;
		}
		
		LuaFunction<bool> luaUiEventCallBack = funcObj;
		
		bool bRet = luaUiEventCallBack(uinode, targetEvent, param);
		
		return bRet;
	}
}
