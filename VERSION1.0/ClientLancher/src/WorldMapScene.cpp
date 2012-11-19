//
//  WorldMapScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-25.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "WorldMapScene.h"
#include "CCPointExtension.h"
#include "NDUtility.h"
#include "NDDirector.h"
//#include "ItemMgr.h"
#include "NDPlayer.h"
///< #include "NDMapMgr.h" ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
#include "GameScene.h"
#include "NDUIImage.h"
#include "NDPath.h"
#include <stdlib.h>
#include "CCTextureCache.h"
#include "CCTexture2D.h"

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
	m_buttonsFocus = NULL;
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
	m_buttonsFocus->release();
}

void WorldMapLayer::Initialization(int nMapId)
{
	int width = m_mapData->getMapSize().width;
	int height = m_mapData->getMapSize().height;
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();

	NDUILayer::Initialization();
	this->SetTag(ScriptMgrObj.excuteLuaFuncRetN("GetWorldMapUITag", ""));
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	this->SetFrameRect(CGRectMake(0, 0, width, height));

	m_mapFilename.insert(
			std::make_pair(3, GetSMImgPath("icon_town_high_2.png")));
	m_mapFilename.insert(
			std::make_pair(1, GetSMImgPath("icon_town_low_2.png")));
	m_mapFilename.insert(
			std::make_pair(2, GetSMImgPath("icon_town_mid_2.png")));
	m_mapFilename.insert(
			std::make_pair(4, GetSMImgPath("icon_town_mid_2.png")));
	m_mapFilename.insert(
			std::make_pair(5, GetSMImgPath("icon_town_mid_2.png")));
	m_mapFilename.insert(
			std::make_pair(6, GetSMImgPath("icon_town_mid_2.png")));
	m_mapFilename.insert(
			std::make_pair(7, GetSMImgPath("icon_town_mid_2.png")));

	m_buttons = cocos2d::CCArray::array();
	m_buttonsFocus = cocos2d::CCArray::array();
	for (unsigned int i = 0; i < m_mapData->getPlaceNodes()->count(); i++)
	{
		PlaceNode* pkNode =
				(PlaceNode *) (PlaceNode*) (PlaceNode*) m_mapData->
						getPlaceNodes()->objectAtIndex(i);

		if (NULL == pkNode)
		{
			continue;
		}

		if (m_mapFilename.end() == m_mapFilename.find(pkNode->getPlaceId()))
		{
			continue;
		}

		const char* path = m_mapFilename[pkNode->getPlaceId()].c_str();
		if (NULL == path)
		{
			continue;
		}

		cocos2d::CCTexture2D* tex =
				cocos2d::CCTextureCache::sharedTextureCache()->addImage(path);
		if (NULL == tex)
		{
			continue;
		}

		{
			NDTile* pkTile = new NDTile;
			pkTile->setTexture(pkNode->getTexture());
			pkTile->setCutRect(
					CGRectMake(0, 0,
							pkNode->getTexture()->getContentSizeInPixels().width,
							pkNode->getTexture()->getContentSizeInPixels().height));
			pkTile->setDrawRect(
					CGRectMake(pkNode->getX(), pkNode->getY(),
							pkNode->getTexture()->getContentSizeInPixels().width,
							pkNode->getTexture()->getContentSizeInPixels().height));
			pkTile->setReverse((bool)NO);
			pkTile->setRotation(NDRotationEnumRotation0);
			pkTile->setMapSize(
					CGSizeMake(m_mapData->getMapSize().width,
							m_mapData->getMapSize().height));
			pkTile->make();
			m_buttons->addObject(pkTile);
			pkTile->release();
		}

		{
			NDTile* pkTile = new NDTile;
			pkTile->setTexture(tex);
			pkTile->setCutRect(
					CGRectMake(0, 0,
							pkTile->getTexture()->getContentSizeInPixels().width,
							pkTile->getTexture()->getContentSizeInPixels().height));
			pkTile->setDrawRect(
					CGRectMake(pkNode->getX(), pkNode->getY(),
							pkTile->getTexture()->getContentSizeInPixels().width,
							pkTile->getTexture()->getContentSizeInPixels().height));
			pkTile->setReverse(NO);
			pkTile->setRotation(NDRotationEnumRotation0);
			pkTile->setMapSize(
					CGSizeMake(m_mapData->getMapSize().width,
							m_mapData->getMapSize().height));
			pkTile->make();
			m_buttonsFocus->addObject(pkTile);
			pkTile->release();
		}
	}

	m_roleNode = new CUIRoleNode;
	m_roleNode->Initialization();
	m_roleNode->ChangeLookFace(GetPlayerLookface());
	m_roleNode->SetRoleScale(0.6f);
	this->AddChild(m_roleNode);

	NDPicture* picClose = NDPicturePool::DefaultPool()->AddPicture(
			GetSMImgPath("btn_close.png"));
	CGSize sizeClose = picClose->GetSize();
	CGRect rectClose = CGRectMake(
			(winsize.width - 10 * fScaleFactor - sizeClose.width),
			10 * fScaleFactor, sizeClose.width, sizeClose.height);

	NDUIImage *imgClose = new NDUIImage;
	imgClose->Initialization();
	imgClose->SetPicture(picClose, true);
	imgClose->SetFrameRect(
			CGRectMake(rectClose.origin.x, rectClose.origin.y - 128,
					rectClose.size.width, rectClose.size.height));
	this->AddChild(imgClose);

	//rectClose.origin = ConvertToMapPoint(rectClose.origin);
	m_btnClose = new NDUIButton();
	m_btnClose->Initialization();
	m_btnClose->SetDelegate(this);
	m_btnClose->CloseFrame();
	//m_btnClose->SetImage(picClose);
	m_btnClose->SetFrameRect(rectClose);
	this->AddChild(m_btnClose);

	/*
	 m_btnRet = new NDUIButton();
	 m_btnRet->Initialization();
	 m_btnRet->SetDelegate(this);
	 m_btnRet->SetFrameRect(
	 CGRectMake((winsize.width - BTN_W * fScaleFactor),
	 (winsize.height - BTN_H * fScaleFactor),
	 BTN_W * fScaleFactor, BTN_H * fScaleFactor));
	 this->AddChild(m_btnRet);
	 */

	SetCenterAtPos(ccp(winsize.width / 2, winsize.height / 2));

	ShowRoleAtPlace(nMapId);

}

