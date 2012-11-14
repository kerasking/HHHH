//
//  NDAnimationGroup.m
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDAnimationGroup.h"
#include "NDAnimation.h"
#include "NDPath.h"
#include "JavaMethod.h"
#include "NDFrame.h"
//#include "NDSprite.h"

using namespace cocos2d;

NDTileTableRecord::NDTileTableRecord() :
m_nImageIndex(0),
m_nX(0),
m_nY(0),
m_nW(0),
m_nH(0),
m_nReplace(0)
{
}

//////////////////////////////////////////////////////////////////////////
NDAnimationGroup::NDAnimationGroup() :
m_nType(0),
m_nIdentifer(0),
m_bReverse(false),
m_pkAnimations(NULL),
m_pkImages(NULL),
m_pkTileTable(NULL),
m_pkRuningSprite(NULL),
m_pkUnpassPoint(NULL)
{
	m_kPosition = CGPointMake(0, 0);
	m_kRunningMapSize = CGSizeMake(0, 0);
	m_pkAnimations = CCArray::array();
	m_pkTileTable = CCArray::array();
	m_pkImages = new vector<std::string>();
	//m_pkUnpassPoint = new vector<int>();

	m_pkAnimations->retain();
	m_pkTileTable->retain();
}

NDAnimationGroup::~NDAnimationGroup()
{
	CC_SAFE_RELEASE (m_pkAnimations);
	CC_SAFE_RELEASE (m_pkTileTable);
	CC_SAFE_DELETE (m_pkImages);
	CC_SAFE_DELETE (m_pkUnpassPoint);
}

void NDAnimationGroup::initWithSprFile(const char* sprFile)
{
	if (sprFile)
	{
		char sprtFile[256] =
		{ 0 };
		sprintf(sprtFile, "%st", sprFile);
		FILE* pkSprtStream = fopen(sprtFile, "rb");

		if (pkSprtStream)
		{
			this->decodeSprtFile(pkSprtStream);
			fclose(pkSprtStream);
		}

		FILE* pkSprStream = fopen(sprFile, "rb");

		if (pkSprStream)
		{
			this->decodeSprFile(pkSprStream);
			fclose(pkSprStream);
		}
	}
}

void NDAnimationGroup::setReverse(bool bNewReverse)
{
	m_bReverse = bNewReverse;
	for (int i = 0; i < (int) m_pkAnimations->count(); i++)
	{
		NDAnimation *pkAnimation = (NDAnimation *) m_pkAnimations->
			objectAtIndex(i);
		pkAnimation->setReverse(bNewReverse);
	}
}

bool NDAnimationGroup::getReverse()
{
	return m_bReverse;
}

void NDAnimationGroup::decodeSprtFile(FILE* pkStream)
{
	FileOp kFileOp;
	int nCount = kFileOp.readByte(pkStream);

	for (int i = 0; i < nCount; i++)
	{
		NDTileTableRecord *pkRecord = new NDTileTableRecord;

		int nImageIndex = kFileOp.readByte(pkStream);

		pkRecord->setImageIndex(nImageIndex);

		int nX = kFileOp.readShort(pkStream);
		int nY = kFileOp.readShort(pkStream);
		int nW = kFileOp.readShort(pkStream);
		int nH = kFileOp.readShort(pkStream);

		pkRecord->setX(nX);
		pkRecord->setY(nY);
		pkRecord->setW(nW);
		pkRecord->setH(nH);

		unsigned int uiTemp = kFileOp.readByte(pkStream);

		pkRecord->setReplace(uiTemp);
		m_pkTileTable->addObject(pkRecord);
		pkRecord->release();

		CCLog("the number is : %d",uiTemp);
	}
}

