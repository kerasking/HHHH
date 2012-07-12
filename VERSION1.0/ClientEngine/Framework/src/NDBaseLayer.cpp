//
//  NDBaseLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDBaseLayer.h"
#include "CCTouchDispatcher.h"
#include "NDLayer.h"
#include "NDUILayer.h"
#include "NDDirector.h"

using namespace cocos2d;

#define PRIORITY_ADJUST (100)

NDBaseLayer::NDBaseLayer()
{
	m_ndTouch = new NDTouch();
	//m_press = false;
}

NDBaseLayer::~NDBaseLayer()
{
	delete m_ndTouch;
}

void NDBaseLayer::SetUILayer(NDUILayer* uilayer)
{
	if (!uilayer) 
	{
		_ndUILayerNode.Clear();
		return;
	}
	_ndUILayerNode = uilayer->QueryLink();
}

void NDBaseLayer::SetLayer(NDLayer* layer)
{
	if (!layer) 
	{
		_ndLayerNode.Clear();
		return;
	}
	_ndLayerNode = layer->QueryLink();
}

void NDBaseLayer::registerWithTouchDispatcher(void)
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
	
	CCTouchDispatcher::sharedDispatcher()->addTargetedDelegate(this, iPriority, true);
}

bool NDBaseLayer::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	m_ndTouch->Initialization(pTouch);
	
	//if (g_NDBaseLayerPress)
	//{
	//	return NO;
	//}
	
	if (_ndUILayerNode) 
	{
		if (_ndUILayerNode->UITouchBegin(m_ndTouch))
		{
			//g_NDBaseLayerPress = true;
			//m_press = true;
			return true;
		}
	}
	else if (_ndLayerNode) 
	{
		if (_ndLayerNode->TouchBegin(m_ndTouch))
		{
			//g_NDBaseLayerPress = true;
			//m_press = true;
			return true;
		}
	}
	return false;	
}

void NDBaseLayer::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	m_ndTouch->Initialization(pTouch);
	
	//g_NDBaseLayerPress = false;
	
	//m_press = false;
	
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchEnd(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchEnd(m_ndTouch);
	}
}

void NDBaseLayer::ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{
	m_ndTouch->Initialization(pTouch);
	
	//g_NDBaseLayerPress = false;
	
	//m_press = false;
	
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchCancelled(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchCancelled(m_ndTouch);
	}
}

void NDBaseLayer::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	m_ndTouch->Initialization(pTouch);
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->UITouchMoved(m_ndTouch);
	}
	else if (_ndLayerNode) 
	{
		return _ndLayerNode->TouchMoved(m_ndTouch);
	}
}

bool NDBaseLayer::ccTouchDoubleClick(CCTouch *pTouch, CCEvent *pEvent)
{
//	g_NDBaseLayerPress = false;
	
	m_ndTouch->Initialization(pTouch);
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

void NDBaseLayer::draw()
{
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

void NDBaseLayer::onExit()
{
	cocos2d::CCLayer::onExit();
	
	if (_ndUILayerNode) 
	{
		return _ndUILayerNode->OnCanceledTouch();
	}
}