void WorldMapLayer::draw()
{
	NDUILayer::draw();
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	/*
	 int rowStart = (m_screenCenter.y - winSize.height / 2) / MAP_UNITSIZE - 1;
	 int rowEnd   = (m_screenCenter.y + winSize.height / 2) / MAP_UNITSIZE + 1;
	 int colStart = (m_screenCenter.x - winSize.width  / 2) / MAP_UNITSIZE - 1;
	 int colEnd   = (m_screenCenter.x + winSize.width  / 2) / MAP_UNITSIZE + 1;
	 */
	//bgs
	for (unsigned int i = 0; i < m_mapData->getBgTiles()->count(); i++)
	{
		NDSceneTile* bgTile =
				(NDSceneTile*) (m_mapData->getBgTiles()->objectAtIndex(i));
		if (bgTile)
		{
			bgTile->draw();
		}
	}

	//scenes
	for (unsigned int i = 0; i < m_mapData->getSceneTiles()->count(); i++)
	{
		NDSceneTile* sceneTile =
				(NDSceneTile*) (m_mapData->getSceneTiles()->objectAtIndex(i));
		if (sceneTile)
		{
			sceneTile->draw();
		}
	}

	int nFocusIndex = GetCurPlaceIndex();
	//places
	for (unsigned int i = 0; i < m_buttons->count(); i++)
	{
		if (IsInFilterList(GetPlaceIdByIndex(i)))
		{
			continue;
		}

		NDTile* tile = NULL;
		if ((unsigned int) nFocusIndex == i)
		{
			tile = (NDTile*) m_buttonsFocus->objectAtIndex(i);
		}
		else
		{
			tile = (NDTile*) m_buttons->objectAtIndex(i);
		}

		if (tile)
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

	/***
	 * ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	 * begin
	 */
// 	if (!ScriptMgrObj.excuteLuaFunc("IsMapCanOpen", "AffixBossFunc"))
// 	{
// 		return true;
// 	}
	/***
	 * ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	 * end
	 */

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
	if (tag != TAG_TIMER_MOVE)
	{
		return NDUILayer::OnTimer(tag);
	}

	if (IsMoveArrive())
	{
		m_timer.KillTimer(this, TAG_TIMER_MOVE);
		SetMove(false);
		// todo move
//		NDMapMgrObj.WorldMapSwitch(GetTargetMapId()); ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
		return;
	}

	if (m_roleNode)
	{
		CGRect rectRole = m_roleNode->GetFrameRect();
		float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
		CGPoint posRole = rectRole.origin;
		CGPoint posTarget = GetTarget();

		float fDiffX = posTarget.x - posRole.x;
		float fDiffY = posTarget.y - posRole.y;
		float fDis = sqrt(pow(fDiffX, 2) + pow(fDiffY, 2));
		float fStep = MOVE_STEP * fScaleFactor;

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
		rect.size = CGSizeMake(fScaleFactor * 150, fScaleFactor * 120);
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
	CGPoint pt = ConvertToMapPoint(touch->GetLocation());
	float fScaleFactor = NDDirector::DefaultDirector()->GetScaleFactor();
	for (unsigned int i = 0; i < m_mapData->getPlaceNodes()->count(); i++)
	{
		PlaceNode* node =
				(PlaceNode*) m_mapData->getPlaceNodes()->objectAtIndex(i);
		CGRect btnRect = CGRectMake(node->getX(), node->getY(),
				node->getTexture()->getContentSizeInPixels().width,
				node->getTexture()->getContentSizeInPixels().height);
		if (CGRectContainsPoint(btnRect, pt))
		{
			OnNodeClick(node);
			NDUILayer::TouchBegin(touch);
			return true;
		}
	}
	return NDUILayer::TouchBegin(touch);
}

void WorldMapLayer::OnNodeClick(PlaceNode* button)
{
	if (m_curBtn != button && button && !IsInFilterList(button->getPlaceId()))
	{
		Goto(button->getPlaceId());
		m_curBtn = button;
	}
}

void WorldMapLayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnRet || button == m_btnClose)
	{
		this->RemoveFromParent(true);
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
		m_timer.SetTimer(this, TAG_TIMER_MOVE, float(1) / 24);
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
		CGPoint pos = CGPointMake(
				node->getX()
						+ node->getTexture()->getContentSizeInPixels().width
								/ 2,
				node->getY()
						- node->getTexture()->getContentSizeInPixels().height);
		posRet = ConvertToScreenPoint(pos);
		posRet = ccpSub(posRet, ccp(fScaleFactor * 75, fScaleFactor * 120));
	}

	return posRet;
}
