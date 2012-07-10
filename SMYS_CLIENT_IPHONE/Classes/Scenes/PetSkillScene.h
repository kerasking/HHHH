/*
 *  PetSkillScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
 
#ifndef _PET_SKILL_SCENE_H_
#define _PET_SKILL_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"

using namespace NDEngine;

void PetSkillSceneUpdate();

class PetSkillScene : 
public NDScene, 
public NDUITableLayerDelegate,
public NDUIDialogDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(PetSkillScene)
public:
	PetSkillScene();
	~PetSkillScene();
	
	void Initialization(); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnButtonClick(NDUIButton* button); override
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
	void UpdateGui();
private:
	NDUIMenuLayer		*m_menulayerBG;
	NDUILabel			*m_lbTitle;
	NDUITableLayer		*m_tlMain;
};

#endif // _PET_SKILL_SCENE_H_

