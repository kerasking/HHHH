//
//  NDLightEffect.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-21.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDLightEffect.h"
#include "NDAnimationGroupPool.h"
#include "NDDebugOpt.h"
#include "NDSprite.h"
#include "ObjectTracker.h"

namespace NDEngine
{
IMPLEMENT_CLASS(NDLightEffect, NDNode)

NDLightEffect::NDLightEffect()
{
	INC_NDOBJ_RTCLS

	m_pkFrameRunRecord = NULL;
	m_pkAniGroup = NULL;
	m_nLightID = 0;
	m_bReverse = false;
	m_fScale = 1.0f;
}

NDLightEffect::~NDLightEffect()
{
	DEC_NDOBJ_RTCLS

	CC_SAFE_RELEASE (m_pkAniGroup);
	CC_SAFE_RELEASE (m_pkFrameRunRecord);
}

void NDLightEffect::Initialization(const char* sprFile)
{
	NDNode::Initialization();

	m_pkAniGroup = NDAnimationGroupPool::defaultPool()->addObjectWithSpr(
			sprFile);
	m_pkFrameRunRecord = new NDFrameRunRecord();
}

void NDLightEffect::SetPosition(CCPoint kNewPosition)
{
	m_kPosition = kNewPosition;
}

void NDLightEffect::SetRepeatTimes(unsigned int times)
{
	if (m_pkFrameRunRecord)
	{
		m_pkFrameRunRecord->setRepeatTimes(times);
	}
}

void NDLightEffect::SetLightId(unsigned int uiLightID, bool bReverse/*=true*/)
{
	m_nLightID = uiLightID;
	m_bReverse = bReverse;
}

void NDLightEffect::SlowDown(unsigned int mutli)
{
	if (m_pkAniGroup)
	{
		NDAnimation *pkAnimation =
				(NDAnimation *) m_pkAniGroup->getAnimations()->objectAtIndex(
						m_nLightID);

		if (pkAnimation)
		{
			pkAnimation->SlowDown(mutli);
		}
	}
}

void NDLightEffect::Run(CCSize mapSize, bool draw/*=true*/)
{
	if (m_pkAniGroup->getAnimations()->count() > m_nLightID)
	{
		void* pOldSprite = m_pkAniGroup->getRuningSprite();
		m_pkAniGroup->setRuningSprite(NULL);
		NDAnimation *pkAnimation =
				(NDAnimation *) m_pkAniGroup->getAnimations()->objectAtIndex(
						m_nLightID);
		m_pkAniGroup->setRunningMapSize(mapSize);
		m_pkAniGroup->setPosition(m_kPosition);
		pkAnimation->setReverse(m_bReverse);
		pkAnimation->runWithRunFrameRecord(m_pkFrameRunRecord, true);
		m_pkAniGroup->setRuningSprite((NDSprite*) pOldSprite);
	}
}

void NDLightEffect::draw()
{
	if (!NDDebugOpt::getDrawLightEffectEnabled()) return;

	NDNode::draw();

	NDLayer* pkLayer = (NDLayer*) GetParent();
	if (pkLayer)
	{
		if (m_pkFrameRunRecord->getIsCompleted())
		{
			RemoveFromParent(true);
			return;
		}

		if (m_pkAniGroup->getAnimations()->count() > m_nLightID)
		{
			NDAnimation *pkAnimation =
					(NDAnimation *) m_pkAniGroup->getAnimations()->objectAtIndex(
							m_nLightID);
			m_pkAniGroup->setRunningMapSize(pkLayer->GetContentSize());
			m_pkAniGroup->setPosition(m_kPosition);
			pkAnimation->setReverse(m_bReverse);
			pkAnimation->runWithRunFrameRecord(m_pkFrameRunRecord, true);
		}
		else
		{
			RemoveFromParent(true);
		}
	}
}

}