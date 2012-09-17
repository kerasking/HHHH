/*
 *  Fighter.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-19.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __FIGHTER_H__
#define __FIGHTER_H__

#include "Hurt.h"
#include "EnumDef.h"
#include "define.h"
#include "NDBaseRole.h"
#include "NDManualRole.h"
#include <string>
#include <vector>
#include "ImageNumber.h"
#include <set>
#include "BattleSkill.h"
#include "NDSprite.h"
#include "NDSubAniGroup.h"
#include <map>

using namespace std;
using namespace NDEngine;

enum ACTION_WORD
{
	AW_DEF,
	AW_DODGE,
	AW_FLEE,
};

enum LOOKFACE_TYPE
{
	LOOKFACE_NONE = 0,
	LOOKFACE_MANUAL,
	LOOKFACE_MONSTER,
};

class Battle;

typedef struct _FIGHTER_INFO
{
	_FIGHTER_INFO()
	{
		::memset(this, 0L, sizeof(_FIGHTER_INFO));
	}

	int idObj;
	int idType;
	int idlookface;
	Byte btBattleTeam;
	Byte btStations;
	FIGHTER_TYPE fighterType; // 玩家，怪物,幻兽
	BATTLE_GROUP group;
	int original_life;
	int nLife;
	int nLifeMax;
	int nMana;
	int nManaMax;
	short level;
} FIGHTER_INFO;

class FighterStatus
{
public:
	FighterStatus()
	{
		m_nID = 0;
		m_nStartEffectID = 0;
		m_nLastEffectID = 0;
		m_pkAniGroup = NULL;
	}

	FighterStatus(int id, int startEffectID, int lastEffectID)
	{
		m_nID = id;
		m_nStartEffectID = startEffectID;
		m_nLastEffectID = lastEffectID;
		m_pkAniGroup = NULL;
	}

	FighterStatus(const FighterStatus& rhs)
	{
		m_nID = rhs.m_nID;
		m_nStartEffectID = rhs.m_nStartEffectID;
		m_nLastEffectID = rhs.m_nLastEffectID;
		m_pkAniGroup = NULL;
	}

	FighterStatus& operator =(const FighterStatus& rhs)
	{
		m_nID = rhs.m_nID;
		m_nStartEffectID = rhs.m_nStartEffectID;
		m_nLastEffectID = rhs.m_nLastEffectID;
		m_pkAniGroup = NULL;
		return *this;
	}

	~FighterStatus()
	{
		CC_SAFE_DELETE(m_pkAniGroup);
	}

public:
	int m_nID;
	int m_nStartEffectID;
	int m_nLastEffectID;
	NDSubAniGroup* m_pkAniGroup;
};

//struct FIGHTER_CMD
//{
//	FIGHTER_CMD()
//	{
//		memset(this, 0L, sizeof(FIGHTER_CMD));
//	}
//	
//	~FIGHTER_CMD()
//	{
//		
//	}
//	
//	BATTLE_EFFECT_TYPE effect_type;
//	int actor;
//	FighterStatus* status;
//	int data;
//};

typedef vector<FighterStatus*> VEC_FIGHTER_STATUS;
typedef VEC_FIGHTER_STATUS::iterator VEC_FIGHTER_STATUS_IT;
//typedef vector<FIGHTER_CMD*> VEC_COMMAND;
//typedef VEC_COMMAND::iterator VEC_COMMAND_IT;

class StatusAction
{
public:
	enum
	{
		ADD_STATUS = 0, CANCEL_STATUS = 1,
	};

	StatusAction(int act, FighterStatus* fs, int id) :
		m_pkStatus(fs)
	{
		m_nAction = act;
		m_nTargetID = id;
	}

	int m_nAction;
	FighterStatus* m_pkStatus;
	int m_nTargetID;
};

typedef set<string> SET_STATUS_PERSIST;
typedef SET_STATUS_PERSIST::iterator SET_STATUS_PERSIST_IT;

typedef vector<Hurt> VEC_HURT;
typedef VEC_HURT::iterator VEC_HURT_IT;

typedef vector<int> VEC_PAS_STASUS; // 被施加的被动状态
typedef VEC_PAS_STASUS::iterator VEC_PAS_STASUS_IT;

typedef vector<HurtNumber> VEC_HURT_NUM;
typedef VEC_HURT_NUM::iterator VEC_HURT_NUM_IT;

typedef pair<bool/*bFind*/, Hurt> PAIR_GET_HURT;

typedef vector<StatusAction> VEC_STATUS_ACTION;
typedef VEC_STATUS_ACTION::iterator VEC_STATUS_ACTION_IT;

int countX(int teamAmount, BATTLE_GROUP group, int team, int pos);
int countY(int teamAmount, BATTLE_GROUP group, int team, int pos);

