//
//  NDFrame.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _ND_FRAME_H_
#define _ND_FRAME_H_

#include "platform/CCPlatformMacros.h"
#include "CCMutableArray.h"

class NDFrameRunRecord : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nNextFrameIndex, NextFrameIndex)
	CC_PROPERTY(int, m_nCurrentFrameIndex, CurrentFrameIndex)
	CC_PROPERTY(int, m_nRunCount, RunCount)
	CC_PROPERTY(bool, m_bIsCompleted, IsCompleted)
	CC_PROPERTY(int, m_nRepeatTimes, RepeatTimes)

public:
	NDFrameRunRecord();

	void SetPlayRange(int nStartFrame, int nEndFrame);
	void NextFrame(int nTotalFrames);

private:
	int m_nStartFrame, m_nEndFrame;
	BOOL m_bSetPlayRange;
};

//////////////////////////////////////////////////////////////////////////
//动画中所使用到的瓦片
class NDFrameTile : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nX, X)
	CC_PROPERTY(int, m_nY, Y)
	CC_PROPERTY(int, m_nRotation, Rotation)
	CC_PROPERTY(int, m_nTableIndex, TableIndex)

public:
	NDFrameTile();
};

//////////////////////////////////////////////////////////////////////////
typedef struct _TILE_REVERSE_ROTATION
{
	BOOL reverse;					//是否翻转
	NDRotationEnum rotation;		//旋转角度
	float tileW;
}TILE_REVERSE_ROTATION;

class NDAnimation;
class NDAnimationGroups;
class NDFrame : public cocos2d::CCObject
{
	CC_PROPERTY(int, m_nEnduration, Enduration)
	CC_PROPERTY(NDAnimation*, m_BelongAnimation, BelongAnimation)
	CC_SYNTHESIZE_RETAIN(CCMutableArray<NDAnimationGroups*>*, m_SubAnimationGroups, SubAnimationGroups)
	CC_SYNTHESIZE_RETAIN(CCMutableArray<NDFrameTile*>*, m_FrameTiles, FrameTiles)

public:
	void initTiles();
	//是否允许跑下一帧
	bool enableRunNextFrame(NDFrameRunRecord* frameRunRecord);
	//跑一帧
	void run();
	void run(float scale);

	// 绘制人物头像
	void drawHeadAt(CCPoint pos);

private:
	int						m_count;
	bool					m_needInitTitles;
	CCMutableArray<NDTile*> m_tiles;

private:
	TILE_REVERSE_ROTATION tileReverseRotationWithReverse(bool reverse, int rota);
	CCTexture2D* getTileTextureWithImageIndex(int imageIndex, int replace);
	float getTileW(int w, int h, NDRotationEnum rotation);
};

#endif