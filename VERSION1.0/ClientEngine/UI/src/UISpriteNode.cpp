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
	m_pSpriteParentNode		= NULL;
	m_pSprite				= NULL;
}

CUISpriteNode::~CUISpriteNode()
{
	SAFE_DELETE_NODE(m_pSpriteParentNode);
}

void CUISpriteNode::Initialization()
{
	NDUINode::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_pSpriteParentNode	= new NDUINode;
	m_pSpriteParentNode->Initialization();
	m_pSpriteParentNode->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
}

/////////////////////////////////////////////////////////
void 
CUISpriteNode::SetPosition(int nPosX, int nPosY)
{
	CGPoint point;
	point.x = nPosX;
	point.y = nPosY;
	m_pSprite->SetPosition(point);
}

void CUISpriteNode::ChangeSprite(const char* sprfile)
{
	SAFE_DELETE_NODE(m_pSprite);
	
	if (!m_pSpriteParentNode || !sprfile)
	{
		return;
	}
	
	if (std::string("") == sprfile)
	{
		return;
	}
	
	m_pSprite		= new NDEngine::NDSprite;
	m_pSprite->Initialization(sprfile);
	m_pSprite->SetCurrentAnimation(0, false);
	m_pSpriteParentNode->AddChild(m_pSprite);
}

bool CUISpriteNode::isAnimationComplete()
{
	if(!m_pSprite)
	{
		return true;
	}
	
	return m_pSprite->IsAnimationComplete();
}

void CUISpriteNode::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	NDUINode::draw();
	
	if (!m_pSprite)
	{
		return;
	}
	
	
	//CGFloat w = m_pSprite->GetWidth();
	//CGFloat h = m_pSprite->GetHeight();
	CGRect scrRect	= this->GetScreenRect();
	CGPoint pos		= ccpAdd(scrRect.origin, 
							 ccp((scrRect.size.width ) / 2 ,
								 (scrRect.size.height) / 2) );
	
	m_pSprite->SetPosition(pos);
	m_pSprite->RunAnimation(true);
}

void CUISpriteNode::SetAnimation(int nIndex, bool bFaceRight)
{
	if (m_pSprite)
	{
		m_pSprite->SetCurrentAnimation(nIndex, bFaceRight);
	}
}

void CUISpriteNode::SetPlayFrameRange(int nStartFrame, int nEndFrame)
{
	if (m_pSprite)
	{
		m_pSprite->SetPlayFrameRange(nStartFrame, nEndFrame);
	}
}
