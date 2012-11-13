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
#define MOVE_STEP			(8)

IMPLEMENT_CLASS(WorldMapLayer, NDUILayer)

WorldMapLayer::WorldMapLayer()
{
	m_mapData = NDWorldMapData::SharedData();
	m_curBtn = NULL;
	m_buttons = NULL;
	m_screenCenter = CGPointZero;
	m_roleNode = NULL;
	m_btnClose = NULL;
	m_btnRet = NULL;
	m_posTarget = CGPointZero;
	m_bInMoving = false;
	m_posMapOffset = CGPointZero;
}

WorldMapLayer::~WorldMapLayer()
{
	m_buttons->release();
}

void WorldMapLayer::Initialization(int nMapId)
{
	int width = m_mapData->getMapSize().width;
	int height = m_mapData->getMapSize().height;
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	NDUILayer::Initialization();
	SetTag(ScriptMgrObj.excuteLuaFuncRetN("GetWorldMapUITag", ""));

    //ScriptMgrObj.excuteLuaFunc("PlayWorldMusic", "Music");
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	SetFrameRect(CGRectMake(0, 0, width, height));

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
		
		pkTile->setCutRect(CGRectMake(0, 0, iWidth, iHeight));
		int iX = pkNode->getX();
		int iY = pkNode->getY();
		
		pkTile->setDrawRect(CGRectMake(iX, iY, iWidth, iHeight));
		pkTile->setReverse((bool)NO);
		pkTile->setRotation(NDRotationEnumRotation0);
		
		iWidth = m_mapData->getMapSize().width;
		iHeight = m_mapData->getMapSize().height;
		
		pkTile->setMapSize(CGSizeMake(iWidth, iHeight));
		pkTile->make();
		
		m_buttons->addObject(pkTile);
		pkTile->release();
	}

	NDPicture* picClose	= NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("btn_close.png"));
	NDPicture* picCloseSelect	= NDPicturePool::DefaultPool()->AddPicture(GetSMImgPath("btn_close.png"));    
	CGSize sizeClose	= picClose->GetSize();

	int iFlag =  fScaleFactor < 1.5 ? 2 : 1;
	picClose->Cut(CGRectMake(0,  0,  sizeClose.width,  sizeClose.height/2 - 2));
	picCloseSelect->Cut(CGRectMake(0,  sizeClose.height/2,  sizeClose.width,  sizeClose.height/2));

	CGRect rectClose	= CGRectMake((winsize.width - sizeClose.width/iFlag), 0,
									 sizeClose.width/iFlag, sizeClose.height/2/iFlag);

	m_btnClose = new NDUIButton();
	m_btnClose->Initialization();
	m_btnClose->SetDelegate(this);
	m_btnClose->SetImage(picClose);
	m_btnClose->SetFrameRect(rectClose);
	AddChild(m_btnClose);

	SetCenterAtPos(ccp(winsize.width / 2, winsize.height / 2));

	m_roleNode = new CUIRoleNode;
	m_roleNode->Initialization();
	m_roleNode->ChangeLookFace(GetPlayerLookface());

	NDPlayer& player = NDPlayer::defaultHero();
	m_roleNode->GetRole()->ChangeModelWithMount(player.m_nRideStatus, player.m_nMountType);
	m_roleNode->SetRoleScale(0.5f);
	AddChild(m_roleNode);
	ShowRoleAtPlace(nMapId);

/*	m_timer.SetTimer(this, TAG_TIMER_MOVE, 1.0/24.0);*/

// 	NDUILabel *tmpLabel = new NDUILabel();
// 	tmpLabel->Initialization();
// 	tmpLabel->SetText("能不能显示出来呢？");
// 	tmpLabel->SetFontSize(18);
// 	tmpLabel->SetFrameRect(CGRectMake(200, 200, 300,100));
// 	tmpLabel->SetTextAlignment(LabelTextAlignmentLeft);
// 	AddChild(tmpLabel);

// 	CUIRoleNode *tmpRoleNode = new CUIRoleNode;
// 	tmpRoleNode->Initialization();
// 	tmpRoleNode->ChangeLookFace(11200003);
// 	tmpRoleNode->SetFrameRect(CGRectMake(200, 200, 300,150));
// 	m_roleNode->SetVisible(true);
// 	AddChild(tmpRoleNode);

// 	NDUINode *tmpUINode = new NDUINode();
// 	tmpUINode->Initialization();
// 	tmpUINode->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
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
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();

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

	//m_roleNode->draw();
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
	int mapid = GetTargetMapId();
	ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "",mapid);

#if 1
	if (tag != TAG_TIMER_MOVE)
	{
		return NDUILayer::OnTimer(tag);
	}

	if (IsMoveArrive())
	{
		m_timer.KillTimer(this, TAG_TIMER_MOVE);
		SetMove(false);
		// todo move
        int mapid = GetTargetMapId();
        
        if(mapid==1 || mapid == 2)
            //NDMapMgrObj.WorldMapSwitch(GetTargetMapId());
			;
        else
            ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "",mapid);
		return;
	}

	if (m_roleNode)
	{
		CGRect rectRole = m_roleNode->GetFrameRect();
		//float	fScaleFactor	= NDDirector::DefaultDirector()->GetScaleFactor(); //@check
		CGPoint posRole = rectRole.origin;
		CGPoint posTarget = GetTarget();

		float fDiffX = posTarget.x - posRole.x;
		float fDiffY = posTarget.y - posRole.y;
		float fDis = sqrt(pow(fDiffX, 2) + pow(fDiffY, 2));
		float fStep		= MOVE_STEP; //* fScaleFactor;

		if (fDis < fStep)
		{
			rectRole.origin = posTarget;
		}
		else
		{
			float fK = fStep / fDis;
			float fX = fK * (fDiffX);
			float fY = fK * (fDiffY);
			rectRole.origin = ccpAdd(rectRole.origin, ccp(fX, fY));
		}

		m_roleNode->SetFrameRect(rectRole);
	}
