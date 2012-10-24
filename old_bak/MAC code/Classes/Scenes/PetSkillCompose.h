/*
 *  PetSkillCompose.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PET_SKILL_COMPOSE_H_
#define _PET_SKILL_COMPOSE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "GameItemBag.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class SkillItemView;

class PetSkillCompose :
public NDScene,
public NDUIButtonDelegate,
public GameItemBagDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(PetSkillCompose)
	
public:
	PetSkillCompose();
	~PetSkillCompose();
	
	static PetSkillCompose* Scene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	static void refresh();
	
	void UpdateGui();
private:
	void UpdateFoucus();
	void InitTLContent(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	int getItemAmontByName(std::string name);
private:
	NDUIMenuLayer *m_menulayerBG;
	GameItemBag *m_itemBag;

	NDUILabel *m_lbSkillNum;
	NDUILabel *m_lbSkillInfo;
	
	ItemFocus *m_itemfocus;
	int m_iFocusIndex;
	
	enum  { eRow = 3, eCol = 4, MAXCHOICE = 5, };
	SkillItemView *m_SkillItemView[eRow*eCol];
	NDUITableLayer *m_tlOperate;
	
	Item m_itemSkill;
	
	int choiceAmount;
private:
	static PetSkillCompose* s_instance;
};
#endif // _PET_SKILL_COMPOSE_H_