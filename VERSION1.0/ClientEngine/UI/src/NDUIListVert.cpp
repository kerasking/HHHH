/*--------------------------------------------------------------------------
 *  NDUIListVert.cpp
 *
 *	´¹Ö±ÁÐ±í¿ò
 *
 *  Created by zhangwq on 2013.01.29
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *--------------------------------------------------------------------------
 */

#include "NDUIListVert.h"
#include "ObjectTracker.h"


IMPLEMENT_CLASS(NDUIListVert, NDUIScrollViewContainer)

NDUIListVert::NDUIListVert()
{
	INC_NDOBJ_RTCLS
}

NDUIListVert::~NDUIListVert()
{
	DEC_NDOBJ_RTCLS
}