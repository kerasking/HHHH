/*
 *  SyndicateVoteList.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_VOTE_LIST_H__
#define __SYNDICATE_VOTE_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDUIButton.h"

using namespace NDEngine;

class SyndicateVoteList :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(SyndicateVoteList)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static SyndicateVoteList* s_instance;
	
public:
	SyndicateVoteList();
	~SyndicateVoteList();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	
	VEC_SOCIAL_ELEMENT m_vElement;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
};

#endif