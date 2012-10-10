/*
 *  VipStoreScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _VIP_STORE_SCENE_H_
#define _VIP_STORE_SCENE_H_

#include "NDScene.h"
#include "NDUIDialog.h"
#include "NDUITableLayer.h"
#include "NDUIMenuLayer.h"
#include "ImageNumber.h"
#include "NDUIButton.h"
#include "NDUICustomView.h"


void VipStoreUpdateEmoney();

///////////////////////////////////////
class StoreTabLayer;

class StoreTabLayerDelegate
{
public:
	virtual void OnFocusTablayer(StoreTabLayer* tablayer) {}
}; 

class StoreTabLayer : public NDUILayer
{
	DECLARE_CLASS(StoreTabLayer)
public:
	StoreTabLayer();
	~StoreTabLayer();
	
	void Initialization(); override
	void draw(); override
	
	bool TouchBegin(NDTouch* touch); override
	bool TouchEnd(NDTouch* touch); override
	
	void SetTabFocus(bool bTabFocus);
	void SetText(std::string text);
	
private:
	enum { eBegin = 0, eSel = eBegin, eUnSel, eEnd, };
	NDUILabel			*m_lbText;
	NDPicture			*m_picLeft[eEnd], *m_picRight[eEnd], *m_picMid[eEnd];
	bool				m_bTabFocus;
	bool				m_bCacl;
};

///////////////////////////////////////
class StoreItemLayer;
class StoreItemLayerDelegate
{
public:
	virtual void OnFocusStoreItemLayer(StoreItemLayer* storeitemlayer) {}
};

///////////////////////////////////////

#define vipstore_tab_count (5)

class VipStoreScene :
public NDScene,
public NDUIDialogDelegate,
public StoreTabLayerDelegate,
public StoreItemLayerDelegate,
//public NDUIVerticalScrollBarDelegate, ///< 临时性注释 郭浩
public NDUIButtonDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(VipStoreScene)
public:
	VipStoreScene();
	~VipStoreScene();
	
	static VipStoreScene * Scene();
	
	void Initialization(); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnFocusTablayer(StoreTabLayer* tablayer); override
	void OnFocusStoreItemLayer(StoreItemLayer* storeitemlayer); override
	void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar); override
	void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar); override
	void OnButtonClick(NDUIButton* button); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override

	void UpdateMoney();
	
	void SetTab(int iIndex);
private:
	void Adust(bool bUp);
	void Reset();
	void UpdateGui();
private:
	NDUIMenuLayer		*m_menulayerBG;
	NDUIImage			*m_imageTitle; NDPicture *m_picTitle;
	enum { eMaxTab = vipstore_tab_count, eCol = 2, eRow = 4,};
	StoreTabLayer		*m_tabLayer[eMaxTab];
	StoreItemLayer		*m_storeitemLayer[eCol*eRow];
	NDUIImage			*m_imageMoney; NDPicture *m_picMoney;
	ImageNumber			*m_imageNumMoney;
	NDUIPolygon			*m_nodePolygon;
	
	NDUIVerticalScrollBar *m_Scroll;
	int					m_iCurTabFocus;
	int					m_iCurVipItemFocusRow; //显示的第一个元素对应于物品列表
	int					m_iFocusLayerIndex;	   //相对于m_iCurVipItemFocusRow
};
#endif // _VIP_STORE_SCENE_H_