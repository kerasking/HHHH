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
#include <vector>

//using namespace NDEngine;
using namespace cocos2d;

namespace NDEngine
{
	class NDSprite;
}

class NDTileTableRecord : public cocos2d::CCObject
{
	CC_SYNTHESIZE(int, m_nImageIndex, ImageIndex)
	CC_SYNTHESIZE(int, m_nX, X)
	CC_SYNTHESIZE(int, m_nY, Y)
	CC_SYNTHESIZE(int, m_nW, W)
	CC_SYNTHESIZE(int, m_nH, H)
	CC_SYNTHESIZE(int, m_nReplace, Replace)
public:
	NDTileTableRecord();
	~NDTileTableRecord();
};

//////////////////////////////////////////////////////////////////////////
class NDAnimationGroup : public cocos2d::CCObject
{
	CC_SYNTHESIZE(int, m_nType, Type)
	CC_SYNTHESIZE(int, m_nIdentifer, Identifer)
	CC_SYNTHESIZE(CCPoint, m_kPosition, Position)
	CC_SYNTHESIZE(CCSize, m_kRunningMapSize, RunningMapSize)
	CC_SYNTHESIZE(NDEngine::NDSprite*, m_pkRuningSprite, RuningSprite)
	
	CC_PROPERTY(bool, m_bReverse, Reverse)
	CC_SYNTHESIZE(cocos2d::CCArray*, m_pkAnimations, Animations)
	CC_SYNTHESIZE(cocos2d::CCArray*, m_pkTileTable, TileTable)
	CC_SYNTHESIZE(std::vector<std::string>*, m_pkImages, Images)
	CC_SYNTHESIZE(std::vector<int>*, m_pkUnpassPoint, UnpassPoint)

public:

	NDAnimationGroup();
	~NDAnimationGroup();

	void initWithSprFile(const char* sprFile);

	void drawHeadAt(CCPoint pos);

private:

	int m_nOrderID;

	//NDEngine::NDSprite* m_RunningSprite;
	void* m_pRunningSprite;

private:
	void decodeSprtFile(FILE* pkStream);
	void decodeSprFile(FILE* pkStream);
};

#endif