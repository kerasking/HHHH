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
#include "define.h"

NS_NDENGINE_BGN

class NDUILoadEngine : public NDObject
{
	DECLARE_CLASS(NDUILoadEngine)
	
	virtual bool Load(
		  const char* uiname,
		  NDUINode *parent, 
		  NDUITargetDelegate* delegate, 
		  CCSize sizeOffset = CCSizeZero);
		  
	virtual bool LoadLua(
		  const char* uiname,
		  NDUINode *parent, 
		  LuaObject luaDelegate,
		  float sizeOffsetW = 0.0f,
		  float sizeOffsetH = 0.0f);

protected:
	virtual bool LoadAny( const char* uiname,
		NDUINode *parent, 
		NDUITargetDelegate* delegate, 
		LuaObject* luaDelegate,
		CCSize sizeOffset = CCSizeZero );

	virtual NDUINode* LoadCtrl( CUIData& uiData, const int ctrlIndex, NDUINode *parent, const CCSize& sizeOffset );
	
	virtual NDUINode* CreateCtrl( UIINFO& uiInfo, CCSize sizeOffset, const char*& ctrlTypeName );

	virtual void PostLoad(UIINFO& uiInfo);	

	virtual void AdjustCtrlPosByAnchor( UIINFO& uiInfo, const CCPoint& CtrlAnchorPos );

	virtual bool IsAnchorValid( const float anchor );
};

NS_NDENGINE_END