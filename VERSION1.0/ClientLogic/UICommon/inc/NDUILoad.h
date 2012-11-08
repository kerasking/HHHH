/*
 *  NDUILoad.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#pragma once

#include "NDUINode.h"
#include "UIData.h"

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

private:
	void AdjustCtrlPosByAnchor( UIINFO& uiInfo, const CCPoint& CtrlAnchorPos );
	NDUINode* CreateCtrl( UIINFO& uiInfo, CGSize sizeOffset, const char*& ctrlTypeName );
	bool IsAnchorValid( const float anchor );
};