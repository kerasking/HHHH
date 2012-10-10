/*
 *  SyndicateApprove.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_APPROVE_H__
#define __SYNDICATE_APPROVE_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"
#include "NDUIButton.h"

using namespace NDEngine;

class SyndicateApprove :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public IPageButtonDelegate
{
	DECLARE_CLASS(SyndicateApprove)
public:
	static void refreshScroll(NDTransData& data);
	static void delCurSelEle();
	
private:
	static SyndicateApprove* s_instance;
	
public:
	SyndicateApprove();
	~SyndicateApprove();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnPageChange(int nCurPage, int nTotalPage);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDPageButton* m_btnPage;
	
	VEC_SOCIAL_ELEMENT m_vElement;
	
	NDUILabel *m_lbTitle;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
	void releaseCurSelEle();
	
	void UpdtaeTitle(int iCurPageCount);
};

#endif