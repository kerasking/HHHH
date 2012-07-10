/*
 *  SyndicateList.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_LIST_H__
#define __SYNDICATE_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"
#include "NDUIButton.h"

using namespace NDEngine;

class SyndicateListUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public IPageButtonDelegate
{
	DECLARE_CLASS(SyndicateListUILayer)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static SyndicateListUILayer* s_instance;
	
public:
	SyndicateListUILayer();
	~SyndicateListUILayer();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnPageChange(int nCurPage, int nTotalPage);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDPageButton* m_btnPage;
	int m_nCurPage;
	
	VEC_SOCIAL_ELEMENT m_vSyn;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
};

#endif