#endif 
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
		 CGPoint pos = CGPointMake(node->getX() + node->texture.contentSizeInPixels.width / 2,
		 node->getY() - node->texture.contentSizeInPixels.height);
		 CGRect rect	= m_roleNode->GetFrameRect();
		 rect.origin	= ConvertToScreenPoint(pos);
		 rect.origin = ccpSub(rect.origin, ccp(fScaleFactor * 75, fScaleFactor * 150));
		 */
		float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
		CGRect rect = m_roleNode->GetFrameRect();
		rect.origin = GetPlaceIdScreenPos(placeId);
		rect.size = CGSizeMake(fScaleFactor*35, fScaleFactor*70);
		m_roleNode->SetFrameRect(rect);
		m_curBtn = node;
	}
}

void WorldMapLayer::SetCenterAtPos(CGPoint pos)
{
	int width = m_mapData->getMapSize().width;
	int height = m_mapData->getMapSize().height;

	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();

	if (pos.x > width - winSize.width / 2)
		pos.x = width - winSize.width / 2;
	if (pos.x < winSize.width / 2)
		pos.x = winSize.width / 2;

	if (pos.y > height - winSize.height / 2)
		pos.y = height - winSize.height / 2;
	if (pos.y < winSize.height / 2)
		pos.y = winSize.height / 2;

	CGPoint posCenter = ccp(winSize.width / 2 - pos.x,
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

CGPoint WorldMapLayer::ConvertToMapPoint(CGPoint screenPoint)
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	return ccpAdd(
			ccpSub(screenPoint, ccp(winSize.width / 2, winSize.height / 2)),
			m_screenCenter);
}

CGPoint WorldMapLayer::ConvertToScreenPoint(CGPoint mapPoint)
{
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	return ccpAdd(ccpSub(mapPoint, m_screenCenter),
			ccp(winSize.width / 2, winSize.height / 2));
}

bool WorldMapLayer::TouchBegin(NDTouch* touch)
{	
	CGPoint m_Touch = touch->GetLocation();
// 	float fScale = NDDirector::DefaultDirector()->GetScaleFactor();
// 	CGPoint tmpTouch = CGPointMake(m_Touch.x * fScale, m_Touch.y * fScale);
	CGPoint tmpTouch = CGPointMake(m_Touch.x, m_Touch.y);
	m_Touch = tmpTouch;

	CGPoint pt = ConvertToMapPoint(m_Touch);
	int iPlaceNodeNum = m_mapData->getPlaceNodes()->count();

	for (unsigned int i = 0; i < iPlaceNodeNum; i++)
	{
		PlaceNode* node = (PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(i);
		
		CGRect btnRect = CGRectMake(node->getX(), node->getY(),
									 node->getTexture()->getContentSizeInPixels().width,
									 node->getTexture()->getContentSizeInPixels().height);

		if (CGRectContainsPoint(btnRect, pt))
		{
			OnNodeClick(node);
			//NDUILayer::TouchBegin(touch);
			return true;
		}
	}
	return NDUILayer::TouchBegin(touch);
}

void WorldMapLayer::OnNodeClick(PlaceNode* button)
{
	if (button && !IsInFilterList(button->getPlaceId()))
	{
		ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "", button->getPlaceId());
		//Goto(button->getPlaceId());
	}
}

void WorldMapLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnRet || button == m_btnClose)
	{
		RemoveFromParent(true);
		ScriptMgrObj.excuteLuaFunc("closeworldbutton", "");
	}
}

void WorldMapLayer::Goto(int nMapId)
{
	PlaceNode* node = GetPlaceNodeWithId(nMapId);
	if (!node)
	{
		return;
	}
	if (node && m_roleNode && m_curBtn != node)
	{
		CGPoint pos = GetPlaceIdScreenPos(nMapId);
		SetMove(true);
		SetRoleDirect(pos.x > m_roleNode->GetFrameRect().origin.x);
		SetTarget(pos);
		SetTargetMapId(node->getPlaceId());

		//ScriptMgrObj.excuteLuaFunc("showBattleMapUI", "", nMapId);
		m_timer.SetTimer(this, TAG_TIMER_MOVE, float(1) / 24);
		m_curBtn = node;
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

	CGPoint posRole = m_roleNode->GetFrameRect().origin;

	if (fabs(posRole.x - m_posTarget.x) < REACH_X * fScaleFactor
			&& fabs(posRole.y - m_posTarget.y) < REACH_Y * fScaleFactor)
	{
		return true;
	}

	return false;
}

void WorldMapLayer::SetTarget(CGPoint pos)
{
	m_posTarget = pos;
}

CGPoint WorldMapLayer::GetTarget()
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

CGPoint WorldMapLayer::GetPlaceIdScreenPos(int placeId)
{
	CGPoint posRet = CGPointZero;

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
		int iHeight  = node->getTexture()->getContentSizeInPixels().height;

		CGPoint pos = CGPointMake((iStartX + iWidth/4), (iStartY - iHeight/8));
		posRet = ConvertToScreenPoint(pos);
		//posRet = ccpSub(posRet, ccp(fScaleFactor * 75, fScaleFactor * 120));
	}

	return posRet;
}
