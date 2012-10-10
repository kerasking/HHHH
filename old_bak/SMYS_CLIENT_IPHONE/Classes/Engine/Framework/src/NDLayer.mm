//
//  NDLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDLayer.h"
#import "NDBaseLayer.h"

namespace NDEngine
{
	IMPLEMENT_CLASS(NDLayer, NDNode)
	
	NDLayer::NDLayer()
	{
		INIT_AUTOLINK(NDLayer);
	}
	
	NDLayer::~NDLayer()
	{
		
	}
	
	NDLayer* NDLayer::Layer()
	{
		NDLayer *layer = new NDLayer(); 
		layer->Initialization();
		return layer;
	}
	
	void NDLayer::Initialization()
	{
		NDAsssert(m_ccNode == nil);		
		m_ccNode = [[NDBaseLayer alloc] init];		
		NDBaseLayer *layer = (NDBaseLayer *)m_ccNode;
		[layer SetLayer:this];
		
		this->SetContentSize(CGSizeZero);			
	}
	
	void NDLayer::draw()
	{
		
	}
	
	void NDLayer::SetTouchEnabled(bool bEnabled)
	{
		NDAsssert(m_ccNode != nil);
		
		NDBaseLayer *layer = (NDBaseLayer *)m_ccNode;
		layer.isTouchEnabled = bEnabled;
	}
	
	bool NDLayer::TouchBegin(NDTouch* touch)
	{
		return true;
	}
	
	void NDLayer::TouchEnd(NDTouch* touch)
	{
		
	}
	
	void NDLayer::TouchCancelled(NDTouch* touch)
	{
		
	}
	
	void NDLayer::TouchMoved(NDTouch* touch)
	{
		
	}
	
	bool NDLayer::TouchDoubleClick(NDTouch* touch)
	{
		return true;
	}
}