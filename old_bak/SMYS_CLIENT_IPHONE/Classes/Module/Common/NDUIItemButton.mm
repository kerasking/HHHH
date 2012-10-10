/*
 *  NDUIItemButton.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUIItemButton.h"
#include "NDUtility.h"
#include "ItemImage.h"

#define BKCOLOR4 (ccc4(227, 229, 218, 255))

IMPLEMENT_CLASS(NDUIItemButton, NDUIButton)

NDUIItemButton::NDUIItemButton()
{
	this->m_pItem = NULL;
	this->m_picItem = NULL;
	m_colorLayer = NULL;
	m_backDackLayer = NULL;
	m_picColor = NULL;
	m_picDefaultItem = NULL;
	m_imageNumItemCount = NULL;
	m_uiItemCount = 0;
	
	m_showItemCount = true;
	
	m_ShowItemOnly = false;
}

NDUIItemButton::~NDUIItemButton()
{
	SAFE_DELETE(this->m_image);
	SAFE_DELETE(this->m_picItem);
	SAFE_DELETE(m_colorLayer);
	SAFE_DELETE(m_backDackLayer);
	SAFE_DELETE(m_picDefaultItem);
	SAFE_DELETE(m_imageNumItemCount);
}

void NDUIItemButton::Initialization()
{
	NDUIButton::Initialization();
	//this->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPath("ui_item.png")), false, CGRectMake(0, 0, 0, 0));
	
	this->CloseFrame();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	this->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_bagitem.png")), NULL, false, CGRectZero, true);
	
	this->SetFocusImage(pool.AddPicture(GetImgPathNew("bag_bagitem_sel.png")), false, CGRectZero, true);
	
	m_backDackLayer = new NDUILayer;
	m_backDackLayer->Initialization();
	m_backDackLayer->SetTouchEnabled(false);
	m_backDackLayer->SetBackgroundColor(ccc4(255, 0, 0, 85));
	m_backDackLayer->SetVisible(false);
	
	m_imageNumItemCount = new ImageNumber;
	m_imageNumItemCount->Initialization();
}

void NDUIItemButton::draw()
{
	NDUIButton::draw();
	
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	CGRect rectItemImg = this->GetScreenRect();
	rectItemImg.origin.x += 2;
	rectItemImg.origin.y += 2;
	rectItemImg.size.width -= 4;
	rectItemImg.size.height -= 4;
	
	if (this->m_picColor && !m_ShowItemOnly) 
	{
		this->m_picColor->DrawInRect(rectItemImg);
	}
	else if (this->m_colorLayer && !m_ShowItemOnly) 
	{
		this->m_colorLayer->SetFrameRect(rectItemImg);
		this->m_colorLayer->draw();
	}
	
	if (this->m_picItem) {
		this->m_picItem->DrawInRect(rectItemImg);
		
		if (m_uiItemCount > 0 && m_imageNumItemCount && m_showItemCount && !m_ShowItemOnly)
		{
			CGSize size = m_imageNumItemCount->GetNumberSize();
			m_imageNumItemCount->SetFrameRect(CGRectMake(rectItemImg.origin.x+rectItemImg.size.width-size.width-2,
											  rectItemImg.origin.y+rectItemImg.size.height-size.height,
											  size.width,
											  size.height));
			m_imageNumItemCount->draw();
			
			const std::vector<NDNode*>& children = m_imageNumItemCount->GetChildren();
			
			for_vec(children, std::vector<NDNode*>::const_iterator)
			{
				if (!(*it)->IsKindOfClass(RUNTIME_CLASS(NDUINode))) continue;
				
				((NDUINode*)(*it))->draw();
			}
		}
	}
	else if (this->m_picDefaultItem && !m_ShowItemOnly)
	{
		this->m_picDefaultItem->DrawInRect(rectItemImg);
	}
	
	if (this->m_backDackLayer && this->m_backDackLayer->IsVisibled() && !m_ShowItemOnly) {
		this->m_backDackLayer->SetFrameRect(rectItemImg);
		this->m_backDackLayer->draw();
	}
}

void NDUIItemButton::ChangeItem(Item* item, bool gray/*=false*/)
{
	SAFE_DELETE(this->m_picItem);
	SAFE_DELETE(this->m_colorLayer);
	SAFE_DELETE(this->m_picColor);
	
	m_uiItemCount = 0;
	m_pItem	= item;
	
	if (item)
	{
		int iIconIndex = item->getIconIndex();
		
		if (iIconIndex > 0)
		{
			iIconIndex = (iIconIndex % 100 - 1) + (iIconIndex / 100 - 1) * 6;
		}
		
		if (iIconIndex != -1)
		{
			this->m_picItem = ItemImage::GetItem(iIconIndex, gray);
			if (this->m_picItem) this->m_picItem->SetGrayState(gray);
			this->m_colorLayer = new NDUILayer;
			m_colorLayer->Initialization();
			CGRect rectItemImg = this->GetScreenRect();
			rectItemImg.origin.x += 2;
			rectItemImg.origin.y += 2;
			rectItemImg.size.width -= 4;
			rectItemImg.size.height -= 4;
			this->m_colorLayer->SetFrameRect(rectItemImg);
			m_colorLayer->SetBackgroundColor(INTCOLORTOCCC4(item->getItemColor()));
			m_picColor = ItemImage::GetPinZhiPic(item->iItemType);
		}
		
		//int type = Item::getIdRule(item->iItemType,Item::ITEM_TYPE); // 物品类型
		if (item->canChaiFen() && !item->isRidePet())
		{
			m_uiItemCount = item->iAmount;
			m_imageNumItemCount->SetSmallRedNumber(item->iAmount);
		}
		else 
		{
			m_uiItemCount = 0;
		}

	}
	
	setBackDack(false);
}

void NDUIItemButton::SetShowItemOnly(bool bShow) 
{ 
	m_ShowItemOnly = bShow; 
	
	this->SetBackgroundPicture(NULL);
	
	this->SetFocusImage(NULL);
}

void NDUIItemButton::SetDefaultItemPicture(NDPicture *pic)
{
	SAFE_DELETE(m_picDefaultItem);
	
	m_picDefaultItem = pic;
}

void NDUIItemButton::SetItemCount(unsigned int amount)
{
	if (m_pItem && m_pItem->canChaiFen() && !m_pItem->isRidePet())
	{
		m_uiItemCount = amount;
		m_imageNumItemCount->SetSmallRedNumber(amount);
	}
}
