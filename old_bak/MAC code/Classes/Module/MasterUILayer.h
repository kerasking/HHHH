/*
 *  MasterUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __MASTER_UI_LAYER_H__
#define __MASTER_UI_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"

using namespace NDEngine;

class MasterUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public IPageButtonDelegate
{
	DECLARE_CLASS(MasterUILayer)
public:
	static void refreshScroll(NDTransData& data);
	
private:
	static MasterUILayer* s_instance;
	
public:
	MasterUILayer();
	~MasterUILayer();
	
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	virtual void OnPageChange(int nCurPage, int nTotalPage);
	void Initialization();
	
private:
	NDUITableLayer* m_tlMain;
	SocialElement* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDPageButton* m_btnPage;
	
	typedef vector<SocialElement*> VEC_DAOSHI_ELEMENT;
	typedef VEC_DAOSHI_ELEMENT::iterator VEC_DAOSHI_ELEMENT_IT;
	
	VEC_DAOSHI_ELEMENT m_vDaoshi;
	
private:
	void refreshMainList(NDTransData& data);
	void releaseDaoshi();
};

#endif