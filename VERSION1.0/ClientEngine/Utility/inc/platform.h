/*
 *  platform.h
 *  SMYS
 *
 *  Created by jhzheng on 12-5-07.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _PLATFORM_H_ZJH_
#define _PLATFORM_H_ZJH_

#include "CCPlatformConfig.h"
#include "CCGeometry.h"

#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS)
#define CGPoint					cocos2d::CCPoint
#define CGSize					cocos2d::CCSize
#define CGRect					cocos2d::CCRect
#define CGPointMake				cocos2d::CCPointMake
#define CGSizeMake				cocos2d::CCSizeMake
#define CGRectMake				cocos2d::CCRectMake
#define CGPointZero				cocos2d::CCPointZero
#define CGSizeZero				cocos2d::CCSizeZero
#define CGRectZero				cocos2d::CCRectZero
#define CGRectContainsPoint		cocos2d::CCRect::CCRectContainsPoint
#define CGRectIntersectsRect	cocos2d::CCRect::CCRectIntersectsRect
#endif

#define ccc4					cocos2d::ccc4f


	#define uint				unsigned int
#ifdef WIN32
	#define UTEXT(str)			GBKToUTF8(str)

	#include "third_party/win32/iconv/iconv.h"
	const char* GBKToUTF8(const char *strChar);
#else
	#define UTEXT(str) str
#endif

CGSize getStringSize(const char* pszStr, unsigned int fontSize);
CGSize getStringSizeMutiLine(const char* pszStr, unsigned int fontSize, CGSize contentSize = CGSizeMake(480, 320));

#endif // _PLATFORM_H_ZJH_