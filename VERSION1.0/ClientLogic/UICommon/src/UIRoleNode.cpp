/*
 *  UIRoleNode.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-20.
 *  Copyright 2012 (����)DeNA. All rights reserved.
 *
 */

#include "UIRoleNode.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDUtility.h"
#include "NDConstant.h"
#include "CCGeometry.h"

IMPLEMENT_CLASS(CUIRoleNode, NDUINode)

using namespace cocos2d;

CUIRoleNode::CUIRoleNode()
{
	m_pRoleParentNode		= NULL;
	m_pRole					= NULL;
}

CUIRoleNode::~CUIRoleNode()
{
	SAFE_DELETE_NODE(m_pRoleParentNode);
}

void CUIRoleNode::Initialization()
{
	NDUINode::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_pRoleParentNode	= new NDUINode;
	m_pRoleParentNode->Initialization();
	m_pRoleParentNode->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
}

void CUIRoleNode::ChangeLookFace(int nLookFace)
{
	SAFE_DELETE_NODE(m_pRole);
	
	if (0 >= nLookFace)
	{
		return;
	}
	
	if (!m_pRoleParentNode)
	{
		return;
	}
	
	m_pRole		= new NDManualRole;
	m_pRole->Initialization(nLookFace);
	m_pRole->SetCurrentAnimation(MANUELROLE_STAND, false);
	m_pRoleParentNode->AddChild(m_pRole);
}

void CUIRoleNode::SetRoleScale(float scale)
{
	if(m_pRole){
		m_pRole->SetScale(scale);
	}
}

void CUIRoleNode::SetEquip(int nEquipId, int nQuality)
{
	if (!m_pRole)
	{
		return;
	}
	
	m_pRole->SetEquipment(nEquipId, nQuality);
}

void CUIRoleNode::draw()
{
	if (!this->IsVisibled())
	{
		return;
	}
	
	NDUINode::draw();
	
	if (!m_pRole)
	{
		return;
	}
	
	
	CGFloat w = m_pRole->GetWidth();
	CGFloat h = m_pRole->GetHeight();
	CGRect scrRect	= this->GetScreenRect();
	CGPoint pos		= ccpAdd(scrRect.origin, 
							 ccp((scrRect.size.width - w) / 2 + m_pRole->getGravityX(),
								 (scrRect.size.height - h) / 2 + m_pRole->getGravityY()) );
	
	m_pRole->SetPositionEx(pos);
	m_pRole->RunAnimation(true);
}

void CUIRoleNode::SetMove(bool bSet, bool directRight/*=true*/)
{
	if (!m_pRole)
	{
		return;
	}
	
	m_pRole->SetAction(bSet);
	m_pRole->SetSpriteDir(directRight ? 0 : 2);
}
