/*
 *  platform.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-5-07.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "platform.h"
#include "NDDirector.h"

using namespace NDEngine;

#ifdef WIN32
static char g_GBKConvUTF8Buffer[5000] = {0};
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
	memset(g_GBKConvUTF8Buffer, 0, 5000);

	char* outbuf = (char*) malloc(outLength);
	char* pBuff = outbuf;
	memset( outbuf, 0, outLength);

	if (-1 == iconv(iconvH, &strChar, &strLength, &outbuf, &outLength))
	{
		iconv_close(iconvH);
		return NULL;
	}
	memcpy(g_GBKConvUTF8Buffer,pBuff,copyLength);
	free(pBuff);
	iconv_close(iconvH);
	return g_GBKConvUTF8Buffer;
}
#endif

CGSize getStringSize(const char* pszStr, unsigned int fontSize)
{
	CGSize sz = CGSizeMake(0.0f, 0.0f);

	fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();

	if (pszStr) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		NSString str = [NSString stringWithUTF8String:pszStr];
		sz = [str sizeWithFont:[UIFont fontWithName:FONT_NAME size:fontSize]];
#endif
	}

	return sz;
}

CGSize getStringSizeMutiLine(const char* pszStr, unsigned int fontSize, CGSize contentSize)
{
	CGSize sz = CGSizeZero;

	if (!pszStr)
	{
		return sz;
	}

	fontSize = fontSize * NDDirector::DefaultDirector()->GetScaleFactor();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	NSString *nstext = [NSString stringWithUTF8String:pszStr];
	sz = [nstext sizeWithFont:[UIFont fontWithName:FONT_NAME size:fontSize] 
constrainedToSize:contentSize];
#endif
	return sz;
}