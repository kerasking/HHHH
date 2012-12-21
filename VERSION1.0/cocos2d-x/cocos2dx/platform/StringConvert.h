//-----------------------------------------------------------------
//  StringConvert.h
//
//  Created by zhangwq on 2012-12-21.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//
//	字符串不同编码转换
//	先支持GB2312与utf8编码，后续支持所有宽字符编码格式
//
//	支持win32,android,ios
//
//	把这个工具类放在cocos2dx这层以便为CCImage类提供编码转换能力.
//
//	CCImage类存在编码混合问题：
//	CCImage实现涵盖了不同编码（android&ios用utf8, win32用ansi）
//	不同编码导致了函数原型的模糊，进一步导致了上层传参数编码错误.
//-----------------------------------------------------------------

#pragma once

#include "platform/CCPlatformMacros.h"

class CC_DLL StringConvert
{
public:
	static const char* convert( const char* fromcode, const char* tocode, const char* str );
	static bool isUTF8ChineseCharacter( const char* str );
};

#define CONVERT_GBK_TO_UTF8(gbk)		StringConvert::convert("gb2312", "utf-8", gbk)
#define CONVERT_UTF8_TO_GBK(utf8)		StringConvert::convert("utf-8", "gb2312", utf8)

#define GBKToUTF8						CONVERT_GBK_TO_UTF8 
