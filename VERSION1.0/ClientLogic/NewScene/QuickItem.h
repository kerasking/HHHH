/*
 *  QuickItem.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-19.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _QUICK_ITEM_H_
#define _QUICK_ITEM_H_

#include "NDUISpecialLayer.h"
#include "NDUIButton.h"
#include "NDUIAnimation.h"

using namespace NDEngine;

class NDUIItemTypeButton : public NDUIButton {
	DECLARE_CLASS(NDUIItemTypeButton)
public:
	NDUIItemTypeButton();
	~NDUIItemTypeButton();
	
	void Initialization();
	void draw();
	
	void ChangeItemType(int itemtype);
	
	unsigned int GetItemType() {
		return this->m_itemType;
	}
	
	void SetBackgroundPicture(NDPicture *pic);
	
	void refresh();
	
	NDPicture *GetItemPicture() {
		return this->m_picItem;
	}
private:
	int m_itemType;
	NDPicture* m_picItem;
	NDPicture* m_picBackGround;
};

class NDUIItemTypeImage : public NDUIImage
{
	DECLARE_CLASS(NDUIItemTypeImage)
	
public:
	NDUIItemTypeImage();
	~NDUIItemTypeImage();
	
	int GetItemType();
	
	void SetItemType(int itemType);
	
private:
	int m_itemType;
};

/***
* 临时性注释 郭浩
* this class
*/
//class QuickItem :
//public NDUIChildrenEventLayer,
//public NDUIButtonDelegate
//{
//	DECLARE_CLASS(QuickItem)
//	
//	QuickItem();
//	
//	~QuickItem();
//	
//public:
//	
//	void Initialization(); override
//	
//	void OnBattleBegin();
//	
//	void OnButtonClick(NDUIButton* button); override 
//	
//	//bool OnButtonLongClick(NDUIButton* button); override
//	
//	//void SetShrink(bool bShrink, bool animation=true); ///< 临时性注释 郭浩
//	
//	void Refresh(); // refresh data and ui
//	
//	void RefreshData();
//	
//	void RefreshUI();
//	
//	bool IsShrink();
//	
//	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
//	
//	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
//	
//	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
//	
//	bool OnButtonDragOver(NDUIButton* overButton, bool inRange); override
//	
//	bool OnButtonLongClick(NDUIButton* button); override
//	
//	bool OnButtonLongTouch(NDUIButton* button); override
//	
//	void OnButtonDown(NDUIButton* button); override
//	
//	void OnButtonUp(NDUIButton* button); override
//private:
//	void ReverseShrink();
//	
//	void DealShrink(float time);
//	
//	void RefreshSwitchPage();
//	
//	void ShowMask(bool show, NDPicture* pic=NULL, int itemType=0);
//private:
//	void InitItemCell();
//	CGRect GetCellRect(unsigned int index);
//	NDPicture* GetCellBackGround(unsigned int index);
//	
//private:
//	enum { max_btn = 18 };
//	
//	NDPicture  *m_picShrink;
//	NDUIButton *m_btnShrink;
//	
//	NDUIButton *m_btnConfig, *m_btnSwitch;
//	
//	NDUIItemTypeButton* m_btns[max_btn];
//	
//	NDUIChildrenEventLayer* m_layerBtnParent;
//	
//	NDUIImage* m_imgSecondBg;
//	
//	NDUIAnimation	m_curUiAnimation;
//	unsigned int	m_keyAnimation;
//	bool			m_stateShrink;
//	
//	unsigned int	m_uiCurPage;
//	
////	CAutoLink<NDUIMaskLayer> m_layerMask; ///< 临时性注释 郭浩
//};

#endif // _QUICK_ITEM_H_