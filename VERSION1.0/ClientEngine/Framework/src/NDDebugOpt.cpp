//-------------------------------------------------------------------------
//  NDDebugOpt.cpp
//
//  Created by zhangwq on 22012-10-26.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	功能：调试开关
//-------------------------------------------------------------------------

#include "NDDebugOpt.h"

#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android/jni/SystemInfoJni.h"
#include <android/log.h>
#include <jni.h>
#endif

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDDebugOpt, NDObject)

void NDDebugOpt::Log(const char* pszTag, const char * pszFormat,... )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	char buf[2048] = {0};

	va_list args;
	va_start(args, pszFormat);    	
	vsprintf(buf, pszFormat, args);
	va_end(args);

	__android_log_print(ANDROID_LOG_DEBUG,pszTag,buf);

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	char buf[2048] = {0};

	va_list args = 0;
	va_start(args, pszFormat);    	
	vsprintf(buf, pszFormat, args);
	va_end(args);

	printf(buf);
#endif
}

#define IMP_STATIC_PROPERTY(varType,varName,varVal,clsName)	\
	varType clsName::varName = varVal;

IMP_STATIC_PROPERTY(bool,bTick,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bScript,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bNetwork,true,NDDebugOpt)

IMP_STATIC_PROPERTY(bool,bMainLoop,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bDrawHud,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bDrawUI,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bDrawUILabel,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bDrawRole,true,NDDebugOpt)
IMP_STATIC_PROPERTY(bool,bDrawMap,true,NDDebugOpt)

IMP_STATIC_PROPERTY(bool,bLightEffect,true,NDDebugOpt)

NS_NDENGINE_END