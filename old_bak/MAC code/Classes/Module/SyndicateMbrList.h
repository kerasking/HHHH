/*
 *  SyndicateMbrList.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_MBR_LIST_H__
#define __SYNDICATE_MBR_LIST_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"
#include "NDUIButton.h"
#include "NDUICustomView.h"
#include "NDUIDialog.h"

using namespace NDEngine;

class SyndicateMbrList :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public IPageButtonDelegate,
public NDUICustomViewDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(SyndicateMbrList)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static SyndicateMbrList* s_instance;
	
public:
	SyndicateMbrList();
	~SyndicateMbrList();
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	bool OnCustomViewConfirm(NDUICustomView* customView);
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
	
private:
	void refreshMainList(NDTransData& data);
	void releaseElement();
};

#endif