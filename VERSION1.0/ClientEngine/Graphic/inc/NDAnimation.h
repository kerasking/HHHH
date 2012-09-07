//
//  NDAnimation.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_ANIMATION_H_
#define _ND_ANIMATION_H_

//#include "NDFrame.h"
#include "CCMutableArray.h"
#include "Utility.h"
#include "NDFrame.h"

#define ANIMATION_TYPE_ONCE_CYCLE 0
#define ANIMATION_TYPE_ONCE_END 1
#define ANIMATION_TYPE_ONCE_START 2

class NDFrameRunRecord;
class NDAnimationGroup;
class NDAnimation: public cocos2d::CCObject
{
	CC_SYNTHESIZE_RETAIN(cocos2d::CCMutableArray<NDFrame*>*, m_pkFrames, Frames)
	CC_SYNTHESIZE(int, m_nX, X)
	CC_SYNTHESIZE(int, m_nY, Y)
	CC_SYNTHESIZE(int, m_nW, W)
	CC_SYNTHESIZE(int, m_nH, H)
	CC_SYNTHESIZE(int, m_nMidX, MidX)
	CC_SYNTHESIZE(int, m_nBottomY, BottomY)
	CC_SYNTHESIZE(int, m_nType, Type)
	CC_SYNTHESIZE(bool, m_bReverse, Reverse)
	CC_SYNTHESIZE(NDAnimationGroup*, m_pkBelongAnimationGroup, BelongAnimationGroup)
	CC_SYNTHESIZE(int, m_nCurIndexInAniGroup, CurIndexInAniGroup)

public:
	NDAnimation();
	~NDAnimation();

	CGRect getRect();

	void runWithRunFrameRecord(NDFrameRunRecord* pkRunFrameRecord, bool bNeedDraw);
	void runWithRunFrameRecord(NDFrameRunRecord* pkRunFrameRecord, bool bNeedDraw,
			float drawScale);
	void SlowDown(unsigned int multi);

	bool lastFrameEnd(NDFrameRunRecord* pkRunRecord);
};

#endif
