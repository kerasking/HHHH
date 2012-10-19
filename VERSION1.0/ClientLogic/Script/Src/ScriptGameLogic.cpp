/*
 *  ScriptGameLogic.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-13.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "ScriptGameLogic.h"
#include "ScriptInc.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "CCPointExtension.h"
#include "ItemMgr.h"
#include "Chat.h"
///< #include "NDMapMgr.h" 临时性注释 郭浩
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
#include "NDDataTransThread.h"

using namespace NDEngine;

void QuitGame()
{
	quitGame();
	ScriptGameDataObj.DelAllData();
}

// 根据seed值，产生一个salt值，直接采用vc crt库的srand和rand算法
int GetEncryptSalt(unsigned int seed)
{
    return( ((seed * 214013L + 2531011L) >> 16) & 0x7fff );
}

// void sendMsgConnect(int idAccount) 
// {
// 	NDTransData data(_MSG_CONNECT);
//     std::string phoneKey = "1yyyyyyyyyyyyyyyyyyyyyyyyyy";
// 	int dwAuthorize = 0;
// 	data << idAccount;
// 	data << dwAuthorize;
// 	data.Write((unsigned char*)(phoneKey.c_str()), phoneKey.size());
// 	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
// }

std::string Int2StrIP(int ip_Int)
{
	int num1 = ((ip_Int & 0xff000000) >> 24) & 0xff;
	int num2 = ((ip_Int & 0xff0000L) >> 16) & 0xff;
	int num3 = ((ip_Int & 0xff00L) >> 8) & 0xff;
	int num4 = (ip_Int & 0xff);
	tq::CString str;
	str.Format("%d.%d.%d.%d", num4,num3,num2,num1);

	return str;
}

void sendMsgConnect(const char* pszIp, int nPort, int idAccount)
{
	NDDataTransThread::DefaultThread()->Stop();
	NDDataTransThread::ResetDefaultThread();
	NDDataTransThread::DefaultThread()->Start(pszIp, nPort);
	if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
	{
		return;
	}
	NDBeforeGameMgrObj.sendMsgConnect(idAccount);
}

void CreatePlayer(int lookface, int x, int y, int userid, std::string name)
{
	NDPlayer::pugeHero();
	NDPlayer& player = NDPlayer::defaultHero(lookface, true);
	player.InitRoleLookFace(lookface);

	player.stopMoving();
//  	player.SetPositionEx(ccp(x * MAP_UNITSIZE + DISPLAY_POS_X_OFFSET, y * MAP_UNITSIZE + DISPLAY_POS_Y_OFFSET));
//  	player.SetServerPositon(x, y);
	player.m_nID = userid;
	player.m_strName = "王增";
}

unsigned long GetPlayerId()
{
	return NDPlayer::defaultHero().m_nID;
}

void PlayerStopMove()
{
	NDPlayer::defaultHero().stopMoving();
}

unsigned long GetMapId()
{
	//return NDMapMgrObj.GetMotherMapID(); ///< 临时性注释 郭浩
	return 0;
}

int GetCurrentMonsterRound()
{
	//return NDMapMgrObj.GetCurrentMonsterRound(); ///< 临时性注释 郭浩
	return 0;
}

int GetPlayerLookface()
{
	return NDPlayer::defaultHero().GetLookface();
}

int GetItemCount(int nItemType)
{
	int count = 0;
	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();

	for_vec(vec_item, VEC_ITEM_IT)
	{
		Item *item = (*it);

		if (item->m_nItemType == nItemType)
		{
			if (item->isEquip())
			{
				count++;
			}
			else
			{
				count += item->m_nAmount;
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
//	Chat::DefaultChat()->AddMessage(ChatTypeSystem, text); ///< 临时性注释 郭浩
}

void NavigateTo(int nMapId, int nMapX, int nMapY)
{
	//NDMapMgrObj.NavigateTo(nMapX, nMapY, nMapId); ///< 临时性注释 郭浩
}

void NavigateToNpc(int nNpcId)
{
	// NDMapMgrObj.NavigateToNpc(nNpcId); ///< 临时性注释 郭浩
}

void ShowChat()
{
	NewChatScene::DefaultManager()->Show();
}

/***
 * 临时性注释 郭浩
 * this function
 */
