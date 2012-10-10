/*
 *  SyndicateInfoLayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYNDICATE_INFO_LAYER_H__
#define __SYNDICATE_INFO_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUIMemo.h"
#include "NDUILabel.h"

using namespace NDEngine;

class SyndicateInfoLayer :
public NDUIMenuLayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SyndicateInfoLayer)
public:
	static void refresh(const string& title, const string& content);
	
private:
	static SyndicateInfoLayer* s_instance;
	
public:
	SyndicateInfoLayer();
	~SyndicateInfoLayer();
	
	void OnButtonClick(NDUIButton* button);
	void Initialization();
	
private:
	NDUILabel* m_lbTitle;
	NDUIMemo* m_memoContent;
	
private:
	void refreshContent(const string& title, const string& content);
};

#endif