//
//  NDAnimationGroup.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "NDSprite.h"
#include "CCTexture2D.h"

using namespace NDEngine;

class NDTileTableRecord : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nImageIndex, ImageIndex)
	CC_PROPERTY(int, m_nX, X)
	CC_PROPERTY(int, m_nY, Y)
	CC_PROPERTY(int, m_nW, W)
	CC_PROPERTY(int, m_nH, H)
	CC_PROPERTY(int, m_nReplace, Replace)
};

//////////////////////////////////////////////////////////////////////////

class NDAnimationGroup : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nType, Type)
	CC_PROPERTY(int, m_nIdentifer, Identifer)
	CC_PROPERTY(CGPoint, m_Position, Position)
	CC_PROPERTY(CGSize, m_RunningMapSize, RunningMapSize)
	CC_PROPERTY(NDSprite*, m_RuningSprite, RuningSprite)
	
	CC_PROPERTY_READONLY(bool, m_bReverse, Reverse)
	CC_PROPERTY_READONLY(CCArray<NDAnimation*>, m_Animations, Animations)
	CC_PROPERTY_READONLY(CCArray<NDTileTableRecord*>*, m_TileTable, TileTable)
	CC_PROPERTY_READONLY(std::vector<std::string>*, m_Images, Images)
	CC_PROPERTY_READONLY(std::vector<int>*, m_UnpassPoint, UnpassPoint)

public:
	void initWithSprFile(const char* sprFile);

	void drawHeadAt(CGPoint pos);

private:
	int _orderId;

	NDSprite* m_runningSprite;

private:
	void decodeSprtFile(FILE* stream);
	void decodeSprFile(FILE* stream);

	void setReverse(bool newReverse);
};
