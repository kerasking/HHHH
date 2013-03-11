//-------------------------------------------------------------
//  NDBitmapMacro.h
//
//  Created by zhangwq on 2013-02-20.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	NDBitmap机制的开关
//-------------------------------------------------------------

#pragma once

//@ndbitmap
//是否把NDBITMAP这套机制编译进去（仅支持android）
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	#define WITH_NDBITMAP 1
#else
	#define WITH_NDBITMAP 0
#endif
#define WITH_NDBITMAP 0 //编译开关

