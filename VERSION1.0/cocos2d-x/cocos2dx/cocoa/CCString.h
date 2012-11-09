/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#ifndef __CCSTRING_H__
#define __CCSTRING_H__

#if (CC_TARGET_PLATFORM == CC_PLATFORM_BLACKBERRY)
#include <string.h>
#endif

#include <stdarg.h>
#include <string>
#include <functional>
#include "CCObject.h"
#include "CCFileUtils.h"

#if ND_MOD
	#include "..\platform\third_party\win32\iconv\iconv.h"
	#include <stdarg.h>
#endif

NS_CC_BEGIN

#if ND_MOD
	static char g_GBKConvUTF8Buf[5000] = {0};
#endif

/**
 * @addtogroup data_structures
 * @{
 */

class CC_DLL CCString : public CCObject
{
public:
    CCString();
    CCString(const char* str);
    CCString(const std::string& str);
    CCString(const CCString& str);

    virtual ~CCString();
    
    /* override assignment operator */
    CCString& operator= (const CCString& other);

    /** init a string with format, it's similar with the c function 'sprintf' */ 
    bool initWithFormat(const char* format, ...);

    /** convert to int value */
    int intValue() const;

    /** convert to unsigned int value */
    unsigned int uintValue() const;

    /** convert to float value */
    float floatValue() const;

    /** convert to double value */
    double doubleValue() const;

    /** convert to bool value */
    bool boolValue() const;

    /** get the C string */
    const char* getCString() const;

    /** get the length of string */
    unsigned int length() const;

    /** compare to a c string */
    int compare(const char *) const;

    /* override functions */
    virtual CCObject* copyWithZone(CCZone* pZone);
    virtual bool isEqual(const CCObject* pObject);

    /* static functions */
    /** create a string with c string
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     @deprecated: This interface will be deprecated sooner or later.
     */
    CC_DEPRECATED_ATTRIBUTE static CCString* stringWithCString(const char* pStr);

    /** create a string with std::string
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     */
    CC_DEPRECATED_ATTRIBUTE static CCString* stringWithString(const std::string& str);

    /** create a string with format, it's similar with the c function 'sprintf', the default buffer size is (1024*100) bytes,
     *  if you want to change it, you should modify the kMaxStringLen macro in CCString.cpp file.
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     @deprecated: This interface will be deprecated sooner or later.
     */ 
    CC_DEPRECATED_ATTRIBUTE static CCString* stringWithFormat(const char* format, ...);

    /** create a string with binary data 
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     @deprecated: This interface will be deprecated sooner or later.
     */
    CC_DEPRECATED_ATTRIBUTE static CCString* stringWithData(const unsigned char* pData, unsigned long nLen);

    /** create a string with a file, 
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     @deprecated: This interface will be deprecated sooner or later.
     */
    CC_DEPRECATED_ATTRIBUTE static CCString* stringWithContentsOfFile(const char* pszFileName);

    /** create a string with std string, you can also pass a c string pointer because the default constructor of std::string can access a c string pointer. 
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     */
    static CCString* create(const std::string& str);

    /** create a string with format, it's similar with the c function 'sprintf', the default buffer size is (1024*100) bytes,
     *  if you want to change it, you should modify the kMaxStringLen macro in CCString.cpp file.
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     */ 
    static CCString* createWithFormat(const char* format, ...);

    /** create a string with binary data 
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     */
    static CCString* createWithData(const unsigned char* pData, unsigned long nLen);

    /** create a string with a file, 
     *  @return A CCString pointer which is an autorelease object pointer,
     *          it means that you needn't do a release operation unless you retain it.
     */
    static CCString* createWithContentsOfFile(const char* pszFileName);

#if ND_MOD
		const std::string& toStdString()
		{
			return m_sString;
		}

		/***
		* @brief 去除路径中最后一个"\"之后的所有的东西，包括斜杠本身。
		*
		* @return CCString* 返回CCString类的指针
		* @author (DeNA)郭浩
		* @date 20120731
		*/
		CCString* stringByDeletingLastPathComponent()
		{
			int nPos = -1;
			std::string strSubString = "";

			if (-1 == (nPos = m_sString.find_last_of('\\')))
			{
				return new CCString(m_sString.c_str());
			}

			strSubString = m_sString.substr(0,nPos);

			return new CCString(strSubString.c_str());
		}

		/***
		* @brief 返回转换成UTF8格式的字符
		*
		* @return const unsigned char* 返回UTF8指针
		* @retval 0 空指针即为无法转换
		* @author (DeNA)郭浩
		* @date 20120731
		*/
		const char* UTF8String()
		{
			const char* strChar = m_sString.c_str();
			iconv_t iconvH = 0;
			iconvH = iconv_open("utf-8","gb2312");

			if (iconvH == 0)
			{
				return NULL;
			}

			size_t strLength = strlen(strChar);
			size_t outLength = strLength<<2;
			size_t copyLength = outLength;
			memset(g_GBKConvUTF8Buf, 0, 5000);

			char* outbuf = (char*) malloc(outLength);
			char* pBuff = outbuf;
			memset( outbuf, 0, outLength);

			if (-1 == iconv(iconvH, &strChar, &strLength, &outbuf, &outLength))
			{
				iconv_close(iconvH);
				return NULL;
			}
			memcpy(g_GBKConvUTF8Buf,pBuff,copyLength);
			free(pBuff);
			iconv_close(iconvH);

			return g_GBKConvUTF8Buf;
		}


