//
//  NDFrame.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDFrame.h"
#include "NDTile.h"
#include "NDAnimationGroup.h"
#include "NDAnimation.h"
#include "CCTexture2D.h"
#include "CCTextureCache.h"
#include "CCDirector.h"
#include "NDSprite.h"
#include "NDPath.h"
#include "NDConstant.h"

using namespace cocos2d;
using namespace NDEngine;

//控制动画慢动作方便调试
int g_slowDownMul = 1;

NDFrameRunRecord::NDFrameRunRecord() :
m_nNextFrameIndex(0),
m_nCurrentFrameIndex(0),
m_nRunCount(0),
m_bIsCompleted(false),
m_nRepeatTimes(0),
m_nStartFrame(0),
m_nEndFrame(0),
m_nEnduration(0),
m_nTotalFrame(0),
m_bSetPlayRange(false)
{

}

void NDFrameRunRecord::SetPlayRange(int nStartFrame, int nEndFrame)
{
	m_bSetPlayRange = true;
	m_nStartFrame = nStartFrame;
	m_nEndFrame = nEndFrame;

	m_nCurrentFrameIndex = nStartFrame;
	m_nNextFrameIndex = nStartFrame;
}

void NDFrameRunRecord::NextFrame(int nTotalFrames)
{
	if (m_bSetPlayRange)
	{
		m_nEndFrame = nTotalFrames < m_nEndFrame ? nTotalFrames : m_nEndFrame;
		m_nCurrentFrameIndex =
			m_nStartFrame < m_nEndFrame ?
			m_nCurrentFrameIndex + 1 : m_nCurrentFrameIndex - 1;
		m_nNextFrameIndex =
			m_nStartFrame < m_nEndFrame ?
			m_nCurrentFrameIndex + 1 : m_nCurrentFrameIndex - 1;
		return;
	}

	//当前帧的索引值改变
	if (++m_nCurrentFrameIndex == nTotalFrames)
	{
		m_nCurrentFrameIndex = 0;

		if (m_nRepeatTimes > 0)
		{
			m_nRepeatTimes--;
		}
	}

	//下一帧的索引值改变
	m_nNextFrameIndex = m_nCurrentFrameIndex + 1;
	if (m_nNextFrameIndex == nTotalFrames)
	{
		m_nNextFrameIndex = 0;
	}

	if ((nTotalFrames - 1) == m_nCurrentFrameIndex && m_nRepeatTimes <= 0)
	{
		m_bIsCompleted = true;
	}
}

bool NDFrameRunRecord::isThisFrameEnd()
{
	if ( m_nEnduration && m_nRunCount >= m_nEnduration-1 )//++Guosen 2012.11.26 
		return true;
	else
		return false;
// #if 1
// 	return (m_nEnduration > 0)
// 		&& (m_nRunCount >= int(m_nEnduration * max(1,g_slowDownMul) + 0.5f));
// #else
// 	return (m_nEnduration > 0) 
// 		&& (m_nRunCount >= int(m_nEnduration + 0.5f));
// #endif
}

void NDFrameRunRecord::Clear()
{
	m_nNextFrameIndex = 0;
	m_nCurrentFrameIndex = 0;
	m_nRunCount = 0;
	m_bIsCompleted = false;
	m_nRepeatTimes = 0;
	m_nStartFrame = 0;
	m_nEndFrame = 0;
	m_nEnduration = 0;
	m_nTotalFrame = 0;
}

//////////////////////////////////////////////////////////////////////////
NDFrameTile::NDFrameTile() :
m_nX(0),
m_nY(0),
m_nRotation(0),
m_nTableIndex(0)
{

}

//////////////////////////////////////////////////////////////////////////
NDFrame::NDFrame() :
m_nEnduration(0),
m_pkBelongAnimation(NULL),
m_pkSubAnimationGroups(NULL),
m_pkFrameTiles(NULL),
m_bNeedInitTitles(true)
{
// 	m_pkSubAnimationGroups = new CCMutableArray<NDAnimationGroup*>();
// 	m_pkFrameTiles = new CCMutableArray<NDFrameTile*>();
// 	m_pkTiles = new CCMutableArray<NDTile*>();
	m_pkSubAnimationGroups = new CCArray();
	m_pkFrameTiles = new CCArray();
	m_pkTiles = new CCArray();
}

NDFrame::~NDFrame()
{
	CC_SAFE_RELEASE (m_pkSubAnimationGroups);
	CC_SAFE_RELEASE (m_pkFrameTiles);
	CC_SAFE_RELEASE (m_pkTiles);
}

bool NDFrame::enableRunNextFrame(NDFrameRunRecord* pkFrameRunRecord)
{
#if 1
	if (pkFrameRunRecord->getRunCount() >= m_nEnduration * max(1,g_slowDownMul) - 1)
#else
	if (pkFrameRunRecord->getRunCount() >= m_nEnduration - 1)
#endif
	{
		pkFrameRunRecord->setRunCount(0);
		return true;
	}

	pkFrameRunRecord->setRunCount(pkFrameRunRecord->getRunCount() + 1);
	
	return false;
}

