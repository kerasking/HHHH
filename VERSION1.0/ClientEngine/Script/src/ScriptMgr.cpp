/*
 *  ScriptMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-4.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "ScriptMgr.h"
#include "LuaStateMgr.h"
#include <time.h>
// #include "ScriptCommon.h"
// #include "ScriptGameData.h"
// #include "ScriptNetMsg.h"
// #include "ScriptUI.h"
// #include "ScriptTask.h"
// #include "ScriptGlobalEvent.h"
// #include "ScriptGameLogic.h"
// #include "ScriptDataBase.h"
// #include "ScriptTimer.h"
// #include "ScriptDrama.h"


//#include "NDDataPersist.h"

#include "src/lstate.h"
//#include "NDTextureMonitor.h"


using namespace NDEngine;

void luaExceptRunTimeOutPut(const char *exceptinfo)
{
	ScriptMgrObj.DebugOutPut("run failed!!!");
	ScriptMgrObj.DebugOutPut(exceptinfo);
	ScriptMgrObj.DebugOutPut("run failed end!!!");
}

void luaExceptLoadOutPut(const char *exceptinfo)
{
	ScriptMgrObj.DebugOutPut("load failed!!!");
	ScriptMgrObj.DebugOutPut(exceptinfo);
	ScriptMgrObj.DebugOutPut("load failed end!!!");
}

LuaObject ScriptMgr::GetLuaFunc(const char* funcname, const char* modulename)
{
	LuaObject funcObj;
	
	if	(!funcname) 
	{
		return funcObj;
	}
	
	if (modulename && std::string("") != modulename)
	{
		LuaObject module = LuaStateMgrObj.GetState()->GetGlobal(modulename);
		
		if (!module.IsTable())
		{
			return funcObj;
		}
		
		funcObj = module.GetByName(funcname);
	}
	else 
	{
		funcObj = LuaStateMgrObj.GetState()->GetGlobal(funcname);
	}
	
	return funcObj;
}

ScriptMgr::ScriptMgr()
{
}

ScriptMgr::~ScriptMgr()
{
	if (m_fDebugOutPut)
	{
		fclose(m_fDebugOutPut);
	}
}

/*
void ScriptMgr::DebugOutPut(const char* str)
{
	if (!str || !m_fDebugOutPut)
	{
		return;
	}
	
	fprintf(m_fDebugOutPut, "\r\n%s", str);
	fflush(m_fDebugOutPut);
}
*/

void ScriptMgr::DebugOutPut(const char* fmt, ...)
{
	if (!fmt || !m_fDebugOutPut)
	{
		return;
	}
	va_list argumentList;
	char buffer[4096] = "";
	va_start(argumentList, fmt);
	::vsprintf( buffer, fmt, argumentList);
	va_end(argumentList);
#ifdef DEBUG
	printf("\n%s", buffer);
#else
	fprintf(m_fDebugOutPut, "\r\n%s", buffer);
	fflush(m_fDebugOutPut);
#endif
}

//using namespace LuaPlus;
void ScriptMgr::update()
{
 	static unsigned int frameCount = 0;
	if ((++frameCount % 20) == 0) 
	{
		LuaStateMgrObj.GetState()->GC(LUA_GCCOLLECT, 0);
	}
}	
// 	if (++frameCount % 120 == 0) // 120帧打印一次lua当前使用的内存总量
// 	{
// 		lua_State* state = LuaStateMgrObj.GetState()->GetCState();
// 		if (state)
// 		{
// 			global_State *g_state = state->l_G;
// 			if (g_state)
// 			{
// 				unsigned int nTotal = g_state->totalbytes;
// 				
// 				//NDAsssert(s_nLuaMemTotalSize == nTotal);
// 				//printf("\n*************lua cur use memory [%d] kbyte, [%d]mbyte", nTotal / 1024 , nTotal / 1024 / 1024);
// 				
// 			}
// 		}
// 		
// 		//ScriptGameDataObj.LogOutMemory();
// 		
// 		//TextureMonitorObj.Report();
// 	}

