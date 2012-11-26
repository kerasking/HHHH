/*
*
*/

#ifndef NDBASESCRIPTMGR_H
#define NDBASESCRIPTMGR_H

#include "define.h"
#include "NDObject.h"
#include "LuaStateMgr.h"
#include "ccTypes.h"

using namespace cocos2d;

NS_NDENGINE_BGN

class NDBaseScriptMgr:
	public TSingleton<NDBaseScriptMgr>,
	public NDObject
{
	DECLARE_CLASS(NDBaseScriptMgr)

public:

	typedef bool (*RegisterClassFunc)();

	NDBaseScriptMgr();
	virtual ~NDBaseScriptMgr();

	virtual void update();
	virtual void Load();
	virtual bool AddRegClassFunc(RegisterClassFunc func);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, int param1);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3);

	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, const char* param1);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, const char* param1, const char* param2);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, const char* param1, const char* param2, const char* param3);
	virtual bool excuteLuaFunc(const char* funcname, const char* modulename, int param1, int param2, int param3,int param4);
	virtual bool IsLuaFuncExist(const char* funcname, const char* modulename);

	virtual int excuteLuaFuncRetN(const char* funcname, const char* modulename);
	virtual const char* excuteLuaFuncRetS(const char* funcname, const char* modulename);
	virtual ccColor4B excuteLuaFuncRetColor4(const char* funcname, const char* modulename,int param1);
	//void DebugOutPut(const char* str);
	virtual void DebugOutPut(const char* fmt, ...);
	virtual void LoadLuaFile(const char* pszluaFile);
	virtual void WriteLog(const char* fmt, ...);
	virtual LuaObject GetLuaFunc(const char* funcname, const char* modulename);

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
	RT excuteLuaFunc(const char* funcname, const char* modulename, T1 param1, T2 param2)
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
	RT excuteLuaFunc(const char* funcname, const char* modulename, T1 param1, T2 param2, T3 param3)
	{
		LuaObject funcObj = GetLuaFunc(funcname, modulename);

		if (!funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<RT> func = funcObj;

		return func(param1, param2, param3);
	}
	template<typename RT, typename T1, typename T2, typename T3,typename T4>
	RT excuteLuaFunc(const char* funcname, const char* modulename, T1 param1, T2 param2, T3 param3,T4 param4)
	{
		LuaObject funcObj = GetLuaFunc(funcname, modulename);

		if (!funcObj.IsFunction())
		{
			return false;
		}

		LuaFunction<RT> func = funcObj;

		return func(param1, param2, param3, param4);
	}

protected:
private:
};

#define BaseScriptMgrObj NDBaseScriptMgr::GetBackSingleton("ScriptMgr")

NS_NDENGINE_END

#endif