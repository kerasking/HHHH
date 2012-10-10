/*
 *  NDUISearchButton.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ND_UI_SEARCH_BUTTON_H__
#define __ND_UI_SEARCH_BUTTON_H__

#include "define.h"
#include "NDUIButton.h"

using namespace NDEngine;

class NDUISearchButton :
public NDUIButton
{
	DECLARE_CLASS(NDUISearchButton)
public:
	NDUISearchButton();
	~NDUISearchButton();
	
	void Initialization(); override
	void SetFrameRect(CGRect rect);
	void SetTitles(const string& title1, const string& title2);
	
private:
	NDUILabel* m_title2, *m_title1;
};

#endif