/*
 *  SyndicateRegList.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_REG_LIST_H__
#define __SYNDICATE_REG_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"
#include "NDUIButton.h"

using namespace NDEngine;

class SyndicateRegListUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public IPageButtonDelegate
{
	DECLARE_CLASS(SyndicateRegListUILayer)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static SyndicateRegListUILayer* s_instance;
	
public:
	SyndicateRegListUILayer();
	~SyndicateRegListUILayer();
	
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