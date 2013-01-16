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
#include "ScriptGameData_New.h"
#include "ScriptNetMsg.h"
#include "ScriptUI.h"
#include "ScriptTask.h"
#include "ScriptGlobalEvent.h"
#include "ScriptGameLogic.h"
#include "ScriptDataBase.h"
#include "ScriptTimer.h"
#include "ScriptDrama.h"
#include "ObjectTracker.h"
#include "NDDataPersist.h"
#include "Des.h"
#include <sys/stat.h>
//#include "lstate.h"
#include "NDTextureMonitor.h"
#include "NDPicture.h"
#include "NDPath.h"
#include "NDUtil.h"
#include "NDProfile.h"
#include "ScriptRegLua.h"

// #ifndef UPDATE_RES
// #define UPDATE_RES 1
// #endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "direct.h"
#endif
#include "uitypes.h"

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

#define TextureMonitorObj	CNDTextureMonitor::GetSingleton()

using namespace NDEngine;
const unsigned char g_dekey[] = {0x80,0x12,0x97,0x67,0x24,0x88,0x89,0x98,0x55,0x34,0xBD,0x33,0x34,0x80,0x12,0x97,0x67,0x24,0x88,0x89,0x98,0x55,0x34,0xBD};
std::string* s_DataDir = 0;

IMPLEMENT_CLASS(ScriptMgr,NDBaseScriptMgr)

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

const char* DataFilePath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if(0 == s_DataDir)
    {
        s_DataDir = new std::string;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [documentsDirectory stringByAppendingPathComponent:@"/DHLJ"];
        *s_DataDir = ([documentsDirectory UTF8String]);
    }
#else
    if(0 == s_DataDir)
    {
        s_DataDir = new std::string;
        char szTempPath[MAX_PATH] = {0};
        
        getcwd(szTempPath,MAX_PATH);
        
        *s_DataDir =  "DHLJ";
    }
#endif
    return s_DataDir->c_str();
}

ScriptMgr::ScriptMgr()
: m_bLoadLuaOK(false)
{
	INC_NDOBJ_RTCLS

	#if 0
char filename[256];
	memset(filename, 0, sizeof(filename));
	snprintf(filename, sizeof(filename), "%s/log%ld.txt", 
			 DataFilePath(),
			 time(NULL));
	m_fDebugOutPut = fopen(filename, "a");
    printf(filename);
#endif

	char filename[256] = {0};
	memset(filename, 0, sizeof(filename));
	snprintf(filename, sizeof(filename), "%s/name.txt", NDPath::GetLogPath().c_str());
	m_fTest = fopen(filename, "w+");
}

ScriptMgr::~ScriptMgr()
{
	DEC_NDOBJ_RTCLS
	if (m_fDebugOutPut)
	{
		fclose(m_fDebugOutPut);
	}
	if (m_fTest)
	{
		fclose(m_fTest);
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

void ScriptMgr::WriteLog(const char* fmt, ...)
{
	return;

	if (!fmt)
	{
		return;
	}
	va_list argumentList;
	char buffer[1024] = "";
	va_start(argumentList, fmt);
	::vsprintf( buffer, fmt, argumentList);
	sprintf(buffer, "%s\0", buffer);
	va_end(argumentList);

	if(strstr(buffer, "tzq") != NULL && m_fTest)
	{
		//fwrite(buffer, 1, strlen(buffer) + 1, m_fTest);
		//fwrite("\n", 1, 1, m_fTest);
		//fflush(m_fTest);
	}

	CCLog( "%s\r\n", buffer );
}

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
	
    //NDLog(buffer);
    printf(buffer);
    printf("\n");
}

//using namespace LuaPlus;
void ScriptMgr::update()
{
	static unsigned int frameCount = 0;
//	if ( !ScriptMgrObj.IsLoadLuaOK() )//装载未完成则不执行下述语句
//		return;

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
	CCLog("@@ ScriptMgr::Load()\r\n");

	PROFILE_REGLUA();

	//TIME_SLICE("ScriptMgr::Load()");
	
	{
		TIME_SLICE("ScriptCommonLoad()");
		ScriptCommonLoad();
	}
	
	{
		TIME_SLICE("ScriptGlobalEvent::Load()");
		ScriptGlobalEvent::Load();
	}
	
	{
		TIME_SLICE("ScriptTimerMgrObj.Load()");
		ScriptTimerMgrObj.Load();
	}
	
	{
		TIME_SLICE("ScriptUiLoad()");
		ScriptUiLoad();
	}
	
	{
		TIME_SLICE("ScriptNetMsg::Load()");
		ScriptNetMsg::Load();
	}
	
	{
		TIME_SLICE("ScriptGameDataObj.Load()");
		ScriptGameDataObj.Load();
	}
	
	{
		TIME_SLICE("ScriptDBObj.Load()");
		ScriptDBObj.Load();
	}
	
	{
		TIME_SLICE("ScriptTaskLoad()");
		ScriptTaskLoad();
	}
	
	{
		TIME_SLICE("ScriptGameLogicLoad()");
		ScriptGameLogicLoad();
	}
	
	{
		TIME_SLICE("ScriptDramaLoad()");
		ScriptDramaLoad();
	}

#ifndef UPDATE_RES 
	{
 		TIME_SLICE("DoFile(entry.lua)");
 		const string strPath = NDPath::GetScriptPath("entry.lua");
 		LOGD("ready to load script,%s",strPath.c_str());
 		
 		if (0 == LuaStateMgrObj.GetState()->DoFile(strPath.c_str()))
 		{
 			LOGD("Load %s succeeded!",strPath.c_str());
 		}
 		else
 		{
 			LOGERROR("Load %s failed!",strPath.c_str());
 
 		}
	}
#else
	{
		TIME_SLICE("LoadLuaFile(entry.lua)");
		LoadLuaFile(NDPath::GetScriptPath("entry.lua").c_str());
	}
#endif

	LuaStateMgrObj.SetExceptOutput(&luaExceptRunTimeOutPut);
	m_bLoadLuaOK = true;

	CCLog("@@ ScriptMgr::Load() -- done.\r\n");
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
	fclose(fp);
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
bool ScriptMgr::excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3,int param4,int param5)
{
	LuaObject funcObj = GetLuaFunc(funcname, modulename);

	if (!funcObj.IsFunction())
	{
		return false;
	}
	LuaFunction<bool> func = funcObj;
	bool ret = func(param1, param2, param3, param4,param5);

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
	TIME_SLICE("LoadRegClassFuncs()");

	vec_regclass_func_it it = vRegClassFunc.begin();
	
	for (; it != vRegClassFunc.end(); it++) 
	{
		(*it)();
	}
	
	vRegClassFunc.clear();
}

ScriptMgr& NDEngine::ScriptMgr::GetScriptMgr()
{
	if (0 == ms_pkSingleton)
	{
		ms_pkSingleton = new ScriptMgr;
	}

	return *((ScriptMgr*)ms_pkSingleton);
}

ScriptMgr* NDEngine::ScriptMgr::GetScriptMgrPtr()
{
	if (0 == ms_pkSingleton)
	{
		ms_pkSingleton = new ScriptMgr;
	}

	return (ScriptMgr*)ms_pkSingleton;
}