void NDFrame::initTiles()
{
	if (m_bNeedInitTitles)
	{
		for (int i = 0; i < (int) m_pkFrameTiles->count(); i++)
		{
			NDTile *pkTile = new NDTile;
			m_pkTiles->addObject(pkTile);
			pkTile->release();
		}
	}
	m_bNeedInitTitles = false;
}

void NDFrame::drawHeadAt(CCPoint pos)
{
	///< 头像绘制已放于Lua，此处作废。郭浩
}

void NDFrame::run()
{
	run(1.0f);
}

void NDFrame::run(float fScale)
{
	if (m_bNeedInitTitles)
	{
		initTiles();
	}

	NDAnimation* pkAnimation = m_pkBelongAnimation;
	NDAnimationGroup *pkAnimationGroup = pkAnimation->getBelongAnimationGroup();
	int nCount = m_pkFrameTiles->count();

	for (int i = 0; i < nCount; i++)
	{
		NDFrameTile* pkFrameTile = (NDFrameTile*)m_pkFrameTiles->objectAtIndex(i);
		
		NDTileTableRecord *pkRecord =
			(NDTileTableRecord *) pkAnimationGroup->getTileTable()->objectAtIndex( 
				pkFrameTile->getTableIndex());

		NDTile *pkTile = (NDTile*)m_pkTiles->objectAtIndex(i);

		pkTile->setTexture(
			getTileTextureWithImageIndex(pkRecord->getImageIndex(),
			pkRecord->getReplace()));

		if (pkTile->getTexture() == NULL)
		{
			continue;
		}

		TILE_REVERSE_ROTATION kReverseRotation = tileReverseRotationWithReverse(
			pkAnimation->getReverse(), pkFrameTile->getRotation());
		pkTile->setReverse(kReverseRotation.reverse);
		pkTile->setRotation(kReverseRotation.rotation);

		NDEngine::NDSprite *pkSprite =
			(NDEngine::NDSprite *) pkAnimationGroup->getRuningSprite();

		//if (!pkSprite->IsKindOfClass(RUNTIME_CLASS(NDPlayer))) continue; //@todo @del

		if (pkSprite && !pkSprite->IsCloakEmpty()
			&& pkRecord->getReplace() >= REPLACEABLE_LEFT_SHOULDER
			&& pkRecord->getReplace() <= REPLACEABLE_SKIRT_LIFT_LEG)
		{
			pkTile->setCutRect(
				CCRectMake(0, 0,
				pkTile->getTexture()->getMaxS() * pkTile->getTexture()->getPixelsWide(),
				pkTile->getTexture()->getMaxT() * pkTile->getTexture()->getPixelsHigh()));
		}
		else
		{
			int nCutX = pkRecord->getX();
			int nCutY = pkRecord->getY();
			int nCutW = pkRecord->getW();
			int nCutH = pkRecord->getH();
			pkTile->setCutRect(CCRectMake(nCutX, nCutY, nCutW, nCutH)); //@check
		}

		GLfloat x = pkAnimationGroup->getPosition().x;
		GLfloat y = pkAnimationGroup->getPosition().y;

#if 1 //@todo @check
		if (pkAnimation->getMidX() != 0)
		{
			x -= (pkAnimation->getMidX() - pkAnimation->getX()) * fScale;
		}

		if (pkAnimation->getBottomY() != 0)
		{
			y -= (pkAnimation->getBottomY() - pkAnimation->getY()) * fScale;
		}

		y = y + pkFrameTile->getY() * fScale - pkAnimation->getY() * fScale;

		if (pkAnimation->getReverse())
		{
			int tileW = getTileW(pkRecord->getW(), pkRecord->getH(), kReverseRotation.rotation);

			int newX = pkAnimation->getMidX()
				+ (pkAnimation->getMidX() - pkFrameTile->getX() - tileW);

			x = x + newX * fScale - pkAnimation->getX() * fScale;
		}
		else
		{
			x = x + pkFrameTile->getX() * fScale - pkAnimation->getX() * fScale;
		}
#endif

		pkTile->setDrawRect(
			CCRectMake(	x, y, 
			pkTile->getCutRect().size.width * fScale,
			pkTile->getCutRect().size.height * fScale));

		pkTile->setMapSize(pkAnimationGroup->getRunningMapSize());
		pkTile->make();
		pkTile->draw();
	}
}

