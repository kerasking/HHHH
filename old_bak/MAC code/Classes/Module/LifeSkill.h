/*
 *  LifeSkill.h
 *  DragonDrive
 *
 *  Created by wq on 11-2-16.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __LIFE_SKILL_H__
#define __LIFE_SKILL_H__

#include "define.h"

enum
{
	ALCHEMY_IDSKILL = 11, // 炼金技能 ：旧值110020 
	GEM_IDSKILL = 12, // 宝石合成  旧值120020
};

class LifeSkill {
public:
	LifeSkill() {
		this->idSkill = 0;
		this->uSkillExp = 0;
		this->uSkillGrade = 0;
		this->uSkillExp_max = 0;
	}
	
	LifeSkill(int _idSkill, int _uSkillExp, int _uExp_max, Byte _uSkillGrade, string _sName) {
		this->idSkill = _idSkill;
		this->uSkillExp = _uSkillExp;
		this->uSkillGrade = _uSkillGrade;
		this->uSkillExp_max = _uExp_max;
		this->m_skillName = _sName;
	}
	
	~LifeSkill() {
		
	}
	
	void updateLearnLifeSkill(int exp,int grade,int uExp_max) {
		if(exp!=-1){
			uSkillExp = exp;
		}
		if(grade!=-1){
			uSkillGrade = grade;
		}
		if(uExp_max!=-1){
			uSkillExp_max = uExp_max;
		}
	}
	
public:
	OBJID idSkill; // 技能id ；炼金ALCHEMY_IDSKILL=11，宝石合成GEM_IDSKILL = 12
	int uSkillExp; // 技能的熟练度
	int uSkillExp_max;//升级经验
	Byte uSkillGrade; // 技能等级；
	string m_skillName;
};

#endif