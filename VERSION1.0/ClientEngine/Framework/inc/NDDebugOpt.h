//-------------------------------------------------------------------------
//  NDDebugOpt.h
//
//  Created by zhangwq on 22012-10-26.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	功能：调试开关
//-------------------------------------------------------------------------

#include "NDObject.h"

NS_NDENGINE_BGN

#define DECL_STATIC_PROPERTY(varType, varName, funName)\
protected: static varType varName;\
public: static varType get##funName(void) { return varName; } \
public: static void set##funName(varType var) { varName = var; }


class NDDebugOpt : private NDObject
{
	DECLARE_CLASS(NDDebugOpt)

	DECL_STATIC_PROPERTY(bool, bTick,			TickEnabled);
	DECL_STATIC_PROPERTY(bool, bScript,			ScriptEnabled);
	DECL_STATIC_PROPERTY(bool, bNetwork,		NetworkEnabled);

	DECL_STATIC_PROPERTY(bool, bMainLoop,		MainLoopEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawHud,		DrawHudEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawUI,			DrawUIEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawUILabel,	DrawUILabelEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawMap,		DrawMapEnabled);

	DECL_STATIC_PROPERTY(bool, bDrawRole,		DrawRoleEnabled);//for all roles
	DECL_STATIC_PROPERTY(bool, bDrawRoleNpc,	DrawRoleNpcEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawRoleMonster,DrawRoleMonsterEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawRolePlayer,	DrawRolePlayerEnabled);
	DECL_STATIC_PROPERTY(bool, bDrawRoleManual,	DrawRoleManualEnabled);

	DECL_STATIC_PROPERTY(bool, bLightEffect,DrawLightEffectEnabled);
};

NS_NDENGINE_END