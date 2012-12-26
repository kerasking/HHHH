/*
 *  BattleMgr.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __BATTLE_MGR_H__
#define __BATTLE_MGR_H__

#include <algorithm>
#include "Singleton.h"
#include "define.h"
#include "EnumDef.h"
#include "NDNetMsg.h"
#include "BattleSkill.h"
#include "NDTransData.h"
#include "NDTimer.h"
#include "ScriptDataBase.h"
#include "SMBattleScene.h"
#include "Fighter.h"
#include "NDBaseBattleMgr.h"
#include "ObjectTracker.h"

using namespace std;
using namespace NDEngine;

#define BattleMgrObj BattleMgr::GetBattleMgr()

typedef map<OBJID, BattleSkill*> MAP_BATTLE_SKILL;
typedef MAP_BATTLE_SKILL::iterator MAP_BATTLE_SKILL_IT;

class BattleUILayer;
struct Command;

enum FIGHT_ACTION_STATUS
{
	ACTION_STATUS_NONE = ID_NONE,
	ACTION_STATUS_WAIT,
	ACTION_STATUS_PLAY,
	ACTION_STATUS_FINISH,
};


//----------------------------------------------------------------------
//战斗奖励
class BattleReward
{
public:
	BattleReward()
	{
		m_nMoney = 0;
		m_nEMoney = 0;
		m_nRepute = 0;
		m_nEXP = 0;
		m_nSoph = 0;
		m_nBattleResult = 0;

		for (int i = 0; i < 5; i++)
		{
			m_nItemTypes[i] = 0;
			m_nItemAmount[i] = 0;
		}

		for (int i = 0; i < 5; i++)
		{
			m_nPetId[i] = 0;
			m_nPetGainExp[i] = 0;
		}
	}

	void addItem(int itemType, int amount)
	{
		for (int i = 0; i < 5; i++)
		{
			if (m_nItemTypes[i] == 0)
			{
				m_nItemTypes[i] = itemType;
				m_nItemAmount[i] = amount;
				return;
			}
		}
	}
	//add by tangziqin 2012.7.21
	BattleReward &operator = (const BattleReward &other)
	{
		if(this == &other)
		{
			return *this;
		}

		m_nMoney   = other.m_nMoney;
		m_nEMoney = other.m_nEMoney;
		m_nRepute   = other.m_nRepute;
		m_nSoph     = other.m_nSoph;
		m_nEXP        = other.m_nEXP;
		m_nBattleResult = other.m_nBattleResult;

		for (int i = 0; i < 5; i++)
		{
			m_nItemTypes[i] = other.m_nItemTypes[i] ;
			m_nItemAmount[i] = other.m_nItemAmount[i] ;
		} 

		for (int i = 0; i < 5; i++)
		{
			m_nPetId[i] = other.m_nPetId[i];
			m_nPetGainExp[i] = other.m_nPetGainExp[i];
		}

		return *this;
	}
	//add end
public:
	int m_nMoney;
	int m_nEMoney;
	int m_nRepute;
	int m_nSoph;
	int m_nEXP;
	int m_nItemTypes[5];
	int m_nItemAmount[5];

	int m_nPetId[5];                         //人物id
	int m_nPetGainExp[5];             //人物获得的经验数

	int m_nBattleResult;
};
//----------------------------------------------------------------------


enum FIGHTER_ROLE_ANI
{
	ROLE_ANI_NONE = ID_NONE,
	ROLE_ANI_HURT,
	ROLE_ANI_DODGE,
	ROLE_ANI_BLOCK,
};

struct FIGHTER_CMD
{
	FIGHTER_CMD()
	{
		INC_NDOBJ("FIGHTER_CMD");
		memset(this, 0L, sizeof(FIGHTER_CMD));
	}

	~FIGHTER_CMD()
	{
		DEC_NDOBJ("FIGHTER_CMD");
	}

	BATTLE_EFFECT_TYPE effect_type;
	FIGHTER_ROLE_ANI role_ani;
	int actor;
	FighterStatus* status;
	int data;
};

typedef vector<FIGHTER_CMD*> VEC_FIGHTERCOMMAND;
typedef VEC_FIGHTERCOMMAND::iterator VEC_FIGHTERCOMMAND_IT;

typedef vector<Fighter*> VEC_FIGHTER;
typedef VEC_FIGHTER::iterator VEC_FIGHTER_IT;

//----------------------------------------------------------------------
class FightAction
{
public:
	int m_nTeamAttack;
	int m_nTeamDefense;

	BATTLE_EFFECT_TYPE m_eEffectType;
	FIGHT_ACTION_STATUS m_eActionStatus;
	
	int m_nData;
	bool m_bIsCombo;
	bool m_bIsCriticalHurt;
	bool m_bIsDritical;

	Fighter* m_pkActor;
	Fighter* m_pkTarget;

	BattleSkill* m_pkSkill; //@free
	FighterStatus* m_pkStatus;

	VEC_FIGHTER m_kFighterList;
	VEC_FIGHTERCOMMAND m_vCmdList; //@free

	void init()
	{
		m_nTeamAttack = 0;
		m_nTeamDefense = 0;
		m_pkActor = NULL;
		m_pkTarget = NULL;
		m_eEffectType = BATTLE_EFFECT_TYPE_NONE;
		m_eActionStatus = ACTION_STATUS_NONE;
		m_nData = 0;
		m_bIsCombo = false;
		m_bIsCriticalHurt = false;
		m_bIsDritical = false;
		m_pkSkill = NULL;
		m_pkStatus = NULL;
	}

	~FightAction()
	{
		DEC_NDOBJ("FightAction");
	}

	FightAction(Fighter* f1, Fighter* f2, BATTLE_EFFECT_TYPE type)
	{
		INC_NDOBJ("FightAction");

		this->init();

		m_pkActor = f1;
		m_pkTarget = f2;
		m_eEffectType = type;
		m_eActionStatus = ACTION_STATUS_WAIT;
		m_bIsCombo = false;
		m_pkSkill = NULL;
	}

	FightAction(int team1, int team2, BATTLE_EFFECT_TYPE type)
	{
		INC_NDOBJ("FightAction");

		this->init();

		m_pkActor = NULL;
		m_pkTarget = NULL;
		m_nTeamAttack = team1;
		m_nTeamDefense = team2;
		m_eEffectType = type;
		m_eActionStatus = ACTION_STATUS_WAIT;
		m_bIsCombo = false;
		m_bIsCriticalHurt = false;
		m_bIsDritical = false;
		m_pkSkill = NULL;
	}

	void addCommand(FIGHTER_CMD* cmd)
	{
		if (cmd)
			m_vCmdList.push_back(cmd);
	}
};

typedef vector<FightAction*> VEC_FIGHTACTION;
typedef VEC_FIGHTACTION::iterator VEC_FIGHTACTION_IT;


//----------------------------------------------------------------------
class BattleMgr : public NDBaseBattleMgr
{
public:
	BattleMgr();
	~BattleMgr();
	static BattleMgr& GetBattleMgr();

public:
	virtual bool process(MSGID msgID, NDEngine::NDTransData* bao, int len);
	void dumpBao(MSGID msgID, NDEngine::NDTransData* bao, int len);

	// 退出战斗
	void quitBattle(bool bEraseOut = true);
	void loadRewardUI();
	BattleSkill* GetBattleSkill(OBJID idSkill);
	void ReleaseAllBattleSkill();

	MAP_BATTLE_SKILL& GetBattleSkills()
	{
		return m_mapBattleSkill;
	}

	BattleUILayer* GetBattle()
	{
		return this->m_pkBattle;
	}

	void showBattleScene();
	void OnTimer(OBJID tag);override
	void OnDramaFinish(); override
	void restartLastBattle();
	void showBattleResult();

	BattleReward* GetBattleReward()
	{
		return m_pkBattleReward;
	}
	
	void BattleContinue();//剧情返回 战斗继续

	void SetBattleOver(void);

	string getEffectName( BATTLE_EFFECT_TYPE eType );

private:
	void processBattleStart(NDEngine::NDTransData& bao);
	void processControlPoint(NDEngine::NDTransData& bao);
	void processBattleEffect(NDEngine::NDTransData& bao);
	void processBattleEnd(NDEngine::NDTransData& bao);
	void processSkillInfo(NDTransData& data, int len);
	void processBattleSkillList(NDTransData& data, int len);
	void closeUI();
	void ReleaseActionList();
	void ReleaseActionList_Imp( VEC_FIGHTACTION& vecFightAction );
	void RestoreActionList();
	void destroyFighters();
	void cleanup();

private:
	//处理显示战斗胜利的结果 （包括副本战斗以及竞技场战斗）
	void ShowBattleWinResult(int nBattleType);

	//处理显示战斗失败的结果 （包括副本战斗以及竞技场战斗）
	void ShowBattleLoseResult(int nBattleType);	

	//处理显示战斗胜利回放的结果 （包括副本战斗以及竞技场战斗）
	void ShowReplayWinResult(int nBattleType);	

	//处理显示战斗失败回放的结果 （包括副本战斗以及竞技场战斗）
	void ShowReplayLoseResult(int nBattleType);

public:
	VEC_FIGHTACTION m_vActionList1; //1队战斗指令
	VEC_FIGHTACTION m_vActionList2; //2队战斗指令
	VEC_FIGHTACTION m_vActionList3; //3队战斗指令

private:
	BattleUILayer*	m_pkBattle;
	ScriptDB*		m_pkDatabase;
	Command*		m_pkBeforeCommand;

	CSMBattleScene* m_pkBattleScene;
	NDTimer*		m_pkQuitTimer;
	NDTimer*		m_pkStartDramaTimer;

	BattleReward*	m_pkBattleReward;
	BattleReward*	m_pkPrebattleReward;   //记录最近一次的信息

	int m_nCurrentTeamId;
	int m_nBattleMapId;
	int m_nBattleX;
	int m_nBattleY;
	int m_nLastBattleType;
	int m_nLastBattleTeamCount;

	//进入战斗前的场景地图数据ID及窗口位置备份//++Guosen 2012.7.5
	int m_nLastSceneMapDocID;
	int m_nLastSceneScreenX;
	int m_nLastSceneScreenY;

	// 技能配置信息
	MAP_BATTLE_SKILL	m_mapBattleSkill;
	VEC_FIGHTER			m_vFighter;
};

#endif
