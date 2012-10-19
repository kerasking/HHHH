/*
 *  BattleSkill.h
 *  DragonDrive
 *
 *  Created by wq on 11-2-10.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __BATTLE_SKILL_H__
#define __BATTLE_SKILL_H__

#include <string>
#include "EnumDef.h"
#include "BattleUtil.h"

using std::string;

enum
{
	NO_NEXT_LEVET = 100,
	FULL_LEVEL = 101,
	STATUS_NO_LEARN = 0,
	STATUS_LEARNED = 1,
};

class BattleSkill
{
public:
	BattleSkill();
	~BattleSkill();

	string getFullDes();

	string getSimpleDes(bool bIncludeName);

	/**
	 * 技能类型
	 * 
	 * @return 主动，被动，自动释放
	 */
	SKILL_TYPE getType()
	{
		return type;
	}

	void setType(SKILL_TYPE t)
	{
		this->type = t;
	}

	int getLvRequire()
	{
		return lvRequire;
	}

	void setLvRequire(int lvReq)
	{
		lvRequire = lvReq;
	}

	int getSpRequire()
	{
		return spRequire;
	}

	void setSpRequire(int spReq)
	{
		spRequire = spReq;
	}

	int getMpRequire()
	{
		return mpRequire;
	}

	void setMpRequire(int mpReq)
	{
		mpRequire = mpReq;
	}

	int getHpRequire()
	{
		return hpRequire;
	}

	void setHpRequire(int hpReq)
	{
		hpRequire = hpReq;
	}

	int getCd()
	{
		return cd;
	}

	void setCd(int n)
	{
		cd = n;
	}

	int getStatusLast()
	{
		return statusLast;
	}

	void setStatusLast(int last)
	{
		statusLast = last;
	}

	int getArea()
	{
		return this->area;
	}

	void setArea(int a)
	{
		area = a;
	}

	int getSuccessRate()
	{
		return successRate;
	}

	void setSuccessRate(int rate)
	{
		successRate = rate;
	}

	SKILL_ATK_TYPE getAtkType()
	{
		return atkType;
	}

	void setAtkType(SKILL_ATK_TYPE atk)
	{
		atkType = atk;
	}

	int getFighterType()
	{
		return fighterType;
	}

	void setFighterType(int f)
	{
		fighterType = f;
	}

	int getLevel()
	{
		return level;
	}

	void setLevel(int l)
	{
		level = l;
	}

	int getId()
	{
		return idSkill;
	}

	void setId(int skill)
	{
		this->idSkill = skill;

		int result[6] =
		{ 0 };
		result[0] = this->idSkill / 10000000; // 种族
		result[1] = this->idSkill / 1000000 % 10; // 职业
		result[2] = this->idSkill / 100000 % 10; // 技能类型,主动，被动
		result[3] = this->idSkill / 10000 % 10; // 武器需求
		result[4] = this->idSkill / 100 % 100; // 序号
		result[5] = this->idSkill % 100; // 技能等级

		this->setCamp(CAMP_TYPE(result[0]));
		this->setProfession(result[1]);
		this->setType(SKILL_TYPE(result[2]));
		this->setWeaponRequire(WEAPON_REQUIRE(result[3]));
		this->setSkillTypeID(idSkill / 100);
		this->setLevel(result[5]);

		//int skillType = idSkill / 10000;
//		if (1216 == skillType) {
//			subAniID = 121000 + (idSkill / 100) % 100;
//		} else {
//			subAniID = idSkill / 100;
//		}

		subAniID = (idSkill / 1000) % 1000;
	}

	const string& getName()
	{
		return this->name;
	}

	void setName(const string& n)
	{
		this->name = n;
	}

	const string& getDes()
	{
		return des;
	}

	void setDes(const string& s)
	{
		des = s;
	}

	int getMaxLevel()
	{
		return maxLevel;
	}

	void setMaxLevel(int max)
	{
		maxLevel = max;
	}

	int getMaskFlag()
	{
		return maskFlag;
	}

	void setMaskFlag(int mask)
	{
		maskFlag = mask;
	}

	int getNextLevel()
	{
		return nextLevel;
	}

	void setNextLevel(int next)
	{
		nextLevel = next;
	}

	int getProfession()
	{
		return profession;
	}

	void setProfession(int pro)
	{
		profession = pro;
	}

	int getSkillTypeID()
	{
		return idSkillType;
	}

	void setSkillTypeID(int skill)
	{
		this->idSkillType = skill;
	}

	int getStatus()
	{
		return status;
	}

	void setStatus(int s)
	{
		status = s;
	}

	int getMoney()
	{
		return money;
	}

	void setMoney(int m)
	{
		money = m;
	}

	CAMP_TYPE getCamp()
	{
		return camp;
	}

	void setCamp(CAMP_TYPE c)
	{
		camp = c;
	}

	WEAPON_REQUIRE getWeaponRequire()
	{
		return weaponRequire;
	}

	void setWeaponRequire(WEAPON_REQUIRE wReq)
	{
		weaponRequire = wReq;
	}

	int getInjury()
	{
		return injury;
	}

	void setInjury(int i)
	{
		injury = i;
	}

	int getSpeed()
	{
		return speed;
	}

	void setSpeed(int s)
	{
		speed = s;
	}

	int getAtk_point()
	{
		return atk_point;
	}

	void setAtk_point(int atk)
	{
		atk_point = atk;
	}

	int getDef_point()
	{
		return def_point;
	}

	void setDef_point(int def)
	{
		def_point = def;
	}

	int getDis_point()
	{
		return dis_point;
	}

	void setDis_point(int dis)
	{
		dis_point = dis;
	}

	int getCurSp()
	{
		return curSp;
	}

	void setCurSp(int sp)
	{
		curSp = sp;
	}

	int getSubAniID()
	{
		return this->subAniID;
	}

	string getUpdate_required()
	{
		return this->update_required;
	}

	void setUpdate_required(string& update_req)
	{
		this->update_required = update_req;
	}

	void setIconIndex(int icon)
	{
		this->iconIndex = icon;
	}

	int getIconIndex()
	{
		return this->iconIndex;
	}

	void SetSkillOwn(bool bPlayer)
	{
		this->bPlayer = bPlayer;
	}

	bool IsSkillOwnByPlayer()
	{
		return this->bPlayer;
	}

	int GetSlot()
	{
		return m_nSlot;
	}

	void SetSlot(int nSlot)
	{
		m_nSlot = nSlot;
	}

	void setLookface(int act, int lookface, int lookface_target)
	{
		act_id = act;
		lookface_id = lookface;
		lookface_target_id = lookface_target;
	}

	int GetActId()
	{
		return act_id;
	}

	int GetLookfaceID()
	{
		return lookface_id;
	}

	int GetLookfaceTargetID()
	{
		return lookface_target_id;
	}

private:
	SKILL_TYPE type; // 技能类型

	int lvRequire;

	/** 熟练度上限 */
	int spRequire;

	/** 当前熟练度,查看的时候由服务器下发 */
	int curSp;

	int mpRequire;

	int hpRequire;

	WEAPON_REQUIRE weaponRequire;

	/**
	 * 杖技能表现子动画id
	 */
	int subAniID;

	int cd;

	int statusLast;

	int area;

	int successRate;

	SKILL_ATK_TYPE atkType;

	int fighterType;

	int level;

	int maxLevel;

	int nextLevel;

	int idSkill;

	int maskFlag;

	int profession;

	int iconIndex;

	string name;

	string des;

	int idSkillType; // 不包括等级的技能id

	int status;

	int money;

	CAMP_TYPE camp;

	int injury;

	int speed;

	int atk_point;

	int def_point;

	int dis_point;

	string update_required;

	bool bPlayer;  // 玩家或宠物的

	int m_nSlot;	// 槽位置

	int act_id;
	int lookface_id;
	int lookface_target_id;
};

#endif
