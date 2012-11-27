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
#include "ScriptDefine.h"
#include "CCCommon.h"
#include "ScriptMgr.h"
#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

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

#ifdef _DEBUG
	cocos2d::CCLog("reg global envent [%d][%s] sucess!", nEvent, funcname);
#endif

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
	ETCFUNC( "RegisterGlobalEventHandler", RegisterGlobalEventHandler )
	ETCFUNC( "SendGlobalEvent", SendGlobalEvent )
}

void ScriptGlobalEvent::OnEvent(GLOBALEVENT eEvent, int param1, int param2, int param3)
{
#ifdef _DEBUG
	cocos2d::CCLog("ScriptGlobalEvent::OnEvent, eEvent=%d", (int)eEvent);
#endif

	LOGD("Entry OnEvent,Event ID is %d",(int)eEvent);

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

void ScriptGlobalEventLoad()
{

}
