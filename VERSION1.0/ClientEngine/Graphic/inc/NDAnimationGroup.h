//
//  NDAnimationGroup.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_ANIMATION_GROUP_H_ZJH_
#define _ND_ANIMATION_GROUP_H_ZJH_

#include "CCTexture2D.h"
#include "NDObject.h"
#include "CCArray.h"
//#include "NDSprite.h"

//using namespace NDEngine;
//class NDEngine::NDSprite;

class NDTileTableRecord : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nImageIndex, ImageIndex)
	CC_PROPERTY(int, m_nX, X)
	CC_PROPERTY(int, m_nY, Y)
	CC_PROPERTY(int, m_nW, W)
	CC_PROPERTY(int, m_nH, H)
	CC_PROPERTY(int, m_nReplace, Replace)
public:
	NDTileTableRecord();
};

//////////////////////////////////////////////////////////////////////////
class NDAnimationGroup : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nType, Type)
	CC_PROPERTY(int, m_nIdentifer, Identifer)
	CC_PROPERTY(CGPoint, m_Position, Position)
	CC_PROPERTY(CGSize, m_RunningMapSize, RunningMapSize)
	//CC_PROPERTY(NDEngine::NDSprite*, m_RuningSprite, RuningSprite)
	CC_PROPERTY(void*, m_RuningSprite, RuningSprite)
	
//	CC_PROPERTY_READONLY(bool, m_bReverse, Reverse) ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
//	CC_PROPERTY_READONLY(cocos2d::CCArray*/*<NDAnimation*>*/, m_Animations, Animations) ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
	//CC_PROPERTY_READONLY(cocos2d::CCArray*/*<NDTileTableRecord*>*/, m_TileTable, TileTable)
	CC_PROPERTY_READONLY(std::vector<std::string>*, m_Images, Images)
	CC_PROPERTY_READONLY(std::vector<int>*, m_UnpassPoint, UnpassPoint)

public:
	NDAnimationGroup();

	~NDAnimationGroup();

	void initWithSprFile(const char* sprFile);

	void drawHeadAt(CGPoint pos);

	void setReverse(bool newReverse);

private:
	int _orderId;

	//NDEngine::NDSprite* m_RunningSprite;
	void* m_RunningSprite;

private:
	void decodeSprtFile(FILE* stream);
	void decodeSprFile(FILE* stream);
};

#endif