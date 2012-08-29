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
//#include "NDConstant.h"
#include "NDSprite.h"
#include "NDPath.h"
//#include "NDMonster.h"
//#include "NDNpc.h"
//#include "NDPlayer.h"
//#include "NDBaseRole.h"
#include "NDConstant.h"

using namespace cocos2d;
using namespace NDEngine;

NDFrameRunRecord::NDFrameRunRecord() :
m_nNextFrameIndex(0),
m_nCurrentFrameIndex(0),
m_nRunCount(0),
m_bIsCompleted(false),
m_nRepeatTimes(0),
m_nStartFrame(0),
m_nEndFrame(0),
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
		m_nCurrentFrameIndex =
				m_nStartFrame < m_nEndFrame ?
						m_nCurrentFrameIndex + 1 : m_nCurrentFrameIndex - 1;
		m_nNextFrameIndex =
				m_nStartFrame < m_nEndFrame ?
						m_nCurrentFrameIndex + 1 : m_nCurrentFrameIndex - 1;

		if (m_nStartFrame < m_nEndFrame)
		{
			if (m_nCurrentFrameIndex >= m_nEndFrame)
			{
				m_nCurrentFrameIndex = m_nEndFrame;
				m_nNextFrameIndex = m_nEndFrame;
			}
		}
		if (m_nStartFrame == m_nEndFrame)
		{
			m_nCurrentFrameIndex = m_nEndFrame;
			m_nNextFrameIndex = m_nEndFrame;
		}
		else
		{
			if (m_nNextFrameIndex <= m_nEndFrame)
			{
				m_nCurrentFrameIndex = m_nEndFrame;
				m_nNextFrameIndex = m_nEndFrame;
			}
		}

		if (m_nCurrentFrameIndex < 0)
		{
			m_nCurrentFrameIndex = 0;
		}

		if (m_nCurrentFrameIndex >= nTotalFrames)
		{
			m_nCurrentFrameIndex = nTotalFrames;
		}

		if (m_nNextFrameIndex < 0)
		{
			m_nNextFrameIndex = 0;
		}

		if (m_nNextFrameIndex >= nTotalFrames)
		{
			m_nNextFrameIndex = nTotalFrames;
		}

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
		if (m_nRepeatTimes == 0)
		{
			m_bIsCompleted = true;
		}

	}
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
m_BelongAnimation(NULL),
m_SubAnimationGroups(NULL),
m_FrameTiles(NULL),
m_count(0),
m_needInitTitles(true)
{
	m_SubAnimationGroups = new CCMutableArray<NDAnimationGroup*>();
	m_FrameTiles = new CCMutableArray<NDFrameTile*>();
	m_pkTiles = new CCMutableArray<NDTile*>();
}

NDFrame::~NDFrame()
{
	CC_SAFE_RELEASE (m_SubAnimationGroups);
	CC_SAFE_RELEASE (m_FrameTiles);
	CC_SAFE_RELEASE (m_pkTiles);
}

bool NDFrame::enableRunNextFrame(NDFrameRunRecord* frameRunRecord)
{
	if (frameRunRecord->getRunCount() >= m_nEnduration - 1)
	{
		frameRunRecord->setRunCount(0);
		return true;
	}

	frameRunRecord->setRunCount(frameRunRecord->getRunCount() + 1);

	return false;
}

void NDFrame::initTiles()
{
	if (m_needInitTitles)
	{
		for (int i = 0; i < (int) m_FrameTiles->count(); i++)
		{
			NDTile *tile = new NDTile;
			m_pkTiles->addObject(tile);
			tile->release();
		}
	}
	m_needInitTitles = false;
}

