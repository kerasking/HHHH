//
//  NDBaseNode.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _ND_BASE_NODE_H_
#define _ND_BASE_NODE_H_

#include "CCNode.h"
#include "NDNode.h"
#include "platform/CCPlatformMacros.h"

using namespace NDEngine;

class NDBaseNode : public CCNode 
{
	CC_PROPERTY(NDNode*, m_ndNode, NDNode)

public:
	NDBaseNode(void);

private:
	NDNode* _ndNode;

protected:
	virtual void draw(void);
};

#endif