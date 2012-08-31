//
//  NDAnimation.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDAnimation.h"
#include "NDTile.h"
#include "NDAnimationGroup.h"
#include "NDFrame.h"

using namespace cocos2d;

NDAnimation::NDAnimation() :
m_pkFrames(NULL),
m_nX(0), m_nY(0),
m_nW(0), m_nH(0),
m_nMidX(0),
m_nBottomY(0),
m_nType(0),
m_bReverse(false),
m_BelongAnimationGroup(NULL),
m_nCurIndexInAniGroup(-1)
{
	m_pkFrames = new cocos2d::CCMutableArray<NDFrame*>();
}

NDAnimation::~NDAnimation()
{
	CC_SAFE_RELEASE (m_pkFrames);
}

CGRect NDAnimation::getRect()
{
	if (m_BelongAnimationGroup)
	{
		int nPosX = m_BelongAnimationGroup->getPosition().x;
		int nPosY = m_BelongAnimationGroup->getPosition().y;

		if (m_nMidX != 0)
		{
			nPosX -= m_nMidX - m_nX;
		}

		if (m_nBottomY != 0)
		{
			nPosY -= m_nBottomY - m_nY;
		}

		return CGRectMake(nPosX, nPosY, m_nW, m_nH);
	}

	return CGRectZero;
}

void NDAnimation::runWithRunFrameRecord(NDFrameRunRecord* runFrameRecord,
		bool needDraw, float drawScale)
{
	if (m_pkFrames->count())
	{
		if (runFrameRecord->getCurrentFrameIndex() >= (int) m_pkFrames->count())
		{
			return;
		}

		if (runFrameRecord->getNextFrameIndex() != 0
				&& runFrameRecord->getCurrentFrameIndex() == 0)
		{
			if (m_nType == ANIMATION_TYPE_ONCE_END)
			{
				NDFrame* frame = m_pkFrames->getLastObject();
				if (needDraw)
				{
					frame->run(drawScale);
				}
				return;
			}
			else if (m_nType == ANIMATION_TYPE_ONCE_START)
			{
				NDFrame* frame = m_pkFrames->getObjectAtIndex(0);
				if (needDraw)
				{
					frame->run(drawScale);
				}
				return;
			}
		}

		//获取动画的当前帧
		NDFrame *pkFrame = m_pkFrames->getObjectAtIndex(
				runFrameRecord->getCurrentFrameIndex());

		//判断是否允许跑下一帧，如果允许则跑下一帧，否则还是跑当前帧
		if (pkFrame->enableRunNextFrame(runFrameRecord))
		{
			//runFrameRecord.isCompleted = NO;	
			//取下一帧
			pkFrame = m_pkFrames->getObjectAtIndex(
					runFrameRecord->getNextFrameIndex());

			runFrameRecord->NextFrame((int) m_pkFrames->count());
			/*
			 //当前帧的索引值改变
			 if (++runFrameRecord.currentFrameIndex == (int)[_frames count])
			 {
			 runFrameRecord.currentFrameIndex = 0;

			 if (runFrameRecord.repeatTimes > 0)
			 {
			 runFrameRecord.repeatTimes--;
			 }
			 }

			 //下一帧的索引值改变
			 runFrameRecord.nextFrameIndex = runFrameRecord.currentFrameIndex + 1;
			 if (runFrameRecord.nextFrameIndex == (int)[_frames count])
			 {
			 runFrameRecord.nextFrameIndex = 0;
			 if (runFrameRecord.repeatTimes == 0)
			 {
			 runFrameRecord.isCompleted = YES;
			 }

			 }
			 */
		}

		if (needDraw)
		{
			//跑一帧
			pkFrame->run(drawScale);
		}
	}
}

void NDAnimation::runWithRunFrameRecord(NDFrameRunRecord* runFrameRecord,
		bool needDraw)
{
	this->runWithRunFrameRecord(runFrameRecord, needDraw, 1.0f);
}

void NDAnimation::SlowDown(unsigned int multi)
{
	if (m_pkFrames->count())
	{
		for (unsigned int i = 0; i < m_pkFrames->count(); i++)
		{
			NDFrame *frame = m_pkFrames->getObjectAtIndex(i);
			frame->setEnduration(frame->getEnduration() * multi);
		}
	}
}
