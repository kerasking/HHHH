/*
 *  ScriptGameLogic.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */
#pragma once

unsigned long GetPlayerId();
unsigned long GetMapId();
int GetCurrentMonsterRound();
int GetPlayerLookface();
const char* GetSMImgPath(const char* name);

class ScriptObjectGameLogic : public NDEngine::ScriptObject
{
public:
	virtual void OnLoad();
};
