/*
 *  NDMapLayerLogic.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDMapLayerLogic.h"
#include "NDPlayer.h"
#include "NDConstant.h"
#include "NDMsgDefine.h"
#include "EnumDef.h"
#include "NDDataTransThread.h"
#include "NDScene.h"
#include "NDDirector.h"
///< #include "NDMapMgr.h" ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
#include "GameScene.h"
#include "NDTransData.h"
#include "NDUtility.h"
#include "XMLReader.h"
#include "UpdateScene.h"
//#include "cpLog.h"
//#include "SimpleAudioEngine_objc.h"
#include "NDPath.h"

#include "UIChatText.h"

#define TAG_MAP_UPDTAE (2046)
#define	TAG_MAP_LONGTOUCH (2047)
#define TAG_MAP_LONGTOUCH_STATE (2048)
#define LONG_TOUCH_INTERVAL 0.1f

using namespace NDEngine;

IMPLEMENT_CLASS(NDMapLayerLogic, NDMapLayer)

NDMapLayerLogic::NDMapLayerLogic()
{
	//m_doubleTimeStamp = [NSDate timeIntervalSinceReferenceDate];  ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	
	m_timer.SetTimer(this, TAG_MAP_UPDTAE, 0.01f);
	
	SetLongTouch(false);
	
	m_posTouch	= CGPointZero;
	
	SetPathing(false);
}

NDMapLayerLogic::~NDMapLayerLogic()
{
}

void NDMapLayerLogic::DidFinishLaunching()
{
}

bool NDMapLayerLogic::TouchBegin(NDTouch* touch)
{
	if (this->isAutoFight()){
		NDMonster* boss = NDMapMgrObj.GetBoss();
		if (boss!=NULL)
		{
			return false;
		}
	}
	
	SetPathing(false);
	
	SetLongTouch(false);

	m_posTouch = touch->GetLocation();
	CGPoint touchPoint=this->ConvertToMapPoint(m_posTouch);

	/***
	* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	* begin
	*/
// 	if(isTouchTreasureBox(touchPoint))
// 	{
// 		NDLog("touch treasureBox");
// 		this->OpenTreasureBox();
// 		return false;
// 	}
	/**
	* end
	*/
	//if ( NDPlayer::defaultHero().ClickPoint(touchPoint, false) )
//	{
//		m_timer.SetTimer(this, TAG_MAP_LONGTOUCH, LONG_TOUCH_INTERVAL);
//	}
	
	if (!NDPlayer::defaultHero().DealClickPointInSideNpc(touchPoint))
	{
		SetPathing(true);
	}
	
	m_timer.SetTimer(this, TAG_MAP_LONGTOUCH, LONG_TOUCH_INTERVAL);
	
	//ShowTreasureBox();

	return true;
}

bool NDMapLayerLogic::TouchEnd(NDTouch* touch)
{	
	NDPlayer& player = NDPlayer::defaultHero();
	
	if (!player.ClickPoint(this->ConvertToMapPoint(touch->GetLocation()), false, IsPathing()))
	{
		player.stopMoving();
	}
	
	player.CancelClickPointInSideNpc();
	
	m_timer.KillTimer(this, TAG_MAP_LONGTOUCH_STATE);
	m_timer.KillTimer(this, TAG_MAP_LONGTOUCH);
	
	return true;
//	
//	SimpleAudioEngine *audioEngine=[SimpleAudioEngine sharedEngine];
//	NSString *effectFile = [NSString stringWithUTF8String:NDPath::GetSoundPath().append("press.wav").c_str()];
//	[audioEngine playEffect:effectFile loop:NO];

	
//	NDPlayer::defaultHero().Walk(point, SpriteSpeedStep4);
//	NDTransData bao(_MSG_BATTLEACT);
//	bao << (unsigned char)BATTLE_ACT_CREATE // ActionÖµ
//		<< (unsigned char)0 // btturn
//		<< (unsigned char)1 // datacount
//		<< (int)1100611; // ¹ÖÎïId
//	
//	NDDataTransThread::DefaultThread()->GetSocket()->Send(&bao);
}

void NDMapLayerLogic::TouchCancelled(NDTouch* touch)
{
	
}

bool NDMapLayerLogic::TouchMoved(NDTouch* touch)
{
	m_posTouch	= touch->GetLocation();
	return true;
}

void NDMapLayerLogic::Update(unsigned long ulDiff)
{
	NDMapMgrObj.Update(ulDiff);
}

void NDMapLayerLogic::OnTimer(OBJID tag)
{
	if ( !(tag == TAG_MAP_UPDTAE || 
		   tag == TAG_MAP_LONGTOUCH ||
		   tag == TAG_MAP_LONGTOUCH_STATE)  )
	{	
		NDMapLayer::OnTimer(tag);
		return;
	}
	
	if (tag == TAG_MAP_UPDTAE)
	{
		double oldTimeStamp = m_doubleTimeStamp;
		//m_doubleTimeStamp = [NSDate timeIntervalSinceReferenceDate]; ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
		Update( (unsigned long)( (m_doubleTimeStamp - oldTimeStamp)*1000 ) );
	}
	else if (tag == TAG_MAP_LONGTOUCH)
	{
		SetLongTouch(true);
		m_timer.KillTimer(this, TAG_MAP_LONGTOUCH);
		m_timer.SetTimer(this, TAG_MAP_LONGTOUCH_STATE, 0.1f);
	}
	else if (tag == TAG_MAP_LONGTOUCH_STATE)
	{
		if (IsPathing() && !NDPlayer::defaultHero().ClickPoint(this->ConvertToMapPoint(m_posTouch), true) )
		{
			SetLongTouch(false);
			
			m_timer.KillTimer(this, TAG_MAP_LONGTOUCH_STATE);
			m_timer.KillTimer(this, TAG_MAP_LONGTOUCH);
		}
		
		if (!IsPathing())
		{
			NDPlayer::defaultHero().DealClickPointInSideNpc(this->ConvertToMapPoint(m_posTouch));
		}
	}
}

void NDMapLayerLogic::SetLongTouch(bool bSet)
{
	m_bLongTouch	= bSet;
}

bool NDMapLayerLogic::IsLongTouch()
{
	return m_bLongTouch;
}

void NDMapLayerLogic::SetPathing(bool bPathing)
{
	m_bPathing	= bPathing;
}

bool NDMapLayerLogic::IsPathing()
{
	return m_bPathing;
}

override

bool NDEngine::NDMapLayerLogic::isAutoFight()
{
	return true;
}