		/***
		* @brief 根据UTF-8字符，转换成GB2312进行存储。
		*
		* @param pszUTF8 要传入的UTF8字符。
		* @return CCString* 返回CCString类的指针
		* @retval 0 空指针即为pszUTF8这个参数是有问题
		* @author (DeNA)郭浩
		* @date 20120731
		*/
		static CCString* stringWithUTF8String(const char* pszUTF8)
		{
			if (0 == pszUTF8 || !*pszUTF8)
			{
				return new CCString("");
			}

			if (isUTF8ChineseCharacter(pszUTF8))
			{
			iconv_t pConvert = 0;
			const char* pszInbuffer = pszUTF8;
			char* pszOutBuffer = new char[2048];

			memset(pszOutBuffer,0,sizeof(char) * 2048);

			int nStatus = 0;
			size_t sizOutBuffer = 2048;
			size_t sizInBuffer = strlen(pszUTF8);
			const char* pszInPtr = pszInbuffer;
			size_t sizInSize = sizInBuffer;
			char* pszOutPtr = pszOutBuffer;
			size_t sizOutSize = sizOutBuffer;

			pConvert = iconv_open("GB2312","UTF-8");

			iconv(pConvert,0,0,0,0);

			while (0 < sizInSize)
			{
				size_t sizRes = iconv(pConvert,(const char**)&pszInPtr,
					&sizInSize,&pszOutPtr,&sizOutSize);

				if (pszOutPtr != pszOutBuffer)
				{
					strncpy(pszOutBuffer,pszOutBuffer,sizOutSize);
				}

				if ((size_t)-1 == sizRes)
				{
					int nOne = 1;
					iconvctl(pConvert,ICONV_SET_DISCARD_ILSEQ,&nOne);
				}
			}

			iconv_close(pConvert);

			return new CCString(pszOutBuffer);
		}
			else
			{
				return new CCString(pszUTF8);
			}
		}

//@注释：引擎已经实现了相同的原型！
// 		/***
// 		* @brief 为了符合Objective-C语言上NSString的一些结构，所以对CCString
// 		*		 进行类NSString化扩展。
// 		*
// 		* @param pszFormat 动态参数。
// 		* @return CCString* 返回CCString类的指针
// 		* @retval 0 空指针即为动态参数中有空值
// 		* @author (DeNA)郭浩
// 		* @date 20120731
// 		* @warning 一定要析构掉获得的指针，否则会造成内存泄露
// 		*/
// 		static CCString* stringWithFormat(const char* pszFormat,...)
// 		{
// 			char szBuf[255] = {0};
// 			va_list kAp = 0;
// 
// 			va_start(kAp, pszFormat);
// 			vsnprintf_s(szBuf, 255, 255, pszFormat, kAp);
// 			va_end(kAp);
// 
// 			if (!*szBuf)
// 			{
// 				return 0;
// 			}
// 
// 			CCString* pstrString = new CCString(szBuf);
// 
// 			return pstrString;
// 		}


		/***
		* @brief 能够判断一个字符串中汉字是否是UTF-8
		*
		* @param pszFormat 动态参数。
		* @return bool 返回结果
		* @retval false 非UTF-8
		* @retval true 是UTF-8
		* @author (DeNA)郭浩
		* @date 20121101
		*/
		static bool isUTF8ChineseCharacter(const char* pszText)
		{
			UINT uiCharacterCodePage = 0;
			int nLength = strlen(pszText);

			if (3 <= nLength)
			{
				unsigned char ucCharacter_1 = 0;
				unsigned char ucCharacter_2 = 0;
				unsigned char ucCharacter_3 = 0;
				int nNow = 0;

				while (nNow < nLength)
				{
					ucCharacter_1 = (unsigned) pszText[nNow];
					if ((ucCharacter_1 & 0x80) == 0x80)
					{
						if (nLength > nNow + 2)
						{
							ucCharacter_2 = (unsigned) pszText[nNow + 1];
							ucCharacter_3 = (unsigned) pszText[nNow + 2];

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
				}
			}

			return false;
		}
		
#endif //ND_MOD

private:

    /** only for internal use */
    bool initWithFormatAndValist(const char* format, va_list ap);

public:
    std::string m_sString;
};

struct CCStringCompare : public std::binary_function<CCString *, CCString *, bool> {
    public:
        bool operator() (CCString * a, CCString * b) const {
            return strcmp(a->getCString(), b->getCString()) < 0;
        }
};

#define CCStringMake(str) CCString::create(str)
#define ccs               CCStringMake

// end of data_structure group
/// @}

NS_CC_END

#endif //__CCSTRING_H__
