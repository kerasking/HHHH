/*
 *  NpcList.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _____NPC_LIST_H__
#define _____NPC_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDUIButton.h"

using namespace NDEngine;

class NpcList :
public NDUIMenuLayer,
public NDUIButtonDelegate
//public NDUITableLayerDelegate ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
{
	DECLARE_CLASS(NpcList)
public:
	static void refreshScroll();
	static string getCurNpcName();
	static void Close();
	
private:
	static NpcList* s_instance;
	
public:
	NpcList();
	~NpcList();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void Initialization();

private:
	bool CanAutoPath();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDUILabel* m_title;
	
	VEC_SOCIAL_ELEMENT m_vElement;
	
private:
	void refreshMainList();
	void releaseElement();
};

#endif