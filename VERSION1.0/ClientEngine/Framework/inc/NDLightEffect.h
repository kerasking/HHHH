//
//  NDLightEffect.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-21.
//  Copyright 2011 (网龙)DeNA. All rights reserved.
//

#ifndef __NDLightEffect_H
#define __NDLightEffect_H

#include "NDNode.h"
#include "NDLayer.h"

#include "NDAnimation.h"

namespace NDEngine
{
class NDLightEffect: public NDNode
{
DECLARE_CLASS(NDLightEffect)
	NDLightEffect();
	~NDLightEffect();

public:

	void Initialization(const char* sprFile);
	void SetRepeatTimes(unsigned int times);
	void SetLightId(unsigned int uiLightID, bool bReverse = true);
	void SlowDown(unsigned int mutli);

//	void SetPosition(CGPoint kNewPosition);
	void SetWorldPos( const CGPoint& worldPos );
	void SetCellPos( const CGPoint& cellPos );
	CGPoint GetWorldPos();
	CGPoint GetCellPos();

public:
	//武状元光效使用
	void Run(CGSize mapSize, bool draw = true);

	CC_SYNTHESIZE(float,m_fScale,Scale);

public:

	void draw();

private:

	NDFrameRunRecord* m_pkFrameRunRecord;
	NDAnimationGroup* m_pkAniGroup;

	CGPoint m_kPosition; //世界坐标
	unsigned int m_nLightID;

	bool m_bIsStop;
	bool m_bReverse;
};
}
#endif
