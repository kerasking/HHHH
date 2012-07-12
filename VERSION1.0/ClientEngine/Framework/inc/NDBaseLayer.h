//
//  NDBaseLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_BASE_LAYER_H_
#define _ND_BASE_LAYER_H_

#include "CCLayer.h"
#include "NDTouch.h"
#include "NDNode.h"
#include "NDUILayer.h"
#include "NDLayer.h"

using namespace NDEngine;

class NDBaseLayer : public cocos2d::CCLayer 
{
public:
	NDBaseLayer();
	~NDBaseLayer();

private:
	CAutoLink<NDUILayer>	_ndUILayerNode;
	CAutoLink<NDLayer>		_ndLayerNode;
	NDTouch					*m_ndTouch;
	//bool					m_press;

public:
	void SetUILayer(NDUILayer* uilayer); 
	void SetLayer(NDLayer* layer);

public:
	virtual void draw();

	void onExit();

	virtual void registerWithTouchDispatcher(void);

	virtual bool ccTouchBegan(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent);
	virtual void ccTouchMoved(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent);
	virtual void ccTouchEnded(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent);
	virtual void ccTouchCancelled(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent);
	// toto
	virtual bool ccTouchDoubleClick(cocos2d::CCTouch *pTouch, cocos2d::CCEvent *pEvent);
};

#endif