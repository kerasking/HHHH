/*
 *  NDUIItemButton.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __NDUI_ITEM_BUTTON_H__
#define __NDUI_ITEM_BUTTON_H__

#include "NDUIButton.h"
#include "define.h"
#include "ItemMgr.h"
#include "NDUILayer.h"
#include "ImageNumber.h"

using namespace NDEngine;

class NDUIItemButton : public NDUIButton {
	DECLARE_CLASS(NDUIItemButton)
public:
	NDUIItemButton();
	~NDUIItemButton();
	
	void Initialization(); override
	void draw(); override
	
	void ChangeItem(Item* item, bool gray=false);
	
	Item* GetItem()	{ return m_pItem; }
	
	void setBackDack(bool bSet){ 
		if(m_backDackLayer){
			m_backDackLayer->SetVisible(bSet);
		}
	}
	
	void SetDefaultItemPicture(NDPicture *pic);
	
	void EnalbeGray(bool gray) { if (m_picItem) m_picItem->SetGrayState(gray); } hide
	
	bool IsGray() { if (m_picItem) return m_picItem->IsGrayState(); return false; } hide
	
	void ShowItemCount(bool show) { m_showItemCount = show; }
	
	void SetItemCount(unsigned int amount);
	
	void SetShowItemOnly(bool bShow);
	
	bool IsShowItemOnly() { return m_ShowItemOnly; }
private:
	Item* m_pItem;			// 有空时改成存ID
	NDPicture* m_picItem;
	NDUILayer* m_colorLayer; // 物品品质背景色
	NDUILayer* m_backDackLayer;
	NDPicture* m_picColor;
	NDPicture* m_picDefaultItem;
	ImageNumber *m_imageNumItemCount;
	unsigned int m_uiItemCount;
	bool m_showItemCount, m_ShowItemOnly;
};

#endif