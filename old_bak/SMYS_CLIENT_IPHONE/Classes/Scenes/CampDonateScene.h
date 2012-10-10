/*
 *  CampDonateScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _CAMP_DONATE_SCENE_H_
#define _CAMP_DONATE_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDUICustomView.h"
#include "GameItemBag.h"
#include "NDUIItemButton.h"
#include "NDUIDialog.h"
#include "NDPicture.h"

using namespace NDEngine;

void CampDonateUpdate(int iCamp, std::string title, VEC_SOCIAL_ELEMENT& elements);
////////////////////////////////////

class CampDonateScene : 
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(CampDonateScene)
public:
	CampDonateScene();
	~CampDonateScene();
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void refresh(int iCamp, std::string title, VEC_SOCIAL_ELEMENT& elements);
	void SetPage();
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	void UpdateMainUI(VEC_SOCIAL_ELEMENT& elements);
	int GetPageNum();
	void ClearSocialElements();
	void UpdatePage();
	void UpdateTitle();
	void ShowPage(int iPage);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUILabel *m_lbTitle;
	NDUITableLayer *m_tlMain, *m_tlOperate;
	NDUIButton *m_btnPrev; NDPicture *m_picPrev;
	NDUIButton *m_btnNext; NDPicture *m_picNext;
	NDUILabel *m_lbPage;
	int m_iCurPage;
	int m_iTotalPage;
	VEC_SOCIAL_ELEMENT m_vecElement;
	int m_iFocusIndex;
	std::string m_strTitle;
	
public:
	static int s_iCamp;
};

enum  
{
	eItemDonateType_Begin = 0,
	eItemDonateType_DONATE_WEAPON = eItemDonateType_Begin,
	eItemDonateType_DONATE_ARMOR,
	eItemDonateType_DONATE_REMEDY,
	eItemDonateType_End,
};

class ItemDonateScene : 
public NDScene,
public NDUIButtonDelegate,
public NDUITableLayerDelegate,
public GameItemBagDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(ItemDonateScene)
public:
	ItemDonateScene();
	~ItemDonateScene();
	
	void Initialization(int iType); hide
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	void UpdateFocus();
	void showConfirmDlg();
private:
	NDUIMenuLayer *m_menulayerBG;
	NDPicture *m_picTitle;
	GameItemBag *m_itemBag;
	ItemFocus *m_itemfocus;
	int m_iFocusIndex;
	
	NDUITableLayer *m_tlOperate;
	enum { eRow = 5, eCol = 4, };
	NDUIItemButton *m_btns[eRow*eCol];
	
	int m_iType;
};
#endif // _CAMP_DONATE_SCENE_H_