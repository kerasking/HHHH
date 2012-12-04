/*
 *  NDUILoadEngine.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-15.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */


#include "NDUILoadEngine.h"
#include "NDControlHelp.h"
#include "UIData.h"
#include "NDDirector.h"

//备注：这个类和ClientLogic工程里的NDUILoad类重复了！以后整理！

#define ISEQUAL(a,b)		(TAbs((a)-(b))<0.0001f)
#define ISEQUAL_PT(pt,a,b)	(ISEQUAL(pt.x,a) && ISEQUAL(pt.y,b))

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDUILoadEngine, NDObject)

//for cpp
bool NDUILoadEngine::Load(
					const char* uiname,
					NDUINode *parent, 
					NDUITargetDelegate* delegate, 
					CCSize sizeOffset /*= CCSizeZero*/)
{
	return LoadAny( uiname, parent, delegate, NULL, sizeOffset );
}

//for LUA
bool NDUILoadEngine::LoadLua(
					   const char* uiname,
					   NDUINode *parent, 
					   LuaObject luaDelegate,
					   float sizeOffsetW /*= 0.0f*/,
					   float sizeOffsetH /*= 0.0f*/)
{
	return false;
}

// forCpp & forLua都转这儿处理
bool NDUILoadEngine::LoadAny( const char* uiname, NDUINode *parent, 
					   NDUITargetDelegate* delegate, LuaObject* luaDelegate,
					   CCSize sizeOffset /*= CCSizeZero*/ )
{
	return true;
}

NDUINode* NDUILoadEngine::LoadCtrl( CUIData& uiData, const int ctrlIndex,
								   NDUINode *parent, const CCSize& sizeOffset )
{
	return 0;
}

bool NDUILoadEngine::IsAnchorValid( const float anchor )
{
	return true;
}

void NDUILoadEngine::AdjustCtrlPosByAnchor( UIINFO& uiInfo, const CCPoint& CtrlAnchorPos )
{
}

NDUINode* NDUILoadEngine::CreateCtrl( UIINFO& uiInfo, CCSize sizeOffset, const char*& ctrlTypeName )
{
	return 0;
}

void NDUILoadEngine::PostLoad(UIINFO& uiInfo)
{
}

NS_NDENGINE_END