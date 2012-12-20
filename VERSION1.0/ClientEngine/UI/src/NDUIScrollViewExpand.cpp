/*
 *  NDUIScrollViewExpand.cpp
 *  DeNA
 *
 *  Created by chh on 12-07-21.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDUIScrollViewExpand.h"
#include "ObjectTracker.h"

IMPLEMENT_CLASS(UIScrollViewExpand, NDUINode)

UIScrollViewExpand::UIScrollViewExpand()
{
	INC_NDOBJ_RTCLS
	m_nViewId = -1;
}

UIScrollViewExpand::~UIScrollViewExpand()
{
	DEC_NDOBJ_RTCLS
}

void UIScrollViewExpand::Initialization(){
    NDUINode::Initialization();
}