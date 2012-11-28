/*
 *  ScriptGameLogic.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#pragma once
#include <string>
using namespace std;


namespace NDEngine {
	void CreatePlayerWithMount(int lookface, int x, int y, int userid, std::string name, int nRideStatus=0, int nMountType=0 );

	unsigned long GetPlayerId();
	unsigned long GetMapId();
	int GetCurrentMonsterRound();
	int GetPlayerLookface();
	std::string GetSMImgPath(const char* name);
	void ScriptGameLogicLoad();
	
}
