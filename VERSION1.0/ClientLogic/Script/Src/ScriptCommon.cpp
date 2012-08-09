/*
 *  ScriptCommon.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-9.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "ScriptCommon.h"
#include "ScriptInc.h"
#include <sstream>
#include "NDPath.h"

using namespace LuaPlus;
using namespace NDEngine;

int LuaLogInfo(LuaState* state)
{
	LuaStack args(state);
	LuaObject str = args[1];
	
	if (str.IsString())
	{
		ScriptMgrObj.DebugOutPut("%s", str.GetString());
	}

	return 0;
}

int LuaLogError(LuaState* state)
{
	LuaStack args(state);
	LuaObject str = args[1];
	
	if (str.IsString())
	{
		ScriptMgrObj.DebugOutPut("Error:%s", str.GetString());
	}

	return 0;
}

int DoFile(LuaState* state)
{
	int nRet = -1;
	LuaStack args(state);
	LuaObject str = args[1];
	
	if (str.IsString())
	{
		const char* pszPath = NDPath::GetScriptPath(str.GetString());
		nRet = state->DoFile(pszPath);
	}

	return nRet;
}

int LeftShift(int x, int y)
{
	return x << y;
}	

int RightShift(int x, int y)
{
	return x >> y;
}

int BitwiseAnd(int x, int y)
{
	return x & y;
}

////////////////////////////////////////////////////////////
//std::string g_strTmpWords;
////////////////////////////////////////////////////////////

void ScriptObjectCommon::OnLoad()
{
	ETLUAFUNC("LuaLogInfo", LuaLogInfo);
	ETLUAFUNC("LuaLogError", LuaLogError);
	ETLUAFUNC("DoFile", DoFile);
	ETCFUNC("LeftShift", LeftShift)
	ETCFUNC("RightShift", RightShift)
	ETCFUNC("BitwiseAnd", BitwiseAnd)
        //ETCFUNC("GetRandomWords", GetRandomWords);
}