void NDFrame::drawHeadAt(CGPoint pos)
{
	//todo(zjh)
	int faceX = 5;
	int faceY = 8;
	int coordX = 0;
	int coordY = 0;

	NDAnimation* pkAnimation = m_BelongAnimation;
	NDAnimationGroup* pkAnimationGroup = pkAnimation->getBelongAnimationGroup();

	if (m_needInitTitles)
	{
		this->run();
	}

	// 计算脸部偏移
	for (unsigned int i = 0; i < m_FrameTiles->count(); i++)
	{
		NDFrameTile* pkFrameTile = m_FrameTiles->getObjectAtIndex(i);

		NDTileTableRecord* pkRecord =
				(NDTileTableRecord *) pkAnimationGroup->getTileTable()->objectAtIndex(
						pkFrameTile->getTableIndex());

		if (pkRecord->getReplace() == REPLACEABLE_FACE && pkRecord->getX() == 0
				&& pkRecord->getY() == 0)
		{
			coordX = (pkFrameTile->getX() - pkAnimation->getX()) - faceX;
			coordY = (pkFrameTile->getY() - pkAnimation->getY()) - faceY;
			break;
		}
	}

	for (unsigned i = 0; i < m_FrameTiles->count(); i++)
	{
		NDFrameTile* pkFrameTile = m_FrameTiles->getObjectAtIndex(i);
		NDTileTableRecord* pkRecord =
				(NDTileTableRecord *) pkAnimationGroup->getTileTable()->objectAtIndex(
						pkFrameTile->getTableIndex());

		int fx = pkFrameTile->getX();
		int fy = pkFrameTile->getY();

		int clipw = pkRecord->getW();
		int replace = pkRecord->getReplace();

		if (replace == REPLACEABLE_FACE || replace == REPLACEABLE_HAIR
				|| replace == REPLACEABLE_EXPRESSION)
		{
			NDTile* pkTile = m_pkTiles->getObjectAtIndex(i);

			if (!pkTile)
			{
				continue;
			}

			pkTile->setTexture(
					this->getTileTextureWithImageIndex(
							pkRecord->getImageIndex(), pkRecord->getReplace()));

			if (pkTile->getTexture() == NULL)
			{
				continue;
			}

			int xx = pos.x
					+ (pkAnimation->getMidX()
							+ (pkAnimation->getMidX() - fx - clipw)
							- pkAnimation->getX()) - coordX;

			int yy = pos.y + (fy - pkAnimation->getY()) - coordY;

			pkTile->setReverse(true);
			pkTile->setDrawRect(
					CGRectMake(xx, yy, pkRecord->getW(), pkRecord->getH()));
			pkTile->setMapSize(CGSizeMake(480.0f, 320.0f));
			pkTile->make();
			pkTile->draw();
		}
	}

}

void NDFrame::run()
{
	this->run(1.0f);
}

