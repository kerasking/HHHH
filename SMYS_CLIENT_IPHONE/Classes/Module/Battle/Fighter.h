/*
 *  Fighter.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __FIGHTER_H__
#define __FIGHTER_H__

#include "Hurt.h"
#include "EnumDef.h"
#include "define.h"
#include "NDBaseRole.h"
#import "NDManualRole.h"
#include <string>
#include <vector>
#include "ImageNumber.h"
#include <set>
#include "BattleSkill.h"
#include "NDSprite.h"
#include <map>

using namespace std;
using namespace NDEngine;

enum ACTION_WORD
{
	AW_DEF,
	AW_DODGE,
	AW_FLEE,
};

enum LOOKFACE_TYPE {
	LOOKFACE_NONE=0,
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
}FIGHTER_INFO;



class FighterStatus {
public:
	FighterStatus()
	{
		m_id = 0;
		m_StartEffectID = 0;
		m_LastEffectID = 0;
		m_aniGroup = NULL;
	}
	
	FighterStatus(int id, int startEffectID, int lastEffectID) {
		m_id = id;
		m_StartEffectID = startEffectID;
		m_LastEffectID = lastEffectID;
		m_aniGroup = NULL;
	}
	
	FighterStatus(const FighterStatus& rhs)
	{
		m_id = rhs.m_id;
		m_StartEffectID = rhs.m_StartEffectID;
		m_LastEffectID = rhs.m_LastEffectID;
		m_aniGroup = NULL;
	}
	
	FighterStatus& operator = (const FighterStatus& rhs)
	{
		m_id = rhs.m_id;
		m_StartEffectID = rhs.m_StartEffectID;
		m_LastEffectID = rhs.m_LastEffectID;
		m_aniGroup = NULL;
		return *this;
	}
	
	~FighterStatus() {
		SAFE_DELETE(m_aniGroup);
	}
	
public:
	int m_id;
	int m_StartEffectID;
	int m_LastEffectID;
	NDSubAniGroup* m_aniGroup;
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
	enum {
		ADD_STATUS = 0,
		CANCEL_STATUS = 1,
	};
	
	StatusAction(int act, FighterStatus* fs, int id) : status(fs)
	{
		action = act;
		idTarget = id;
	}
	
	int action;
	FighterStatus* status;
	int idTarget;
};

typedef set<string> SET_STATUS_PERSIST;
typedef SET_STATUS_PERSIST::iterator SET_STATUS_PERSIST_IT;

typedef vector<Hurt> VEC_HURT;
typedef VEC_HURT::iterator VEC_HURT_IT;

typedef vector<int> VEC_PAS_STASUS; // 被施加的被动状态
typedef VEC_PAS_STASUS::iterator VEC_PAS_STASUS_IT;

typedef vector<HurtNumber>VEC_HURT_NUM;
typedef VEC_HURT_NUM::iterator VEC_HURT_NUM_IT;

typedef pair<bool/*bFind*/, Hurt> PAIR_GET_HURT;

typedef vector<StatusAction> VEC_STATUS_ACTION;
typedef VEC_STATUS_ACTION::iterator VEC_STATUS_ACTION_IT;

int countX(int teamAmount,BATTLE_GROUP group,int team,int pos );
int countY(int teamAmount,BATTLE_GROUP group,int team,int pos );

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
	int targetX;
	int targetY;
	LOOKFACE_TYPE m_lookfaceType;
	BATTLE_GROUP GetGroup() const { return m_info.group; }
	void SetRole(NDBaseRole* role);
	void LoadMonster(int nLookFace, int lev, const string& name);
	void LoadRole(int nLookFace,int lev,const string& name);
	NDBaseRole* GetRole() const { return m_role; }
	
	void setPosition(int offset);
	void updatePos();
	void draw();
	
