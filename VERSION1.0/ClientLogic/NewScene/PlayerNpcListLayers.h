/*
 *  PlayerNpcListLayers.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PLAYER_NPC_LIST_LAYERS_H_
#define _PLAYER_NPC_LIST_LAYERS_H_

#include "define.h"
#include "NDUILayer.h"
#include "NDUIButton.h"
#include "NDNpc.h"
#include "NDLightEffect.h"
#include "NewPlayerTask.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

enum CONTROL_BTN_TAG {
	eNpcBegin,
	eNpcTask,
	eNpcDaoHang,
	eNpcEnd,
	
	ePlayerBegin,
	ePlayerTrade,			// 交易
	ePlayerJoinTeam,		// 加入队伍
	ePlayerInviteTeam,	// 邀请组队
	ePlayerAddFriend,	// 添加好友
	ePlayerPrivateTalk,	// 私聊
	ePlayerPK,			// PK
	ePlayerReherse,		// 比武
	ePlayerWatchBattle,	// 观战
	ePlayerBaiShi,		// 拜师
	ePlayerShouTu,		// 收徒
	ePlayerMail,			// 邮件
	ePlayerInviteSyn,		// 军团邀请
	ePlayerEnd,
};

class NpcRole : public NDUINode {
	DECLARE_CLASS(NpcRole)
public:
	NpcRole();
	~NpcRole();
	
	void Initialization(NDNpc* npc);
	void Initialization(NDLightEffect* switchPoint);
	
	void draw();
private:
	// 新new的npc
	NDNpc* m_npc;
	// 由外部释放
	NDLightEffect* m_switchPoint;
};

class NpcNode : public NDUIButton {
	DECLARE_CLASS(NpcNode)
public:
	NpcNode();
	~NpcNode();
	
	void Initialization();
	void draw();
	
	void SetNpc(NDNpc* npc);
	
	void SetSwitchPoint(NDLightEffect* switchPoint);
	
	bool IsSwitchPoint() {
		return m_bSwitchPoint;
	}
	
private:
	NpcRole* m_npcRole;
	bool m_bSwitchPoint;
};

class NpcTaskLayer :
public NDUILayer
//public NDUITableLayerDelegate ///< 临时性注释 郭浩
{
	DECLARE_CLASS(NpcTaskLayer)
public:
	NpcTaskLayer();
	~NpcTaskLayer();
	
	void Initialization(vector<pair<int, string> >& vTasks);
	
	void OnTableLayerCellFocused(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);

	void ShowTaskInfo();
	
private:
	NDUILabel* m_lbTaskTitle;
	TaskDeal m_taskInfo;
	NDUITableLayer* m_tlTasks;
};

class PlayerNpcListScene;
class NpcListLayer :
public NDUIContainerHScrollLayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NpcListLayer)
public:
	static void processTaskList(NDTransData& data){}
	static void refreshNpcTaskInfo();
	
	NpcListLayer();
	~NpcListLayer();
	
	void Initialization(PlayerNpcListScene* npcListScene);
	
	void draw();
	
	void OnButtonClick(NDUIButton* button);
	
	void OnClickTab();
	
	bool OnClickTask();
	
	void OnClickDaoHang();
	
private:
	bool m_bNpcInit;
	
	NpcNode* m_focusNpcNode;
	
	NpcTaskLayer* m_npcTask;
	
	PlayerNpcListScene* m_npcListScene;
	
	static NpcListLayer* s_instance;
	
	NDLightEffect* m_switchPoint;
private:
	bool CanAutoPath();
	void ShowNpcTask(NDTransData& data);
	void ShowNpcTaskInfo();
	bool DirectNpc(NDNpc *npc);
};

class Item;
class ManualRole :
public NDUINode
{
	DECLARE_CLASS(ManualRole)
public:
	ManualRole();
	~ManualRole();
	
	void Initialization(NDManualRole* role); hide
	void draw(); override
	
	void uppackEquip(int iPos);
	void unpackAllEquip();
	void packEquip(int idEquipType);
	void SetOffset(CCPoint offset);
	void setFace(bool bRight);
	int getID();
	
private:
	NDManualRole		*m_role;
	
	CCPoint m_ptOffset;
};

class PlayerNode :
public NDUIButton
{
	DECLARE_CLASS(PlayerNode)
public:
	PlayerNode();
	~PlayerNode();
	
	void Initialization();
	void draw();
	
	void SetManualRole(NDManualRole* role);
	
private:
	ManualRole* m_role;
};

class PlayerNpcListScene;
class PlayerListLayer :
public NDUIContainerHScrollLayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(PlayerListLayer)
public:
	PlayerListLayer();
	~PlayerListLayer();
	
	void Initialization(PlayerNpcListScene* scene);
	
	void draw();
	
	void OnButtonClick(NDUIButton* button);
	
	void OnClickControl(int tag);
	
private:
	PlayerNode* m_focusPlayer;
	PlayerNpcListScene* m_parentScene;
	
private:
	bool IsPlayerStillThere(int idPlayer);
};

#endif // _PLAYER_NPC_LIST_LAYERS_H_