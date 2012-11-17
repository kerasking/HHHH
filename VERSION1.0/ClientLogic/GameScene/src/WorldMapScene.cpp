//
//  WorldMapScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-25.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#include "WorldMapScene.h"
#include "CCPointExtension.h"
#include "NDUtility.h"
#include "NDDirector.h"
#include "ItemMgr.h"
#include "NDPlayer.h"
#include "NDMapMgr.h"
#include "GameScene.h"
#include "NDUIImage.h"
#include "NDPath.h"
#include <stdlib.h>
#include "CCTextureCache.h"

#include "CCPointExtension.h"
#include "ScriptGameLogic.h"


#define TAG_TIMER_MOVE		(1024)
#define BTN_W				(40)
#define BTN_H				(20)
#define REACH_X				(8)
#define REACH_Y				(8)
#define MOVE_STEP			(4) //@tune

extern WorldMapLayer* g_pWorldMapLayer = NULL; //for debug only.

IMPLEMENT_CLASS(WorldMapLayer, NDUILayer)

WorldMapLayer::WorldMapLayer()
{
	WriteCon( "WorldMapLayer::WorldMapLayer()\r\n");

	m_mapData = NDWorldMapData::SharedData();
	m_curBtn = NULL;
	m_buttons = NULL;
	m_screenCenter = CCPointZero;
	m_roleNode = NULL;
	m_btnClose = NULL;
	m_btnRet = NULL;
	m_posTarget = CCPointZero;
	m_bInMoving = false;
	m_posMapOffset = CCPointZero;

	m_tmStartMoving.tv_sec = 0;
	m_tmStartMoving.tv_usec = 0;
}

WorldMapLayer::~WorldMapLayer()
{
	WriteCon( "WorldMapLayer::~WorldMapLayer()\r\n");

	m_buttons->release();
	g_pWorldMapLayer = NULL;
}

void WorldMapLayer::Initialization(int nMapId)
{
	g_pWorldMapLayer = this;

	int width = m_mapData->getMapSize().width;
	int height = m_mapData->getMapSize().height;
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	NDUILayer::Initialization();
	SetTag(ScriptMgrObj.excuteLuaFuncRetN("GetWorldMapUITag", ""));

    //ScriptMgrObj.excuteLuaFunc("PlayWorldMusic", "Music");
	CCSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	SetFrameRect(CCRectMake(0, 0, width, height));

	m_buttons = cocos2d::CCArray::array();
	m_buttons->retain();

	int iNodeNum = m_mapData->getPlaceNodes()->count();
	for (unsigned int i = 0; i < iNodeNum; i++)
	{
		PlaceNode* pkNode =(PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(i);
		if (NULL == pkNode)
		{
			continue;
		}
		if (NULL == (pkNode->getTexture()))
		{
			continue;
		}

		NDTile* pkTile = new NDTile;
		pkTile->setTexture(pkNode->getTexture());

#if 1 //@check
 		int iWidth = pkNode->getTexture()->getContentSizeInPixels().width;
 		int iHeight = pkNode->getTexture()->getContentSizeInPixels().height;
#else
		CCSize texSize = ConvertUtil::getTextureSizeInPoints( *pkNode->getTexture() );
		int iWidth = texSize.width;
		int iHeight = texSize.height;
#endif
		
		pkTile->setCutRect(CCRectMake(0, 0, iWidth, iHeight));
		int iX = pkNode->getX();
		int iY = pkNode->getY();
		
		pkTile->setDrawRect(CCRectMake(iX, iY, iWidth, iHeight));
		pkTile->setReverse((bool)NO);
		pkTile->setRotation(NDRotationEnumRotation0);
		
		iWidth = m_mapData->getMapSize().width;
		iHeight = m_mapData->getMapSize().height;
		
		pkTile->setMapSize(CCSizeMake(iWidth, iHeight));
		pkTile->make();
		
		m_buttons->addObject(pkTile);
		pkTile->release();
	}

	// load pictures for button
	NDPicture* picClose	= NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("btn_close.png"));
	NDPicture* picCloseSelect	= NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("btn_close.png"));    
	CCSize sizeClose	= picClose->GetSize();

	int iFlag =  fScaleFactor < 1.5 ? 2 : 1;
	picClose->Cut(CCRectMake(0,  0,  sizeClose.width,  sizeClose.height/2 - 2));
	picCloseSelect->Cut(CCRectMake(0,  sizeClose.height/2,  sizeClose.width,  sizeClose.height/2));
	CCRect rectClose = CCRectMake((winsize.width - sizeClose.width/iFlag), 0,
									 sizeClose.width/iFlag, sizeClose.height/2/iFlag);
	// init close button
	{
		m_btnClose = new NDUIButton();
		m_btnClose->Initialization();
		m_btnClose->SetDelegate(this);
		m_btnClose->SetImage(picClose);
		m_btnClose->SetFrameRect(rectClose);
		AddChild(m_btnClose);
	}
	

	// init role node
	{
		m_roleNode = new CUIRoleNode;
		m_roleNode->Initialization();
		m_roleNode->ChangeLookFace(GetPlayerLookface());
		m_roleNode->SetRoleScale(0.5f);

 		NDPlayer& hero = NDPlayer::defaultHero();
		if (m_roleNode->GetRole())
		{
			m_roleNode->GetRole()->ChangeModelWithMount( hero.m_nRideStatus, hero.m_nMountType );
			AddChild(m_roleNode);
		}
	}
	
	ShowRoleAtPlace(nMapId);
	SetCenterAtPos(ccp(winsize.width / 2, winsize.height / 2));

