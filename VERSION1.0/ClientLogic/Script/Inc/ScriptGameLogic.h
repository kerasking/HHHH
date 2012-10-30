/*
 *  ScriptGameLogic.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#pragma once

namespace NDEngine {
	unsigned long GetPlayerId();
	unsigned long GetMapId();
	int GetCurrentMonsterRound();
	int GetPlayerLookface();
	const char* GetSMImgPath(const char* name);
	void ScriptGameLogicLoad();
	
}
