/*
 *  UITabLogic.h
 *  SMYS
 *
 *  Created by jhzheng on 12-5-11.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _UI_TAB_LOGIC_H_ZJH_
#define _UI_TAB_LOGIC_H_ZJH_

#include "NDUINode.h"
#include "NDUIButton.h"
#include <vector>

using namespace NDEngine;


class CUITabLogic 
: public NDUINode
{
	DECLARE_CLASS(CUITabLogic)
	
public:
	void AddTab(NDUIButton* tab, NDUINode* client);
	
	void Select(NDUIButton* tab);
	
	void SelectWithIndex(int nIndex);
	
private:
	typedef CAutoLink<NDCommonProtocol>				NODE_TAB;
	typedef CAutoLink<NDCommonProtocol>				NODE_CLIENT;
	typedef struct _tagTabData
	{
		NODE_TAB		tab;
		NODE_CLIENT		client;
	}TAB_DATA;
	typedef std::vector<TAB_DATA>					VEC_TAB_DATA;
	typedef VEC_TAB_DATA::iterator					VEC_TAB_DATA_IT;
	
	VEC_TAB_DATA									m_vTabData;
	
public:
	// viewer of tab
	bool OnClick(NDObject* object);
};

#endif // _UI_TAB_LOGIC_H_ZJH_