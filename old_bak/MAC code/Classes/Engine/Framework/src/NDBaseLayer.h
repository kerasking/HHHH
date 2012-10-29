//
//  NDBaseLayer.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLayer.h"
#import "NDTouch.h"
#import "NDNode.h"
#import "NDUILayer.h"
#import "NDLayer.h"

using namespace NDEngine;


@interface NDBaseLayer : CCLayer 
{
	CAutoLink<NDUILayer>	_ndUILayerNode;
	CAutoLink<NDLayer>		_ndLayerNode;
	NDTouch					*m_ndTouch;
	BOOL					m_press;
}

-(void)SetUILayer:(NDUILayer*) uilayer; 

-(void)SetLayer:(NDLayer*) layer;


@end
