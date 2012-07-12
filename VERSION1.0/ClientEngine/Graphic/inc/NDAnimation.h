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
class NDAnimation : public cocos2d::CCObject 
{
	CC_SYNTHESIZE_RETAIN(cocos2d::CCMutableArray<NDFrame*>*, m_Frames, Frames)
	CC_PROPERTY(int, m_nX, X)
	CC_PROPERTY(int, m_nY, Y)
	CC_PROPERTY(int, m_nW, W)
	CC_PROPERTY(int, m_nH, H)
	CC_PROPERTY(int, m_nMidX, MidX)
	CC_PROPERTY(int, m_nBottomY, BottomY)
	CC_PROPERTY(int, m_nType, Type)
	CC_PROPERTY(bool, m_bReverse, Reverse)
	CC_PROPERTY(NDAnimationGroup*, m_BelongAnimationGroup, BelongAnimationGroup)
	CC_PROPERTY(int, m_nCurIndexInAniGroup, CurIndexInAniGroup)

public:
	NDAnimation();
	~NDAnimation();

	CGRect getRect();

	void runWithRunFrameRecord(NDFrameRunRecord* runFrameRecord, bool needDraw);
	void runWithRunFrameRecord(NDFrameRunRecord* runFrameRecord, bool needDraw, float drawScale);
	void SlowDown(unsigned int multi);
};

#endif