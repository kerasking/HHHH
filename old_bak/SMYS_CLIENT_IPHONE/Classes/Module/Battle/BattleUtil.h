/*
 *  BattleUtil.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __BATTLE_UTIL_H__
#define __BATTLE_UTIL_H__

#include "define.h"
#include <string>
#include <set>

const std::string ELE_POWER = NDCommonCString("TiLi");//防御
const std::string ELE_VITALITY = NDCommonCString("yuanqi");//攻击
const std::string ELE_SPIRIT = NDCommonCString("jingsheng");//混乱

enum {
	DEFAULT_FONT_SIZE = 12,
};

typedef std::set<OBJID> SET_BATTLE_SKILL_LIST;
typedef SET_BATTLE_SKILL_LIST::iterator SET_BATTLE_SKILL_LIST_IT;

class Fighter;

typedef vector<Fighter*> VEC_FIGHTER;
typedef VEC_FIGHTER::iterator VEC_FIGHTER_IT;

void defenceAction(Fighter& f);

void attackAction(Fighter& f);

void moveToTargetAction(Fighter& f);

void dodgeAction(Fighter& f);

void moveBackAction(Fighter& f);

void hurtAction(Fighter& f);

void dieAction(Fighter& f);

void battleStandAction(Fighter& f);

void useItemAction(Fighter& f);

void catchPetAction(Fighter& f);

void fleeSuccessAction(Fighter& f);

void fleeFailAction(Fighter& f);

void warriorSkillAction(Fighter& f);

void assasinSkillAction(Fighter& f);

void wizzardSkillAction(Fighter& f);

void monsterResult(VEC_FIGHTER& monsterList);

void petAction(Fighter& f, int act);

void roleAction(Fighter& f, int act);

#endif