/*
 *  NDUILoad.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#pragma once

#include "NDUINode.h"

#pragma mark 加载ui

using namespace NDEngine;

class NDUILoad : public NDObject
{
	DECLARE_CLASS(NDUILoad)
	
	bool Load(
		  const char* uiname,
		  NDUINode *parent, 
		  NDUITargetDelegate* delegate, 
		  CGSize sizeOffset = CGSizeZero);
		  
	bool LoadLua(
		  const char* uiname,
		  NDUINode *parent, 
		  LuaObject luaDelegate,
		  float sizeOffsetW = 0.0f,
		  float sizeOffsetH = 0.0f);
};