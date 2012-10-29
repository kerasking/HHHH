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
#include "NDMapMgr.h"
#include "GameScene.h"
#include "NDTransData.h"
#include "NDUtility.h"
#include "XMLReader.h"
#include "UpdateScene.h"
//#include "cpLog.h"
//#include "SimpleAudioEngine_objc.h"
#include "NDPath.h"

#include "UIChatText.h"
#include "ScriptInc.h"
#define TAG_MAP_UPDTAE (2046)
#define	TAG_MAP_LONGTOUCH (2047)
#define TAG_MAP_LONGTOUCH_STATE (2048)
#define LONG_TOUCH_INTERVAL 0.1f

using namespace NDEngine;

IMPLEMENT_CLASS(NDMapLayerLogic, NDMapLayer)

NDMapLayerLogic::NDMapLayerLogic()
{
	m_dTimeStamp = time(NULL);

	m_kTimer.SetTimer(this, TAG_MAP_UPDTAE, 0.01f);

	SetLongTouch(false);

	m_kPosTouch = CGPointZero;

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

	m_kPosTouch = touch->GetLocation();
	CGPoint touchPoint = this->ConvertToMapPoint(m_kPosTouch);
	if(isTouchTreasureBox(touchPoint))
	{
		NDLog("touch treasureBox");
		this->OpenTreasureBox();
		return false;
	}

	if (!NDPlayer::defaultHero().DealClickPointInSideNpc(touchPoint))
	{
		SetPathing(true);
	}

	m_kTimer.SetTimer(this, TAG_MAP_LONGTOUCH, LONG_TOUCH_INTERVAL);
	return true;
}

void NDMapLayerLogic::TouchEnd(NDTouch* touch)
{
	NDPlayer& kPlayer = NDPlayer::defaultHero();
	if (!kPlayer.ClickPoint(this->ConvertToMapPoint(touch->GetLocation()), false, IsPathing()))
	{
		kPlayer.stopMoving();
		if (ScriptMgrObj.excuteLuaFunc<bool>("IsInPractising", "PlayerFunc"))
		{
			kPlayer.SetCurrentAnimation(7, kPlayer.IsReverse());
		}
	}

	kPlayer.CancelClickPointInSideNpc();
	m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH_STATE);
	m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH);
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

void NDMapLayerLogic::TouchMoved(NDTouch* touch)
{
	m_kPosTouch = touch->GetLocation();
	return true;
}

void NDMapLayerLogic::Update(unsigned long ulDiff)
{
	NDMapMgrObj.Update(ulDiff);
}

void NDMapLayerLogic::OnTimer(OBJID uiTag)
{
	if (!(uiTag == TAG_MAP_UPDTAE ||
		  uiTag == TAG_MAP_LONGTOUCH ||
		  uiTag == TAG_MAP_LONGTOUCH_STATE))
	{
		NDMapLayer::OnTimer(uiTag);
		return;
	}

	if (uiTag == TAG_MAP_UPDTAE)
	{
		double oldTimeStamp = m_dTimeStamp;
		m_doubleTimeStamp = time(NULL);
		Update((unsigned long) ((m_dTimeStamp - oldTimeStamp) * 1000));
	}
	else if (uiTag == TAG_MAP_LONGTOUCH)
	{
		SetLongTouch(true);
		m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH);
		m_kTimer.SetTimer(this, TAG_MAP_LONGTOUCH_STATE, 0.1f);
	}
	else if (uiTag == TAG_MAP_LONGTOUCH_STATE)
	{
		if (IsPathing() && !NDPlayer::defaultHero().ClickPoint(this->ConvertToMapPoint(m_kPosTouch), true))
		{
			SetLongTouch(false);

			m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH_STATE);
			m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH);
		}

		if (!IsPathing())
		{
			NDPlayer::defaultHero().DealClickPointInSideNpc(this->ConvertToMapPoint(m_kPosTouch));
		}
	}
}

void NDMapLayerLogic::SetLongTouch(bool bSet)
{
	m_bLongTouch = bSet;
}

bool NDMapLayerLogic::IsLongTouch()
{
	return m_bLongTouch;
}

void NDMapLayerLogic::SetPathing(bool bPathing)
{
	m_bPathing = bPathing;
}

bool NDMapLayerLogic::IsPathing()
{
	return m_bPathing;
}