void ScriptMgr::Load()
{
	char filename[256];
	memset(filename, 0, sizeof(filename));

	_snprintf(filename, sizeof(filename), "%slog%ld.txt", 
		m_strLogFilePath,
		time(NULL));
	m_fDebugOutPut = fopen(filename, "a");
	LoadRegClassFuncs();
	
	for(vec_script_object_it it = m_vScriptObject.begin();
		it != m_vScriptObject.end();
		it++)
	{
		(*it)->OnLoad();
	}

	/*
	ScriptCommonLoad();
	
	ScriptGlobalEvent::Load();
	
	ScriptTimerMgrObj.Load();
	
	ScriptUiLoad();
	
	ScriptNetMsg::Load();
	
	ScriptGameDataObj.Load();
	
	ScriptDBObj.Load();
	
	ScriptTaskLoad();
	
	ScriptGameLogicLoad();
	
	ScriptDramaLoad();
	*/
	
	LuaStateMgrObj.SetExceptOutput(&luaExceptLoadOutPut);
	
	// make sure load lua file last;
	LuaStateMgrObj.GetState()->DoFile((m_strScriptFilePath + "entry.lua").c_str());
	
	LuaStateMgrObj.SetExceptOutput(&luaExceptRunTimeOutPut);
}

void ScriptMgr::AddScriptObject(ScriptObject* object)
{
	for(vec_script_object_it it = m_vScriptObject.begin();
		it != m_vScriptObject.end();
		it++)
	{
		if (object == *it)
		{
			return;
		}
	}

	m_vScriptObject.push_back(object);
}

void ScriptMgr::DelScriptObject(ScriptObject* object)
{
	for(vec_script_object_it it = m_vScriptObject.begin();
		it != m_vScriptObject.end();
		it++)
	{
		if (object == *it)
		{
			m_vScriptObject.erase(it);
		}
	}
}

bool ScriptMgr::AddRegClassFunc(RegisterClassFunc func)
{
	vRegClassFunc.push_back(func);
	
	return true;
}

void ScriptMgr::SetLogFilePath(const char* szFilePath)
{
	if (!szFilePath)
	{
		return;
	}

	m_strLogFilePath	= szFilePath;
}

void ScriptMgr::SetScriptFilePath(const char* szFilePath)
{
	if (!szFilePath)
	{
		return;
	}

	m_strScriptFilePath	= szFilePath;
}

// int ScriptMgr::excuteLuaFuncRetN(const char* funcname, const char* modulename)
// {
// 	LuaObject funcObj = GetLuaFunc(funcname, modulename);
// 	
// 	if (!funcObj.IsFunction())
// 	{
// 		return 0;
// 	}
// 	
// 	LuaFunction<int> func = funcObj;
// 	int ret = func();
// 	
// 	return ret;
// }
// 
// bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename)
// {
// 	LuaObject funcObj = GetLuaFunc(funcname, modulename);
// 
// 	if (!funcObj.IsFunction())
// 	{
// 		return false;
// 	}
// 	
// 	LuaFunction<bool> func = funcObj;
// 	bool ret = func();
// 	
// 	return ret;
// }
// 
// bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1)
// {
// 	LuaObject funcObj = GetLuaFunc(funcname, modulename);
// 	
// 	if (!funcObj.IsFunction())
// 	{
// 		return false;
// 	}
// 	
// 	LuaFunction<bool> func = funcObj;
// 	bool ret = func(param1);
// 	
// 	return ret;
// }
// 
// bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2)
// {
// 	LuaObject funcObj = GetLuaFunc(funcname, modulename);
// 	
// 	if (!funcObj.IsFunction())
// 	{
// 		return false;
// 	}
// 	
// 	LuaFunction<bool> func = funcObj;
// 	bool ret = func(param1, param2);
// 	
// 	return ret;
// }
// 
// bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3)
// {
// 	LuaObject funcObj = GetLuaFunc(funcname, modulename);
// 	
// 	if (!funcObj.IsFunction())
// 	{
// 		return false;
// 	}
// 	
// 	LuaFunction<bool> func = funcObj;
// 	bool ret = func(param1, param2, param3);
// 	
// 	return ret;
// }

bool ScriptMgr::IsLuaFuncExist(const char* funcname, const char* modulename)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return false;
	}
	
	return true;
}

void ScriptMgr::LoadRegClassFuncs()
{
	vec_regclass_func_it it = vRegClassFunc.begin();
	
	for (; it != vRegClassFunc.end(); it++) 
	{
		(*it)();
	}
	
	vRegClassFunc.clear();
}

int NDEngine::ScriptMgr::excuteLuaFuncRetN( const char* funcname, const char* modulename )
{
	return 0;
}