/*	m_timer.SetTimer(this, TAG_TIMER_MOVE, 1.0/24.0);*/

// 	NDUILabel *tmpLabel = new NDUILabel();
// 	tmpLabel->Initialization();
// 	tmpLabel->SetText("能不能显示出来呢？");
// 	tmpLabel->SetFontSize(18);
// 	tmpLabel->SetFrameRect(CCRectMake(200, 200, 300,100));
// 	tmpLabel->SetTextAlignment(LabelTextAlignmentLeft);
// 	AddChild(tmpLabel);

// 	CUIRoleNode *tmpRoleNode = new CUIRoleNode;
// 	tmpRoleNode->Initialization();
// 	tmpRoleNode->ChangeLookFace(11200003);
// 	tmpRoleNode->SetFrameRect(CCRectMake(200, 200, 300,150));
// 	m_roleNode->SetVisible(true);
// 	AddChild(tmpRoleNode);

// 	NDUINode *tmpUINode = new NDUINode();
// 	tmpUINode->Initialization();
// 	tmpUINode->SetFrameRect(CCRectMake(0, 0, winsize.width, winsize.height));
// 	AddChild(tmpUINode);

// 	NDManualRole *tmpRole = new NDManualRole;
// 	tmpRole->m_nID = 103;
// 	tmpRole->Initialization(12300006, true);
// 	tmpRole->SetPositionEx(ccp(200, 200));
// 	AddChild(tmpRole);
/*	tmpUINode->AddChild(tmpRole);*/

// 	NDScene *gameScene = NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
// 	NDLayer *layer = (NDLayer *)gameScene->GetChild(MAPLAYER_TAG);
// 	layer->AddChild(tmpRole);
}

void WorldMapLayer::draw()
{
	NDUILayer::draw();
	CCSize winSize = NDDirector::DefaultDirector()->GetWinSize();

	int iNum = m_mapData->getBgTiles()->count();
	for (unsigned int i = 0; i < iNum; i++)
	{
		NDSceneTile* bgTile = (NDSceneTile*) (m_mapData->getBgTiles()->objectAtIndex(i));
		if (bgTile)
		{
			bgTile->draw();
		}
	}

	//scenes
	iNum = m_mapData->getSceneTiles()->count();
	for (unsigned int i = 0; i < iNum; i++)
	{
		NDSceneTile* sceneTile = (NDSceneTile*) (m_mapData->getSceneTiles()->objectAtIndex(i));
		if (sceneTile)
		{
			sceneTile->draw();
		}
	}

	iNum = m_buttons->count();
	//places
	for (unsigned int i = 0; i < iNum; i++)
	{
		if (IsInFilterList(GetPlaceIdByIndex(i)))
		{
			continue;
		}

		NDTile* tile = (NDTile*) m_buttons->objectAtIndex(i);
		if (NULL != tile)
		{
			tile->draw();
		}
	}
}

void WorldMapLayer::SetFilter(ID_VEC idVec)
{
	m_vIdFilter = idVec;
}

