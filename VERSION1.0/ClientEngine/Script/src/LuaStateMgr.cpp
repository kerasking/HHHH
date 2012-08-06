/*
 *  LuaStateMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "LuaStateMgr.h"

using namespace NDEngine;

static LuaState* ms_pkLuaState = NULL;

static LuaStateMgr* mgr = NULL;

void exceptOutPut(LuaState *L, const char *exceptinfo)
{
	FUNCEXCEPTOUTPUT fun = LuaStateMgrObj.GetExceptOutput();
	
	if (fun)
	{
		fun(exceptinfo);
		
		return;
	}
}

LuaStateMgr::LuaStateMgr(void)
{
	m_funExceptOutput = NULL;
}

LuaStateMgr::~LuaStateMgr(void)
{
	mgr = NULL;
}

LuaStateMgr& LuaStateMgr::GetSingle()
{
	if (mgr == NULL)
	{
		mgr = new LuaStateMgr;
	}
	
	return *mgr;
}

LuaState* LuaStateMgr::GetState()
{
	if (ms_pkLuaState ==  NULL)
	{
		ms_pkLuaState = LuaState::Create(true);
		
		ms_pkLuaState->SetExceptInfoOutHandler(&exceptOutPut);
	}
	
	return ms_pkLuaState;
}