//
//  NDBaseLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDBaseLayer.h"
#import "CCTouchDispatcher.h"
#import "NDLayer.h"
#import "NDUILayer.h"
#import "NDDirector.h"
#include "I_Analyst.h"

#define PRIORITY_ADJUST (100)

//bool g_NDBaseLayerPress = false;

@implementation NDBaseLayer

- (id)init
{
	if ((self = [super init])) 
	{
		m_ndTouch = new NDTouch();
		m_press = NO;
	}
	return self;
}

- (void)dealloc
{
	if (m_press)
	{
		//g_NDBaseLayerPress = false;
	}
	
	delete m_ndTouch;
	[super dealloc];
}

-(void) registerWithTouchDispatcher
{
	int iPriority  = INT_MAX - PRIORITY_ADJUST;
	
	NDNode* node = NULL;
	if (_ndUILayerNode.Pointer())
	{
		node = _ndUILayerNode.Pointer();
	}
	else if (_ndLayerNode.Pointer())
	{
		node = _ndLayerNode.Pointer();
	} 
	
	while (node) 
	{
		iPriority -= node->GetzOrder();
		node = node->GetParent();
	}
	
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:iPriority swallowsTouches:true];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	m_ndTouch->Initialization(touch);
	
	//if (g_NDBaseLayerPress)
	//{
	//	return NO;
	//}
	
	if (_ndUILayerNode) 
	{
		if (_ndUILayerNode->UITouchBegin(m_ndTouch))
		{
			//g_NDBaseLayerPress = true;
			m_press = true;
			return YES;
		}
	}
	else if (_ndLayerNode) 
	{
		if (_ndLayerNode->TouchBegin(m_ndTouch))
		{
			//g_NDBaseLayerPress = true;
			m_press = true;
			return YES;
		}
	}
	return NO;	
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	m_ndTouch->Initialization(touch);
	
	//g_NDBaseLayerPress = false;
	
	m_press = false;
	
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchEnd(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchEnd(m_ndTouch);
	}
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	m_ndTouch->Initialization(touch);
	
	//g_NDBaseLayerPress = false;
	
	m_press = false;
	
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchCancelled(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchCancelled(m_ndTouch);
	}
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	m_ndTouch->Initialization(touch);
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchMoved(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchMoved(m_ndTouch);
	}
}

- (bool)ccTouchDoubleClick:(UITouch *)touch withEvent:(UIEvent *)event
{
//	g_NDBaseLayerPress = false;
	
	m_ndTouch->Initialization(touch);
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchDoubleClick(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchDoubleClick(m_ndTouch);
	}
	
	return false;
}

- (void)draw
{
    TICK_ANALYST(ANALYST_DRAW_BASELAYER);
	NDNode* node = NULL;
	if (_ndUILayerNode.Pointer())
	{
		node = _ndUILayerNode.Pointer();
	}
	else if (_ndLayerNode.Pointer())
	{
		node = _ndLayerNode.Pointer();
	} 
	
	if (node && node->DrawEnabled()) 
	{
		NDDirector::DefaultDirector()->ResumeViewRect(node);
		node->draw();	
	}	
}

-(void) onExit
{
	[super onExit];
	
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->OnCanceledTouch();
	}
}

-(void)SetUILayer:(NDUILayer*) uilayer
{
	if (!uilayer) 
	{
		_ndUILayerNode.Clear();
		return;
	}
	_ndUILayerNode = uilayer->QueryLink();
}

-(void)SetLayer:(NDLayer*) layer
{
	if (!layer) 
	{
		_ndLayerNode.Clear();
		return;
	}
	_ndLayerNode = layer->QueryLink();
}


@end
