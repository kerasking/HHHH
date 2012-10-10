/*
 *  NpcTaskList.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __NPC_TASK_LIST_H__
#define __NPC_TASK_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDUIButton.h"

using namespace NDEngine;

class NpcTaskList :
public NDUIMenuLayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NpcTaskList)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static NpcTaskList* s_instance;
	
public:
	NpcTaskList();
	~NpcTaskList();
	
	void OnButtonClick(NDUIButton* button);
	void Initialization(const string& strTitle);
	
private:
	NDUITableLayer* m_tlMain;
	VEC_SOCIAL_ELEMENT m_vElement;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
};

#endif