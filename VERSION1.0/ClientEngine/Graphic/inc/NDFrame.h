//
//  NDFrame.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#ifndef _ND_FRAME_H_
#define _ND_FRAME_H_

#include "platform/CCPlatformMacros.h"
#include "CCArray.h"
#include "NDTile.h"
#include "NDAnimationGroup.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//#include "objc/objc.h"
//typedef signed char		BOOL;
#include "BaseType.h"
#endif

class NDFrameRunRecord: public cocos2d::CCObject
{
	CC_SYNTHESIZE(int, m_nNextFrameIndex, NextFrameIndex)
	CC_SYNTHESIZE(int, m_nCurrentFrameIndex, CurrentFrameIndex)
	CC_SYNTHESIZE(int, m_nRunCount, RunCount)
	CC_SYNTHESIZE(bool, m_bIsCompleted, IsCompleted)
	CC_SYNTHESIZE(int, m_nRepeatTimes, RepeatTimes)
	CC_SYNTHESIZE(int,m_nEnduration,Enduration);
	CC_SYNTHESIZE(int,m_nTotalFrame,TotalFrame);

public:

	NDFrameRunRecord();
	~NDFrameRunRecord();

	void SetPlayRange(int nStartFrame, int nEndFrame);
	void NextFrame(int nTotalFrames);
	bool isThisFrameEnd();
	void Clear();

private:

	int m_nStartFrame;
	int m_nEndFrame;
	BOOL m_bSetPlayRange;
};

//////////////////////////////////////////////////////////////////////////
//动画中所使用到的瓦片
class NDFrameTile: public cocos2d::CCObject
{
	CC_SYNTHESIZE(int, m_nX, X)
	CC_SYNTHESIZE(int, m_nY, Y)
	CC_SYNTHESIZE(int, m_nRotation, Rotation)
	CC_SYNTHESIZE(int, m_nTableIndex, TableIndex)

public:
	NDFrameTile();
	~NDFrameTile();
};

//////////////////////////////////////////////////////////////////////////
typedef struct _TILE_REVERSE_ROTATION
{
	BOOL reverse;					//是否翻转
	NDRotationEnum rotation;		//旋转角度
	float tileW;
} TILE_REVERSE_ROTATION;

class NDAnimation;
class NDAnimationGroup;
class NDFrame: public cocos2d::CCObject
{
	CC_SYNTHESIZE(int, m_nEnduration, Enduration)
	CC_SYNTHESIZE(NDAnimation*, m_pkBelongAnimation, BelongAnimation)
// 	CC_SYNTHESIZE_RETAIN(cocos2d::CCMutableArray<NDAnimationGroup*>*, m_pkSubAnimationGroups, SubAnimationGroups)
// 	CC_SYNTHESIZE_RETAIN(cocos2d::CCMutableArray<NDFrameTile*>*, m_pkFrameTiles, FrameTiles)
	CC_SYNTHESIZE_RETAIN(cocos2d::CCArray*, m_pkSubAnimationGroups, SubAnimationGroups)
	CC_SYNTHESIZE_RETAIN(cocos2d::CCArray*, m_pkFrameTiles, FrameTiles)

public:
	NDFrame();
	~NDFrame();

	void initTiles();
	//是否允许跑下一帧
	bool enableRunNextFrame(NDFrameRunRecord* pkFrameRunRecord);
	//跑一帧
	void run();
	void run(float fScale);

	// 绘制人物头像
	void drawHeadAt(CCPoint pos);

private:

	bool m_bNeedInitTitles;
	//cocos2d::CCMutableArray<NDTile*>* m_pkTiles;
	cocos2d::CCArray* m_pkTiles;

private:

	TILE_REVERSE_ROTATION tileReverseRotationWithReverse(bool bReverse,
			int nRota);
	cocos2d::CCTexture2D* getTileTextureWithImageIndex(int nImageIndex,
			int nReplace);
	float getTileW(int w, int h, NDRotationEnum rotation);
};

#endif
