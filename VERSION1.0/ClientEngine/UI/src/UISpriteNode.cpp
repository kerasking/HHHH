/*
 *  UISpriteNode.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-2-22.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "UISpriteNode.h"

#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDUtil.h"
#include "NDSprite.h"
#include "NDDebugOpt.h"
#include "ObjectTracker.h"

IMPLEMENT_CLASS(CUISpriteNode, NDUINode)

CUISpriteNode::CUISpriteNode()
{
	INC_NDOBJ_RTCLS
	m_pSpriteParentNode		= NULL;
	m_pSprite				= NULL;
}

CUISpriteNode::~CUISpriteNode()
{
	DEC_NDOBJ_RTCLS
	SAFE_DELETE_NODE(m_pSpriteParentNode);
}

void CUISpriteNode::Initialization()
{
	NDUINode::Initialization();
	
	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	m_pSpriteParentNode	= new NDUINode;
	m_pSpriteParentNode->Initialization();
	m_pSpriteParentNode->SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));
}

void CUISpriteNode::ChangeSprite(const char* sprfile)
{
	SAFE_DELETE_NODE(m_pSprite);
    printf("SpriteFile[%s]\n", sprfile);
	if (!m_pSpriteParentNode || !sprfile)
	{
		return;
	}
	
	if (std::string("") == sprfile)
	{
		return;
	}
	
	m_pSprite		= new NDSprite;
	m_pSprite->Initialization(sprfile,this);
	m_pSprite->SetCurrentAnimation(0, false);
	m_pSpriteParentNode->AddChild(m_pSprite);
}

bool CUISpriteNode::IsAnimationComplete()
{
	if(!m_pSprite)
	{
		return true;
	}
	
	return m_pSprite->IsAnimationComplete();
}

void CUISpriteNode::draw()
{
	if (!NDDebugOpt::getDrawUIEnabled()) return;

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
	CCRect scrRect	= this->GetScreenRect();
	CCPoint pos		= ccpAdd(scrRect.origin, 
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

///////////////////////////////////////////////////////////////////////////////////////////////
#if 0
void 
CUISpriteNode::DisplayFrameEvent(int nCurrentAnimation, int nCurrentFrame)
{
    
}
/*一个动画播放完成后的回调*/
///////////////////////////////////////////////////////////////////////////////////////////////
void 
CUISpriteNode::DisplayCompleteEvent(int nCurrentAnimation, int nDispCount)
{
    
}
#endif 

//===========================================================================
//+2012.6.3++ Guosen ++ 
void CUISpriteNode::SetScale( float fScale )
{
	if( m_pSprite )
	{
		m_pSprite->SetScale(fScale);
	}
}

float CUISpriteNode::GetScale()
{
	if( m_pSprite )
	{
		return m_pSprite->GetScale();
	}
	return 0;
}

unsigned int CUISpriteNode::GetAnimationAmount()
{
	if( m_pSprite )
	{
		return m_pSprite->GetAnimationAmount();
	}
	return 0;
}

void CUISpriteNode::PlayAnimation( unsigned int nIndex, bool bReverse )
{
	if( m_pSprite )
	{
		return m_pSprite->SetCurrentAnimation( nIndex, bReverse );
	}
}
