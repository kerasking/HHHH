//
//  NDLayer.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDLayer.h"
#include "NDBaseLayer.h"

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
	NDAsssert(m_ccNode == NULL);
	m_ccNode = new NDBaseLayer();
	NDBaseLayer *layer = (NDBaseLayer *) m_ccNode;
	layer->SetLayer(this);

	this->SetContentSize(CGSizeZero);
}

void NDLayer::draw()
{

}

void NDLayer::SetTouchEnabled(bool bEnabled)
{
	NDAsssert(m_ccNode != NULL);

	NDBaseLayer *layer = (NDBaseLayer*) m_ccNode;
	layer->setTouchEnabled(bEnabled);
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
