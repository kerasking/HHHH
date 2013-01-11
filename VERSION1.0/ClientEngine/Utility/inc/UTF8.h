/*
 *  UTF8.h
 *  
 *  Created by zhangwq. 2012.12.25
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
/* Code from GLIB gutf8.c starts here. */

#pragma once

#define UTF8_COMPUTE(Char, Mask, Len)        \
	if (Char < 128)                \
	{                        \
	Len = 1;                    \
	Mask = 0x7f;                \
	}                        \
  else if ((Char & 0xe0) == 0xc0)        \
	{                        \
	Len = 2;                    \
	Mask = 0x1f;                \
	}                        \
  else if ((Char & 0xf0) == 0xe0)        \
	{                        \
	Len = 3;                    \
	Mask = 0x0f;                \
	}                        \
  else if ((Char & 0xf8) == 0xf0)        \
	{                        \
	Len = 4;                    \
	Mask = 0x07;                \
	}                        \
  else if ((Char & 0xfc) == 0xf8)        \
	{                        \
	Len = 5;                    \
	Mask = 0x03;                \
	}                        \
  else if ((Char & 0xfe) == 0xfc)        \
	{                        \
	Len = 6;                    \
	Mask = 0x01;                \
	}                        \
  else                        \
  Len = -1;



#define UTF8_LENGTH(Char)            \
	((Char) < 0x80 ? 1 :                \
	((Char) < 0x800 ? 2 :            \
	((Char) < 0x10000 ? 3 :            \
	((Char) < 0x200000 ? 4 :            \
	((Char) < 0x4000000 ? 5 : 6)))))


#define UTF8_GET(Result, Chars, Count, Mask, Len)    \
	(Result) = (Chars)[0] & (Mask);            \
	for ((Count) = 1; (Count) < (Len); ++(Count))        \
	{                            \
	if (((Chars)[(Count)] & 0xc0) != 0x80)        \
	{                        \
	(Result) = -1;                \
	break;                    \
	}                        \
	(Result) <<= 6;                    \
	(Result) |= ((Chars)[(Count)] & 0x3f);        \
	}

#define UNICODE_VALID(Char)            \
	((Char) < 0x110000 &&                \
	(((Char) & 0xFFFFF800) != 0xD800) &&        \
	((Char) < 0xFDD0 || (Char) > 0xFDEF) &&    \
	((Char) & 0xFFFE) != 0xFFFE)


// static const char utf8_skip_data[256] = {
// 	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
// 	1, 1, 1, 1, 1, 1, 1,
// 	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
// 	2, 2, 2, 2, 2, 2, 2,
// 	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5,
// 	5, 5, 5, 6, 6, 1, 1
// };
// 
// static const char *const g_utf8_skip = utf8_skip_data;
// 
// #define cc_utf8_next_char(p) (char *)((p) + g_utf8_skip[*(unsigned char *)(p)])


struct UTF8
{
	//读utf8串的下一个字符，返回静态指针，不要保存!
	//charLen是字符占用的字节数（1~6个字节）
	static char* getNextChar( const char*& text, int* charLen = 0 )
	{
		if (!text || *text == 0) return 0;

		static char word[10] = { 0x0 };
		memset(word, 0, sizeof(word));
		const unsigned char c = *text;
		
		int mask = 0, len = 0;
		UTF8_COMPUTE(c,mask,len);

		if (len >= 1 && len <= 6)
		{
			memcpy(word, text, len);
			text += len;
		}
		else
		{
			//容错
			text++; len = 1;
			word[0] = '?';
		}

		if (charLen) *charLen = len;
		return word;
	}
};