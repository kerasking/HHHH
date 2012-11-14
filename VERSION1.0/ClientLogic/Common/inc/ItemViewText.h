/*
 *  ItemViewText.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __ITEM_VIEW_TEXT_H__
#define __ITEM_VIEW_TEXT_H__

#include "define.h"
#include "NDUINode.h"
#include "NDPicture.h"

using namespace NDEngine;

// 需要支持的功能
// 1. 显示物品图表icon
// 2. 后面显示label

class Item;
class ItemViewText : public NDUINode
{
	DECLARE_CLASS(ItemViewText)
public:
	ItemViewText();
	~ItemViewText();
	
	void Initialization(Item* item, const char* pszText, const CCSize& size);
	
	void draw();
	
	void SetBackgroundColor(ccColor4B clrBg) {
		this->m_clrBackground = clrBg;
	}
	
	void SetFocusColor(ccColor4B clrFocus) {
		this->m_clrFocus = clrFocus;
	}
	
	Item* GetItem() const {
		return this->m_item;
	}
	
private:
	Item* m_item;
	ccColor4B m_clrBackground;		// 背景颜色
	ccColor4B m_clrFocus;			// 焦点色
};

#endif