void NDFrame::run(float scale)
{
	if (m_needInitTitles)
	{
		this->initTiles();
	}

	NDAnimation *pkAnimation = m_BelongAnimation;
	NDAnimationGroup *pkAnimationGroup = pkAnimation->getBelongAnimationGroup();

	for (int i = 0; i < (int) m_FrameTiles->count(); i++)
	{
		NDFrameTile* pkFrameTile = m_FrameTiles->getObjectAtIndex(i);
		NDTileTableRecord *record =
				(NDTileTableRecord *) pkAnimationGroup->getTileTable()->objectAtIndex(
						pkFrameTile->getTableIndex());

		NDTile *pkTile = m_pkTiles->getObjectAtIndex(i);

		pkTile->setTexture(
				getTileTextureWithImageIndex(record->getImageIndex(),
						record->getReplace()));

		if (pkTile->getTexture() == NULL)
		{
			continue;
		}

		TILE_REVERSE_ROTATION reverseRotation = tileReverseRotationWithReverse(
				true, pkFrameTile->getRotation());
		pkTile->setReverse(reverseRotation.reverse);
		//	tile->setRotation(reverseRotation.rotation);

		NDEngine::NDSprite *sprite =
				(NDEngine::NDSprite *) pkAnimationGroup->getRuningSprite();

		if (sprite && !sprite->IsCloakEmpty()
				&& record->getReplace() >= REPLACEABLE_LEFT_SHOULDER
				&& record->getReplace() <= REPLACEABLE_SKIRT_LIFT_LEG)
		{
			pkTile->setCutRect(
					CGRectMake(0, 0,
							pkTile->getTexture()->getMaxS()
									* pkTile->getTexture()->getPixelsWide(),
							pkTile->getTexture()->getMaxT()
									* pkTile->getTexture()->getPixelsHigh()));
		}
		else
		{
			pkTile->setCutRect(
					CGRectMake(record->getX(), record->getY(), record->getW(),
							record->getH()));
		}

		GLfloat x = pkAnimationGroup->getPosition().x;
		GLfloat y = pkAnimationGroup->getPosition().y;
		if (pkAnimation->getMidX() != 0)
		{
			x -= (pkAnimation->getMidX() - pkAnimation->getX()) * scale;
		}

		if (pkAnimation->getBottomY() != 0)
		{
			y -= (pkAnimation->getBottomY() - pkAnimation->getY()) * scale;
		}

		y = y + pkFrameTile->getY() * scale - pkAnimation->getY() * scale;

		if (pkAnimation->getReverse())
		{
			int tileW = this->getTileW(record->getW(), record->getH(),
					reverseRotation.rotation);
//			if (reverseRotation.rotation == NDRotationEnumRotation90 || reverseRotation.rotation == NDRotationEnumRotation270) 
//			{
//				tileW = record.h;
//			}
			int newX = pkAnimation->getMidX()
					+ (pkAnimation->getMidX() - pkFrameTile->getX() - tileW);
			x = x + newX * scale - pkAnimation->getX() * scale;
		}

		else
		{
			x = x + pkFrameTile->getX() * scale - pkAnimation->getX() * scale;
		}

		pkTile->setDrawRect(
				CGRectMake(x, y, pkTile->getCutRect().size.width * scale,
						pkTile->getCutRect().size.height * scale));
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

TILE_REVERSE_ROTATION NDFrame::tileReverseRotationWithReverse(bool reverse,
		int rota)
{
	//reverse = true;
	static TILE_REVERSE_ROTATION reverseRotaionResult;
	switch (rota)
	{
	case 0:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		break;
	case 1:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		break;
	case 2:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		break;
	case 3:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		break;
	case 4:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation60;
			;
		}
		break;
	case 5:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		break;
	case 6:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		break;
	case 7:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		break;
	case 8:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		break;
	case 9:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		break;
	case 10:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		break;
	case 11:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		break;
	case 12:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		break;
	case 13:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		break;
	case 14:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		break;
	case 15:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		break;
	case 16:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		break;
	case 17:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		break;
	case 18:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		break;
	case 19:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		break;
	case 20:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		break;
	case 21:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		break;
	case 22:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		break;
	case 23:
		if (reverse)
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		else
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		break;
	case 24:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation0;
		}
		break;
	case 25:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		break;
	case 26:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		break;
	case 27:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		break;
	case 28:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		break;
	case 29:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		break;
	case 30:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		break;
	case 31:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		break;
	case 32:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		break;
	case 33:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		break;
	case 34:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		break;
	case 35:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		break;
	case 36:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation180;
		}
		break;
	case 37:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation195;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation165;
		}
		break;
	case 38:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation210;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation150;
		}
		break;
	case 39:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation225;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation135;
		}
		break;
	case 40:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation240;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation120;
		}
		break;
	case 41:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation255;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation105;
		}
		break;
	case 42:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation270;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation90;
		}
		break;
	case 43:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation285;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation75;
		}
		break;
	case 44:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation300;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation60;
		}
		break;
	case 45:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation315;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation45;
		}
		break;
	case 46:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation330;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation30;
		}
		break;
	case 47:
		if (reverse)
		{
			reverseRotaionResult.reverse = false;
			reverseRotaionResult.rotation = NDRotationEnumRotation345;
		}
		else
		{
			reverseRotaionResult.reverse = true;
			reverseRotaionResult.rotation = NDRotationEnumRotation15;
		}
		break;
	}

	return reverseRotaionResult;
}

