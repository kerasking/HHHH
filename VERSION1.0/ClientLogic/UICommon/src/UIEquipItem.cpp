/*
 *  UIEquipItem.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-7.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIEquipItem.h"
#include "NDPath.h"
#include "NDDirector.h"
#include "ObjectTracker.h"

IMPLEMENT_CLASS(CUIEquipItem, CUIItemButton)
#define G_UPGRADE_SPRITE "shengjiejt01.spr"
#define R_UPGRADE_SPRITE "shengjiejt02.spr"

#define UPGRADE_ICON_W      (RESOURCE_SCALE * 15)
#define UPGRADE_ICON_H      (RESOURCE_SCALE * 30)

CUIEquipItem::CUIEquipItem()
{
	INC_NDOBJ_RTCLS
    m_nUpgradeIconPos   = 0;
    m_GUpgradeSprite    = NULL;
    m_RUpgradeSprite    = NULL;
    m_nIsUpgrade        = 0;
}

CUIEquipItem::~CUIEquipItem()
{
	DEC_NDOBJ_RTCLS
    m_GUpgradeSprite = NULL;
    m_RUpgradeSprite = NULL;
}

void CUIEquipItem::Initialization()
{
    CUIItemButton::Initialization();    
}

void CUIEquipItem::AdjustPos()
{
	if (m_nIsUpgrade != 0)
	{

		if (m_GUpgradeSprite == NULL)
		{
			//** ³õÊ¼»¯Éý¼¶Í¼Æ¬ **//

			m_GUpgradeSprite = new CUISpriteNode;
			m_GUpgradeSprite->Initialization();
			m_GUpgradeSprite->ChangeSprite(
				NDPath::GetAniPath(G_UPGRADE_SPRITE).c_str());
			this->AddChild(m_GUpgradeSprite);
		}

		if (m_RUpgradeSprite == NULL)
		{
			m_RUpgradeSprite = new CUISpriteNode;
			m_RUpgradeSprite->Initialization();
			m_RUpgradeSprite->ChangeSprite(
				NDPath::GetAniPath(R_UPGRADE_SPRITE).c_str());
			this->AddChild(m_RUpgradeSprite);
		}

		if (m_nIsUpgrade == 1)
		{
			m_GUpgradeSprite->SetVisible(true);
			m_RUpgradeSprite->SetVisible(false);
		}
		else
		{
			m_GUpgradeSprite->SetVisible(false);
			m_RUpgradeSprite->SetVisible(true);
		}

		CCRect rect = this->GetFrameRect();
		CCRect rectT;
		if (m_nUpgradeIconPos == 0)
		{
			rectT = CCRectMake(-UPGRADE_ICON_W,
				rect.size.height - UPGRADE_ICON_H, UPGRADE_ICON_W,
				UPGRADE_ICON_H);
		}
		else
		{
			rectT = CCRectMake(rect.size.width,
				rect.size.height - UPGRADE_ICON_H, UPGRADE_ICON_W,
				UPGRADE_ICON_H);
		}
		m_GUpgradeSprite->SetFrameRect(rectT);
		m_RUpgradeSprite->SetFrameRect(rectT);
	}
	else
	{
		if (m_GUpgradeSprite)
		{
			m_GUpgradeSprite->SetVisible(false);
		}
		if (m_GUpgradeSprite)
		{
			m_RUpgradeSprite->SetVisible(false);
		}
	}
}

void CUIEquipItem::SetItemFrameRect(CCRect rect)
{
	SetFrameRect(rect);
}

void CUIEquipItem::CloseItemFrame()
{
	CloseFrame();
}

void CUIEquipItem::SetItemBackgroundPicture(NDPicture *pic,
											 NDPicture *touchPic /*= NULL*/, bool useCustomRect /*= false*/,
											 CCRect customRect /*= CGRectZero*/, bool clearPicOnFree /*= false*/)
{
	SetBackgroundPicture(pic, touchPic, useCustomRect, customRect,
		clearPicOnFree);
}

void CUIEquipItem::SetItemBackgroundPictureCustom(NDPicture *pic,
												   NDPicture *touchPic /*= NULL*/, bool useCustomRect /*= false*/,
												   CCRect customRect /*= CGRectZero*/)
{
	SetBackgroundPictureCustom(pic, touchPic, useCustomRect, customRect);
}

void CUIEquipItem::SetItemTouchDownImage(NDPicture *pic,
									 bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/,
									 bool clearPicOnFree /*= false*/)
{
	SetTouchDownImage(pic, useCustomRect, customRect, clearPicOnFree);
}

void CUIEquipItem::SetItemTouchDownImageCustom(NDPicture *pic,
										   bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/)
{
	SetTouchDownImageCustom(pic, useCustomRect, customRect);
}

void CUIEquipItem::SetItemFocusImage(NDPicture *pic,
									  bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/,
									  bool clearPicOnFree /*= false*/)
{
	SetFocusImage(pic, useCustomRect, customRect, clearPicOnFree);
}

void CUIEquipItem::SetItemFocusImageCustom(NDPicture *pic,
											bool useCustomRect /*= false*/, CCRect customRect /*= CGRectZero*/)
{
	SetFocusImageCustom(pic, useCustomRect, customRect);
}

void CUIEquipItem::InitializationItem()
{
	Initialization();
}