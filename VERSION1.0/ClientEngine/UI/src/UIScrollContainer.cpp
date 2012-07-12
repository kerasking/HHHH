/*
 *  UIScrollContainer.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-10.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIScrollContainer.h"
#include "NDDirector.h"

IMPLEMENT_CLASS(CUIScrollContainer, NDUILayer)

CUIScrollContainer::CUIScrollContainer()
{
	m_uiLeftDistance			= 0;
	m_uiRightDistance			= 0;
	m_uiLeftDistance			= 0;
	m_uiTopDistance				= 0;
	m_uiBottomDistance			= 0;
}

CUIScrollContainer::~CUIScrollContainer()
{
}

void CUIScrollContainer::Initialization()
{
	NDUILayer::Initialization();
}

void CUIScrollContainer::SetLeftReserveDistance(unsigned int distance)
{
	m_uiLeftDistance			= distance; 
}

void CUIScrollContainer::SetRightReserveDistance(unsigned int distance)
{
	m_uiRightDistance			= distance; 
}

void CUIScrollContainer::SetTopReserveDistance(unsigned int distance)
{
	m_uiTopDistance				= distance; 
}

void CUIScrollContainer::SetBottomReserveDistance(unsigned int distance)
{
	m_uiBottomDistance			= distance; 
}

void CUIScrollContainer::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
	
	NDUILayer::draw();
}

bool CUIScrollContainer::CanHorizontalMove(NDObject* object, float& hDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	CGRect rectself = this->GetFrameRect();
	CGRect rectmove = layer->GetFrameRect();
	
	if (hDistance > 0.0f)
	{
		if ( (rectself.size.width - m_uiRightDistance) <
			 (rectmove.origin.x + hDistance) )
		{
            hDistance = rectself.size.width - m_uiRightDistance - rectmove.origin.x;
			return true;
		}
	}
	else if (hDistance < 0.0f)
	{
		if ( (m_uiLeftDistance) >
			 (rectmove.origin.x + rectmove.size.width + hDistance) )
		{
            hDistance = m_uiLeftDistance - (rectmove.origin.x + rectmove.size.width);
			return true;
		}
	}
	else
	{
		return false;
	}
	
	return true;
}

bool CUIScrollContainer::CanVerticalMove(NDObject* object, float& vDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	CGRect rectself = this->GetFrameRect();
	CGRect rectmove = layer->GetFrameRect();
	
	if (vDistance > 0.0f)
	{
		if ( (rectself.size.height - m_uiBottomDistance) <
			(rectmove.origin.y + vDistance) )
		{
			return false;
		}
	}
	else if (vDistance < 0.0f)
	{
		if ( (m_uiTopDistance) >
			(rectmove.origin.y + rectmove.size.height + vDistance) )
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

bool CUIScrollContainer::TouchBegin(NDTouch* touch)
{
	const std::vector<NDNode*>& childlist	= this->GetChildren();
	std::vector<NDNode*>::const_iterator it	= childlist.begin();
	
	for (; it != childlist.end(); it++) 
	{
		NDNode* pNode	= (*it);
		if (!pNode->IsKindOfClass(RUNTIME_CLASS(NDUINode)))
		{
			continue;
		}
		if (CGRectContainsPoint(((NDUINode*)pNode)->GetScreenRect(), touch->GetLocation()))
		{
			return NDUILayer::TouchBegin(touch);
		}
	}
	
	return false;
}