/*
 *  SynUpgradeUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_UPGRADE_UI_LAYER_H__
#define __SYNDICATE_UPGRADE_UI_LAYER_H__

#include "define.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUIButton.h"

using namespace NDEngine;

class SynUpgradeUILayer :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SynUpgradeUILayer)
	static SynUpgradeUILayer* s_instance;
public:
	static SynUpgradeUILayer* GetCurInstance() {
		return s_instance;
	}
	
	void processSynUpgrade(NDTransData& data);
	
public:
	SynUpgradeUILayer();
	~SynUpgradeUILayer();
	
	void Initialization();
	
	void OnButtonClick(NDUIButton* button);
	
	void Query();
	
private:
	bool m_bQuery;
	NDUIMemo* m_memoContent1;
	NDUIMemo* m_memoContent2;
};

#endif