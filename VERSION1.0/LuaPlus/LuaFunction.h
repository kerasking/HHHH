///////////////////////////////////////////////////////////////////////////////
// This source file is part of the LuaPlus source distribution and is Copyright
// 2001-2004 by Joshua C. Jensen (jjensen@workspacewhiz.com).
//
// The latest version may be obtained from http://wwhiz.com/LuaPlus/.
//
// The code presented in this file may be used in any environment it is
// acceptable to use Lua.
///////////////////////////////////////////////////////////////////////////////
#ifdef _MSC_VER
#pragma once
#endif // _MSC_VER
#ifndef LUAFUNCTION_H
#define LUAFUNCTION_H

#include "LuaPlusInternal.h"
#include "LuaAutoBlock.h"

namespace LuaPlus {
	
// add by jhzheng 2012.1.19
	static int traceback (lua_State *L) {
		lua_getfield(L, LUA_GLOBALSINDEX, "debug");
		if (!lua_istable(L, -1)) {
			lua_pop(L, 1);
			return 1;
		}
		lua_getfield(L, -1, "traceback");
		if (!lua_isfunction(L, -1)) {
			lua_pop(L, 2);
			return 1;
		}
		lua_pushvalue(L, 1);  /* pass error message */
		lua_pushinteger(L, 2);  /* skip this function and traceback */
		lua_call(L, 2, 1);  /* call debug.traceback */
		return 1;
	}

// add by jhzheng 2012.1.19
	static int docall (lua_State *L, int narg, int clear) {
		int status;
		int base = lua_gettop(L) - narg;  /* function index */
		lua_pushcfunction(L, traceback);  /* push traceback function */
		lua_insert(L, base);  /* put it under chunk and args */
		//signal(SIGINT, laction);
		status = lua_pcall(L, narg, (clear), base);
		//signal(SIGINT, SIG_DFL);
		lua_remove(L, base);  /* remove traceback function */
		/* force a complete garbage collection in case of errors */
		if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
		return status;
	}

#define LUAFUNCTION_PRECALL() \
		lua_State* L = m_functionObj.GetCState(); \
		LuaAutoBlock autoBlock(L); \
		m_functionObj.Push();

// modify by jhzheng 2012.1.19
#define LUAFUNCTION_POSTCALL(numArgs) \
		if (docall(L, numArgs, 1) != 0) \
		{ \
			const char* errorString = lua_tostring(L, -1); \
			LuaState *state = m_functionObj.GetState(); \
			if (state && state->GetExceptInfoOutHandler()) \
			{ \
				state->GetExceptInfoOutHandler()(state, errorString); \
			} \
		} \
		return LPCD::Get(LPCD::TypeWrapper<RT>(), L, -1);


/**
**/
template <typename RT>
class LuaFunction
{
public:
	LuaFunction(LuaObject& functionObj) :
		m_functionObj(functionObj)
	{
		luaplus_assert(m_functionObj.IsFunction());
	}

	LuaFunction(LuaState* state, const char* functionName)
	{
		m_functionObj = state->GetGlobals()[functionName];
		luaplus_assert(m_functionObj.IsFunction());
	}

	RT operator()()
	{
		LUAFUNCTION_PRECALL();
		LUAFUNCTION_POSTCALL(0);
	}

	template <typename P1>
	RT operator()(P1 p1)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LUAFUNCTION_POSTCALL(1);
	}

	template <typename P1, typename P2>
	RT operator()(P1 p1, P2 p2)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LUAFUNCTION_POSTCALL(2);
	}

	template <typename P1, typename P2, typename P3>
	RT operator()(P1 p1, P2 p2, P3 p3)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LUAFUNCTION_POSTCALL(3);
	}

	template <typename P1, typename P2, typename P3, typename P4>
	RT operator()(P1 p1, P2 p2, P3 p3, P4 p4)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LUAFUNCTION_POSTCALL(4);
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5>
	RT operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LPCD::Push(L, p5);
		LUAFUNCTION_POSTCALL(5);
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6>
	RT operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LPCD::Push(L, p5);
		LPCD::Push(L, p6);
		LUAFUNCTION_POSTCALL(6);
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6, typename P7>
	RT operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6, P7 p7)
	{
		LUAFUNCTION_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LPCD::Push(L, p5);
		LPCD::Push(L, p6);
		LPCD::Push(L, p7);
		LUAFUNCTION_POSTCALL(7);
	}

protected:
	LuaObject m_functionObj;
};


#define LUAFUNCTIONVOID_PRECALL() \
		lua_State* L = m_functionObj.GetCState(); \
		LuaAutoBlock autoBlock(L); \
		m_functionObj.Push();

// modify by jhzheng 2012.1.19
#define LUAFUNCTIONVOID_POSTCALL(numArgs) \
		if (docall(L, numArgs, 1)) \
		{ \
		const char* errorString = lua_tostring(L, -1); \
			LuaState *state = m_functionObj.GetState(); \
			if (state && state->GetExceptInfoOutHandler()) \
			{ \
			state->GetExceptInfoOutHandler()(state, errorString); \
			} \
		}


/**
**/
class LuaFunctionVoid
{
public:
	LuaFunctionVoid(const LuaObject& functionObj) :
		m_functionObj(functionObj)
	{
		luaplus_assert(m_functionObj.IsFunction());
	}

	LuaFunctionVoid(LuaState* state, const char* functionName)
	{
		m_functionObj = state->GetGlobals()[functionName];
		luaplus_assert(m_functionObj.IsFunction());
	}

	void operator()()
	{
		LUAFUNCTIONVOID_PRECALL();
		LUAFUNCTIONVOID_POSTCALL(0);
	}

	template <typename P1>
	void operator()(P1 p1)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LUAFUNCTIONVOID_POSTCALL(1);
	}

	template <typename P1, typename P2>
	void operator()(P1 p1, P2 p2)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LUAFUNCTIONVOID_POSTCALL(2);
	}

	template <typename P1, typename P2, typename P3>
	void operator()(P1 p1, P2 p2, P3 p3)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LUAFUNCTIONVOID_POSTCALL(3);
	}

	template <typename P1, typename P2, typename P3, typename P4>
	void operator()(P1 p1, P2 p2, P3 p3, P4 p4)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LUAFUNCTIONVOID_POSTCALL(4);
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5>
	void operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LPCD::Push(L, p5);
		LUAFUNCTIONVOID_POSTCALL(5);
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6>
	void operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LPCD::Push(L, p5);
		LPCD::Push(L, p6);
		LUAFUNCTIONVOID_POSTCALL(6);
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6, typename P7>
	void operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6, P7 p7)
	{
		LUAFUNCTIONVOID_PRECALL();
		LPCD::Push(L, p1);
		LPCD::Push(L, p2);
		LPCD::Push(L, p3);
		LPCD::Push(L, p4);
		LPCD::Push(L, p5);
		LPCD::Push(L, p6);
		LPCD::Push(L, p7);
		LUAFUNCTIONVOID_POSTCALL(7);
	}

protected:
	LuaObject m_functionObj;
};

} // namespace LuaPlus

#endif // LUAFUNCTION_H