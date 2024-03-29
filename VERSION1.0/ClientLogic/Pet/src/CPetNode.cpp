/*
 *  CPetNode.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-14.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "CPetNode.h"
#include "NDDirector.h"
#include "CPet.h"
//#include "CCPointExtension.h"
#include "CCGeometry.h"
#include "ObjectTracker.h"

IMPLEMENT_CLASS(CPetNode, NDUILayer)

CPetNode::CPetNode()
{
	INC_NDOBJ_RTCLS
	m_role = NULL;
	m_pos = CCPointZero;
}

CPetNode::~CPetNode()
{
	DEC_NDOBJ_RTCLS
}

void CPetNode::Initialization()
{
	NDUILayer::Initialization();
	
	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	this->SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));
	this->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->SetTouchEnabled(false);
}

void CPetNode::draw()
{
	if (!this->IsVisibled() || !m_role) return;
	
	m_role->RunAnimation(true);
}

void CPetNode::ChangePet(OBJID idPet)
{
	PetInfo* petInfo = PetMgrObj.GetPet(idPet);
	
	if ( !(m_role && m_role->m_nID == idPet) )
	{
		SAFE_DELETE_NODE(m_role);
		
		if (!petInfo) return;
		
		PetInfo::PetData& petData = petInfo->data;
		
		m_role = new NDBaseRole;
		m_role->SetNormalAniGroup(petData.int_PET_ATTR_LOOKFACE);
		m_role->m_nID = idPet;
		this->AddChild(m_role);
		refeshPosition();
	}
	
	// 更新宠物的装备 todo
}

void CPetNode::SetDisplayPos(CCPoint pos)
{
	m_pos = pos;
	
	refeshPosition();
}

void CPetNode::refeshPosition()
{
	if (!m_role) return;
	
	int iH = m_role->GetHeight()-32;
	
	iH = iH < 7 ? iH + 15 : iH;
	
	m_role->SetPositionEx(CCPointMake(m_pos.x, m_pos.y+iH));
}