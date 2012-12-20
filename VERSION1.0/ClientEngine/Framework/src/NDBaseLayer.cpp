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
#include "NDMapLayer.h"

using namespace cocos2d;

//#define PRIORITY_ADJUST (100)

NDBaseLayer::NDBaseLayer()
{
	setSubPriority( 0xff ); //@priority
	setDebugName("NDBaseLayer");
	m_pkTouch = new NDTouch();
	m_bPress = false;
}

NDBaseLayer::~NDBaseLayer()
{
	delete m_pkTouch;
}

void NDBaseLayer::SetUILayer(NDUILayer* uilayer)
{
	if (!uilayer)
	{
		m_kUILayerNode.Clear();
		return;
	}
	m_kUILayerNode = uilayer->QueryLink();
}

void NDBaseLayer::SetLayer(NDLayer* layer)
{
	if (!layer)
	{
		m_kLayerNode.Clear();
		return;
	}
	m_kLayerNode = layer->QueryLink();
}

void NDBaseLayer::registerWithTouchDispatcher(void)
{
//	int iPriority = INT_MAX - PRIORITY_ADJUST;

	NDNode* pkNode = NULL;
	if (m_kUILayerNode.Pointer())
	{
		pkNode = m_kUILayerNode.Pointer();
	}
	else if (m_kLayerNode.Pointer())
	{
		pkNode = m_kLayerNode.Pointer();
	}
	CCAssert(pkNode, "NDBaseLayer::m_k??Node NULL");

//	while (pkNode)
//	{
//		iPriority -= pkNode->GetzOrder();
//		pkNode = pkNode->GetParent();
//	}

	// ×¢²átouch·Ö·¢ //@priority
	CCTouchDispatcher* touchDispatcher = CCDirector::sharedDirector()->getTouchDispatcher();
	if (m_kUILayerNode.Pointer())
	{
		NDUILayer* Layer = m_kUILayerNode.Pointer();
		touchDispatcher->addTargetedDelegate(this, Layer->getPriority(), true);
	}
	else if (m_kLayerNode.Pointer())
	{
		NDLayer* Layer = m_kLayerNode.Pointer();
		touchDispatcher->addTargetedDelegate(this, Layer->getPriority(), true);
	}
}

bool NDBaseLayer::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) return false;

	m_pkTouch->Initialization(pTouch);

	//if (g_NDBaseLayerPress)
	//{
	//	return NO;
	//}

	if (m_kUILayerNode)
	{
		if (m_kUILayerNode->UITouchBegin(m_pkTouch))
		{
			//g_NDBaseLayerPress = true;
			m_bPress = true;
			return true;
		}
	}
	else if (m_kLayerNode)
	{
		if (m_kLayerNode->TouchBegin(m_pkTouch))
		{
			//g_NDBaseLayerPress = true;
			m_bPress = true;
			return true;
		}
	}

	return false;
}

void NDBaseLayer::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) return;

	m_pkTouch->Initialization(pTouch);

	//g_NDBaseLayerPress = false;

	m_bPress = false;

	if (m_kUILayerNode)
	{
		return m_kUILayerNode->UITouchEnd(m_pkTouch);
	}
	else if (m_kLayerNode)
	{
		return m_kLayerNode->TouchEnd(m_pkTouch);
	}
}

void NDBaseLayer::ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) return;

	m_pkTouch->Initialization(pTouch);

	//g_NDBaseLayerPress = false;

	m_bPress = false;

	if (m_kUILayerNode)
	{
		return m_kUILayerNode->UITouchCancelled(m_pkTouch);
	}
	else if (m_kLayerNode)
	{
		return m_kLayerNode->TouchCancelled(m_pkTouch);
	}
}

void NDBaseLayer::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) return;

	m_pkTouch->Initialization(pTouch);
	if (m_kUILayerNode)
	{
		return m_kUILayerNode->UITouchMoved(m_pkTouch);
	}
	else if (m_kLayerNode)
	{
		return m_kLayerNode->TouchMoved(m_pkTouch);
	}
}

bool NDBaseLayer::ccTouchDoubleClick(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) return false;

//	g_NDBaseLayerPress = false;

	m_pkTouch->Initialization(pTouch);
	if (m_kUILayerNode)
	{
		return m_kUILayerNode->UITouchDoubleClick(m_pkTouch);
	}
	else if (m_kLayerNode)
	{
		return m_kLayerNode->TouchDoubleClick(m_pkTouch);
	}

	return false;
}

void NDBaseLayer::draw()
{
	NDNode* pkNode = NULL;
	if (m_kUILayerNode.Pointer())
	{
		pkNode = m_kUILayerNode.Pointer();
	}
	else if (m_kLayerNode.Pointer())
	{
		pkNode = m_kLayerNode.Pointer();
	}

	if (pkNode && pkNode->DrawEnabled())
	{
		NDDirector::DefaultDirector()->ResumeViewRect(pkNode);
		pkNode->draw();
	}
}

void NDBaseLayer::onExit()
{
	cocos2d::CCLayer::onExit();

	if (m_kUILayerNode)
	{
		return m_kUILayerNode->OnCanceledTouch();
	}
}
