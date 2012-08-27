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


NDTileTableRecord::NDTileTableRecord()
: m_nImageIndex(0)
, m_nX(0)
, m_nY(0)
, m_nW(0)
, m_nH(0)
, m_nReplace(0)
{
}

//////////////////////////////////////////////////////////////////////////
NDAnimationGroup::NDAnimationGroup()
: m_nType(0)
, m_nIdentifer(0)
, m_bReverse(false)
, m_Animations(NULL)
, m_Images(NULL)
, m_TileTable(NULL)
, m_RuningSprite(NULL)
, m_UnpassPoint(NULL)
{
	m_Position			= CGPointMake(0, 0);
	m_RunningMapSize	= CGSizeMake(0, 0);
	m_Animations		= CCArray::array();
	m_TileTable			= CCArray::array();
	m_Images			= new vector<std::string>();

	m_Animations->retain();
	m_TileTable->retain();
}

NDAnimationGroup::~NDAnimationGroup()
{
	CC_SAFE_RELEASE(m_Animations);
	CC_SAFE_RELEASE(m_TileTable);
	CC_SAFE_DELETE(m_Images);
	CC_SAFE_DELETE(m_UnpassPoint);
}

void NDAnimationGroup::initWithSprFile(const char* sprFile)
{
	if (sprFile) 
	{	
		char sprtFile[256] = {0};
		sprintf(sprtFile, "%st", sprFile);
		FILE* pkSprtStream = fopen(sprtFile, "rt");

		if (pkSprtStream) 
		{
			this->decodeSprtFile(pkSprtStream);
			fclose(pkSprtStream);
		}
		
		FILE* pkSprStream = fopen(sprFile, "rt");

		if (pkSprStream) 
		{
			this->decodeSprFile(pkSprStream);
			fclose(pkSprStream);
		}			
	}
}

void NDAnimationGroup::setReverse(bool newReverse)
{
	m_bReverse = newReverse;
	for (int i = 0; i < (int)m_Animations->count(); i++) 
	{
		NDAnimation *animation = (NDAnimation *)m_Animations->objectAtIndex(i);
		animation->setReverse(newReverse);
	}
}

bool NDAnimationGroup::getReverse()
{
	return m_bReverse;
}

void NDAnimationGroup::decodeSprtFile(FILE* pkStream)
{
	FileOp kFileOp;
	int count = kFileOp.readByte(pkStream);

	for (int i = 0; i < count; i++) 
	{
 		NDTileTableRecord *pkRecord = new NDTileTableRecord;
 		pkRecord->setImageIndex(kFileOp.readByte(pkStream));
 		pkRecord->setX(kFileOp.readShort(pkStream));
 		pkRecord->setY(kFileOp.readShort(pkStream));
 		pkRecord->setW(kFileOp.readShort(pkStream));
 		pkRecord->setH(kFileOp.readShort(pkStream));

		//kFileOp.readByte(pkStream);

 		pkRecord->setReplace(kFileOp.readByte(pkStream));
 		m_TileTable->addObject(pkRecord);
 		pkRecord->release();	
	}
}



void NDAnimationGroup::decodeSprFile(FILE* pkStream)
{
	FileOp kFileOp;
	//动画用到的图片数目		
	int nImageCount = kFileOp.readByte(pkStream);
	for (int i = 0; i < nImageCount; i++) 
	{
		std::string imageName = kFileOp.readUTF8String(pkStream);
		std::string image = NDEngine::NDPath::GetImagePath() + imageName;
		m_Images->push_back(image);
	}
	
	int nAnimationCount = kFileOp.readByte(pkStream);
	for (int i = 0; i < nAnimationCount; i++) 
	{
		NDAnimation* pkAnimation = new NDAnimation;
		pkAnimation->setX(kFileOp.readShort(pkStream));
		pkAnimation->setY(kFileOp.readShort(pkStream));
		pkAnimation->setW(kFileOp.readShort(pkStream));
		pkAnimation->setH(kFileOp.readShort(pkStream));
		pkAnimation->setMidX(kFileOp.readShort(pkStream));
		pkAnimation->setBottomY(kFileOp.readShort(pkStream));
		pkAnimation->setType(kFileOp.readByte(pkStream));
		pkAnimation->setReverse(false);
		pkAnimation->setBelongAnimationGroup(this);
		
		int frameSize = kFileOp.readByte(pkStream);		
		for (int j = 0; j < frameSize; j++) 
		{
			NDFrame* pkFrame = new NDFrame;
			pkFrame->setEnduration(kFileOp.readShort(pkStream));
			pkFrame->setBelongAnimation(pkAnimation);
			// read music, do not deal now
			int sound_num = kFileOp.readShort(pkStream);

			for(int n = 0;n < sound_num;n++)
			{
				kFileOp.readUTF8String(pkStream);
			}

			int sagSize = kFileOp.readByte(pkStream);

			for (int k = 0; k < sagSize; k++) 
			{				
				std::string animationPath = NDEngine::NDPath::GetAnimationPath();
				std::string sprFile = animationPath + kFileOp.readUTF8String(pkStream);
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
			
			int tileSize = kFileOp.readByte(pkStream);
			for (int k = 0; k < tileSize; k++) 
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
		
		m_Animations->addObject(pkAnimation);
		pkAnimation->release();
	}
	
	//根据特殊字符怕是是否是带掩码点的动画
	std::string judge = kFileOp.readUTF8StringNoExcept(pkStream);
	if (judge == "■") 
	{
		if (!m_UnpassPoint)
		{
			m_UnpassPoint = new std::vector<int>;
		}

		int nSize = kFileOp.readByte(pkStream);

		for (int i = 0; i < nSize; i++)
		{
			m_UnpassPoint->push_back(kFileOp.readByte(pkStream));
			m_UnpassPoint->push_back(kFileOp.readByte(pkStream));
		}
	}
}

void NDAnimationGroup::drawHeadAt(CGPoint pos)
{
	NDAnimation* firstAni = (NDAnimation*)m_Animations->objectAtIndex(0);
	NDFrame* firstFrame = firstAni->getFrames()->getObjectAtIndex(0);
	firstFrame->drawHeadAt(pos);
}