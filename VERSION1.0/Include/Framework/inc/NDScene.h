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
//		
//		函数：Scene
//		作用：静态方法，通过该方法调用无需显示调用Initialization方法
//		参数：无
//		返回值：本对象指针
		static NDScene* Scene();
			
	};
}

#endif