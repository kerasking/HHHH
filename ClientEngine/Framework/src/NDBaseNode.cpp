//
//  NDBaseNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "NDBaseNode.h"
#include "NDNode.h"
#include "NDDirector.h"
#include "NDUITableLayer.h"

NDBaseNode::NDBaseNode(void)
: m_ndNode(NULL)
{
}

void NDBaseNode::draw(void)
{
	if (m_ndNode->DrawEnabled()) 
	{
		NDDirector::DefaultDirector()->ResumeViewRect(_ndNode);
		_ndNode->draw();
	}	
}
