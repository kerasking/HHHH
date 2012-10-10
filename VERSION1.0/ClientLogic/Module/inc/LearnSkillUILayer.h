/*
 *  LearnSkillUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __LEARN_SKILL_UI_LAYER_H__
#define __LEARN_SKILL_UI_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
//#include "NDMapMgr.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class LearnSkillUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(LearnSkillUILayer)
public:

	/***
	* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	* begin
	*/
// 	static void Show(VEC_BATTLE_SKILL& vSkills);
// 	static void RefreshSkillList();
	/***
	* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	* end
	*/
	
private:
	static LearnSkillUILayer* s_instance;
	
public:
	LearnSkillUILayer();
	~LearnSkillUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	//void Initialization(VEC_BATTLE_SKILL& vSkills); ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;

// 	VEC_BATTLE_SKILL* m_pVecSkills; ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
// 	VEC_SOCIAL_ELEMENT m_vSkillElement; ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ

private:
	void refreshMainList();
	void releaseSkillElement();
};

#endif