float NDFrame::getTileW(int w, int h, NDRotationEnum rotation)
{
	switch (rotation)
	{
	case NDRotationEnumRotation0:
	case NDRotationEnumRotation180:
		return w;
	case NDRotationEnumRotation15:
	case NDRotationEnumRotation195:
		return SIN15 * h + COS15 * w;
	case NDRotationEnumRotation30:
	case NDRotationEnumRotation210:
		return SIN30 * h + COS30 * w;
	case NDRotationEnumRotation45:
	case NDRotationEnumRotation225:
		return SIN45 * h + COS45 * w;
	case NDRotationEnumRotation60:
	case NDRotationEnumRotation240:
		return SIN60 * h + COS60 * w;
	case NDRotationEnumRotation75:
	case NDRotationEnumRotation255:
		return SIN75 * h + COS75 * w;
	case NDRotationEnumRotation90:
	case NDRotationEnumRotation270:
		return h;
	case NDRotationEnumRotation105:
	case NDRotationEnumRotation285:
		return COS15 * h + SIN15 * w;
	case NDRotationEnumRotation120:
	case NDRotationEnumRotation300:
		return COS30 * h + SIN30 * w;
	case NDRotationEnumRotation135:
	case NDRotationEnumRotation315:
		return COS45 * h + SIN45 * w;
	case NDRotationEnumRotation150:
	case NDRotationEnumRotation330:
		return COS60 * h + SIN60 * w;
	case NDRotationEnumRotation165:
	case NDRotationEnumRotation345:
		return COS75 * h + SIN75 * w;
	case NDRotationEnumRotation360:
		return w;
	default:
		return w;
	}

	return w;
}

TILE_REVERSE_ROTATION NDFrame::tileReverseRotationWithReverse(bool bReverse,
															  int nRota)
{
	//reverse = true;
	static TILE_REVERSE_ROTATION s_kReverseRotaionResult =
	{ 0 };

	switch (nRota)
	{
	case 0:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		break;
	case 1:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		break;
	case 2:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		break;
	case 3:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		break;
	case 4:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		break;
	case 5:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		break;
	case 6:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		break;
	case 7:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		break;
	case 8:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		break;
	case 9:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		break;
	case 10:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		break;
	case 11:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		break;
	case 12:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		break;
	case 13:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		break;
	case 14:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		break;
	case 15:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		break;
	case 16:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		break;
	case 17:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		break;
	case 18:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		break;
	case 19:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		break;
	case 20:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		break;
	case 21:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		break;
	case 22:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		break;
	case 23:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		else
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		break;
	case 24:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		break;
	case 25:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		break;
	case 26:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		break;
	case 27:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		break;
	case 28:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		break;
	case 29:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		break;
	case 30:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		break;
	case 31:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		break;
	case 32:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		break;
	case 33:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		break;
	case 34:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		break;
	case 35:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		break;
	case 36:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		break;
	case 37:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		break;
	case 38:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		break;
	case 39:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		break;
	case 40:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		break;
	case 41:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		break;
	case 42:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		break;
	case 43:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		break;
	case 44:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		break;
	case 45:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		break;
	case 46:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		break;
	case 47:
		if (bReverse)
		{
			s_kReverseRotaionResult.reverse = false;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		else
		{
			s_kReverseRotaionResult.reverse = true;
			s_kReverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		break;
	}

	return s_kReverseRotaionResult;
}

CCTexture2D* NDFrame::getTileTextureWithImageIndex(int nImageIndex,
												   int nReplace)
{
	NDAnimation *pkAnimation = m_pkBelongAnimation;
	NDAnimationGroup *pkAnimationGroup = pkAnimation->getBelongAnimationGroup();
	NDEngine::NDSprite *pkSprite =
		(NDEngine::NDSprite *) pkAnimationGroup->getRuningSprite();

	CCTexture2D *pkTexture = NULL;

	if (pkSprite)
	{
		pkTexture = pkSprite->getColorTexture(nImageIndex, pkAnimationGroup);
		if (pkTexture)
		{
			return pkTexture;
		}

		if (pkSprite->IsNonRole())
		{
			pkTexture = NDPicturePool::DefaultPool()->AddTexture(
				pkAnimationGroup->getImages()->at(nImageIndex).c_str());
		}

		if (pkTexture)
		{
			return pkTexture;
		}
	}

	/***
	* 此处需要去除，但是因为下面部分代码引用并没有实现，所以暂时保留
	* 郭浩
	* begin
	*/

	std::vector < std::string >* vImg = pkAnimationGroup->getImages();
	if (vImg && vImg->size() > nImageIndex)
	{
		pkTexture = CCTextureCache::sharedTextureCache()->addImage(
			(*vImg)[nImageIndex].c_str());
	}

	/***
	* end
	*/

	if (REPLACEABLE_ONE_HAND_WEAPON_1 == nReplace)
	{
		//pkTexture = pkSprite->GetWeaponImage(); ///< 没有实现 郭浩
	}

	if (0 == pkTexture)
	{
// 		pkTexture = NDPicturePool::DefaultPool()->AddTexture(			///< 等256色调色板 郭浩
// 			pkAnimationGroup->getImages()->at(nImageIndex).c_str());
	}

	return pkTexture;
}