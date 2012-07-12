/*
 *  NDUILoad.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (Õ¯¡˙)DeNA. All rights reserved.
 *
 */

#pragma once

#include "NDUINode.h"

#pragma mark º”‘ÿui

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