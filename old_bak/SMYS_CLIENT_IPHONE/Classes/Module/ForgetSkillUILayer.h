/*
 *  ForgetSkillUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __FORGET_SKILL_UI_LAYER_H__
#define __FORGET_SKILL_UI_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
//#include "NDMapMgr.h" ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
#include "NDUIDialog.h"

using namespace NDEngine;

class ForgetSkillUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(ForgetSkillUILayer)
public:
	static void Show();
	static void RefreshSkillList();
	
private:
	static ForgetSkillUILayer* s_instance;
	
public:
	ForgetSkillUILayer();
	~ForgetSkillUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	VEC_SOCIAL_ELEMENT m_vSkillElement;
	
private:
	void refreshMainList();
	void releaseSkillElement();
};

#endif