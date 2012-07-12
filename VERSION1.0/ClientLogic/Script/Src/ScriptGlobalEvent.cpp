/*
 *  ScriptGlobalEvent.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "ScriptGlobalEvent.h"
#include "ScriptInc.h"
#include <multimap.h>

using namespace NDEngine;
using namespace LuaPlus;

typedef std::multimap<GLOBALEVENT, LuaObject>::const_iterator	GLOBALEVENTCIT;
typedef std::multimap<GLOBALEVENT, LuaObject>::value_type		GLOBALEVENTVT;
std::multimap<GLOBALEVENT, LuaObject> mapGlobalEventHandler;

bool RegisterGlobalEventHandler(int nEvent, const char* funcname, LuaObject func)
{
	if (nEvent < GLOBALEVENT_BEGIN || nEvent >= GLOBALEVENT_END)
	{
		if (funcname)
		{
			ScriptMgrObj.DebugOutPut("reg global envent [%d][%s] failed! because invalid param event type", 
				  nEvent,
				  funcname);
		}
		return false;
	}
	
	if (!func.IsFunction())
	{
		ScriptMgrObj.DebugOutPut("reg global envent [%d][%s] failed! because invalid param function", 
			  nEvent,
			  funcname);
		return false;
	}
    
    ScriptMgrObj.DebugOutPut("reg global envent [%d][%s] sucess!", 
                             nEvent,
                             funcname);
	
	mapGlobalEventHandler.insert(GLOBALEVENTVT(GLOBALEVENT(nEvent), func));
	
	return true;
}

void ScriptGlobalEvent::OnLoad()
{
	ETCFUNC("RegisterGlobalEventHandler", RegisterGlobalEventHandler)
}

void ScriptGlobalEvent::OnEvent(GLOBALEVENT eEvent, int param1, int param2, int param3)
{
	std::pair<GLOBALEVENTCIT, GLOBALEVENTCIT> range;
	range = mapGlobalEventHandler.equal_range(eEvent);
	
	for (GLOBALEVENTCIT i = range.first; i != range.second; i++) 
	{
		LuaObject fun = i->second;
		if (!fun.IsFunction())
		{
			continue;
		}
		LuaFunction<void> luaFunc(fun);
		luaFunc(param1, param2, param3);
	}
}
