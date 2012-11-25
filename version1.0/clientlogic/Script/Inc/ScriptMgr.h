/*
 *  ScriptMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-4.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#pragma once

#include "Singleton.h"
#include "ScriptInc.h"

#include <vector>
#include "ccTypes.h"
#include "NDBaseScriptMgr.h"

const char* DataFilePath();
#define ScriptMgrObj	NDEngine::ScriptMgr::GetScriptMgr()
using namespace cocos2d;

namespace NDEngine
{

//const char* GetScriptPath(const char* fileName);

class ScriptMgr:public NDBaseScriptMgr
{
	DECLARE_CLASS(ScriptMgr)
	typedef std::vector<RegisterClassFunc> vec_regclass_func;

	typedef vec_regclass_func::iterator vec_regclass_func_it;
	
public:

	ScriptMgr();
	~ScriptMgr();

	static ScriptMgr& GetScriptMgr();
	
	void Load();
	bool AddRegClassFunc(RegisterClassFunc func);
	bool excuteLuaFunc(const char* funcname, const char* modulename);
	bool excuteLuaFunc(const char* funcname, const char* modulename, int param1);
	bool excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2);
	bool excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3);

    bool excuteLuaFunc(const char* funcname, const char* modulename, const char* param1);
	bool excuteLuaFunc(const char* funcname, const char* modulename, const char* param1, const char* param2);
	bool excuteLuaFunc(const char* funcname, const char* modulename, const char* param1, const char* param2, const char* param3);
    bool excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3,int param4);
	bool IsLuaFuncExist(const char* funcname, const char* modulename);
	
	int excuteLuaFuncRetN(const char* funcname, const char* modulename);
    const char* excuteLuaFuncRetS(const char* funcname, const char* modulename);
    ccColor4B excuteLuaFuncRetColor4(const char* funcname, const char* modulename,int param1);
	//void DebugOutPut(const char* str);
	void DebugOutPut(const char* fmt, ...);
	void LoadLuaFile(const char* pszluaFile);
	void WriteLog(const char* fmt, ...);

private:
	vec_regclass_func vRegClassFunc;
	FILE* m_fDebugOutPut;
	FILE* m_fTest;	
private:
	void LoadRegClassFuncs();

	LuaObject GetLuaFunc(const char* funcname, const char* modulename);

public:
	void update();
};

}