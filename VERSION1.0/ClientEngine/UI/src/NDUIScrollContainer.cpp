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
#include "UIScroll.h"
#include "CCPointExtension.h"
#include "NDUtil.h"
#include "ScriptGameLogic.h"
#include "NDPath.h"

IMPLEMENT_CLASS(NDUIScrollContainer, NDUILayer)

NDUIScrollContainer::NDUIScrollContainer()
{
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
		scroll->SetFrameRect(CCRectMake(rect.origin.x, 0, rect.size.width, rect.size.height));
		break;
	}
}
void NDUIScrollContainer::ScrollToBottom()
{
	CCRect selfRect							= this->GetFrameRect();
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
		if (rect.size.height < selfRect.size.height)
		{
			continue;
		}
		scroll->SetFrameRect(CCRectMake(rect.origin.x, selfRect.size.height - rect.size.height, 
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
	
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
//#else
//	NDDirector::DefaultDirector()->SetViewRect(this->GetScreenRect(), this);
//#endif
	
	NDUILayer::draw();
	DrawScrollBar();
}

bool NDUIScrollContainer::CanHorizontalMove(NDObject* object, float& hDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	CCRect rectself = this->GetFrameRect();
	CCRect rectmove = layer->GetFrameRect();
	
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

bool NDUIScrollContainer::CanVerticalMove(NDObject* object, float& vDistance)
{
	if (!object || !object->IsKindOfClass(RUNTIME_CLASS(CUIMovableLayer)))
	{
		return false;
	}
	
	CUIMovableLayer *layer = (CUIMovableLayer*)object;
	
	CCRect rectself = this->GetFrameRect();
	CCRect rectmove = layer->GetFrameRect();
	
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

bool NDUIScrollContainer::TouchBegin(NDTouch* touch)
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
		if (cocos2d::CCRect::CCRectContainsPoint(((NDUINode*)pNode)->GetScreenRect(), touch->GetLocation()))
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
	NDNode *pNode		= m_kChildrenList[0];
	if (!pNode || !pNode->IsKindOfClass(RUNTIME_CLASS(CUIScroll)))
	{
		return;
	}
	CUIScroll* scroll	= (CUIScroll*)pNode;
	if (scroll->GetScrollStyle() != UIScrollStyleVerical ||
		!scroll->IsTouchDown())
	{
		return;
	}
	CCRect rectScroll	= scroll->GetFrameRect();
	if(rectScroll.size.height > this->GetFrameRect().size.height)
	{
		CCRect rectself		= this->GetScreenRect();
		CCRect rectClient	= rectScroll;
		CCRect rect			= CCRectZero;
		//float fScale		= NDDirector::DefaultDirector()->GetScaleFactor();
		CCSize sizePic		= m_picScroll->GetSize();
		rect.size.width		= sizePic.width;
		rect.size.height	= rectself.size.height / rectClient.size.height * rectself.size.height;//sizePic.height * fScale;
		rect.origin			= ccp(rectself.size.width - rect.size.width,
								  -rectClient.origin.y / rectClient.size.height * rectself.size.height);
		rect.origin			= ccpAdd(rect.origin, this->GetScreenRect().origin);
		
		m_picScroll->DrawInRect(rect);
        
        if(m_picScrollBg) {
            rect.origin.y = rectClient.origin.y;
            m_picScrollBg->DrawInRect(rect);
        }
	}	
}
