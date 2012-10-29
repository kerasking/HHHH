/*
 *  BattleMgr.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
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
#import "Fighter.h"
#import "Drama.h"

using std::map;
using namespace NDEngine;

#define BattleMgrObj BattleMgr::GetSingleton()

typedef map<OBJID, BattleSkill*> MAP_BATTLE_SKILL;
typedef MAP_BATTLE_SKILL::iterator MAP_BATTLE_SKILL_IT;

class Battle;
struct Command;

enum FIGHT_ACTION_STATUS 
{
	ACTION_STATUS_NONE=ID_NONE,
	ACTION_STATUS_WAIT,
	ACTION_STATUS_PLAY,
	ACTION_STATUS_FINISH,
};

//战斗奖励
class BattleReward{
public:
	BattleReward()
	{
		money=0;
		emoney=0;
		repute=0;
		exp=0;
        soph = 0;

		for (int i=0;i<5;i++)
		{
			itemtype[i]=0;
			item_amount[i]=0;
		}
        
        for (int i=0;i<5;i++)
		{
			iPetId[i]=0;
			iPetGainExp[i]=0;
		}
        
        //mSoldExp.clear();
	}
	
	void addItem(int itemType,int amount)
	{
		for(int i=0;i<5;i++)
		{
			if (itemtype[i]==0)
			{
				itemtype[i]=itemType;
				item_amount[i]=amount;
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
        money   = other.money;
        emoney = other.emoney;
        repute   = other.repute;
        soph     = other.soph;
        exp        = other.exp;
        battleResult = other.battleResult;
    
        for (int i=0;i<5;i++)
        {
            itemtype[i]           =  other.itemtype[i] ;
            item_amount[i]   =  other.item_amount[i] ;
        } 
        
        for (int i=0; i<5; i++)
		{
			iPetId[i] = other.iPetId[i];
			iPetGainExp[i] = other.iPetGainExp[i];
		}
        //mSoldExp = other.mSoldExp;
    
        return *this;
    }
    //add end
public:
	int money;
	int emoney;
	int repute;
    int soph;
	int exp;
	int itemtype[5];
	int item_amount[5];
   
	int iPetId[5];                         //人物id
	int iPetGainExp[5];             //人物获得的经验数
    
	int battleResult;
    
    //map<int, int> mSoldExp; //出战的将士与经验对
};

enum FIGHTER_ROLE_ANI {
	ROLE_ANI_NONE=ID_NONE,
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
	int team_Atk;
	int team_def;
	
	Fighter* m_Actor;
	Fighter* m_Target;
	BATTLE_EFFECT_TYPE effect_type;
	FIGHT_ACTION_STATUS action_status;
	int data;
	bool isCombo;
    bool isCriticalHurt;
	bool isDritical;
	VEC_FIGHTER m_FighterList;
	FightAction(Fighter* f1,Fighter* f2,BATTLE_EFFECT_TYPE type)
	{
		m_Actor=f1;
		m_Target=f2;
		effect_type=type;
		action_status=ACTION_STATUS_WAIT;
		isCombo=false;
		skill=NULL;
	}
	
	FightAction(int team1,int team2,BATTLE_EFFECT_TYPE type)
	{
		m_Actor=NULL;
		m_Target=NULL;
		team_Atk=team1;
		team_def=team2;
		effect_type=type;
		action_status=ACTION_STATUS_WAIT;
		isCombo=false;
        isCriticalHurt=false;
		isDritical=false;
		skill=NULL;
	}
	VEC_FIGHTERCOMMAND m_vCmdList;
	void addCommand(FIGHTER_CMD* cmd){
		m_vCmdList.push_back(cmd);
	}
	BattleSkill* skill;
	FighterStatus* status;
};

typedef vector<FightAction*> VEC_FIGHTACTION;
typedef VEC_FIGHTACTION::iterator VEC_FIGHTACTION_IT;

class BattleMgr : public TSingleton<BattleMgr>, public NDMsgObject, public ITimerCallback
{
public:
	BattleMgr();
	~BattleMgr();
	virtual bool process(MSGID msgID, NDEngine::NDTransData* bao, int len);
	// 退出战斗
	void quitBattle(bool bEraseOut=true);
	void loadRewardUI();
	BattleSkill* GetBattleSkill(OBJID idSkill);
	void ReleaseAllBattleSkill();
	MAP_BATTLE_SKILL& GetBattleSkills() { return m_mapBattleSkill; }
	
	Battle* GetBattle() {
		return this->m_battle;
	}
	void showBattleScene();
	void OnTimer(OBJID tag); override
	void OnDramaFinish(); override
	void restartLastBattle();
	void showBattleResult();
	BattleReward* GetBattleReward(){return battleReward;}
	VEC_FIGHTACTION m_vActionList1;//1队战斗指令
	VEC_FIGHTACTION m_vActionList2;//2队战斗指令
	VEC_FIGHTACTION m_vActionList3;//3队战斗指令
    
    
    void BattleContinue();//剧情返回 战斗继续
    
public:   
    void SetBattleOver(void);
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
	Battle* m_battle;
	ScriptDB* m_Db;
	Command* cmdBefore;
	// 技能配置信息
	MAP_BATTLE_SKILL m_mapBattleSkill;
	CSMBattleScene* battleScene;
	NDTimer *m_quitTimer;
    NDTimer *m_startDramaTimer;
	int m_CurrentTeamId;
	
	BattleReward* battleReward;
    BattleReward* prebattleReward;   //记录最近一次的信息

	VEC_FIGHTER m_vFighter;
	
	int battleMapId;
	int battleX;
	int battleY;
	int lastBattleType;
	int lastBattleTeamCount;
	
	//进入战斗前的场景地图数据ID及窗口位置备份//++Guosen 2012.7.5
	int m_iLastSceneMapDocID;
	int m_iLastSceneScreenX;
	int m_iLastSceneScreenY;
    
private:
    //处理显示战斗胜利的结果 （包括副本战斗以及竞技场战斗）
    void ShowBattleWinResult(int nBattleType);
    //处理显示战斗失败的结果 （包括副本战斗以及竞技场战斗）
    void ShowBattleLoseResult(int nBattleType);	
    //处理显示战斗胜利回放的结果 （包括副本战斗以及竞技场战斗）
    void ShowReplayWinResult(int nBattleType);	
    //处理显示战斗失败回放的结果 （包括副本战斗以及竞技场战斗）
    void ShowReplayLoseResult(int nBattleType);	
};

#endif