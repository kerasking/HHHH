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

using std::map;
using namespace NDEngine;

#define BattleMgrObj BattleMgr::GetSingleton()

typedef map<OBJID, BattleSkill*> MAP_BATTLE_SKILL;
typedef MAP_BATTLE_SKILL::iterator MAP_BATTLE_SKILL_IT;

class Battle;
struct Command;

enum FIGHT_ACTION_STATUS
{
	ACTION_STATUS_NONE = ID_NONE,
	ACTION_STATUS_WAIT,
	ACTION_STATUS_PLAY,
	ACTION_STATUS_FINISH,
};

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

		for (int i = 0; i < 5; i++)
		{
			m_nItemTypes[i] = 0;
			m_nItemAmount[i] = 0;
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
public:
	int m_nMoney;
	int m_nEMoney;
	int m_nRepute;
	int m_nEXP;
	int m_nItemTypes[5];
	int m_nItemAmount[5];
	int m_nBattleResult;
};

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
		memset(this, 0L, sizeof(FIGHTER_CMD));
	}

	~FIGHTER_CMD()
	{

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

class FightAction
{
public:
	int m_nTeamAttack;
	int m_nTeamDefense;

	Fighter* m_pkActor;
	Fighter* m_pkTarget;
	BATTLE_EFFECT_TYPE m_eEffectType;
	FIGHT_ACTION_STATUS m_eActionStatus;
	int m_nData;
	bool m_bIsCombo;
	VEC_FIGHTER m_kFighterList;
	FightAction(Fighter* f1, Fighter* f2, BATTLE_EFFECT_TYPE type)
	{
		m_pkActor = f1;
		m_pkTarget = f2;
		m_eEffectType = type;
		m_eActionStatus = ACTION_STATUS_WAIT;
		m_bIsCombo = false;
		m_pkSkill = NULL;
	}

	FightAction(int team1, int team2, BATTLE_EFFECT_TYPE type)
	{
		m_pkActor = NULL;
		m_pkTarget = NULL;
		m_nTeamAttack = team1;
		m_nTeamDefense = team2;
		m_eEffectType = type;
		m_eActionStatus = ACTION_STATUS_WAIT;
		m_bIsCombo = false;
		m_pkSkill = NULL;
	}
	VEC_FIGHTERCOMMAND m_vCmdList;
	void addCommand(FIGHTER_CMD* cmd)
	{
		m_vCmdList.push_back(cmd);
	}
	BattleSkill* m_pkSkill;
	FighterStatus* m_pkStatus;
};

typedef vector<FightAction*> VEC_FIGHTACTION;
typedef VEC_FIGHTACTION::iterator VEC_FIGHTACTION_IT;

class BattleMgr: public TSingleton<BattleMgr>,
		public NDMsgObject,
		public ITimerCallback
{
public:
	BattleMgr();
	~BattleMgr();
	virtual bool process(MSGID msgID, NDEngine::NDTransData* bao, int len);
	// 退出战斗
	void quitBattle(bool bEraseOut = true);

	BattleSkill* GetBattleSkill(OBJID idSkill);
	void ReleaseAllBattleSkill();
	MAP_BATTLE_SKILL& GetBattleSkills()
	{
		return m_mapBattleSkill;
	}

	Battle* GetBattle()
	{
		return this->m_pkBattle;
	}
	void showBattleScene();
	void OnTimer(OBJID tag);override
	void restartLastBattle();
	void showBattleResult();
	BattleReward* GetBattleReward()
	{
		return m_pkBattleReward;
	}
	VEC_FIGHTACTION m_vActionList1; //1队战斗指令
	VEC_FIGHTACTION m_vActionList2; //2队战斗指令
	VEC_FIGHTACTION m_vActionList3; //3队战斗指令
private:

	void processBattleStart(NDEngine::NDTransData& bao);
	void processControlPoint(NDEngine::NDTransData& bao);
	void processBattleEffect(NDEngine::NDTransData& bao);
	void processBattleEnd(NDEngine::NDTransData& bao);
	void processSkillInfo(NDTransData& data, int len);
	void processBattleSkillList(NDTransData& data, int len);
	void closeUI();
	void ReleaseActionList();
	void RestoreActionList();
private:
	Battle* m_pkBattle;
	ScriptDB* m_pkDatabase;
	Command* m_pkBeforeCommand;
	// 技能配置信息
	MAP_BATTLE_SKILL m_mapBattleSkill;
	CSMBattleScene* m_pkBattleScene;
	NDTimer* m_pkQuitTimer;
	int m_nCurrentTeamId;

	BattleReward* m_pkBattleReward;

	VEC_FIGHTER m_vFighter;

	int m_nBattleMapId;
	int m_nBattleX;
	int m_nBattleY;
	int m_nLastBattleType;
	int m_nLastBattleTeamCount;
};

#endif