void NDAnimationGroup::decodeSprFile(FILE* pkStream)
{
	FileOp kFileOp;
	//动画用到的图片数目		
	int nImageCount = kFileOp.readByte(pkStream);
	for (int i = 0; i < nImageCount; i++)
	{
		std::string strImageName = kFileOp.readUTF8String(pkStream);
		if (strstr(strImageName.c_str(), "fuck2") != NULL)
		{
			int i = 1;
		}
		std::string strImage = NDEngine::NDPath::GetImagePath() + strImageName;
		m_pkImages->push_back(strImage);
	}

	int nAnimationCount = kFileOp.readByte(pkStream);
	for (int i = 0; i < nAnimationCount; i++)
	{
		NDAnimation* pkAnimation = new NDAnimation;

		int nX = kFileOp.readShort(pkStream);
		int nY = kFileOp.readShort(pkStream);
		int nW = kFileOp.readShort(pkStream);
		int nH = kFileOp.readShort(pkStream);
		int nMid = kFileOp.readShort(pkStream);
		int nBottomY = kFileOp.readShort(pkStream);
		int nType = kFileOp.readByte(pkStream);

		pkAnimation->setX(0);
		pkAnimation->setY(0);
		pkAnimation->setW(136);
		pkAnimation->setH(159);
		pkAnimation->setMidX(59);
		pkAnimation->setBottomY(nBottomY);
		pkAnimation->setType(nType);
		pkAnimation->setReverse(false);
		pkAnimation->setBelongAnimationGroup(this);

		int nFrameSize = kFileOp.readByte(pkStream);
		for (int j = 0; j < nFrameSize; j++)
		{
			NDFrame* pkFrame = new NDFrame;
			pkFrame->setEnduration(kFileOp.readShort(pkStream));
			pkFrame->setBelongAnimation(pkAnimation);
			// read music, do not deal now
			int nSoundNumber = kFileOp.readShort(pkStream);

			for (int n = 0; n < nSoundNumber; n++)
			{
				kFileOp.readUTF8String(pkStream);
			}

			int nSagSize = kFileOp.readByte(pkStream);

			for (int k = 0; k < nSagSize; k++)
			{
				std::string strAnimationPath =
						NDEngine::NDPath::GetAnimationPath();
				std::string sprFile = strAnimationPath
						+ kFileOp.readUTF8String(pkStream);
				NDAnimationGroup* pkSag = new NDAnimationGroup;
				pkSag->initWithSprFile(sprFile.c_str());
				pkSag->setType(kFileOp.readByte(pkStream));
				pkSag->setIdentifer(kFileOp.readInt(pkStream));
				CGFloat xx = kFileOp.readShort(pkStream);
				CGFloat yy = kFileOp.readShort(pkStream);
				pkSag->setPosition(CGPointMake(xx, yy));
				pkSag->setReverse(kFileOp.readByte(pkStream));

				pkFrame->getSubAnimationGroups()->addObject(pkSag);
				pkSag->release();
			}

			int nTileSize = kFileOp.readByte(pkStream);
			for (int k = 0; k < nTileSize; k++)
			{
				NDFrameTile* pkFrameTile = new NDFrameTile;

				pkFrameTile->setX(kFileOp.readShort(pkStream));
				pkFrameTile->setY(kFileOp.readShort(pkStream));
				pkFrameTile->setRotation(kFileOp.readShort(pkStream));
				pkFrameTile->setTableIndex(kFileOp.readShort(pkStream));

				pkFrame->getFrameTiles()->addObject(pkFrameTile);
				pkFrameTile->release();
			}

			pkAnimation->getFrames()->addObject(pkFrame);
			pkFrame->release();
		}

		m_pkAnimations->addObject(pkAnimation);
		pkAnimation->release();
	}

	//根据特殊字符怕是是否是带掩码点的动画
	std::string strJudge = kFileOp.readUTF8StringNoExcept(pkStream);
	if (strJudge == "■")
	{
		if (!m_pkUnpassPoint)
		{
			m_pkUnpassPoint = new std::vector<int>;
		}

		int nSize = kFileOp.readByte(pkStream);

		for (int i = 0; i < nSize; i++)
		{
			m_pkUnpassPoint->push_back(kFileOp.readByte(pkStream));
			m_pkUnpassPoint->push_back(kFileOp.readByte(pkStream));
		}
	}
}

void NDAnimationGroup::drawHeadAt(CGPoint pos)
{
	NDAnimation* pkFirstAni = (NDAnimation*) m_pkAnimations->objectAtIndex(0);
	NDFrame* pkFirstFrame = (NDFrame*)pkFirstAni->getFrames()->objectAtIndex(0);
	pkFirstFrame->drawHeadAt(pos);
}
