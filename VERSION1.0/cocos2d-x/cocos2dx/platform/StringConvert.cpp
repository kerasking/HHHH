//-----------------------------------------------------------------
//  StringConvert.cpp
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


#include <string.h>
#include <stdlib.h>
#include "StringConvert.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "third_party/win32/iconv/iconv.h"
#else
#include "iconv.h"
#endif


const char* StringConvert::convert( const char* fromcode, const char* tocode, const char* str )
{
	if (!tocode || !fromcode || !str) return ""; //don't crash.
	if (str[0] == 0) return str;
	
	// open iconv
	iconv_t iconvH = iconv_open( tocode, fromcode );
	if (iconvH == 0) return "";
	iconv(iconvH,0,0,0,0);

	// static buf
	const int buflen = 1024*4;
	static char s_outbuf[buflen] = {0};
	memset(s_outbuf, 0, buflen);
	
	char* in_buf = (char*)str;
	char* out_buf = s_outbuf;

	size_t in_len = strlen(in_buf);
	size_t out_len = buflen;

	// convert
	// 备注：windows平台和android平台iconv()函数声明不一致.
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	int result = iconv( iconvH, 
		(const char**)&in_buf, &in_len, 
		&out_buf, &out_len );
#else
	int result = iconv( iconvH, 
		&in_buf, &in_len, 
		&out_buf, &out_len );
#endif

	iconv_close(iconvH);

	if (result == (size_t)-1)
	{
		int nOne = 1;
		iconvctl(iconvH,ICONV_SET_DISCARD_ILSEQ,&nOne);
		s_outbuf[0] = 0;
	}
	return s_outbuf;
}

//slow
bool StringConvert::isUTF8ChineseCharacter(const char* str)
{
	if (!str) return false;

	unsigned int uiCharacterCodePage = 0;
	int nLength = strlen(str);
	if (3 > nLength) return false;
	
	unsigned char ucCharacter_1 = 0;
	unsigned char ucCharacter_2 = 0;
	unsigned char ucCharacter_3 = 0;
	int nNow = 0;

	while (nNow < nLength)
	{
		ucCharacter_1 = (unsigned) str[nNow];
		if ((ucCharacter_1 & 0x80) == 0x80)
		{
			if (nLength > nNow + 2)
			{
				ucCharacter_2 = (unsigned) str[nNow + 1];
				ucCharacter_3 = (unsigned) str[nNow + 2];

				if (((ucCharacter_1 & 0xE0) == 0XE0)
					&& ((ucCharacter_2 & 0xC0) == 0x80)
					&& ((ucCharacter_3 & 0xC0) == 0x80))
				{
					uiCharacterCodePage = 65001;
					nNow = nNow + 3;

					return true;
				}
				else
				{
					uiCharacterCodePage = 0;
					break;
				}
			}
			else
			{
				uiCharacterCodePage = 0;
				break;
			}
		}
		else
		{
			nNow++;
		}
	}//while

	return false;
}