/*
 *  UIScrollContainer.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDUIScrollContainer.h"
#include "NDDirector.h"
#include "NDUIScroll.h"
#include "CCPointExtension.h"
#include "NDUtil.h"
#include "ScriptGameLogic.h"
#include "NDPath.h"
#include "ObjectTracker.h"

IMPLEMENT_CLASS(NDUIScrollContainer, NDUILayer)

NDUIScrollContainer::NDUIScrollContainer()
{
	INC_NDOBJ_RTCLS
	m_uiLeftDistance			= 0;
	m_uiRightDistance			= 0;
	m_uiLeftDistance			= 0;
	m_uiTopDistance				= 0;
	m_uiBottomDistance			= 0;
	m_bOpenScrollBar			= false;
	m_picScroll					= NULL;
    m_picScrollBg               = NULL;
}

NDUIScrollContainer::~NDUIScrollContainer()
{
	DEC_NDOBJ_RTCLS
	SAFE_DELETE(m_picScroll);
    SAFE_DELETE(m_picScrollBg);
    m_picScroll = NULL;
    m_picScrollBg = NULL;
}

void NDUIScrollContainer::Initialization()
{
	NDUILayer::Initialization();
}

void NDUIScrollContainer::SetLeftReserveDistance(unsigned int distance)
{
	m_uiLeftDistance			= distance; 
}

void NDUIScrollContainer::SetRightReserveDistance(unsigned int distance)
{
	m_uiRightDistance			= distance; 
}

void NDUIScrollContainer::SetTopReserveDistance(unsigned int distance)
{
	m_uiTopDistance				= distance; 
}

void NDUIScrollContainer::SetBottomReserveDistance(unsigned int distance)
{
	m_uiBottomDistance			= distance; 
}

void NDUIScrollContainer::ScrollToTop()
{
	const std::vector<NDNode*>& kChildren	= this->GetChildren();
	for(std::vector<NDNode*>::const_iterator it = kChildren.begin();
		it != kChildren.end();
		it++)
	{
		NDNode* pkNode			= *it;
		if (!pkNode->IsKindOfClass(RUNTIME_CLASS(CUIScroll)))
		{
			continue;
		}
		CUIScroll* pkScroll		= (CUIScroll*)pkNode;
		CCRect kRect				= pkScroll->GetFrameRect();
		pkScroll->SetFrameRect(CCRectMake(kRect.origin.x, 0,
			kRect.size.width, kRect.size.height));
		break;
	}
}
void NDUIScrollContainer::ScrollToBottom()
{
	CCRect kSelfRect							= this->GetFrameRect();
	const std::vector<NDNode*>& children	= this->GetChildren();
	for(std::vector<NDNode*>::const_iterator it = children.begin();
		it != children.end();
		it++)
	{
		NDNode* node			= *it;
		if (!node->IsKindOfClass(RUNTIME_CLASS(CUIScroll)))
		{
			continue;
		}
		CUIScroll* scroll		= (CUIScroll*)node;
		CCRect rect				= scroll->GetFrameRect();
		if (rect.size.height < kSelfRect.size.height)
		{
			continue;
		}
		scroll->SetFrameRect(CCRectMake(rect.origin.x, kSelfRect.size.height - rect.size.height, 
										rect.size.width, rect.size.height));
		break;
	}
}
void NDUIScrollContainer::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}

	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);

	NDUILayer::draw();
	DrawScrollBar();
}

bool NDUIScrollContainer::CanHorizontalMove(NDObject* object, float& hDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer* pkLayer = (CUIMovableLayer*)object;
	
	CCRect kSelfRect = this->GetFrameRect();
	CCRect kMoveRect = pkLayer->GetFrameRect();
	
	if (hDistance > 0.0f)
	{
		if ( (kSelfRect.size.width - m_uiRightDistance) <
			 (kMoveRect.origin.x + hDistance) )
		{
            hDistance = kSelfRect.size.width - m_uiRightDistance - kMoveRect.origin.x;
			return true;
		}
	}
	else if (hDistance < 0.0f)
	{
		if ( (m_uiLeftDistance) >
			 (kMoveRect.origin.x + kMoveRect.size.width + hDistance) )
		{
            hDistance = m_uiLeftDistance - (kMoveRect.origin.x + kMoveRect.size.width);
			return true;
		}
	}
	else
	{
		return false;
	}
	
	return true;
}

bool NDUIScrollContainer::CanVerticalMove(NDObject* object, float& vDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	CCRect kSelfRect = this->GetFrameRect();
	CCRect kMoveRect = layer->GetFrameRect();
	
	if (vDistance > 0.0f)
	{
		if ( (kSelfRect.size.height - m_uiBottomDistance) <
			(kMoveRect.origin.y + vDistance) )
		{
			return false;
		}
	}
	else if (vDistance < 0.0f)
	{
		if ( (m_uiTopDistance) >
			(kMoveRect.origin.y + kMoveRect.size.height + vDistance) )
		{
			return false;
		}
	}
	else
	{
		return false;
	}
	
	return true;
}

bool NDUIScrollContainer::TouchBegin(NDTouch* touch)
{
	if (!this->IsVisibled())
	{
		return false;
	}

	const std::vector<NDNode*>& kChildList	= this->GetChildren();
	std::vector<NDNode*>::const_iterator it	= kChildList.begin();
	
	for (; it != kChildList.end(); it++) 
	{
		NDNode* pNode = (*it);

		if (!pNode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
		{
			continue;
		}

		if (cocos2d::CCRect::CCRectContainsPoint(((NDUINode*)pNode)->GetScreenRect(),
			touch->GetLocation()))
		{
			return NDUILayer::TouchBegin(touch);
		}
	}
	
	return false;
}

void NDUIScrollContainer::EnableScrollBar(bool bEnable)
{
	m_bOpenScrollBar = bEnable;

	if (m_bOpenScrollBar)
	{
		if (m_picScroll == NULL)
		{
			m_picScroll = NDPicturePool::DefaultPool()->AddPicture(
				NDPath::GetSMImgPath("General/texture/texture5.png"));
		}

		if (m_picScrollBg == NULL)
		{
			m_picScrollBg = NDPicturePool::DefaultPool()->AddPicture(
				NDPath::GetSMImgPath("General/texture/texture4.png"));
		}
	}
	else
	{
		delete m_picScroll;
		m_picScroll = NULL;

		delete m_picScrollBg;
		m_picScrollBg = NULL;
	}

}

void NDUIScrollContainer::DrawScrollBar()
{
	if (!(m_bOpenScrollBar && m_picScroll))
	{
		return;
	}
	if (0 == int(m_kChildrenList.size()))
	{
		return;
	}
	NDNode* pNode = m_kChildrenList[0];
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScroll)))
	{
		return;
	}
	CUIScroll* pkScroll	= (CUIScroll*)pNode;
	if (pkScroll->GetScrollStyle() != UIScrollStyleVerical ||
		!pkScroll->IsTouchDown())
	{
		return;
	}
	CCRect kScrollRect	= pkScroll->GetFrameRect();
	if(kScrollRect.size.height > this->GetFrameRect().size.height)
	{
		CCRect kSelfRect		= this->GetScreenRect();
		CCRect kClientRect	= kScrollRect;
		CCRect kRect			= CCRectZero;
		CCSize kPicSize		= m_picScroll->GetSize();
		kRect.size.width		= kPicSize.width;
		kRect.size.height	= kSelfRect.size.height / kClientRect.size.height * kSelfRect.size.height;
		kRect.origin			= ccp(kSelfRect.size.width - kRect.size.width,
								  -kClientRect.origin.y / kClientRect.size.height * kSelfRect.size.height);
		kRect.origin			= ccpAdd(kRect.origin, this->GetScreenRect().origin);
		
		m_picScroll->DrawInRect(kRect);

		if(m_picScrollBg)
		{
			kRect.origin.y = kClientRect.origin.y;
			m_picScrollBg->DrawInRect(kRect);
		}
	}	
}