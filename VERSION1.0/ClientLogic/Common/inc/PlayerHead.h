/*
 *  PlayerHead.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-16.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __PLAYER_HEAD_H__
#define __PLAYER_HEAD_H__

#include "ImageNumber.h"
#include "NDPicture.h"
#include "define.h"
//#include "NDPlayer.h"
#include "NDLayer.h"
//#include "Fighter.h"
#include "NDUIButton.h"
//#include "NDBattlePet.h"
#include "..\..\MapAndRole\inc\NDManualRole.h"

using namespace NDEngine;

class HeadNode : public NDNode {
	DECLARE_CLASS(HeadNode)
public:
	HeadNode(NDManualRole* role, bool bBattle, bool drawInClipPos=false);
	
	~HeadNode();
	
	void draw();
	
	void drawOfClipPos();
	
	void SetPos(CGPoint pos) {
		this->m_pos = pos;
	}
	
	void SetRole(NDManualRole* role);
	
protected:
	HeadNode() { m_drawInClipPos = false; }
	
private:
	NDManualRole* m_role;
	bool m_bBattle, m_drawInClipPos;
	
	CGPoint m_pos;
};


class TargetHeadNode : public NDNode
{
	DECLARE_CLASS(TargetHeadNode)
public:
	TargetHeadNode();
	~TargetHeadNode();
	
	void draw();
	
	void SetTargetRole(bool bNpc, int idRole) {
		this->m_bNpc = bNpc;
		this->m_idRole = idRole;
	}
	
private:
	bool m_bNpc;
	int m_idRole;
};

// 绘制玩家头像
// class PlayerHead : public NDLayer
// {
// 	DECLARE_CLASS(PlayerHead)
// public:
// 	PlayerHead(NDManualRole* role);
// 	~PlayerHead();
// 	
// 	// 战斗内使用传入玩家fighter
// 	void Initialization(bool bBattle);
// 	void draw(); override
// 	
// 	void SetBattlePlayer(Fighter* player) {
// 		this->m_player = player;
// 	}
// 	
// protected:
// 	PlayerHead() {}
// 	
// private:
// // 	ImageNumber* m_imgNumHp; // 玩家hp
// // 	ImageNumber* m_imgNumMp; // 玩家mp
// // 	ImageNumber* m_imgNumPlayerLevel;
// 	
// 	NDUIImage* m_imgHp;
// 	NDUIImage* m_imgMp;
// 	
// 	Fighter* m_player;
// 	
// 	bool m_bBattle;
// 	NDManualRole* m_role;
// 	
// private:
// 	
// 	void drawInMap();
// 	void drawInBattle();
// };

// 绘制宠物头像
class PetHead : public NDLayer 
{
	DECLARE_CLASS(PetHead)
public:
	PetHead();
	~PetHead();
	void Initialization(Fighter* pet);
	void draw(); override
	
private:
	Fighter* m_pet;
	//NDBattlePet *m_battlepet;
	
	//ImageNumber* m_imgNumHp;
	//ImageNumber* m_imgNumMp;
	//ImageNumber* m_imgNumLevel;
	
	NDUIImage* m_imgHp;
	NDUIImage* m_imgMp;
	
private:
	void drawInMap();
	void drawInBattle();
};

/***
* 临时性注释 郭浩
* this class
*/
// class PlayerHeadInMap : public NDUILayer
// {
// 	DECLARE_CLASS(PlayerHeadInMap)
// public:
// 	PlayerHeadInMap(NDPlayer* role);
// 	PlayerHeadInMap(NDBattlePet *battlepet);
// 	void ChangeBattlePet(NDBattlePet *battlepet);
// 	~PlayerHeadInMap();
// 	
// 	void Initialization();
// 	void draw(); override
// 	
// 	void SetShrink(bool bShrink);
// 	
// 	bool TouchEnd(NDTouch* touch);
// 	
// protected:
// 	PlayerHeadInMap() {}
// 	
// private:
// 	
// 	enum SHOW_STATUS {
// 		SS_SHOW,
// 		SS_SHRINKING,
// 		SS_EXTENDING,
// 		SS_HIDE,
// 	};
// 	
// 	bool m_bHasBattlepet;
// 	
// //	ImageNumber* m_imgNumPlayerLevel; ///< 临时性注释 郭浩
// 	
// 	NDUIImage* m_imgHp;
// 	NDUIImage* m_imgMp;
// 	NDUILayer* m_imgExp;
// 	
// 	NDPlayer* m_role;
// 	
// 	CAutoLink<NDBattlePet> m_battlepet;
// 	
// 	HeadNode* m_head;
// 	
// 	CGRect m_rectBase;
// 	
// 	CGRect m_rectHide;
// 	
// 	CGPoint m_ptHeadNode;
// 	
// 	SHOW_STATUS m_showStatus;
// };

/***
* 临时性注释 郭浩
* this class
*/
// class TargetHeadInMap : public NDUILayer
// {
// 	DECLARE_CLASS(TargetHeadInMap)
// public:
// 	TargetHeadInMap();
// 	~TargetHeadInMap();
// 	
// 	void Initialization(); override
// 	void draw(); override
// 	
// 	bool TouchEnd(NDTouch* touch);
// 	
// 	//void SetRole(NDBaseRole* role); ///< 临时性注释 郭浩
// 	
// protected:
// 	
// private:
// 	// npc 不显示等级
// //	ImageNumber* m_imgNumPlayerLevel; ///< 临时性注释 郭浩
// 	
// 	// npc 血蓝全满
// 	NDUILayer* m_imgHp;
// 	NDUILayer* m_imgMp;
// 	
// 	// 目标id
// 	int m_idRole;
// 	// 是npc还是玩家
// 	bool m_bNpc;
// 	// 玩家及人形npc显示头像
// 	TargetHeadNode* m_head;
// 	// 其余用统一的资源显示
// 	NDUIImage* m_imgHead;
// };

class TeamRoleButton : public NDUIButton
{
	DECLARE_CLASS(TeamRoleButton)
	
	TeamRoleButton();
	
	~TeamRoleButton();
	
public:
	void Initialization(); override
	
	void draw(); override
	
	void SetVisible(bool visible); override
	 
	void SetRole(int teamId, int index);
	
	void GetTeamRole(int& teamId, int& index);
	
private:
	// npc 血蓝全满
	NDUILayer* m_imgHp;
	NDUILayer* m_imgMp;
	
	HeadNode		*m_head;
	
	NDUILabel		*m_lbName;
	
//	ImageNumber		*m_imgNumPlayerLevel; ///< 临时性注释 郭浩
	
	int				m_iTeamID;
	int				m_iIndexInTeam;
};

#endif