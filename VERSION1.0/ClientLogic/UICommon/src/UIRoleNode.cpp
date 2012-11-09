/*
 *  UIRoleNode.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-20.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "UIRoleNode.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDUtility.h"
#include "NDConstant.h"

IMPLEMENT_CLASS(CUIRoleNode, NDUINode)

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

void CUIRoleNode::SetRidePet(int pet_look,int stand_action,int run_action)
{
	if(m_pRole)
	{
		m_pRole->SetRidePet(pet_look, stand_action, run_action, 0);
	}
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
	
	m_pRole->SetWorldPos(pos);
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
	if (m_pRole->GetRidePet())
	{
		m_pRole->GetRidePet()->SetSpriteDir(directRight ? 0 : 2);
	}
}
