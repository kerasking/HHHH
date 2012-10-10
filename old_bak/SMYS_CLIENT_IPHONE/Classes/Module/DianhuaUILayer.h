/*
 *  DianhuaUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __DIAN_HUA_UI_LAYER_H__
#define __DIAN_HUA_UI_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDMapMgr.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class DianhuaUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(DianhuaUILayer)
public:
	static void RefreshList(int type, int idNextLevelSkill, int lqz);
	
private:
	static DianhuaUILayer* s_instance;
	
public:
	DianhuaUILayer();
	~DianhuaUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void Initialization(int type);
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	VEC_SOCIAL_ELEMENT m_vSkillElement;
	
private:
	void AddSkillToList(int idNextLevelSkill, int lqz);
	void releaseSkillElement();
};

#endif