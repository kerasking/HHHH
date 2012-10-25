/*
 *  ItemViewText.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "ItemViewText.h"
#include "Item.h"
#include "ItemImage.h"
#include "NDUIItemButton.h"
#include "NDUtility.h"
#include "I_Analyst.h"

enum {
	ITEM_WH = 42,
};

IMPLEMENT_CLASS(ItemViewText, NDUINode)

ItemViewText::ItemViewText()
{
	m_item = NULL;
	m_clrFocus = INTCOLORTOCCC4(0xFFDA24);
	m_clrBackground = ccc4(0, 0, 0, 0);
}

ItemViewText::~ItemViewText()
{
	
}

void ItemViewText::Initialization(Item* item, const char* pszText, const CGSize& size)
{
	m_item = item;
	NDUINode::Initialization();
	NDUIItemButton* itemBtn = NULL;
	if (item)
	{
		itemBtn = new NDUIItemButton;
		itemBtn->Initialization();
		itemBtn->ChangeItem(item);
		itemBtn->SetFrameRect(CGRectMake(0, 0, ITEM_WH, ITEM_WH));
		this->AddChild(itemBtn);
	}
	CGRect rectText = CGRectMake(0, 0, size.width, size.height);
	if (itemBtn) {
		rectText.origin.x = ITEM_WH + 3;
		rectText.size.width -= rectText.origin.x;
	}
	
	NDUILabel* lbText = new NDUILabel;
	lbText->Initialization();
	lbText->SetText(pszText);
	lbText->SetTextAlignment(LabelTextAlignmentLeft);
	lbText->SetFrameRect(rectText);
	
	this->AddChild(lbText);
}

void ItemViewText::draw()
{
    TICK_ANALYST(ANALYST_ItemViewText);	
	NDNode* parentNode = this->GetParent();
	if (parentNode && parentNode->IsKindOfClass(RUNTIME_CLASS(NDUILayer))) {
		NDUILayer* uiLayer = (NDUILayer*)parentNode;
		if (uiLayer->GetFocus() == this) { // 当前处于焦点,绘制焦点色
			DrawRecttangle(this->GetScreenRect(), m_clrFocus);
		} else {
			DrawRecttangle(this->GetScreenRect(), m_clrBackground);
		}
	}
	NDUINode::draw();
}