//int GetCurrentTime()
//{
//return (int)([[NSDate date] timeIntervalSince1970] / 1000);
//}
const char* GetSMImgPath(const char* name)
{
	if (!name)
	{
		return "";
	}

	std::string str = "Res00/";
	str += name;

	return NDPath::GetImgPath(str.c_str());
}

const char* GetSMResPath(const char* name)
{
	if (!name)
	{
		return "";
	}

	return NDPath::GetResPath(name);
}

NDMapLayer* GetMapLayer()
{
	/***
	 * 临时性注释 郭浩
	 * all
	 */

// 	NDScene* scene = NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(CSMGameScene));
// 	if(!scene)
// 	{
// 		return NULL;
// 	}
// 	NDMapLayer* layer = NDMapMgrObj.getMapLayerOfScene(scene);
// 	if(!layer)
// 	{
// 		return NULL;
// 	}
// 		
// 	return layer;
	return 0;
}

void AddChatInfoRecord(std::string speaker, std::string text, int content_id,
		int type)
{
	ChatManagerObj.AddChatInfoRecord(speaker, text, content_id,
			CHAT_CHANNEL_TYPE(type));
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
	Battle* battle = BattleMgrObj.GetBattle();
	if (battle)
	{
		battle->FinishBattle();
	}

}

void WorldMapGoto(int nMapId, LuaObject tFilter)
{
	NDScene* pkScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!pkScene)
	{
		return;
	}

	WorldMapLayer* pkWorld = NULL;
	NDNode* node = pkScene->GetChild(TAG_WORLD_MAP);
	if (node && node->IsKindOfClass(RUNTIME_CLASS(WorldMapLayer)))
	{
		pkWorld = (WorldMapLayer*) node;
	}
	else
	{
		pkWorld = new WorldMapLayer;
		pkWorld->Initialization(GetMapId());
		pkScene->AddChild(pkWorld);
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
		pkWorld->SetFilter(vId);
	}

	pkWorld->Goto(nMapId);
}

void FastRegister()
{
//    NDBeforeGameMgrObj.FastGameOrRegister(1); ///< 临时性注释 郭浩
}

////////////////////////////////////////////////
std::string GetFastAccount()
{
//    return NDBeforeGameMgrObj.GetUserName(); ///< 临时性注释 郭浩
	return std::string("");
}
////////////////////////////////////////////////
std::string GetFastPwd()
{
//    return NDBeforeGameMgrObj.GetPassWord(); ///< 临时性注释 郭浩
	return std::string("");
}

///////////////////////////////////////////////
bool SwichKeyToServer(const char* pszIp, int nPort, const char* pszAccountName,
		const char* pszPwd, const char* pszServerName)
{
//     //return NDBeforeGameMgrObj.SwichKeyToServer(pszIp,nPort,pszAccountName,pszPwd,pszServerName);
//     NDDataTransThread::DefaultThread()->Stop();
//     NDDataTransThread::ResetDefaultThread();
// 
//     NDDataTransThread::DefaultThread()->Start(pszIp, nPort);
// 	if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
// 	{
// 		return false;
// 	}
//     
//     //this->SetUserName(pszAccountName);
//     //this->SetServerInfo(pszIp,pszServerName,pszServerName,nPort);
//     //this->SetPassWord(pszPwd);
// 
//     int idAccount = atoi(pszAccountName);
//     sendMsgConnect(idAccount);
// //    srand(idAccount);
//     int nSalt = GetEncryptSalt(idAccount);
//     DWORD dwAuthorize = 0;
//     DWORD dwData = dwAuthorize ^ (nSalt % idAccount);
//     dwAuthorize = dwData;
//     DWORD dwEncryptCode = (idAccount+dwAuthorize)^0x4321;
//     dwAuthorize = dwAuthorize ^ dwEncryptCode;
//     NDDataTransThread::DefaultThread()->ChangeCode(dwAuthorize);

	NDDataTransThread::DefaultThread()->Stop();
	NDDataTransThread::ResetDefaultThread();
	return NDBeforeGameMgrObj.SwichKeyToServer(pszIp,nPort,pszAccountName,pszPwd,pszServerName);
}

///////////////////////////////////////////////
void SetRole(unsigned long ulLookFace, const char* pszRoleName, int nProfession)
{
//    NDBeforeGameMgrObj.SetRole(ulLookFace, pszRoleName, nProfession);///< 临时性注释 郭浩
}

