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
#include "UIData.h"

using namespace NDEngine;

class NDUILoadEngine : public NDObject
{
	DECLARE_CLASS(NDUILoadEngine)
	
	bool Load(
		  const char* uiname,
		  NDUINode *parent, 
		  NDUITargetDelegate* delegate, 
		  CCSize sizeOffset = CCSizeZero);
		  
	bool LoadLua(
		  const char* uiname,
		  NDUINode *parent, 
		  LuaObject luaDelegate,
		  float sizeOffsetW = 0.0f,
		  float sizeOffsetH = 0.0f);

private:
	bool LoadAny( const char* uiname,
		NDUINode *parent, 
		NDUITargetDelegate* delegate, 
		LuaObject* luaDelegate,
		CCSize sizeOffset = CCSizeZero );

	NDUINode* LoadCtrl( CUIData& uiData, const int ctrlIndex, NDUINode *parent, const CCSize& sizeOffset );
	
	NDUINode* CreateCtrl( UIINFO& uiInfo, CCSize sizeOffset, const char*& ctrlTypeName );

	void PostLoad(UIINFO& uiInfo);	

	void AdjustCtrlPosByAnchor( UIINFO& uiInfo, const CCPoint& CtrlAnchorPos );

	bool IsAnchorValid( const float anchor );
};