class Fighter
{
public:
	enum FIGHTER_ACTION
	{
		WAIT = 0,
		MOVETOTARGET = 1,
		ATTACK = 2,
		MOVEBACK = 3,
		AIMTARGET = 4,
		DISTANCEATTACK = 5,
		DISTANCEATTACKOVER = 6,
		DEFENCE = 7,
		WEAK = 8,
		FLEE_FAIL = 9,
		FLEE_SUCCESS = 10,
		DISTANCESKILLATTACK = 11,
		SKILLATTACK = 12,
		USEITEM = 13,
		CATCH_PET = 14,
	};

	enum ACTION_TYPE
	{
		ACTION_TYPE_NORMALATK = 0,
		ACTION_TYPE_SKILLATK = 1,
		ACTION_TYPE_USEITEM = 2,
		ACTION_TYPE_CATCH = 3,
		ACTION_TYPE_PROTECT,
	};

public:
	Fighter(const FIGHTER_INFO& fInfo);
	~Fighter();
	int m_nTargetX;
	int m_nTargetY;
	LOOKFACE_TYPE m_eLookfaceType;
	BATTLE_GROUP GetGroup() const
	{
		return m_kInfo.group;
	}
	void SetRole(NDBaseRole* role);
	void LoadMonster(int nLookFace, int lev, const string& name);
	void LoadRole(int nLookFace, int lev, const string& name);
	NDBaseRole* GetRole() const
	{
		return m_pkRole;
	}

	void setPosition(int offset);
	void updatePos();
	void draw();

//	void AddCommand(FIGHTER_CMD* cmd);

	void setOnline(bool bOnline);

	int GetNormalAtkType() const
	{
		return m_nNormalAtkType;
	}

	void AddAHurt(Fighter* actor, int btType, int hurtHP, int hurtMP,
			int dwData, HURT_TYPE ht);
	void AddAStatusTarget(StatusAction& f);
	void AddATarget(Fighter* f);

	VEC_FIGHTER& getArrayTarget()
	{
		return this->m_vTarget;
	}

	VEC_STATUS_ACTION& getArrayStatusTarget()
	{
		return this->m_kArrayStatusTarget;
	}

	void AddPasStatus(int dwData);
	PAIR_GET_HURT getHurt(Fighter* actor, int btType, int dwData, int type);

	int getActionTime()
	{
		return m_nActionTime;
	}

	void setActionTime(int waitToActionTime)
	{
		m_nActionTime = waitToActionTime;
	}

	void actionTimeIncrease()
	{
		if (m_nActionTime != 0)
		{
			m_nActionTime++;
		}
	}

	void removeAStatusAniGroup(FighterStatus* status);

	bool isActionOK()
	{
		return m_bIsActionOK;
	}

	void setActionOK(bool bOK)
	{
		this->m_bIsActionOK = bOK;
	}

	void setBeginAction(bool bBegin)
	{
		m_bBeginAction = bBegin;
		m_nActionTime = 1;
	}

	bool isBeginAction()
	{
		return m_bBeginAction;
	}

	bool isVisiable();

	bool isCatchable();

	bool isAlive()
	{
		return m_bIsAlive;
	}

	void setAlive(bool a)
	{
		this->m_bIsAlive = a;
	}

	bool isEscape()
	{
		return m_bIsEscape;
	}

	void setEscape(bool esc);

	bool isHurtOK()
	{
		return m_bIsHurtOK;
	}

	void setHurtOK(bool htOK)
	{
		m_bIsHurtOK = htOK;
	}

	bool isDodgeOK()
	{
		return m_bIsDodgeOK;
	}

	void setDodgeOK(bool bOK)
	{
		m_bIsDodgeOK = bOK;
	}

	bool isDefenceOK()
	{
		return m_bIsDefenceOK;
	}

	void setDefenceOK(bool bOK)
	{
		m_bIsDefenceOK = bOK;
	}
	void setOriginPos(int x, int y)
	{
		m_nOriginX = x;
		m_nOriginY = y;
	}

	bool isDieOK()
	{
		return m_bIsDieOK;
	}

	void setDieOK(bool bOK);

	BattleSkill* getUseSkill()
	{
		return &m_kUseSkill;
	}

	void setUseSkill(BattleSkill* skill)
	{
		m_kUseSkill = *skill;
	}

	ATKTYPE getSkillAtkType()
	{
		return m_eSkillAtkType;
	}

	void setSkillAtkType(ATKTYPE atkType)
	{
		m_eSkillAtkType = atkType;
	}

	bool completeOneAction();

	bool moveTo(int tx, int ty);

	int getX()
	{
		return m_nX;
	}
	int getY()
	{
		return m_nY;
	}

	int getOriginX()
	{
		return m_nOriginX;
	}

	int getOriginY()
	{
		return m_nOriginY;
	}

