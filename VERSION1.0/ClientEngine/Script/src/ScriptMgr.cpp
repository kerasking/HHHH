/*
 *  ScriptMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-4.
 *  Copyright 2012 (缂冩垿绶?DeNA. All rights reserved.
 *
 */

#include "ScriptMgr.h"
#include "LuaStateMgr.h"
#include "ScriptCommon.h"
#include "ScriptGameData.h"
#include "ScriptNetMsg.h"
#include "ScriptUI.h"
#include "ScriptTask.h"
#include "ScriptGlobalEvent.h"
#include "ScriptGameLogic.h"
#include "ScriptDataBase.h"
#include "ScriptTimer.h"
#include "ScriptDrama.h"

#include "NDDataPersist.h"
#include "Des.h"
#include <sys/stat.h>
//#include "lstate.h"
#include "NDTextureMonitor.h"
#include "NDPicture.h"
#include "NDPath.h"
#include "NDUtility.h"


using namespace NDEngine;
const unsigned char g_dekey[] = {0x80,0x12,0x97,0x67,0x24,0x88,0x89,0x98,0x55,0x34,0xBD,0x33,0x34,0x80,0x12,0x97,0x67,0x24,0x88,0x89,0x98,0x55,0x34,0xBD};
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

	if (!funcname)
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
/*
const char* NDEngine::GetScriptPath(const char* fileName)
{
	size_t len = strlen(fileName);
#ifdef TRADITION
	return [[NSString stringWithFormat:@"%@/TraditionalChineseRes/res/Script/%@", [[NSBundle mainBundle] resourcePath], [NSString stringWithUTF8String:fileName]] UTF8String];
#else
	return [[NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/Script/%@", [[NSBundle mainBundle] resourcePath], [NSString stringWithUTF8String:fileName]] UTF8String];
#endif
}
*/
ScriptMgr::ScriptMgr()
{
#if 0    tzq

	char filename[256];
	memset(filename, 0, sizeof(filename));
	snprintf(filename, sizeof(filename), "%s/log%ld.txt", 
			 [DataFilePath() UTF8String],
			 time(NULL));
	m_fDebugOutPut = fopen(filename, "a");
    printf(filename);
#endif
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
#if 0  tzq
	if (!fmt || !m_fDebugOutPut)
	{
		return;
	}
	va_list argumentList;
	char buffer[4096] = "";
	va_start(argumentList, fmt);
	::vsprintf( buffer, fmt, argumentList);
	va_end(argumentList);
    NSLog("%@", [NSString stringWithUTF8String:buffer]);
#endif
}

//using namespace LuaPlus;
void ScriptMgr::update()
{
	static unsigned int frameCount = 0;
	if (++frameCount % 20 == 0) // 20帧更新一次
	{
		LuaStateMgrObj.GetState()->GC(LUA_GCCOLLECT, 0);
	}
	
	if (++frameCount % 120 == 0) // 120帧打印一次lua当前使用的内存总量
	{
		ScriptGameDataObj.LogOutMemory();
		TextureMonitorObj.BeforeTextureAdd();
		TextureMonitorObj.Report();
	}
}

void ScriptMgr::Load()
{
#if 0
	LoadRegClassFuncs();
	
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
#endif 
	
	//LuaStateMgrObj.SetExceptOutput(&luaExceptLoadOutPut);
	LoadRegClassFuncs();

	if (0 != LuaStateMgrObj.GetState()->DoFile(NDPath::GetScriptPath("entry.lua").c_str()));
	{
		return;
	}

	LuaStateMgrObj.SetExceptOutput(&luaExceptRunTimeOutPut);

#if 0
#ifndef UPDATE_RES 
    LuaStateMgrObj.GetState()->DoFile(NDPath::GetScriptPath("entry.lua").c_str());
#else
	this->LoadLuaFile(NDPath::GetScriptPath("entry.lua"));
#endif
#endif 
    

}
///////
void ScriptMgr::LoadLuaFile(const char* pszluaFile)
{
    printf("LuaState::DoFile ======DoFIle]");
    struct stat sb;
    if(!(stat(pszluaFile, &sb) >= 0)){
        printf("LuaState::DoFile Not Found File[%s]", pszluaFile);
        return;
    }
    FILE* fp = fopen(pszluaFile, "r");
    if (!fp) {
        printf("LuaState::DoFile Not Found File[%s]", pszluaFile);
        return;
    }
    unsigned int  nCiptextLen =0;
    unsigned char btCiptext[1024] = {0x00};
    unsigned char* btData = new unsigned char[sb.st_size];
    fread(&nCiptextLen, 1, sizeof(unsigned int), fp);
    nCiptextLen = fread(&btCiptext, 1, nCiptextLen, fp);
    unsigned char btPlaintext[1024] = {0x00};
    unsigned int nPlainLen=sizeof(btPlaintext);
    //解密
    CDes::Decrypt_Pad_PKCS_7( (const char *)g_dekey,
                             24,
                             (char*)btCiptext,
                             nCiptextLen,
                             (char*)btPlaintext,
                             nPlainLen);
    ::memcpy(btData,btPlaintext,nPlainLen); 
    int nDataLen = fread(btData+nPlainLen, 1, sb.st_size-nCiptextLen, fp);
    LuaStateMgrObj.GetState()->DoBuffer((const char*)btData,nDataLen+nPlainLen,pszluaFile); 
    delete []btData;
}

bool ScriptMgr::AddRegClassFunc(RegisterClassFunc func)
{
	vRegClassFunc.push_back(func);
	
	return true;
}

int ScriptMgr::excuteLuaFuncRetN(const char* funcname, const char* modulename)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return 0;
	}
	
	LuaFunction<int> func = funcObj;
	int ret = func();
	
	return ret;
}
const char* ScriptMgr::excuteLuaFuncRetS(const char* funcname, const char* modulename)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	if (!funcObj.IsFunction())
	{
		return 0;
	}
	LuaFunction<const char*> func = funcObj;
	const char* ret = func();
	return ret;
}
ccColor4B ScriptMgr::excuteLuaFuncRetColor4(const char* funcname, const char* modulename,int param1){
    LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return ccc4(255, 255, 255, 255);
	}
	
	LuaFunction<ccColor4B> func = funcObj;
	ccColor4B ret = func(param1);
	
	return ret;
}

bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);

	if (!funcObj.IsFunction())
	{
		return false;
	}
	
	LuaFunction<bool> func = funcObj;
	bool ret = func();
	
	return ret;
}

bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return false;
	}
	
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1);
	
	return ret;
}

bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return false;
	}
	
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1, param2);
	
	return ret;
}

bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return false;
	}
	
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1, param2, param3);
	
	return ret;
}
////////////////////////////////////////////////////////////////////////////////////////
bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, const char* param1)
{
    LuaObject funcObj = GetLuaFunc(funcname, modulename);
	if (!funcObj.IsFunction())
	{
		return false;
	}
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1);
	return ret;
}
////////////////////////////////////////////////////////////////////////////////////////
bool 
ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, const char* param1, const char* param2)
{
    LuaObject funcObj = GetLuaFunc(funcname, modulename);
	if (!funcObj.IsFunction())
	{
		return false;
	}
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1, param2);
	return ret;
}
////////////////////////////////////////////////////////////////////////////////////////
bool 
ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, const char* param1, const char* param2, const char* param3)
{
    LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return false;
	}
	
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1, param2,param3);
	
	return ret;
}
bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3,int param4)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);
	
	if (!funcObj.IsFunction())
	{
		return false;
	}
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1, param2, param3, param4);
	
	return ret;
}
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
