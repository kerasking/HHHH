//
//  NDLightEffect.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDLightEffect.h"
#import "NDAnimationGroupPool.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDLightEffect, NDNode)
	
	NDLightEffect::NDLightEffect()
    :m_fScale(1.0f)
	{
		m_frameRunRecord = nil;
		m_aniGroup = nil;
		m_lightId = 0;
		m_reverse = false;
	}
	
	NDLightEffect::~NDLightEffect()
	{
		[m_aniGroup release];
		[m_frameRunRecord release];
	}
	
	void NDLightEffect::Initialization(const char* sprFile)
	{
		NDNode::Initialization();	
		m_aniGroup = [[NDAnimationGroupPool defaultPool] addObjectWithSpr:[NSString stringWithUTF8String:sprFile]];
		m_frameRunRecord = [[NDFrameRunRecord alloc] init];		
	}
	
	void NDLightEffect::SetPosition(CGPoint newPosition)
	{
		m_position = newPosition;
	}
	
	void NDLightEffect::SetRepeatTimes(unsigned int times)
	{
		if (m_frameRunRecord) 
			m_frameRunRecord.repeatTimes = times;
	}
	
	void NDLightEffect::SetLightId(unsigned int lightId, bool reverse/*=true*/)
	{
		m_lightId = lightId;
		m_reverse = reverse;
	}
	
	void NDLightEffect::SlowDown(unsigned int mutli)
	{
		if (m_aniGroup)
		{
			NDAnimation *ani = [m_aniGroup.animations objectAtIndex:m_lightId];
			if (ani) 
				[ani SlowDown:mutli];
		}
	}
    void NDLightEffect::SetScale(float fScale)
    {
        m_fScale = fScale;
    }
	
	void NDLightEffect::Run(CGSize mapSize, bool draw/*=true*/)
	{		
		if ([m_aniGroup.animations count] > m_lightId) 
		{	
			NDSprite *oldSprite = [m_aniGroup getRuningSprite];
			[m_aniGroup setRuningSprite:NULL];			
			NDAnimation *ani = [m_aniGroup.animations objectAtIndex:m_lightId];			
			m_aniGroup.runningMapSize = mapSize;
			m_aniGroup.position = m_position;			
			ani.reverse = m_reverse;
			[ani runWithRunFrameRecord:m_frameRunRecord draw:true scale:m_fScale];
			[m_aniGroup setRuningSprite:oldSprite];
		}
	}
	
	
	void NDLightEffect::draw()
	{
		NDNode::draw();
		
		NDLayer* layer = (NDLayer*)this->GetParent();
		if (layer) 
		{
			if (m_frameRunRecord.isCompleted) 
			{
				this->RemoveFromParent(true);
				return;
			}
			
			if ([m_aniGroup.animations count] > m_lightId) 
			{				
				NDAnimation *ani = [m_aniGroup.animations objectAtIndex:m_lightId];			
				m_aniGroup.runningMapSize = layer->GetContentSize();
				m_aniGroup.position = m_position;			
				ani.reverse = m_reverse;
				[ani runWithRunFrameRecord:m_frameRunRecord draw:true scale:m_fScale];
			}
			else 
			{
				this->RemoveFromParent(true);
			}
		}				
	}
}


