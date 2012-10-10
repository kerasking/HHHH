/*
 *  SynApproveUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_APPROVE_UI_LAYER_H__
#define __SYNDICATE_APPROVE_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"

using namespace NDEngine;

class ApproveListCell :
public NDPropCell {
	DECLARE_CLASS(ApproveListCell)
public:
	ApproveListCell();
	~ApproveListCell();
	
	void Initialization();
	
	CGRect GetYesRect();
	CGRect GetNoRect();
	
private:
	NDUIImage* m_imgYes;
	NDUIImage* m_imgNo;
};

class SynApproveUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate
{
	DECLARE_CLASS(SynApproveUILayer)
	static SynApproveUILayer* s_instance;
public:
	static SynApproveUILayer* GetCurInstance() {
		return s_instance;
	}
	
	void processApproveList(NDTransData& data);
	
	void delCurSelCell();
	
public:
	SynApproveUILayer();
	~SynApproveUILayer();
	
	void Initialization();
	
	void Query();
	
	void OnButtonClick(NDUIButton* button);
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
private:
	NDUITableLayer* m_tlApproveList;
	bool m_bQuery;
	NDUILabel* m_lbPages;
	NDUIButton* m_btnPrePage;
	NDUIButton* m_btnNextPage;
	int m_nCurPage;
	int m_nMaxPage;
};

#endif