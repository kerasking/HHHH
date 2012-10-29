/*
 *  SyndicateElectionList.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_ELECTION_LIST_H__
#define __SYNDICATE_ELECTION_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDUIButton.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class SyndicateElectionList :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(SyndicateElectionList)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static SyndicateElectionList* s_instance;
	
public:
	SyndicateElectionList();
	~SyndicateElectionList();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	
	VEC_SOCIAL_ELEMENT m_vElement;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
};

#endif