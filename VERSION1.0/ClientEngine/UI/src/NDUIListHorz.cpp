/*--------------------------------------------------------------------------
 *  NDUIListHorz.cpp
 *
 *	水平列表框
 *
 *  Created by zhangwq on 2013.01.29
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *--------------------------------------------------------------------------
 */

#include "NDUIListHorz.h"
#include "ObjectTracker.h"
#include "UsePointPls.h"
#include "NDDebugOpt.h"

using namespace NDEngine;

IMPLEMENT_CLASS(NDUIListHorz, NDUIScrollViewContainer)

NDUIListHorz::NDUIListHorz()
{
	INC_NDOBJ_RTCLS
}

NDUIListHorz::~NDUIListHorz()
{
	DEC_NDOBJ_RTCLS
}

void NDUIListHorz::draw()
{
	NDUIScrollViewContainer::draw();

	debugDraw();
}

void NDUIListHorz::debugDraw()
{
	if (!NDDebugOpt::getDrawDebugEnabled()) return;

	CCRect scrRect = this->GetScreenRect();
	ConvertUtil::convertToPointCoord( scrRect );

	// shrink
	const int pad = 2;
	scrRect.origin.x += pad; 
	scrRect.origin.y += pad;
	scrRect.size.width -= 2*pad; 
	scrRect.size.height -= 2*pad;

	float l,r,t,b;
	SCREEN2GL_RECT(scrRect,l,r,t,b);
	{
		// draw rect
		glLineWidth(2);
		ccDrawColor4F(1,0,0,1);
		ccDrawRect( ccp(l,t), ccp(r,b));

		// draw cross lines
		glLineWidth(1);
		ccDrawLine( ccp(l,b), ccp(r,t));
		ccDrawLine( ccp(l,t), ccp(r,b));
	}
}