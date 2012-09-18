/*
 *  UISpriteNode.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-2-22.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UISpriteNode.h"

#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDAnimationGroup.h"
#include "NDSprite.h"

IMPLEMENT_CLASS(CUISpriteNode, NDUINode)

CUISpriteNode::CUISpriteNode()
{
	m_pkSpriteParentNode		= NULL;
	m_pkSprite				= NULL;
}

CUISpriteNode::~CUISpriteNode()
{
	SAFE_DELETE_NODE(m_pkSpriteParentNode);
}

void CUISpriteNode::Initialization()
{
	NDUINode::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_pkSpriteParentNode	= new NDUINode;
	m_pkSpriteParentNode->Initialization();
	m_pkSpriteParentNode->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
}

/////////////////////////////////////////////////////////
void 
CUISpriteNode::SetPosition(int nPosX, int nPosY)
{
	CGPoint point;
	point.x = nPosX;
	point.y = nPosY;
	m_pkSprite->SetPosition(point);
}

void CUISpriteNode::ChangeSprite(const char* sprfile)
{
	SAFE_DELETE_NODE(m_pkSprite);
	
	if (!m_pkSpriteParentNode || !sprfile)
	{
		return;
	}
	
	if (std::string("") == sprfile)
	{
		return;
	}
	
	m_pkSprite		= new NDEngine::NDSprite;
	m_pkSprite->Initialization(sprfile);
	m_pkSprite->SetCurrentAnimation(0, false);
	m_pkSpriteParentNode->AddChild(m_pkSprite);
}

bool CUISpriteNode::isAnimationComplete()
{
	if(!m_pkSprite)
	{
		return true;
	}
	
	return m_pkSprite->IsAnimationComplete();
}

void CUISpriteNode::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	NDUINode::draw();
	
	if (!m_pkSprite)
	{
		return;
	}
	
	
	//CGFloat w = m_pSprite->GetWidth();
	//CGFloat h = m_pSprite->GetHeight();
	CGRect scrRect	= this->GetScreenRect();
	CGPoint pos		= ccpAdd(scrRect.origin, 
							 ccp((scrRect.size.width ) / 2 ,
								 (scrRect.size.height) / 2) );
	
	m_pkSprite->SetPosition(pos);
	m_pkSprite->RunAnimation(true);
}

void CUISpriteNode::SetAnimation(int nIndex, bool bFaceRight)
{
	if (m_pkSprite)
	{
		m_pkSprite->SetCurrentAnimation(nIndex, bFaceRight);
	}
}

void CUISpriteNode::SetPlayFrameRange(int nStartFrame, int nEndFrame)
{
	if (m_pkSprite)
	{
		m_pkSprite->SetPlayFrameRange(nStartFrame, nEndFrame);
	}
}
