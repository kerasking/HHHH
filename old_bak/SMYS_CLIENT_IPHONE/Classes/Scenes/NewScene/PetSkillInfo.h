/*
 *  PetSkillInfo.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __PET_SKILL_INFO_H__
#define __PET_SKILL_INFO_H__

#include "define.h"
#include "NDUILayer.h"
#include "NDPlayer.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"
#include "NDCommonScene.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

//////////////////////////////////////////////////////////////////////////////////////////
class PetSkillInfoLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(PetSkillInfoLayer)
public:
	PetSkillInfoLayer();
	~PetSkillInfoLayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	// -1表示未开启
	void RefreshPetSkill(int idSkill);
	
private:
	NDUIImage* m_imgSkill;
	NDUILabel* m_lbSkillName;
	NDUILabel* m_lbReqLv;
	NDUILabelScrollLayer* m_skillInfo;
	NDUIButton* m_btnKaiQi;
};

//////////////////////////////////////////////////////////////////////////////////////////
class PetSkillIconLayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(PetSkillIconLayer)
	enum {
		ROW_COUNT = 2,
		COL_COUNT = 5,
	};
public:
	static void OnUnLockSkill();
	PetSkillIconLayer();
	~PetSkillIconLayer();
	
	void Initialization(PetSkillInfoLayer* skillInfoLayer);
	
	void OnButtonClick(NDUIButton* button);
	
private:
	NDUIButton* m_btnSkill[ROW_COUNT][COL_COUNT];
	
	PetSkillInfoLayer* m_skillInfoLayer;
	static PetSkillIconLayer* s_instance;
	
private:
	void UnLockSkill();
};

//////////////////////////////////////////////////////////////////////////////////////////
class PetSkillTab : 
public NDUILayer
{
	DECLARE_CLASS(PetSkillTab)
public:
	PetSkillTab();
	~PetSkillTab();
	
	void Initialization();
private:
	PetSkillIconLayer* m_petSkillIconLayer;
	PetSkillInfoLayer* m_petSkillInfoLayer;
};

#endif