///////////////////////////////////////////////
bool LoginByLastData(void)
{
//    return NDBeforeGameMgrObj.LoginByLastData();///< 临时性注释 郭浩
	return true;
}

//////////////////////////////////////////////
int GetAccountListNum(void)
{
//    return NDBeforeGameMgrObj.GetAccountListNum();///< 临时性注释 郭浩
	return 0;
}

//////////////////////////////////////////////
const char* GetRecAccountNameByIdx(int idx)
{
//    return NDBeforeGameMgrObj.GetRecAccountNameByIdx(idx);///< 临时性注释 郭浩
	return 0;
}

//////////////////////////////////////////////
const char* GetRecAccountPwdByIdx(int idx)
{
//    return NDBeforeGameMgrObj.GetRecAccountPwdByIdx(idx);///< 临时性注释 郭浩
	return 0;
}

void CreateRole(const char* pszName, Byte nProfession, int nLookFace,
		const char* pszAccountName)
{
	//   return NDBeforeGameMgrObj.CreateRole(pszName,nProfession, nLookFace, pszAccountName);///< 临时性注释 郭浩
}

const char* GetImagePathNew(const char* pszPath)
{
	return NDPath::GetImgPathNew(pszPath);
}

///////////////////////////////////////////////
void ScriptObjectGameLogic::OnLoad()
{
	ETCFUNC("QuitGame", QuitGame);
	ETCFUNC("CreatePlayer", CreatePlayer);
	ETCFUNC("PlayerStopMove", PlayerStopMove);
	ETCFUNC("GetImgPathNew", GetImagePathNew);
	ETCFUNC("GetPlayerId", GetPlayerId);
	ETCFUNC("SysChat", SysChat);
	ETCFUNC("NavigateTo", NavigateTo);
	ETCFUNC("NavigateToNpc", NavigateToNpc);
	ETCFUNC("ShowChat", ShowChat);
	ETCFUNC("GetMapId", GetMapId);
	ETCFUNC("GetCurrentMonsterRound", GetCurrentMonsterRound);
	ETCFUNC("GetSMImgPath", GetSMImgPath);
	ETCFUNC("GetSMResPath", GetSMResPath);
	ETCFUNC("GetMapLayer", GetMapLayer);
	ETCFUNC("restartLastBattle", restartLastBattle);
	ETCFUNC("GetPlayerLookface", GetPlayerLookface);
	ETCFUNC("WorldMapGoto", WorldMapGoto);
	ETCFUNC("GetRandomWords", &CSMLoginScene::GetRandomWords);
	ETCFUNC("CloseBattle", CloseBattle);
	//ETCFUNC("GetCurrentTime",GetCurrentTime); ///< 临时性注释 郭浩
	/*登陆部分*/
	ETCFUNC("FastRegister", FastRegister);
	ETCFUNC("GetFastAccount", GetFastAccount);
	ETCFUNC("GetFastPwd", GetFastPwd);
	ETCFUNC("SwichKeyToServer", SwichKeyToServer);
	ETCFUNC("SetRole", SetRole);
	ETCFUNC("LoginByLastData", LoginByLastData);
	ETCFUNC("GetAccountListNum", GetAccountListNum);
	ETCFUNC("GetRecAccountNameByIdx", GetRecAccountNameByIdx);
	ETCFUNC("GetRecAccountPwdByIdx", GetRecAccountPwdByIdx);
	ETCFUNC("AddChatInfoRecord", AddChatInfoRecord);
	ETCFUNC("AddAllRecord", AddAllRecord);
	ETCFUNC("SetCurrentChannel", SetCurrentChannel);
	//ETCFUNC("CreateRole",CreateRole);

	ETCFUNC("Int2StrIP",Int2StrIP);
	ETCFUNC("sendMsgConnect",sendMsgConnect);
}

//地图层接口导出
// ETCLASSBEGIN(NDMapLayer)
// ETMEMBERFUNC("setStartRoadBlockTimer",						&NDMapLayer::setStartRoadBlockTimer)
// ETMEMBERFUNC("setAutoBossFight",						&NDMapLayer::setAutoBossFight)	
// ETMEMBERFUNC("IsBattleBackground",						&NDMapLayer::IsBattleBackground)	
// ETMEMBERFUNC("ShowTreasureBox",							&NDMapLayer::ShowTreasureBox)
// ETCLASSEND(NDMapLayer)

