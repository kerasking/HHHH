/*
 *  SyndicateStorage.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_STORAGE_LIST_H__
#define __SYNDICATE_STORAGE_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDUIButton.h"
#include "NDUICustomView.h"

using namespace NDEngine;

class SyndicateStorage :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(SyndicateStorage)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static SyndicateStorage* s_instance;
	
public:
	SyndicateStorage();
	~SyndicateStorage();
	
	bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDUILabel* m_lbTotalContri;
	
	VEC_SOCIAL_ELEMENT m_vElement;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
	bool isInputOk(NDUICustomView* view);
};

#endif