CCTexture2D* NDFrame::getTileTextureWithImageIndex(int imageIndex, int replace)
{
	NDAnimation *animation = m_BelongAnimation;
	NDAnimationGroup *animationGroup = animation->getBelongAnimationGroup();
	NDEngine::NDSprite *sprite =
			(NDEngine::NDSprite *) animationGroup->getRuningSprite();

	CCTexture2D *tex = NULL;
	if (sprite)
	{
		tex = sprite->getColorTexture(imageIndex, animationGroup);
		if (tex)
		{
			return tex;
		}

		if (sprite->IsNonRole())
		{
			std::vector < std::string > *vImg = animationGroup->getImages();

			if (vImg && vImg->size() > imageIndex)
			{
				tex = CCTextureCache::sharedTextureCache()->addImage(
						(*vImg)[imageIndex].c_str());
			}
		}

		if (tex)
		{
			return tex;
		}
	}
	std::vector < std::string > *vImg = animationGroup->getImages();
	if (vImg && vImg->size() > imageIndex)
	{
		tex = CCTextureCache::sharedTextureCache()->addImage(
				(*vImg)[imageIndex].c_str());
	}
	//tex = CCTextureCache::sharedTextureCache()->addImage(animationGroup->getImages()->getObjectAtIndex(imageIndex);
	/*switch (replace) 
	 {
	 case REPLACEABLE_NONE:
	 tex =  CCTextureCache::sharedTextureCache()->addImage(animationGroup->getImages()->objectAtIndex(imageIndex));
	 break;
	 case REPLACEABLE_HAIR:
	 if (sprite)
	 {
	 tex = sprite->GetHairImage();
	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 break;
	 case REPLACEABLE_FACE:
	 if (sprite)
	 {
	 tex = sprite->GetFaceImage();
	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 break;
	 case REPLACEABLE_EXPRESSION:
	 if (sprite)
	 {
	 tex = sprite->GetExpressionImage();
	 if ( !tex )
	 {
	 tex =  CCTextureCache::sharedTextureCache()->addImage(animationGroup->getImages()->objectAtIndex(imageIndex));
	 }
	 }
	 break;
	 case REPLACEABLE_CAP:
	 if (sprite)
	 tex = sprite->GetCapImage();
	 break;
	 case REPLACEABLE_ARMOR:
	 if (sprite)
	 {
	 if (sprite->IsCloakEmpty())
	 {
	 tex = sprite->GetArmorImage();
	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 else
	 tex = sprite->GetCloakImage();
	 }
	 break;
	 case REPLACEABLE_ONE_HAND_WEAPON_1:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == ONE_HAND_WEAPON )
	 tex = sprite->GetRightHandWeaponImage();
	 break;
	 case REPLACEABLE_ONE_HAND_WEAPON_2:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetSecWeaponType() == ONE_HAND_WEAPON)
	 tex = sprite->GetLeftHandWeaponImage();
	 break;
	 case REPLACEABLE_TWO_HAND_WEAPON:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_WEAPON)
	 tex = sprite->GetDoubleHandWeaponImage();
	 break;
	 case REPLACEABLE_DUAL_SWORD:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == DUAL_SWORD)
	 tex = sprite->GetDualSwordImage();
	 break;
	 case REPLACEABLE_DUAL_KNIFE:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_KNIFE)
	 tex = sprite->GetDualKnifeImage();
	 break;
	 case REPLACEABLE_TWO_HAND_WAND:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_WAND)
	 tex = sprite->GetDoubleHandWandImage();
	 break;
	 case REPLACEABLE_TWO_HAND_BOW:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_BOW)
	 tex = sprite->GetDoubleHandBowImage();
	 break;
	 case REPLACEABLE_SHIELD:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == SEC_SHIELD)
	 tex = sprite->GetShieldImage();
	 break;
	 case REPLACEABLE_FAQI:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == SEC_FAQI)
	 tex = sprite->GetFaqiImage();
	 break;
	 case REPLACEABLE_SKIRT_STAND:
	 if (sprite)
	 {
	 tex = sprite->GetSkirtStandImage();

	 if( !tex )
	 {
	 tex = sprite->getArmorImageByCloak();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 if (sprite)
	 {
	 if (sprite->IsCloakEmpty())
	 { //使用原装备，没有进行换裙子
	 if( !tex )
	 {
	 tex = sprite->getArmorImageByCloak();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 else
	 { //换裙子了
	 tex = sprite->GetSkirtStandImage();
	 }
	 }

	 break;
	 case REPLACEABLE_LEFT_SHOULDER:
	 //if (sprite)
	 //			{
	 //				tex = sprite->GetLeftShoulderImage();
	 //				if ( !tex ) //非普通NPC
	 //				{
	 //					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 //				}
	 //			}
	 if (sprite)
	 {
	 if (!sprite->IsCloakEmpty())
	 { //换裙子了
	 tex = sprite->GetLeftShoulderImage();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 break;
	 case REPLACEABLE_RIGHT_SHOULDER:
	 //if (sprite)
	 //			{
	 //				tex = sprite->GetRightShoulderImage();
	 //				if ( !tex ) //非普通NPC
	 //				{
	 //					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 //				}
	 //			}
	 if (sprite)
	 {
	 if (!sprite->IsCloakEmpty())
	 { //换裙子了
	 tex = sprite->GetRightShoulderImage();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }

	 break;
	 case REPLACEABLE_SKIRT_LIFT_LEG:
	 //if (sprite)
	 //			{
	 //				tex = sprite->GetSkirtLiftLegImage();
	 //				if( !tex && sprite->IsCloakEmpty() )
	 //				{
	 //					tex = sprite->GetArmorImage();
	 //				}
	 //
	 //				if ( !tex ) //非普通NPC
	 //				{
	 //					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 //				}
	 //			}
	 if (sprite)
	 {
	 if (!sprite->IsCloakEmpty())
	 { //换裙子了
	 tex = sprite->GetSkirtLiftLegImage();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 break;
	 case REPLACEABLE_SKIRT_SIT:
	 //if (sprite)
	 //			{
	 //				tex = sprite->GetSkirtSitImage();
	 //				if( !tex && sprite->IsCloakEmpty() )
	 //				{
	 //					tex = sprite->GetArmorImage();
	 //				}
	 //				if ( !tex ) //非普通NPC
	 //				{
	 //					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 //				}
	 //			}
	 if (sprite)
	 {
	 if (!sprite->IsCloakEmpty())
	 { //换裙子了
	 tex = sprite->GetSkirtSitImage();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 break;
	 case REPLACEABLE_SKIRT_WALK:
	 //if (sprite)
	 //			{
	 //				tex = sprite->GetSkirtWalkImage();
	 //				if( !tex && sprite->IsCloakEmpty() )
	 //				{
	 //					tex = sprite->GetArmorImage();
	 //				}
	 //
	 //				if ( !tex ) //非普通NPC
	 //				{
	 //					tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 //				}
	 //			}
	 if (sprite)
	 {
	 if (!sprite->IsCloakEmpty())
	 { //换裙子了
	 tex = sprite->GetSkirtWalkImage();
	 }

	 if ( !tex ) //非普通NPC
	 {
	 tex = sprite->getNpcLookfaceTexture(imageIndex, animationGroup);
	 }
	 }
	 break;
	 case REPLACEABLE_TWO_HAND_SPEAR:
	 if (sprite &&
	 sprite->IsKindOfClass(RUNTIME_CLASS(NDBaseRole)) &&
	 ((NDBaseRole*)sprite)->GetWeaponType() == TWO_HAND_SPEAR)
	 tex = sprite->GetDoubleHandSpearImage();
	 break;
	 default:
	 break;
	 }*/

	return tex;
}