	bool StandInOrigin()
	{
		return m_nX == m_nOriginX && m_nY == m_nOriginY;
	}

	void hurted(int num);

	void setCurrentHP(int hp);
	void setCurrentMP(int mp);

	void showSkillName(bool b);
	void showFighterName(bool b);

	void drawHurtNumber();

	void drawActionWord();

	void drawHPMP();

	void clearFighterStatus();

	int getAPasStatus();

	bool hasMorePasStatus()
	{
		return m_vPasStatus.size() > 0;
	}

	//void handleStatusPersist(int type, int dwdata);

	void LoadEudemon();

	//void GetCurSubAniGroup(VEC_SAG& sagList);

	void setWillBeAtk(bool bSet);

	void setBattle(Battle* parent)
	{
		this->m_pkParent = parent;
	}

	void setSkillName(std::string name)
	{
		m_strSkillName = name;
	}
	void addAStatus(FighterStatus* fs);

	VEC_FIGHTER_STATUS& getFighterStatus()
	{
		return this->m_vBattleStatusList;
	}

public:
	FIGHTER_INFO m_kInfo;

	USHORT m_nAttackPoint;
	USHORT m_nDefencePoint;
	USHORT m_nDistancePoint;

	OBJID m_uiUsedItem;

	BATTLE_EFFECT_TYPE m_effectType;

	Fighter* m_pkMainTarget;
	Fighter* m_pkActor;

	/** 保护对象 */
	Fighter* m_pkProtectTarget;
	/** 保护者 */
	Fighter* m_pkProtector;
	/** 保护对象时去的血临时存等保护对象去血的时候显示出来 */
	int m_nHurtInprotect;

	bool m_bMissAtk;
	bool m_bHardAtk;
	bool m_bDefenceAtk;
	bool m_bFleeNoDie;
	bool m_bDefenceOK;

	bool isVisibleStatus;

//	VEC_COMMAND m_vCmdList;

	FIGHTER_ACTION m_action;
	ACTION_TYPE m_actionType; // 动作类型，普通攻击0，技能攻击1，道具使用2, 捕捉宠物3。对应使用的动作
//	EFFECT_CHANGE_LIFE_TYPE m_changeLifeType;// 主动伤血类型，攻击，技能，道具等
//	EFFECT_CHANGE_LIFE_TYPE m_changeLifeTypePas;

	//SET_STATUS_PERSIST m_setStatusPersist;

	void drawRareMonsterEffect(bool bVisible);

	void reStoreAttr();
private:
	int m_nX;
	int m_nY;

	int m_nOriginX;
	int m_nOriginY;

	// role原来的父节点
	NDNode* m_pkRoleParent;
	CGPoint m_kRoleInParentPoint;

	// 绘制动画组
	NDBaseRole* m_pkRole;
	NDSprite* m_pkRareMonsterEffect;
	// 是否要主动释放role
	bool m_bRoleShouldDelete;

	int m_nNormalAtkType; // 普通攻击是进程还是远程
	int m_nActionTime; // fighter开始行动的时间

	VEC_HURT m_vHurt;
	VEC_STATUS_ACTION m_kArrayStatusTarget;
	VEC_FIGHTER m_vTarget;
	VEC_PAS_STASUS m_vPasStatus;
	VEC_HURT_NUM m_vHurtNum;

	bool m_bBeginAction;
	bool m_bIsEscape; // 完全脱离战斗
	bool m_bIsAlive; // 战士是否存活，死亡时暂时脱离战斗，可以被复活再回到战斗
	bool m_bIsDodgeOK;
	bool m_bIsHurtOK;
	bool m_bIsDieOK;
	bool m_bIsDefenceOK;
	bool m_bIsAddLifeOK;
	bool m_bIsActionOK;
	bool m_bIsStatusPerformOK;
	bool m_bIsStatusOverOK;
	bool m_bShowName;
	NDUILabel* m_pkFighterNameLabel;
	NDUILabel* m_pkSkillNameLabel;
	BattleSkill m_kUseSkill;
	std::string m_strSkillName;
	ATKTYPE m_eSkillAtkType;
	bool m_bWillBeAttack;

	//ImageNumber* m_imgHurtNum; ///< 临时性注释 郭浩
	NDUIImage* m_pkCritImage;
	NDUIImage* m_pkActionWordImage;
	NDUIImage* m_pkBojiImage;

	Battle* m_pkParent;

	VEC_FIGHTER_STATUS m_vBattleStatusList;
	std::string m_strFighterName;

	string m_strMsgStatus;

private:
	Fighter(const Fighter& rhs)
	{
	}
	Fighter& operator =(const Fighter& rhs)
	{
		return *this;
	}

	void showActionWord(ACTION_WORD index);
	void drawStatusAniGroup();
	void releaseStatus();
	void showHoverMsg(const char* str);
};

#endif
