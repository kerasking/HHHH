/*
 *  NDMapLayerLogic.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-7.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
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
#include "NDUIChatText.h"
#include "ScriptInc.h"
#include "WorldMapScene.h"
#include "ScriptMgr.h"
#include "ObjectTracker.h"
#include "NDDebugOpt.h"

#define TAG_MAP_UPDTAE (2046)
#define	TAG_MAP_LONGTOUCH (2047)
#define TAG_MAP_LONGTOUCH_STATE (2048)
#define LONG_TOUCH_INTERVAL 0.1f

#define ENABLE_OPT 0 //是否启用性能优化

using namespace NDEngine;

IMPLEMENT_CLASS(NDMapLayerLogic, NDMapLayer)

NDMapLayerLogic::NDMapLayerLogic()
{
	INC_NDOBJ_RTCLS

	m_dTimeStamp = time(NULL);

	m_kTimer.SetTimer(this, TAG_MAP_UPDTAE, 0.01f);

	SetLongTouch(false);

	m_kPosTouch = CCPointZero;

	SetPathing(false);
}

NDMapLayerLogic::~NDMapLayerLogic()
{
	DEC_NDOBJ_RTCLS
}

void NDMapLayerLogic::DidFinishLaunching()
{
}

bool NDMapLayerLogic::TouchBegin(NDTouch* touch)
{
// 	if (this->isAutoFight()){
// 		NDMonster* boss = NDMapMgrObj.GetBoss();
// 		if (boss!=NULL)
// 		{
// 			return false;
// 		}
// 	}

	if (IsWorldMapVisible()) return false;

	SetPathing(false);
	SetLongTouch(false);

	m_kPosTouch = touch->GetLocation();
	CCPoint touchPoint = this->ConvertToMapPoint( m_kPosTouch );
	
	if (NDDebugOpt::getTraceClickMapEnabled())
	{
		CCLog( "@@ NDMapLayerLogic::TouchBegin(%d, %d) -> (%d, %d), ScreenCenter=(%d, %d)\r\n", 
			int(m_kPosTouch.x), int(m_kPosTouch.y), int(touchPoint.x), int(touchPoint.y),
			int(GetScreenCenter().x), int(GetScreenCenter().y));
	}

// 	if(isTouchTreasureBox(touchPoint))
// 	{
// 		NDLog("touch treasureBox");
// 		this->OpenTreasureBox();
// 		return false;
// 	}

	if (!NDPlayer::defaultHero().DealClickPointInSideNpc(touchPoint))
	{
		if (NDDebugOpt::getTraceClickMapEnabled())
		{
			CCLog( "@@ NDMapLayerLogic::TouchBegin(), not click on npc, -> SetPathing(true)\r\n" );
		}

		SetPathing(true);
	}

	m_kTimer.SetTimer(this, TAG_MAP_LONGTOUCH, LONG_TOUCH_INTERVAL);
	return true;
}

void NDMapLayerLogic::TouchEnd(NDTouch* touch)
{
	//if (IsWorldMapVisible()) return;

	CCPoint posTouch = touch->GetLocation();
	CCPoint touchPoint = this->ConvertToMapPoint( posTouch );

	if (NDDebugOpt::getTraceClickMapEnabled())
	{
		CCLog( "@@ NDMapLayerLogic::TouchEnd(%d, %d) -> (%d, %d), ScreenCenter=(%d, %d)\r\n", 
			int(posTouch.x), int(posTouch.y), int(touchPoint.x), int(touchPoint.y),
			int(GetScreenCenter().x), int(GetScreenCenter().y));
	}

	NDPlayer& kPlayer = NDPlayer::defaultHero();
	if (!kPlayer.ClickPoint(touchPoint, false, IsPathing()))
	{
		if (NDDebugOpt::getTraceClickMapEnabled())
		{
			CCLog( "@@ NDMapLayerLogic::TouchEnd(), !kPlayer.ClickPoint(), -> kPlayer.stopMoving()\r\n" );
		}

		kPlayer.stopMoving();
		if (BaseScriptMgrObj.excuteLuaFunc<bool>("IsInPractising", "PlayerFunc"))
		{
			kPlayer.SetCurrentAnimation(7, kPlayer.IsReverse());
		}
	}

	kPlayer.CancelClickPointInSideNpc();
	m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH_STATE);
	m_kTimer.KillTimer(this, TAG_MAP_LONGTOUCH);
//	
//	SimpleAudioEngine *audioEngine=[SimpleAudioEngine sharedEngine];
//	NSString *effectFile = [NSString stringWithUTF8String:NDPath::GetSoundPath().append("press.wav").c_str()];
//	[audioEngine playEffect:effectFile loop:NO];

//	NDPlayer::defaultHero().Walk(point, SpriteSpeedStep4);
//	NDTransData bao(_MSG_BATTLEACT);
//	bao << (unsigned char)BATTLE_ACT_CREATE // Action值
//		<< (unsigned char)0 // btturn
//		<< (unsigned char)1 // datacount
//		<< (int)1100611; // 怪物Id
//	
//	NDDataTransThread::DefaultThread()->GetSocket()->Send(&bao);
}

void NDMapLayerLogic::TouchCancelled(NDTouch* touch)
{

}

void NDMapLayerLogic::TouchMoved(NDTouch* touch)
{
	if (IsWorldMapVisible()) return;

	m_kPosTouch = touch->GetLocation();
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
		m_dTimeStamp = time(NULL);
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

//@opt
bool NDMapLayerLogic::IsWorldMapVisible()
{
	NDScene* pScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (pScene)
	{
		NDNode* pNode = pScene->GetChild(TAG_WORLD_MAP);
		if (pNode && pNode->IsKindOfClass(RUNTIME_CLASS(WorldMapLayer)))
		{
			WorldMapLayer* pWorld = (WorldMapLayer*)pNode;
			return pWorld && pWorld->IsVisibled();
		}
	}
	return false;
}

//@opt
void NDMapLayerLogic::draw()
{
	if (!canDrawMapLayer()) return;

	NDMapLayer::draw();
}

//@opt
bool NDMapLayerLogic::canDrawMapLayer()
{
#if ENABLE_OPT
	if (IsWorldMapVisible()) return false;
	if (hasFullScreenOpaqueUI()) return false;
#endif
	return true;
}

//@opt
bool NDMapLayerLogic::canDrawWorldMapLayer()
{
#if ENABLE_OPT
	if (hasFullScreenOpaqueUI()) return false;
#endif
	return true;
}

//@@ opt
bool NDMapLayerLogic::hasFullScreenOpaqueUI()
{
	NDScene* pScene = NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
	if (!pScene) return false;

	const vector<NDNode*>& vecChildren = pScene->GetChildren();
	for (int i = 0; i < vecChildren.size(); i++)
	{
		NDNode* pNode = vecChildren[i];
		if (pNode && pNode->IsKindOfClass( RUNTIME_CLASS(NDUILayer)))
		{
			NDUILayer* pLayer = (NDUILayer*)pNode;
			const char* layerName = pLayer->getDebugName();
			if (isFullScreenOpaqueUI( layerName ))
				return true;
		}
	}

	return false;
}

//@opt
bool NDMapLayerLogic::isFullScreenOpaqueUI( const char* layerName )
{
	if (!layerName || layerName[0] == 0) return false;
	
	//early out.
	int len = strlen(layerName);
	if (len < 3) return false;

	//early out.
	const char* p = layerName;
	if (p[0] == 'N' && p[1] == 'D' && p[2] == 'U' && p[3] == 'I') return false;

	//early out.
	if (len == 3 && p[0] == 'V' && p[1] == 'I' && p[2] == 'P' ) return true;
	if (len < 6) return false;

	//这些串和LUA脚本设置的SetDebugName()名称对应.
	const char* opaqueLayers[] = 
	{
		//"VIP",
		"DailyAction",
		"DragonTactic",
		"Friend",
		"HeroStar",
		"EmailList",
		"PlayerUI",
		"PlayerBackBag",
		"TaskUI",
		"NormalBoss_Layer",
	};

	int count = sizeof(opaqueLayers) / sizeof(opaqueLayers[0]);
	for (int i = 0; i < count; i++)
	{
		const char* q = opaqueLayers[i];

		// faster check.
		if (p[0] == q[0]
			&& p[1] == q[1]
			&& p[2] == q[2]
			&& p[3] == q[3]
			&& p[4] == q[4]
			&& p[5] == q[5])
		{
			if (strcmp( p + 6, q +6 ) == 0)
				return true;
		}
	}
	return false;
}