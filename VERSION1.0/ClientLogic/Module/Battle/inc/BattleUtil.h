/*
 *  BattleUtil.h
 *  DragonDrive
 *
 *  Created by wq on 11-1-20.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __BATTLE_UTIL_H__
#define __BATTLE_UTIL_H__

#include "define.h"
#include "basedefine.h"
#include <string>
#include <set>
#include <vector>
#include "NDLocalization.h"

const std::string ELE_POWER = NDCommonCString("TiLi"); //·ÀÓù
const std::string ELE_VITALITY = NDCommonCString("yuanqi"); //¹¥»÷
const std::string ELE_SPIRIT = NDCommonCString("jingsheng"); //»ìÂÒ

enum
{
	DEFAULT_FONT_SIZE = 14,
};

typedef std::set<OBJID> SET_BATTLE_SKILL_LIST;
typedef SET_BATTLE_SKILL_LIST::iterator SET_BATTLE_SKILL_LIST_IT;

class Fighter;

typedef std::vector<Fighter*> VEC_FIGHTER;
typedef VEC_FIGHTER::iterator VEC_FIGHTER_IT;

void defenceAction(Fighter& kFighter);

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

void assasinSkillAction(Fighter& kFighter);

void wizzardSkillAction(Fighter& f);

void monsterResult(VEC_FIGHTER& monsterList);

void petAction(Fighter& f, int act);

void roleAction(Fighter& f, int act);

#endif
