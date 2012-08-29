//
//  NDBaseNode.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDBaseNode.h"
#include "NDNode.h"
#include "NDDirector.h"

using namespace NDEngine;

NDBaseNode::NDBaseNode(void) :
		m_ndNode(NULL)
{
}

void NDBaseNode::draw(void)
{
	if (m_ndNode && m_ndNode->DrawEnabled())
	{
		NDDirector::DefaultDirector()->ResumeViewRect(m_ndNode);
		m_ndNode->draw();
	}
}
