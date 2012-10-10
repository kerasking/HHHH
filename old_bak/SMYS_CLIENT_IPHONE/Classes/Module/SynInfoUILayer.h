/*
 *  SynInfoUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_INFO_UI_LAYER_H__
#define __SYNDICATE_INFO_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"
#include "NDUIMemo.h"
#include "NDUICustomView.h"

using namespace NDEngine;

class SynInfoUILayer :
public NDUILayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(SynInfoUILayer)
public:
	static SynInfoUILayer* GetCurInstance();
private:
	static SynInfoUILayer* s_instance;
	
public:
	SynInfoUILayer();
	~SynInfoUILayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	void processSynInfo(NDTransData& data);
	void processSynBraodcast(NDTransData& data);
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	
	bool OnCustomViewConfirm(NDUICustomView* customView);
	
private:
	NDUILabel* m_lbInfoTitle;
	NDUIButton* m_btnQuitSyn;
	NDUIButton* m_btnChgSynBoard;
	NDUIButton* m_btnResign;
	
	NDUIMemo* m_synInfo;
	NDUIMemo* m_synNote;
	
	OBJID m_dlgSyndicateResign; // 军团辞职
	OBJID m_dlgSyndicateQuit; // 退出军团
};

#endif