//	void AddCommand(FIGHTER_CMD* cmd);
	
	void setOnline(bool bOnline);
	
	int GetNormalAtkType() const { return m_normalAtkType; }
	
	void AddAHurt(Fighter* actor, int btType, int hurtHP, int hurtMP, int dwData, HURT_TYPE ht);
	void AddAStatusTarget(StatusAction& f);
	void AddATarget(Fighter* f);
	
	VEC_FIGHTER& getArrayTarget() {
		return this->m_vTarget;
	}
	
	VEC_STATUS_ACTION& getArrayStatusTarget()
	{
		return this->arrayStatusTarget;
	}
	
	void AddPasStatus(int dwData);
	PAIR_GET_HURT getHurt(Fighter* actor, int btType, int dwData, int type);
	
	int getActionTime() { return m_actionTime; }
	
	void setActionTime(int waitToActionTime) { m_actionTime = waitToActionTime; }
	
	void actionTimeIncrease() {
		if (m_actionTime != 0) {
			m_actionTime++;
		}
	}
	
	void removeAStatusAniGroup(FighterStatus* status);
	
	bool isActionOK() { return actionOK; }
	
	void setActionOK(bool bOK) { this->actionOK = bOK; }
	
	void setBeginAction(bool bBegin) {
		beginAction = bBegin;
		m_actionTime = 1;
	}
	
	bool isBeginAction() {
		return beginAction;
	}
	
	bool isVisiable();
	
	bool isCatchable();
	
	bool isAlive() { return alive; }
	
	void setAlive(bool a) { this->alive = a; }
	
	bool isEscape() { return escape; }
	
	void setEscape(bool esc);
	
	bool isHurtOK() { return hurtOK; }
	
	void setHurtOK(bool htOK) { hurtOK = htOK; }
	
	bool isDodgeOK() { return dodgeOK; }
	
	void setDodgeOK(bool bOK) { dodgeOK = bOK; }
	
	bool isDefenceOK() { return defenceOK; }
	
	void setDefenceOK(bool bOK) { defenceOK = bOK; }
	void setOriginPos(int x,int y){originX=x;originY=y;}
	
	bool isDieOK() { return dieOK; }
	
	void setDieOK(bool bOK);
	
	BattleSkill* getUseSkill() {
		return &useSkill;
	}
	
	void setUseSkill(BattleSkill* skill) {
		useSkill = *skill;
	}
	
	ATKTYPE getSkillAtkType() {
		return skillAtkType;
	}
	
	void setSkillAtkType(ATKTYPE atkType) {
		skillAtkType = atkType;
	}
	
	bool completeOneAction();
	
	bool moveTo(int tx, int ty);
	
	int getX() { return x; }
	int getY() { return y; }
	
	int getOriginX() { return originX; }
	
	int getOriginY() { return originY; }
	
	bool StandInOrigin() {
		return x == originX && y == originY;
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
	
	bool hasMorePasStatus() {
		return m_vPasStatus.size() > 0;
	}
	
	//void handleStatusPersist(int type, int dwdata);
	
	void LoadEudemon();
	
	//void GetCurSubAniGroup(VEC_SAG& sagList);
	
	void setWillBeAtk(bool bSet);
	
	void setBattle(Battle* parent) {
		this->m_parent = parent;
	}
	
	void setSkillName(std::string name){
		m_strSkillName=name;
	}
	void addAStatus(FighterStatus* fs);
	
	VEC_FIGHTER_STATUS& getFighterStatus() {
		return this->battleStatusList;
	}
	
public:
	FIGHTER_INFO m_info;
	
	ushort m_atkPoint;
	ushort m_defPoint;
	ushort m_disPoint;
	
	OBJID m_idUsedItem;
	
	BATTLE_EFFECT_TYPE m_effectType;
	
	Fighter* m_mainTarget;
	Fighter* m_actor;
	
	/** 保护对象 */
	Fighter* protectTarget;
	/** 保护者 */
	Fighter* protector;
	/** 保护对象时去的血临时存等保护对象去血的时候显示出来 */
	int hurtInprotect;
	
	bool m_bMissAtk;
	bool m_bHardAtk;
	bool m_bDefenceAtk;
	bool m_bFleeNoDie;
	bool m_bDefenceOK;
	
	bool isVisibleStatus;
	
//	VEC_COMMAND m_vCmdList;
	
	FIGHTER_ACTION m_action;
	ACTION_TYPE m_actionType;// 动作类型，普通攻击0，技能攻击1，道具使用2, 捕捉宠物3。对应使用的动作
//	EFFECT_CHANGE_LIFE_TYPE m_changeLifeType;// 主动伤血类型，攻击，技能，道具等
//	EFFECT_CHANGE_LIFE_TYPE m_changeLifeTypePas;
	
	//SET_STATUS_PERSIST m_setStatusPersist;
	
	void drawRareMonsterEffect(bool bVisible);
	
	void reStoreAttr();
private:
	int x;
	int y;
	
	int originX, originY;
	
	// role原来的父节点
	NDNode* m_roleParent;
	CGPoint m_ptRoleInParent;
	
	// 绘制动画组
	NDBaseRole* m_role;
	NDSprite* m_rareMonsterEffect;
	// 是否要主动释放role
	bool m_bRoleShouldDelete;
	
	int m_normalAtkType; // 普通攻击是进程还是远程
	int m_actionTime;// fighter开始行动的时间
	
	VEC_HURT m_vHurt;
	VEC_STATUS_ACTION arrayStatusTarget;
	VEC_FIGHTER m_vTarget;
	VEC_PAS_STASUS m_vPasStatus;
	VEC_HURT_NUM m_vHurtNum;
	
	bool beginAction;
	bool escape;// 完全脱离战斗
	bool alive;// 战士是否存活，死亡时暂时脱离战斗，可以被复活再回到战斗
	bool dodgeOK;
	bool hurtOK;
	bool dieOK;
	bool defenceOK;
	bool addLifeOK;
	bool actionOK;
	bool statusPerformOK;
	bool statusOverOK;
	bool m_bShowName;
	NDUILabel* lb_FighterName;
	NDUILabel* lb_skillName;
	BattleSkill useSkill;
	std::string m_strSkillName;
	ATKTYPE skillAtkType;
	bool willBeAtk;
	
	ImageNumber* m_imgHurtNum;
	NDUIImage* m_imgBaoJi;
	NDUIImage* m_imgActionWord;
	NDUIImage* m_imgBoji;
	
	Battle* m_parent;
	
	VEC_FIGHTER_STATUS battleStatusList;
	std::string fighter_name;
	
	string strMsgStatus;
	
private:
	Fighter(const Fighter& rhs) { }
	Fighter& operator = (const Fighter& rhs) { return *this; }
	
	void showActionWord(ACTION_WORD index);
	void drawStatusAniGroup();
	void releaseStatus();
	void showHoverMsg(const char* str);
};

#endif