bool WorldMapLayer::IsInFilterList(int nMapId)
{
	bool bFilter = ScriptMgrObj.excuteLuaFunc("IsMapCanOpen", "AffixBossFunc", nMapId);
    
    if (!bFilter)
	{
		return true;
	}
	if (m_vIdFilter.empty())
	{
		return false;
	}

	for (ID_VEC::iterator it = m_vIdFilter.begin(); it != m_vIdFilter.end();
			it++)
	{
		if ((*it) == nMapId)
		{
			return true;
		}
	}

	return false;
}

PlaceNode *WorldMapLayer::GetPlaceNodeWithId(int placeId)
{
	PlaceNode *result = NULL;
	for (unsigned int i = 0; i < m_mapData->getPlaceNodes()->count(); i++)
	{
		PlaceNode* node =
				(PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(i);
		if (node->getPlaceId() == placeId)
		{
			result = node;
			break;
		}
	}

	return result;
}

int WorldMapLayer::GetCurPlaceIndex()
{
	for (unsigned int i = 0; i < m_mapData->getPlaceNodes()->count(); i++)
	{
		PlaceNode* node =
				(PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(i);
		if (node == m_curBtn)
		{
			return i;
		}
	}

	return -1;
}

int WorldMapLayer::GetPlaceIdByIndex(int nIndex)
{
	PlaceNode* node = (PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(
			nIndex);
	if (node)
	{
		return node->getPlaceId();
	}

	return 0;
}

void WorldMapLayer::OnTimer(OBJID tag)
{
// 	int mapid = GetTargetMapId();
// 	ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "",mapid);

	if (tag != TAG_TIMER_MOVE)
	{
		NDUILayer::OnTimer(tag);
	}
	else if (isTimeout() || this->DoMove()) //timeout or moving arrive?
	{
		WriteCon( "[WorldMapLayer] OnTimer, IsMoveArrive()=true\r\n" );
		
		if (m_roleNode && m_roleNode->GetRole())
		{
			m_roleNode->GetRole()->stopMoving(false);
		}

		m_timer.KillTimer(this, TAG_TIMER_MOVE);
		SetMove(false);

		// todo move
		int mapid = GetTargetMapId();

		if(mapid==1 || mapid == 2)
			//NDMapMgrObj.WorldMapSwitch(GetTargetMapId());
			;
		else
			ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "",mapid);
	}

// #if 0
// 		if (IsMoveArrive())
// 		{
// 			WriteCon( "[WorldMapLayer] OnTimer, IsMoveArrive()=true\r\n" );
// 
// 			m_timer.KillTimer(this, TAG_TIMER_MOVE);
// 			SetMove(false);
// 
// 			// todo move
// 			int mapid = GetTargetMapId();
// 
// 			if(mapid==1 || mapid == 2)
// 				//NDMapMgrObj.WorldMapSwitch(GetTargetMapId());
// 				;
// 			else
// 				ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "",mapid);
// 		}
// 		else if (m_roleNode)
// 		{
// 			CCRect rectRole = m_roleNode->GetFrameRect();
// 			//float	fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor(); //@check
// 			CCPoint posRole = rectRole.origin;
// 			CCPoint posTarget = GetTarget();
// 
// 			float fDiffX = posTarget.x - posRole.x;
// 			float fDiffY = posTarget.y - posRole.y;
// 			float fDis = sqrt(pow(fDiffX, 2) + pow(fDiffY, 2));
// 			float fStep		= MOVE_STEP; //* fScaleFactor;
// 
// 			if (fDis < fStep)
// 			{
// 				rectRole.origin = posTarget;
// 			}
// 			else
// 			{
// 				float fK = fStep / fDis;
// 				float fX = fK * (fDiffX);
// 				float fY = fK * (fDiffY);
// 				rectRole.origin = ccpAdd(rectRole.origin, ccp(fX, fY));
// 			}
// 			m_roleNode->SetFrameRect(rectRole);
// 		}
// #endif
}

void WorldMapLayer::ShowRoleAtPlace(int placeId)
{
	PlaceNode* node = GetPlaceNodeWithId(placeId);
	if (!node)
	{
		placeId = 1;
		node = GetPlaceNodeWithId(placeId);
	}
	if (node && m_roleNode && node->getTexture())
	{
		/*
		 float fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor();
		 CCPoint pos = CCPointMake(node->getX() + node->texture.contentSizeInPixels.width / 2,
		 node->getY() - node->texture.contentSizeInPixels.height);
		 CCRect rect	= m_roleNode->GetFrameRect();
		 rect.origin	= ConvertToScreenPoint(pos);
		 rect.origin = ccpSub(rect.origin, ccp(fScaleFactor * 75, fScaleFactor * 150));
		 */
		float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
		CCRect rect = m_roleNode->GetFrameRect();
		rect.origin = GetPlaceIdScreenPos(placeId);
		rect.size = CCSizeMake(fScaleFactor*35, fScaleFactor*70);
		m_roleNode->SetFrameRect(rect);
		m_curBtn = node;
	}
}

void WorldMapLayer::SetCenterAtPos(CCPoint pos)
{
	int width = m_mapData->getMapSize().width;
	int height = m_mapData->getMapSize().height;

	CCSize winSize = NDDirector::DefaultDirector()->GetWinSize();

	if (pos.x > width - winSize.width / 2)
		pos.x = width - winSize.width / 2;
	if (pos.x < winSize.width / 2)
		pos.x = winSize.width / 2;

	if (pos.y > height - winSize.height / 2)
		pos.y = height - winSize.height / 2;
	if (pos.y < winSize.height / 2)
		pos.y = winSize.height / 2;

	CCPoint posCenter = ccp(winSize.width / 2 - pos.x,
			winSize.height / 2 + pos.y - m_mapData->getMapSize().height);

	//m_posMapOffset	= posCenter;
	m_screenCenter = pos;

	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	if (!CompareEqualFloat(fScaleFactor, 0.0f))
	{
		posCenter.x /= fScaleFactor;
		posCenter.y /= fScaleFactor;
	}

	m_ccNode->setPosition(posCenter);
}

//和NDMapLayer::ConvertToMapPoint()一样
CCPoint WorldMapLayer::ConvertToMapPoint(CCPoint screenPoint)
{
	CCSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	return ccpAdd(
			ccpSub(screenPoint, ccp(winSize.width / 2, winSize.height / 2)),
			m_screenCenter);
}

CCPoint WorldMapLayer::ConvertToScreenPoint(CCPoint mapPoint)
{
	CCSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	CCPoint posScreen = ccpAdd(ccpSub(mapPoint, m_screenCenter),
								ccp(winSize.width / 2, winSize.height / 2));
	return posScreen;
}

//return true: 输入独占
bool WorldMapLayer::TouchBegin(NDTouch* touch)
{	
	CCPoint m_Touch = touch->GetLocation();
	CCPoint posMap = ConvertToMapPoint(m_Touch);
	int iPlaceNodeNum = m_mapData->getPlaceNodes()->count();

	for (unsigned int i = 0; i < iPlaceNodeNum; i++)
	{
		PlaceNode* node = (PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(i);
		
		CCRect btnRect = CCRectMake(node->getX(), node->getY(),
									 node->getTexture()->getContentSizeInPixels().width,
									 node->getTexture()->getContentSizeInPixels().height);

		if (cocos2d::CCRect::CCRectContainsPoint(btnRect, posMap))
		{
			WriteCon( "[WorldMapLayer] OnNodeClick(): index=%d, posMap(%d, %d)\r\n", i, (int)posMap.x, (int)posMap.y );
			OnNodeClick(node);
			return true;
		}
	}
	
	NDUILayer::TouchBegin(touch);
	return true;
}

//return true: 输入独占
bool WorldMapLayer::TouchEnd(NDTouch* touch)
{
	NDUILayer::TouchEnd(touch);
	return true;
}

void WorldMapLayer::OnNodeClick(PlaceNode* button)
{
	if (button && !IsInFilterList(button->getPlaceId()))
	{
		//ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "", button->getPlaceId());
		Goto( button->getPlaceId());
	}
}

void WorldMapLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnRet || button == m_btnClose)
	{
		WriteCon( "[WorldMapLayer] click close button\r\n" );
		RemoveFromParent(true);
		ScriptMgrObj.excuteLuaFunc("closeworldbutton", "");
	}
}

void WorldMapLayer::Goto( int nMapId )
{
	PlaceNode* node = GetPlaceNodeWithId(nMapId);
	if (!node)
	{
		return;
	}
	if (node && m_roleNode && m_curBtn != node)
	{
		CCPoint pos = GetPlaceIdScreenPos(nMapId);
		SetMove(true);
		SetRoleDirect(pos.x > m_roleNode->GetFrameRect().origin.x);
		SetTarget(pos);
		SetTargetMapId(node->getPlaceId());

		m_timer.SetTimer(this, TAG_TIMER_MOVE, 1.0f/24);//@tune
		m_curBtn = node;

		CCTime::gettimeofdayCocos2d(&m_tmStartMoving, NULL);
	}
}

void WorldMapLayer::SetMove(bool bSet)
{
	m_bInMoving = bSet;

	if (m_roleNode)
	{
		m_roleNode->SetMove(m_bInMoving);
	}
}

void WorldMapLayer::SetRoleDirect(bool directRight)
{
	if (m_roleNode)
	{
		m_roleNode->SetMove(IsMoving(), directRight);
	}
}

bool WorldMapLayer::IsMoving()
{
	return m_bInMoving;
}

bool WorldMapLayer::IsMoveArrive()
{
	if (!IsMoving())
	{
		return true;
	}

	if (!m_roleNode)
	{
		return true;
	}

	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	CCPoint posRole = m_roleNode->GetFrameRect().origin;

	if (fabs(posRole.x - m_posTarget.x) < REACH_X * fScaleFactor
			&& fabs(posRole.y - m_posTarget.y) < REACH_Y * fScaleFactor)
	{
		return true;
	}

	return false;
}

void WorldMapLayer::SetTarget(CCPoint pos)
{
	m_posTarget = pos;
}

CCPoint WorldMapLayer::GetTarget()
{
	return m_posTarget;
}

void WorldMapLayer::SetTargetMapId(int nMapId)
{
	m_nTargetMapId = nMapId;
}

int WorldMapLayer::GetTargetMapId()
{
	return m_nTargetMapId;
}

CCPoint WorldMapLayer::GetPlaceIdScreenPos(int placeId)
{
	CCPoint posRet = CCPointZero;

	PlaceNode* node = GetPlaceNodeWithId(placeId);
	if (!node)
	{
		placeId = 1;
		node = GetPlaceNodeWithId(placeId);
	}
	if (node && m_roleNode && node->getTexture())
	{
		float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
		int iStartX = node->getX();
		int iStartY = node->getY();
		int iWidth  = node->getTexture()->getContentSizeInPixels().width;
		int iHeight = node->getTexture()->getContentSizeInPixels().height;

		CCPoint pos = ccpAdd( ccp(iStartX, iStartY), ccp(iWidth*0.5, -iHeight*0.5) ); //@tune
		posRet = pos;
	}

	return posRet;
}


bool WorldMapLayer::DoMove()
{
	if (!m_roleNode) return false;

	CCRect rectRole = m_roleNode->GetFrameRect();
	CCPoint posRole = rectRole.origin;
	CCPoint posTarget = GetTarget();

	CCPoint posNext = CalcNextPoint( posRole, posTarget );
	bool bArrive = (pow(posNext.x - posTarget.x, 2) 
					+ pow(posNext.y - posTarget.y, 2) < MOVE_STEP*MOVE_STEP);

	rectRole = CCRectMake( posNext.x,
							posNext.y,
							rectRole.size.width,
							rectRole.size.height );

	m_roleNode->SetFrameRect(rectRole);
	return bArrive;
}

bool WorldMapLayer::isTimeout()
{
	struct cc_timeval currentTime;
	CCTime::gettimeofdayCocos2d(&currentTime, NULL);
	double duration = CCTime::timersubCocos2d(&m_tmStartMoving, &currentTime);
	return (TAbs(duration) > 1000*5); //5 sec
}

CCPoint WorldMapLayer::CalcNextPoint( const CCPoint& posStart, const CCPoint& posEnd )
{
	kmVec2 vStart, vEnd;
	kmVec2Fill( &vStart, posStart.x, posStart.y );
	kmVec2Fill( &vEnd, posEnd.x, posEnd.y );

	kmVec2 vSub, vNorm, vDelta;
	kmVec2Subtract( &vSub, &vEnd, &vStart );
	kmVec2Normalize( &vNorm, &vSub );
	kmVec2Scale( &vDelta, &vNorm, MOVE_STEP );

	kmVec2 vNext;
	kmVec2Add( &vNext, &vStart, &vDelta );
	return ccp(vNext.x, vNext.y);
}