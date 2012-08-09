/*
 *  ScriptGlobalEvent.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (Õ¯¡˙)DeNA. All rights reserved.
 *
 */

#include "ScriptGlobalEvent.h"
#include "ScriptInc.h"
//#include <multimap.h> ///< ¡Ÿ ±–‘◊¢ Õ π˘∫∆

using namespace NDEngine;
using namespace LuaPlus;

typedef std::multimap<GLOBALEVENT, LuaObject>::const_iterator	GLOBALEVENTCIT;
typedef std::multimap<GLOBALEVENT, LuaObject>::value_type		GLOBALEVENTVT;
std::multimap<GLOBALEVENT, LuaObject> mapGlobalEventHandler;

bool PrintString(const char* pszString)
{
	if (0 == pszString || !*pszString)
	{
		return false;
	}
	
	CCLog(pszString);

	return true;
}

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

	/***
	* ¡Ÿ ±–‘◊¢ Õ π˘∫∆
	* begin
	* ’‚¿Ôª·Â¥µÙ
	*/
//     ScriptMgrObj.DebugOutPut("reg global envent [%d][%s] sucess!", 
//                              nEvent,
//                              funcname);
	/***
	* end
	*/
	
	mapGlobalEventHandler.insert(GLOBALEVENTVT(GLOBALEVENT(nEvent), func));
	
	return true;
}

void ScriptGlobalEvent::OnLoad()
{
 	ETCFUNC("RegisterGlobalEventHandler", RegisterGlobalEventHandler)
 	ETCFUNC("PrintString",PrintString)
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
