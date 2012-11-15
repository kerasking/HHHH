//
//  NDUIProgressBar.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDUIProgressBar_H
#define __NDUIProgressBar_H

#include "NDUINode.h"

namespace NDEngine
{
	class NDUIProgressBar : public NDUINode
	{
		DECLARE_CLASS(NDUIProgressBar)
		NDUIProgressBar();
		~NDUIProgressBar();
	public:
		void SetStepCount(float count);
		void SetCurrentStep(float step);
	public:
		void draw(); override
	private:
    public:
		float m_count, m_step;
	};
}

#endif
