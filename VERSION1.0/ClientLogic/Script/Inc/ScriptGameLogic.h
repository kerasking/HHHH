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

typedef struct _STRU_PLAYER_INFO
{
	int m_iId;                    //人物ID
	int m_iLookFace;               //人物外形ID(指向对应的图片）
	int m_iBornX;                  //出生地X坐标（单位）
	int m_iBornY;                  //出生地Y坐标
	int m_iRideStatus;              //骑乘的状态
	int m_iRideType;               //骑乘的类型
	std::string m_strName;              //人物的名字
}stuPlayerInfo;

namespace NDEngine {

	void SetPlayerInfo(int iId, int iLookFace, int iBornX, int iBornY, int iRideStatus, int iRideType, std::string strName);
	void GetPlayerInfo(stuPlayerInfo &stuinfo);
	void CreatePlayerWithMount(int lookface, int x, int y, int userid, std::string name, int nRideStatus=0, int nMountType=0 );

	unsigned long GetPlayerId();
	unsigned long GetMapId();
	int GetCurrentMonsterRound();
	int GetPlayerLookface();
	std::string GetSMImgPath(const char* name);
	void ScriptGameLogicLoad();
	
}
