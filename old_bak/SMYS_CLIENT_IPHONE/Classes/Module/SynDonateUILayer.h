/*
 *  SynDonateUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_DONATE_UI_LAYER_H__
#define __SYNDICATE_DONATE_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "NDCommonControl.h"

using namespace NDEngine;

class DragBar :
public NDPropSlideBar
{
	DECLARE_CLASS(DragBar)
public:
	DragBar();
	~DragBar();
	
	void Initialization(CGRect rect, unsigned int slideWidth);
	void draw(); override
	void SetScale(uint scale) {
		this->m_scale = scale;
	}
	int GetScale() {
		return this->m_scale;
	}
	
private:
	NDUILabel* m_lbNumHint;
	int m_scale;
};

class SynDonateUILayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SynDonateUILayer)
	static SynDonateUILayer* s_instance;
public:
	static SynDonateUILayer* GetCurInstance() {
		return s_instance;
	}
	
	void processSynDonate(NDTransData& data);
	
public:
	SynDonateUILayer();
	~SynDonateUILayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	void Query();
	
private:
	NDUILabel* m_lbTotalCon;
	NDUILabel* m_lbSynMoney;
	NDUILabel* m_lbSynWood;
	NDUILabel* m_lbSynStone;
	NDUILabel* m_lbSynPaint;
	NDUILabel* m_lbSynCoal;
	NDUILabel* m_lbSynEmoney;
	
	NDUILabel* m_lbUserMoney;
	NDUILabel* m_lbUserWood;
	NDUILabel* m_lbUserStone;
	NDUILabel* m_lbUserPaint;
	NDUILabel* m_lbUserCoal;
	NDUILabel* m_lbUserEmoney;
	
	DragBar* m_dragMoney;
	DragBar* m_dragWood;
	DragBar* m_dragStone;
	DragBar* m_dragPaint;
	DragBar* m_dragCoal;
	DragBar* m_dragEmoney;
};

#endif