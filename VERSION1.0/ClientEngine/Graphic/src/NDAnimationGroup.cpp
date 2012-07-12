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
, m_bReverse(0)
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
		sprintf(sprtFile, "%st", sprtFile);
		FILE* sprtStream = fopen(sprtFile, "rt");
		if (sprtStream) 
		{
			this->decodeSprtFile(sprtStream);
			fclose(sprtStream);
		}
		
		FILE* sprStream = fopen(sprFile, "rt");
		if (sprStream) 
		{
			this->decodeSprFile(sprStream);
			fclose(sprStream);
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

void NDAnimationGroup::decodeSprtFile(FILE* stream)
{
	FileOp op;
	int count = op.readByte(stream);
	for (int i = 0; i < count; i++) 
	{
		NDTileTableRecord *record = new NDTileTableRecord;
		record->setImageIndex(op.readByte(stream));
		record->setX(op.readShort(stream));
		record->setY(op.readShort(stream));
		record->setW(op.readShort(stream));
		record->setH(op.readShort(stream));
		record->setReplace(op.readByte(stream));
		m_TileTable->addObject(record);
		record->release();	
	}
}



void NDAnimationGroup::decodeSprFile(FILE* stream)
{
	FileOp op;
	//动画用到的图片数目		
	int imageCount = op.readByte(stream);
	for (int i = 0; i < imageCount; i++) 
	{
		std::string imageName = op.readUTF8String(stream);
		std::string image = NDEngine::NDPath::GetImagePath() + imageName;
		m_Images->push_back(image);
	}
	
	int animationCount = op.readByte(stream);
	for (int i = 0; i < animationCount; i++) 
	{
		NDAnimation *animation = new NDAnimation;
		animation->setX(op.readShort(stream));
		animation->setY(op.readShort(stream));
		animation->setW(op.readShort(stream));
		animation->setH(op.readShort(stream));
		animation->setMidX(op.readShort(stream));
		animation->setBottomY(op.readShort(stream));
		animation->setType(op.readByte(stream));
		animation->setReverse(false);
		animation->setBelongAnimationGroup(this);
		
		int frameSize = op.readByte(stream);		
		for (int j = 0; j < frameSize; j++) 
		{
			NDFrame *frame = new NDFrame;
			frame->setEnduration(op.readShort(stream));
			frame->setBelongAnimation(animation);
			// read music, do not deal now
			int sound_num=op.readShort(stream);
			for(int n=0;n<sound_num;n++){
				op.readUTF8String(stream);
			}
			int sagSize = op.readByte(stream);
			for (int k = 0; k < sagSize; k++) 
			{				
				std::string animationPath = NDEngine::NDPath::GetAnimationPath();
				std::string sprFile = animationPath + op.readUTF8String(stream);
				NDAnimationGroup *sag = new NDAnimationGroup; 
				sag->initWithSprFile(sprFile.c_str());
				sag->setType(op.readByte(stream));
				sag->setIdentifer(op.readInt(stream));
				CGFloat xx = op.readShort(stream);
				CGFloat yy = op.readShort(stream);
				sag->setPosition(CGPointMake(xx, yy));
				sag->setReverse(op.readByte(stream));
				
				frame->getSubAnimationGroups()->addObject(sag);
				sag->release();
			}
			
			int tileSize = op.readByte(stream);
			for (int k = 0; k < tileSize; k++) 
			{				
				NDFrameTile *frameTile = new NDFrameTile;
				
				frameTile->setX(op.readShort(stream));
				frameTile->setY(op.readShort(stream));
				frameTile->setRotation(op.readShort(stream));
				frameTile->setTableIndex(op.readShort(stream));
				
				frame->getFrameTiles()->addObject(frameTile);
				frameTile->release();
			}
			
			animation->getFrames()->addObject(frame);
			frame->release();
			
		}
		
		m_Animations->addObject(animation);
		animation->release();
	}
	
	//根据特殊字符怕是是否是带掩码点的动画
	std::string judge = op.readUTF8StringNoExcept(stream);
	if (judge == "■") 
	{
		if (!m_UnpassPoint) {
			m_UnpassPoint = new std::vector<int>;
		}
		int size= op.readByte(stream);
		for (int i = 0; i < size; i++) {
			m_UnpassPoint->push_back(op.readByte(stream));
			m_UnpassPoint->push_back(op.readByte(stream));
		}
	}
}

void NDAnimationGroup::drawHeadAt(CGPoint pos)
{
	NDAnimation* firstAni = (NDAnimation*)m_Animations->objectAtIndex(0);
	NDFrame* firstFrame = firstAni->getFrames()->getObjectAtIndex(0);
	firstFrame->drawHeadAt(pos);
}
