/*
 *  ScriptGameLogic.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */
#pragma once
//#include "NewGameUIPetAttrib.h"
#include "NDObject.h"
#include "ScriptMgr.h"
#include "NDUtil.h"

unsigned long GetPlayerId();
unsigned long GetMapId();
int GetCurrentMonsterRound();
int GetPlayerLookface();

bool SwichKeyToServer(const char* pszIp, int nPort, const char* pszAccountName,
		const char* pszPwd, const char* pszServerName);

class ScriptObjectGameLogic: public NDEngine::ScriptObject
{
public:
	virtual void OnLoad();
};
