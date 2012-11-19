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

#define ScriptMgrObj	NDEngine::ScriptMgr::GetSingleton()

namespace NDEngine
{

class ScriptObject
{
public:
	ScriptObject()
	{
	}
	virtual ~ScriptObject()
	{
	}
	virtual void OnLoad()
	{
	}
};

class ScriptMgr// public TSingleton<ScriptMgr>
{
	typedef bool (*RegisterClassFunc)();

	typedef std::vector<RegisterClassFunc> vec_regclass_func;

	typedef vec_regclass_func::iterator vec_regclass_func_it;

	typedef std::vector<ScriptObject*> vec_script_object;

	typedef vec_script_object::iterator vec_script_object_it;

public:

	ScriptMgr();
	~ScriptMgr();

	static ScriptMgr& GetSingleton();

	void AddScriptObject(ScriptObject* object);
	void DelScriptObject(ScriptObject* object);
	bool AddRegClassFunc(RegisterClassFunc func);
	void SetLogFilePath(const char* szFilePath);
	void SetScriptFilePath(const char* szFilePath);
	void Load();

	bool excuteLuaFunc(const char* funcname, const char* modulename);
	bool excuteLuaFunc(const char* funcname, const char* modulename,
			int param1);
	bool excuteLuaFunc(const char* funcname, const char* modulename, int param1,
			int param2);
	bool excuteLuaFunc(const char* funcname, const char* modulename, int param1,
			int param2, int param3);

	bool IsLuaFuncExist(const char* funcname, const char* modulename);

	int excuteLuaFuncRetN(const char* funcname, const char* modulename);
	//void DebugOutPut(const char* str);
	void DebugOutPut(const char* fmt, ...);

	template<typename RT>
	RT excuteLuaFunc(const char* funcname, const char* modulename)
	{
		LuaObject funcObj = GetLuaFunc(funcname, modulename);

		if (!funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<RT> func = funcObj;

		return func();
	}

	template<typename RT, typename T>
	RT excuteLuaFunc(const char* funcname, const char* modulename, T param1)
	{
		LuaObject funcObj = GetLuaFunc(funcname, modulename);

		if (!funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<RT> func = funcObj;

		return func(param1);
	}

	template<typename RT, typename T1, typename T2>
	RT excuteLuaFunc(const char* funcname, const char* modulename, T1 param1,
			T2 param2)
	{
		LuaObject funcObj = GetLuaFunc(funcname, modulename);

		if (!funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<RT> func = funcObj;

		return func(param1, param2);
	}

	template<typename RT, typename T1, typename T2, typename T3>
	RT excuteLuaFunc(const char* funcname, const char* modulename, T1 param1,
			T2 param2, T3 param3)
	{
		LuaObject funcObj = GetLuaFunc(funcname, modulename);

		if (!funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<RT> func = funcObj;

		return func(param1, param2, param3);
	}

private:
	vec_regclass_func m_vRegClassFunc;
	FILE* m_fDebugOutPut;
	vec_script_object m_vScriptObject;
	std::string m_strLogFilePath;
	std::string m_strScriptFilePath;

private:

	static ScriptMgr* ms_pkScriptMgr;

	void LoadRegClassFuncs();

	LuaObject GetLuaFunc(const char* funcname, const char* modulename);

public:
	void update();
};

}