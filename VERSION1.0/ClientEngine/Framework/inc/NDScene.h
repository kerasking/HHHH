//
//  NDScene.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#ifndef __NDScene_H
#define __NDScene_H


#include "NDNode.h"
#include "NDLayer.h"
#include <vector>

namespace NDEngine 
{
	class NDScene : public NDNode 
	{
		DECLARE_CLASS(NDScene)
	public:
		NDScene();
		~NDScene();
		
	public:
		static NDScene* Scene();
			
	};
}

#endif