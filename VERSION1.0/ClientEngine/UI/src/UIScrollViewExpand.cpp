/*
 *  UIScrollViewExpand.mm
 *  DeNA
 *
 *  Created by chh on 12-07-21.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "UIScrollViewExpand.h"


IMPLEMENT_CLASS(UIScrollViewExpand, NDUINode)

UIScrollViewExpand::UIScrollViewExpand()
{
	m_nViewId = -1;
}

UIScrollViewExpand::~UIScrollViewExpand()
{
}
void UIScrollViewExpand::Initialization(){
    NDUINode::Initialization();
}