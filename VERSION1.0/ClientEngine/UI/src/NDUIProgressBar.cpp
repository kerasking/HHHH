//
//  NDUIProgressBar.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "NDUIProgressBar.h"
#include "NDUtil.h"
#include "I_Analyst.h"
#include "NDUIBaseGraphics.h"
#include "ObjectTracker.h"

namespace NDEngine
{
IMPLEMENT_CLASS(NDUIProgressBar, NDUINode)

NDUIProgressBar::NDUIProgressBar()
{
	INC_NDOBJ_RTCLS
	m_fCount = 100;
	m_fStep = 0;
}

NDUIProgressBar::~NDUIProgressBar()
{
	DEC_NDOBJ_RTCLS
}

void NDUIProgressBar::SetStepCount(float count)
{
	if (count > 0)
	{
		m_fCount = count;
	}
}

void NDUIProgressBar::SetCurrentStep(float step)
{
	if (step > m_fCount)
	{
		m_fStep = m_fCount;
	}
	else
	{
		m_fStep = step;
	}
	draw();
}

void NDUIProgressBar::draw()
{
	if (!isDrawEnabled())
	{
		return;
	}

	TICK_ANALYST (ANALYST_NDUIProgressBar);
	NDUINode::draw();

	if (this->IsVisibled())
	{
		CCRect scrRect = this->GetScreenRect();
		if (scrRect.size.width > 0)
		{
			DrawRecttangle(
					CCRectMake(scrRect.origin.x, scrRect.origin.y,
							scrRect.size.width, scrRect.size.height),
					ccc4(193, 193, 194, 200));
			float percent = m_fStep / m_fCount;
			DrawRecttangle(
					CCRectMake(scrRect.origin.x, scrRect.origin.y,
							percent * scrRect.size.width, scrRect.size.height),
					ccc4(0, 255, 0, 200));
		}
	}
}
}
