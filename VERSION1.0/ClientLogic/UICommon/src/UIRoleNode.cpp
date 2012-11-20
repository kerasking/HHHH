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
	
	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	m_pRoleParentNode	= new NDUINode;
	m_pRoleParentNode->Initialization();
	m_pRoleParentNode->SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));
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

//@fix
CCPoint& CUIRoleNode::AdjustPos( CCPoint& pos )
{
	const float fScale = CCDirector::sharedDirector()->getContentScaleFactor();

	if (m_pRole->m_nRideStatus == 1)
	{
		if (m_pRole->m_bFaceRight)
		{
			pos = ccpAdd( pos, ccp( fScale * 38, fScale * (-20) ));
		}
		else
		{
			pos = ccpAdd( pos, ccp( fScale * 13, fScale * (-20) ));
		}
	}
	else
	{
		if (m_pRole->m_bFaceRight)
		{

		}
		else
		{

		}
	}

	return pos;
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
	CCRect scrRect	= this->GetScreenRect();
	CCPoint pos		= ccpAdd(scrRect.origin, ccp(0,scrRect.size.height));

	AdjustPos( pos );
	m_pRole->SetPositionEx(pos);
	m_pRole->RunAnimation(true);

	//NDBaseRole::drawCoord( pos, false );
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

	if (!bSet)
	{
		m_pRole->stopMoving();
	}
}
