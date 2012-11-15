/*
 *  FavoriteAccountList.h
 *  DragonDrive
 *
 *  Created by wq on 11-2-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __FAVORITE_ACCOUNT_LIST_H__
#define __FAVORITE_ACCOUNT_LIST_H__

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUIMenuLayer.h"
#include "NDDataPersist.h"
#include "NDUIDefaultTableLayer.h"
#include "NDUIDefaultButton.h"
#include "NDTimer.h"

using namespace NDEngine;

/*
class FavoriteAccountList : public NDScene, public NDUIButtonDelegate, public NDUITableLayerDelegate
{
	DECLARE_CLASS(FavoriteAccountList)
	FavoriteAccountList();
	~FavoriteAccountList();
public:
	static FavoriteAccountList* Scene();
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	
private:
	NDUIMenuLayer *m_menuLayer;
	NDUITableLayer *m_accountList;
	uint m_lastAccountCellIndex;
	NDDataPersist m_accountListData;
	VEC_ACCOUNT m_vAccount;
};
*/

#pragma mark 新的账号列表

class AccountListRecord : public NDUINode
{
	DECLARE_CLASS(AccountListRecord)
public:
	AccountListRecord();
	
	~AccountListRecord();
	
	void Initialization(std::string text); hide
	
	void SetFrameRect(CCRect rect); override
	
	void draw();
private:
	NDPicture *m_picSel;
	NDUILabel *m_lbText;
};

class NewFavoriteAccountList : 
public NDScene, 
public NDUIButtonDelegate, 
public NDUIDefaultTableLayerDelegate,
public ITimerCallback
{
	DECLARE_CLASS(NewFavoriteAccountList)
public:
	NewFavoriteAccountList();
	~NewFavoriteAccountList();
public:
	static NewFavoriteAccountList* Scene();
	void Initialization(); override 
	void OnButtonClick(NDUIButton* button); override
	void OnDefaultTableLayerCellFocused(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	void OnDefaultTableLayerCellSelected(NDUIDefaultTableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnTimer(OBJID tag); override
private:
	void OnClickOk();
	void DealSel();
private:
	NDUILayer	*m_menuLayer;
	NDUIDefaultTableLayer  *m_tableLayer;
	NDUIOkCancleButton *m_btnOk, *m_btnCancel;
	NDDataPersist m_accountListData;
	VEC_ACCOUNT m_vAccount;
	unsigned int m_curCellIndex;
	NDTimer		m_timer;
};

#endif