//
//  NDBaseNode.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#ifndef _ND_BASE_NODE_H_
#define _ND_BASE_NODE_H_

#include "CCNode.h"
#include "NDNode.h"
#include "platform/CCPlatformMacros.h"

class NDBaseNode : public cocos2d::CCNode 
{
	CC_PROPERTY(NDEngine::NDNode*, m_ndNode, NDNode)

public:
	NDBaseNode(void);

protected:
	virtual void draw(void);
};

#endif