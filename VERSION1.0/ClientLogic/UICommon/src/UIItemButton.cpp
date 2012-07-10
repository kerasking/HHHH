/*
 *  UIItemButton.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-3-5.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIItemButton.h"
#include "ItemUtil.h"
#include "NDUIImage.h"
#include "ItemImage.h"
#include "NDUILabel.h"
#include "ScriptGameLogic.h"
#include <sstream>

#include "CCPointExtension.h"
#include "NDUtility.h"

#define TAG_ITEM_COUNT (34567)
#define TAG_ITEM_LOCK (34568)

IMPLEMENT_CLASS(CUIItemButton, NDUIButton)

CUIItemButton::CUIItemButton()
{
	m_unItemId		= 0;
	m_unItemType	= 0;
	m_bLock			= false;
	m_bShowAdapt	= false;
}

CUIItemButton::~CUIItemButton()
{
}

void CUIItemButton::SetLock(bool bSet)
{
	m_bLock			= bSet;
	
	if (!m_bLock)
	{
		this->RemoveChild(TAG_ITEM_LOCK, true);
		return;
	}
	
	if (!this->GetChild(TAG_ITEM_LOCK))
	{
		NDPicture *pic	= NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("bg_grid_closed.png"));
		if (!pic)
		{
			return;
		}
		
		CGSize picSize	= pic->GetSize();
		CGRect rect	= this->GetFrameRect();
		rect.origin	= CGPointZero;
		if (picSize.width < rect.size.width)
		{
			rect.origin.x	= (rect.size.width - picSize.width) / 2;
			rect.size.width	= picSize.width;
		}
		if (picSize.height < rect.size.height)
		{
			rect.origin.y	= (rect.size.height - picSize.height) / 2;
			rect.size.height	= picSize.height;
		}
		NDUIImage* imgLock	= new NDUIImage;
		imgLock->Initialization();
		imgLock->SetFrameRect(rect);
		imgLock->SetPicture(pic, true);
		this->AddChild(imgLock);
		imgLock->SetVisible(this->IsVisibled());
	}
}

bool CUIItemButton::IsLock()
{
	return m_bLock;
}

void CUIItemButton::ChangeItem(unsigned int unItemId)
{
	m_unItemId					= unItemId;

	unsigned int nItemType		= GetItemInfoN(unItemId, ITEM_TYPE);
	
	this->ChangeItemType(nItemType);
	
	this->RefreshItemCount();
	
	if (unItemId > 0)
	{
		this->SetLock(false);
	}
}

unsigned int CUIItemButton::GetItemId()
{
	return m_unItemId;
}

void CUIItemButton::ChangeItemType(unsigned int unItemType)
{
	this->SetImage(NULL, false, CGRectZero, true);
	
	m_unItemType			= unItemType;
	
	unsigned int nIconIndex = GetItemDBN(unItemType, DB_ITEMTYPE_ICONINDEX);
	if (nIconIndex > 0)
	{
		NDPicture* pic	= ItemImage::GetSMItem(nIconIndex);
		if (pic)
		{
			if (!m_bShowAdapt)
			{
				CGSize size = pic->GetSize();
				CGRect frame = this->GetFrameRect();
				CGRect rect	= CGRectMake((frame.size.width - size.width) / 2, 
										 (frame.size.height - size.height) / 2, 
										 size.width, size.height);
				this->SetImage(pic, true, rect, true);
			}
			else
			{
				this->SetImage(pic, false, CGRectZero, true);
			}
		}
	}
}

unsigned int CUIItemButton::GetItemType()
{
	return m_unItemType;
}

void CUIItemButton::RefreshItemCount()
{
	unsigned int nItemCount		= 0;
	
	unsigned int nItemType		= GetItemInfoN(m_unItemId, ITEM_TYPE);
	
	if (IsItemCanChaiFen(nItemType))
	{
		nItemCount	= GetItemInfoN(m_unItemId, ITEM_AMOUNT);
	}
	
	this->ChangeItemCount(nItemCount);
}

void CUIItemButton::ChangeItemCount(unsigned int unItemCount)
{
	if (unItemCount == 0)
	{
		this->RemoveChild(TAG_ITEM_COUNT, true);
		return;
	}
	
	NDNode *pNode		= this->GetChild(TAG_ITEM_COUNT);
	NDUILabel *pLabel	= NULL;
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(NDUILabel)))
	{
		this->RemoveChild(TAG_ITEM_COUNT, true);
		
		CGRect rect = this->GetFrameRect();
		
		pLabel		= new NDUILabel;
		pLabel->Initialization();
		pLabel->SetFontSize(14);
		pLabel->SetFontColor(ccc4(255, 204, 120, 255));
		pLabel->SetTag(TAG_ITEM_COUNT);
		pLabel->SetTextAlignment(LabelTextAlignmentRight);
		pLabel->SetFrameRect(CGRectMake(
							 0.125 * rect.size.width, 
							 0.5 * rect.size.height, 
							 0.75 * rect.size.width,
							 0.333 * rect.size.height));
		this->AddChild(pLabel);
	}
	else
	{
		pLabel		= (NDUILabel*)pNode;
	}
	
	std::stringstream ss; ss << unItemCount;
	pLabel->SetText(ss.str().c_str());
	pLabel->SetVisible(this->IsVisibled());
}

void CUIItemButton::SetShowAdapt(bool bShowAdapt)
{
	m_bShowAdapt	= bShowAdapt;
}

bool CUIItemButton::IsShowAdapt()
{
	return m_bShowAdapt;
}

void CUIItemButton::draw()
{
	NDUIButton::draw();
	
	/*
	 CGRect scrRect = this->GetScreenRect();
	 
	 DrawLine(scrRect.origin, 
	 ccpAdd(scrRect.origin, ccp(scrRect.size.width, 0)),
	 ccc4(255, 255, 0, 255), 5);
	 
	 DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width, 0)),
	 ccpAdd(scrRect.origin, ccp(scrRect.size.width, scrRect.size.height)),
	 ccc4(255, 255, 0, 255), 5);
	 
	 DrawLine(ccpAdd(scrRect.origin, ccp(scrRect.size.width, scrRect.size.height)),
	 ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)),
	 ccc4(255, 255, 0, 255), 5);
	 
	 DrawLine(ccpAdd(scrRect.origin, ccp(0, scrRect.size.height)),
	 scrRect.origin,
	 ccc4(255, 255, 0, 255), 5);*/
	 
}