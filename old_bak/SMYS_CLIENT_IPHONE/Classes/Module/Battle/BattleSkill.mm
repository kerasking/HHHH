/*
 *  BattleSkill.mm
 *  DragonDrive
 *
 *  Created by wq on 11-2-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "BattleSkill.h"
#include "BattleMgr.h"
#include "Battle.h"
#include <sstream>

using namespace std;

BattleSkill::BattleSkill() {
	type = SKILL_TYPE_NONE;// 技能类型
	
	lvRequire = 0;
	
	/** 熟练度上限 */
	spRequire = 0;
	
	/** 当前熟练度,查看的时候由服务器下发 */
	curSp = 0;
	
	mpRequire = 0;
	
	hpRequire = 0;
	
	weaponRequire = WEAPON_REQUIRE_NONE;
	
	/**
	 * 杖技能表现子动画id
	 */
	subAniID = 0;
	
	cd = 0;
	
	statusLast = 0;
	
	area = 0;
	
	successRate = 0;
	
	atkType = SKILL_ATK_TYPE_NONE;
	
	fighterType = 0;
	
	level = 0;
	
	maxLevel = 0;
	
	nextLevel = 0;
	
	idSkill = 0;
	
	maskFlag = 0;
	
	profession = 0;
	
	idSkillType = 0;// 不包括等级的技能id
	
	status = 0;
	
	money = 0;
	
	camp = CAMP_TYPE_NONE;
	
	injury = 0;
	
	speed = 0;
	
	atk_point = 0;
	
	def_point = 0;
	
	dis_point = 0;
	
	iconIndex = 0;
	
	bPlayer = true;
	
	m_nSlot	= 0;
	
	act_id=0;
	lookface_id=0;
	lookface_target_id=0;
}

BattleSkill::~BattleSkill() {
	
}

string BattleSkill::getFullDes() {
	stringstream ss;
	
	ss << getSimpleDes(true);
	/*
	<< "需要等级：" << getLvRequire() << "\n"
	<< "需要银两：" << getMoney() << "\n"
	<< "需要SP：" << getSpRequire() << "\n";
	*/
	
	return ss.str();
}

string BattleSkill::getSimpleDes(bool bIncludeName) {
	stringstream ss;
	
	if (bIncludeName) {
		ss << getName() << "（" << this->level << NDCommonCString("Ji") << "）" << "\n";
	} else {
		ss << NDCommonCString("level") << ": " << this->level << "\n";
	}
	
	ss << NDCommonCString("require") << NDCommonCString("level") << ": " << this->lvRequire << "\n";
	
	stringstream strArea;
	strArea << this->area << NDCommonCString("ren");
	
	string strWeapon = NDCommonCString("wu");
	if (this->weaponRequire == WEAPON_REQUIRE_SWORD) {
		strWeapon = NDCommonCString("JianLei");
	} else if (this->weaponRequire == WEAPON_REQUIRE_KNIFE) {
		strWeapon = NDCommonCString("DaoLei");
	} else if (this->weaponRequire == WEAPON_REQUIRE_BOW) {
		strWeapon = NDCommonCString("GongLei");
	} else if (this->weaponRequire == WEAPON_REQUIRE_DAGGER) {
		strWeapon = NDCommonCString("BiShouLei");
	}else if (this->weaponRequire == WEAPON_REQUIRE_GUN) {
		strWeapon = NDCommonCString("GunLei");
	}else if (this->weaponRequire == WEAPON_REQUIRE_BATTLE) {
		strWeapon = NDCommonCString("ZhangLei");
	}
	
	ss << NDCommonCString("WuQi") << NDCommonCString("require") << "：" << strWeapon << "\n";
	
	string strTarget = NDCommonCString("wu");
	if ((this->atkType & SKILL_ATK_TYPE_ENEMY) == SKILL_ATK_TYPE_ENEMY) {
		strTarget = NDCommonCString("DiFang");
	} else if ((this->atkType & SKILL_ATK_TYPE_SELF) == SKILL_ATK_TYPE_SELF) {
		strTarget = NDCommonCString("ZhiJi");
	} else if ((this->atkType & SKILL_ATK_TYPE_FRIEND) == SKILL_ATK_TYPE_FRIEND) {
		strTarget = NDCommonCString("YouFang");
	}
	
	if (this->type != SKILL_TYPE_PASSIVE) {
		ss << NDCommonCString("target") << "：" << strTarget << strArea.str() << "\n"
		<< NDCommonCString("ConsumeMp") << "：" << getMpRequire() << "\n";
		
		if(getInjury() != 0) {
			ss << NDCommonCString("hurt") << "：" << getInjury() << "\n";
		}
		
		ss << NDCommonCString("speed") << "：" << getSpeed() << "\n";
		
		if (getAtk_point() != 0)
			ss << ELE_VITALITY << "："<<getAtk_point()<<"\n";
		if (getAtk_point() != 0)
			ss << ELE_POWER << "："<<getDef_point()<<"\n";
		if (getAtk_point() != 0)
			ss << ELE_SPIRIT <<"："<<getDis_point()<<"\n";
	}
	
	if (getCd() != 0)
	{
		ss << NDCommonCString("CoolTurn") << ": " << getCd() << "\n";
		
		Battle* battle = BattleMgrObj.GetBattle();
		if (!IsSkillOwnByPlayer() && battle && battle->CanPetFreeUseSkill())
		{
			ss << NDCommonCString("BattleNoLimit");
		}
	}
	
	ss << NDCommonCString("effect") << "：" << getDes() << "\n";
	
	if (getStatusLast() != 0 && getStatusLast() != 255) {
		ss << NDCommonCString("ChiXuTurn") << "：" << getStatusLast()<<"\n";
	}
	
	return ss.str();
}