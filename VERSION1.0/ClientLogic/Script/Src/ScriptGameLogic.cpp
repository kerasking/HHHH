/*
 *  ScriptGameLogic.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "ScriptGameLogic.h"
#include "ScriptInc.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "ItemMgr.h"
#include "Chat.h"
#include "NDMapMgr.h"
#include "ScriptGameData.h"
#include "NewChatScene.h"
#include "NDMapLayer.h"
#include "SMGameScene.h"
#include "SMLoginScene.h"
#include "WorldMapScene.h"
#include "NDBeforeGameMgr.h"
#include "BattleMgr.h"
#include "Battle.h"
#include "ChatManager.h"

using namespace NDEngine;

void QuitGame()
{
	quitGame();
	ScriptGameDataObj.DelAllData();
}
	
void CreatePlayer(int lookface, int x, int y, int userid, std::string name)
{
	NSLog(@"%@", [NSString stringWithUTF8String:name.c_str()]);
	NDPlayer::pugeHero();
	NDPlayer& player = NDPlayer::defaultHero(lookface, true);
	player.InitRoleLookFace(lookface);
		
	player.stopMoving();
	player.SetPositionEx(ccp(x*MAP_UNITSIZE+DISPLAY_POS_X_OFFSET, y*MAP_UNITSIZE+DISPLAY_POS_Y_OFFSET));
	player.SetServerPositon(x, y);
	player.m_id = userid;
	player.m_name = "王增";
}
	
unsigned long GetPlayerId()
{
	return NDPlayer::defaultHero().m_id;
}
	
void PlayerStopMove()
{
	NDPlayer::defaultHero().stopMoving();
}
	
unsigned long GetMapId()
{
	return NDMapMgrObj.GetMotherMapID();
}
	
int GetCurrentMonsterRound()
{
	return NDMapMgrObj.GetCurrentMonsterRound();
}
	
int GetPlayerLookface()
{
	return NDPlayer::defaultHero().GetLookface();
}
	
int	GetItemCount(int nItemType)
{
	int count = 0;
	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
	for_vec(vec_item, VEC_ITEM_IT)
	{
		Item *item = (*it);
		if (item->iItemType == nItemType) {
			if (item->isEquip()) {
				count++;
			} else {
				count += item->iAmount;
			}
		}
			
	}
		
	return count;
}
	
void SysChat(const char* text)
{
	if (!text || 0 == strlen(text))
	{
		return;
	}
	Chat::DefaultChat()->AddMessage(ChatTypeSystem, text);
}
	
void NavigateTo(int nMapId, int nMapX, int nMapY)
{
	NDMapMgrObj.NavigateTo(nMapX, nMapY, nMapId);
}
	
void NavigateToNpc(int nNpcId)
{
	NDMapMgrObj.NavigateToNpc(nNpcId);
}
	
void ShowChat()
{
	NewChatScene::DefaultManager()->Show();
}
	
int GetCurrentTime()
{
	return (int)([[NSDate date] timeIntervalSince1970] / 1000);
}
	
const char* GetSMImgPath(const char* name)
{
	if (!name)
	{
		return "";
	}
		
	std::string str = "Res00/";
	str += name;
		
	return GetImgPath(str.c_str());
}
	
const char* GetSMResPath(const char* name)
{
	if (!name)
	{
		return "";
	}
		
	return GetResPath(name);
}
	
NDMapLayer* GetMapLayer()
{
	NDScene* scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene));
	if(!scene)
	{
		return NULL;
	}
	NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
	if(!layer)
	{
		return NULL;
	}
		
	return layer;
}
	
void AddChatInfoRecord(std::string speaker,std::string text,int content_id,int type)
{
	ChatManagerObj.AddChatInfoRecord(speaker,text,content_id,CHAT_CHANNEL_TYPE(type));
}
	
void AddAllRecord()
{
	ChatManagerObj.AddAllRecord();
}
	
void SetCurrentChannel(CHAT_CHANNEL_TYPE channel)
{
	ChatManagerObj.SetCurrentChannel(channel);
}
	
void restartLastBattle()
{
	BattleMgrObj.restartLastBattle();
}
	
void CloseBattle()
{
	Battle* battle=BattleMgrObj.GetBattle();
	if(battle)
	{
		battle->FinishBattle();
	}

}
	
void WorldMapGoto(int nMapId, LuaObject tFilter)
{
	NDScene* scene	= NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene)
	{
		return;
	}
		
	WorldMapLayer* world	= NULL;
	NDNode* node			= scene->GetChild(TAG_WORLD_MAP);
	if (node && node->IsKindOfClass(RUNTIME_CLASS(WorldMapLayer)))
	{
		world	= (WorldMapLayer*)node;
	}
	else
	{
		world	= new WorldMapLayer;
		world->Initialization(GetMapId());
		scene->AddChild(world);
	}
		
	if (tFilter.IsTable())
	{
		ID_VEC vId;
		int nTableCount = tFilter.GetTableCount();
		if (nTableCount > 0)
		{
			for (int i = 1; i <= nTableCount; i++) 
			{
				LuaObject tag = tFilter[i];
				if (tag.IsInteger())
				{
					vId.push_back(tag.GetInteger());
				}
			}
		}
		world->SetFilter(vId);
	}
		
	world->Goto(nMapId);
}
    
void FastRegister()
{
    NDBeforeGameMgrObj.FastGameOrRegister(1);
}
    
////////////////////////////////////////////////
std::string GetFastAccount()
{
    return NDBeforeGameMgrObj.GetUserName();
}
////////////////////////////////////////////////
std::string GetFastPwd()
{
    return NDBeforeGameMgrObj.GetPassWord();
}
    
///////////////////////////////////////////////
bool SwichKeyToServer(const char* pszIp, int nPort, const char* pszAccountName, const char* pszPwd, const char* pszServerName)
{
    return NDBeforeGameMgrObj.SwichKeyToServer(pszIp,nPort,pszAccountName,pszPwd,pszServerName);
}
    
///////////////////////////////////////////////
void SetRole(unsigned long ulLookFace, const char* pszRoleName, int nProfession)
{
    NDBeforeGameMgrObj.SetRole(ulLookFace, pszRoleName, nProfession);
}
    
///////////////////////////////////////////////
bool LoginByLastData(void)
{
    return NDBeforeGameMgrObj.LoginByLastData();
}
    
//////////////////////////////////////////////
int GetAccountListNum(void)
{
    return NDBeforeGameMgrObj.GetAccountListNum();
}
    
//////////////////////////////////////////////
const char* GetRecAccountNameByIdx(int idx)
{
    return NDBeforeGameMgrObj.GetRecAccountNameByIdx(idx);
}
    
//////////////////////////////////////////////
const char* GetRecAccountPwdByIdx(int idx)
{
    return NDBeforeGameMgrObj.GetRecAccountPwdByIdx(idx);
}
    
void    CreateRole(const char* pszName, Byte nProfession, int nLookFace, const char* pszAccountName)
{
    return NDBeforeGameMgrObj.CreateRole(pszName,nProfession, nLookFace, pszAccountName);
}
    
///////////////////////////////////////////////
void ScriptObjectGameLogic::OnLoad()
{
	ETCFUNC("QuitGame", QuitGame);
	ETCFUNC("CreatePlayer", CreatePlayer);
	ETCFUNC("PlayerStopMove", PlayerStopMove);
	ETCFUNC("NDPath::GetImgPathNew", NDPath::GetImgPathNew);
	ETCFUNC("GetPlayerId", GetPlayerId);
	ETCFUNC("SysChat", SysChat);
	ETCFUNC("NavigateTo", NavigateTo);
	ETCFUNC("NavigateToNpc", NavigateToNpc);
	ETCFUNC("ShowChat", ShowChat);
	ETCFUNC("GetMapId", GetMapId);
	ETCFUNC("GetCurrentMonsterRound",GetCurrentMonsterRound);
	ETCFUNC("GetSMImgPath", GetSMImgPath);
	ETCFUNC("GetSMResPath", GetSMResPath);
	ETCFUNC("GetMapLayer", GetMapLayer);
	ETCFUNC("restartLastBattle",restartLastBattle);
	ETCFUNC("GetPlayerLookface", GetPlayerLookface);
	ETCFUNC("WorldMapGoto", WorldMapGoto);
    ETCFUNC("GetRandomWords", &CSMLoginScene::GetRandomWords);
	ETCFUNC("CloseBattle",CloseBattle);
	ETCFUNC("GetCurrentTime",GetCurrentTime);
    /*登陆部分*/
    ETCFUNC("FastRegister", FastRegister);
    ETCFUNC("GetFastAccount", GetFastAccount);
    ETCFUNC("GetFastPwd", GetFastPwd);
    ETCFUNC("SwichKeyToServer",SwichKeyToServer);
    ETCFUNC("SetRole", SetRole);
    ETCFUNC("LoginByLastData", LoginByLastData);
    ETCFUNC("GetAccountListNum",GetAccountListNum);
    ETCFUNC("GetRecAccountNameByIdx",GetRecAccountNameByIdx);
    ETCFUNC("GetRecAccountPwdByIdx",GetRecAccountPwdByIdx);
	ETCFUNC("AddChatInfoRecord",	AddChatInfoRecord);
	ETCFUNC("AddAllRecord",		AddAllRecord);
	ETCFUNC("SetCurrentChannel",	SetCurrentChannel);
    //ETCFUNC("CreateRole",CreateRole);
}
	
//地图层接口导出
ETCLASSBEGIN(NDMapLayer)
ETMEMBERFUNC("setStartRoadBlockTimer",						&NDMapLayer::setStartRoadBlockTimer)
ETMEMBERFUNC("setAutoBossFight",						&NDMapLayer::setAutoBossFight)	
ETMEMBERFUNC("IsBattleBackground",						&NDMapLayer::IsBattleBackground)	
ETMEMBERFUNC("ShowTreasureBox",							&NDMapLayer::ShowTreasureBox)
ETCLASSEND(NDMapLayer)

