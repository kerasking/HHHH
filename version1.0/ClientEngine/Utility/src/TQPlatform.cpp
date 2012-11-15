/*
 *  platform.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-5-07.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "TQPlatform.h"
#include "NDDirector.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "Foundation/Foundation.h"
#import "UIKit/UIFont.h"
#import "UIKit/UIStringDrawing.h"
#endif
using namespace NDEngine;

#ifdef WIN32
static char g_GBKConvUTF8Buf_Again[5000] = {0};
const char* GBKToUTF8(const char *strChar)
{

	iconv_t iconvH;
	iconvH = iconv_open("utf-8","gb2312");
	if (iconvH == 0)
	{
		return NULL;
	}
	size_t strLength = strlen(strChar);
	size_t outLength = strLength<<2;
	size_t copyLength = outLength;
	memset(g_GBKConvUTF8Buf_Again, 0, 5000);

	char* outbuf = (char*) malloc(outLength);
	char* pBuff = outbuf;
	memset( outbuf, 0, outLength);

	if (-1 == iconv(iconvH, &strChar, &strLength, &outbuf, &outLength))
	{
		iconv_close(iconvH);
		return NULL;
	}
	memcpy(g_GBKConvUTF8Buf_Again,pBuff,copyLength);
	free(pBuff);
	iconv_close(iconvH);
	return g_GBKConvUTF8Buf_Again;
}
#endif

CCSize getStringSize(const char* pszStr, uint fontSize)
{
	CGSize sz = CGSizeMake(0.0f, 0.0f);
    CCSize CCSz = CCSizeMake(0.0f, 0.0f);

	//fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();

	if (pszStr) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		NSString* str = [NSString stringWithUTF8String:pszStr];	
        NSString* strfont = [NSString stringWithUTF8String:FONT_NAME];
		sz = [str sizeWithFont:[UIFont fontWithName:strfont size:fontSize]];
#else
		sz = CCSizeMake(24.0f, 29.0f);

// 		string tmpStr(pszStr);
// 		int strSize = tmpStr.size()/2;
// 		float totalWidth = (fontSize)*strSize*1.0;
// 		if(0 == strSize)
// 			sz = CCSizeMake(0.0f, 0.0f);
// 		else
// 			sz = CCSizeMake(totalWidth, 29.0f);

#endif
	}

    CCSz.width = sz.width;
    CCSz.height = sz.height;
    
	return CCSz;     
}

CCSize getStringSizeMutiLine(const char* pszStr, uint fontSize, CCSize contentSize)
{
	CGSize sz = CGSizeZero;
	CCSize CCSz = CCSizeZero;
    
    CGSize CGcontentSize = CGSizeZero;
    CGcontentSize.width = contentSize.width;
    CGcontentSize.height = contentSize.height;

	if (!pszStr)
	{
		return CCSz;
	}

	fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	NSString *nstext = [NSString stringWithUTF8String:pszStr];
    NSString* strfont = [NSString stringWithUTF8String:FONT_NAME];
	sz = [nstext sizeWithFont:[UIFont fontWithName:strfont size:fontSize] constrainedToSize:CGcontentSize];
#endif
    CCSz.width = sz.width;
    CCSz.height = sz.height;
	return CCSz;
}