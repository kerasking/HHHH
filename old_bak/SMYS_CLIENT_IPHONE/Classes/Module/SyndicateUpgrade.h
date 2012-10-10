/*
 *  SyndicateUpgrade.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_UPGRADE_H__
#define __SYNDICATE_UPGRADE_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUIMemo.h"
#include "NDUILabel.h"

using namespace NDEngine;

class SyndicateUpgrade :
public NDUIMenuLayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SyndicateUpgrade)
public:
	static void refresh(NDTransData& data);
	
private:
	static SyndicateUpgrade* s_instance;
	
public:
	SyndicateUpgrade();
	~SyndicateUpgrade();
	
	void OnButtonClick(NDUIButton* button);
	void Initialization();
	
private:
	NDUILabel* m_lbTitle;
	NDUIMemo* m_memoContent1;
	NDUIMemo* m_memoContent2;
	
private:
	void refreshContent(NDTransData& data);
};

#endif