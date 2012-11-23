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
#include <map>
#include "LuaObject.h"
#include "globaldef.h"
#include "NDDebugOpt.h"

using namespace NDEngine; 
using namespace LuaPlus;

typedef std::multimap<GLOBALEVENT, LuaObject>::const_iterator	GLOBALEVENTCIT;
typedef std::multimap<GLOBALEVENT, LuaObject>::value_type		GLOBALEVENTVT;
std::multimap<GLOBALEVENT, LuaObject> mapGlobalEventHandler;

bool RegisterGlobalEventHandler(int nEvent, const char* funcname, LuaObject func)
{
	NDLog("Entry RegisterGlobalEventHandler");
	NDLog("Rigister event id = %d,the function name is %s",nEvent,funcname);

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

	NDLog("reg global envent [%d][%s] sucess!", nEvent,funcname);

	mapGlobalEventHandler.insert(GLOBALEVENTVT(GLOBALEVENT(nEvent), func));

	return true;
}

//void SendGlobalEvent(int iEventID, int param1=0, int param2=0, int param3=0);
void SendGlobalEvent(int iEventID, int param1=0, int param2=0, int param3=0)
{
	ScriptGlobalEvent::OnEvent((GLOBALEVENT)iEventID, param1, param2, param3);
}
void ScriptGlobalEvent::Load() 
{
	NDLog("entry ScriptGlobalEvent::OnLoad()");
	ETCFUNC( "RegisterGlobalEventHandler", RegisterGlobalEventHandler )
	ETCFUNC( "SendGlobalEvent", SendGlobalEvent )
	NDLog("leave ScriptGlobalEvent::OnLoad()");
}

void ScriptGlobalEvent::OnEvent(GLOBALEVENT eEvent, int param1, int param2, int param3)
{
	NDLog("Entry ScriptGlobalEvent::OnEvent()");
	std::pair<GLOBALEVENTCIT, GLOBALEVENTCIT> range;
	range = mapGlobalEventHandler.equal_range(eEvent);

	for (GLOBALEVENTCIT i = range.first; i != range.second; i++) 
	{
		LuaObject fun = i->second;
		if (!fun.IsFunction())
		{
			NDLog("the lua LuaObject is not a function");
			continue;
		}
		LuaFunction<void> luaFunc(fun);
		luaFunc(param1, param2, param3);
	}

	NDLog("leave ScriptGlobalEvent::OnEvent()");
}

void ScriptGlobalEventLoad()
{

}
