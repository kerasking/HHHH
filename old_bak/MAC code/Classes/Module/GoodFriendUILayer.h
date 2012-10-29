/*
 *  GoodFriend.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __GOOD_FRIEND_H__
#define __GOOD_FRIEND_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "NDUICustomView.h"
#include "FriendElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"

using namespace NDEngine;

enum
{
	GoodFriendNormal,
	GoodFriendEmail,
};

class GoodFriendUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate,
public IPageButtonDelegate
{
	DECLARE_CLASS(GoodFriendUILayer)
public:
	static void refreshScroll();
	
private:
	static GoodFriendUILayer* s_instance;
	
public:
	GoodFriendUILayer();
	~GoodFriendUILayer();
	
	void OnPageChange(int nCurPage, int nTotalPage); override
	bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnButtonClick(NDUIButton* button);
	bool TouchEnd(NDTouch* touch);
	
	void Initialization(int iType = GoodFriendNormal);
	
private:	
	FriendElement* m_curSelEle;
	NDOptLayer* m_optLayer;
public:
	NDUITableLayer* m_tlMain;
	
private:
	void refreshMainList();
	void showCustomeView();
private:
	int m_iType;
	NDPageButton* m_btnPage;
	int m_nCurPage;
};

#endif