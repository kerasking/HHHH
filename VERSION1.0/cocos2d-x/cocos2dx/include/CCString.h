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
#include <string>
#include <stdlib.h>
#include "CCObject.h"
#include "CCFileUtils.h"

#if ND_MOD
	#include "..\platform\third_party\win32\iconv\iconv.h"
	#include <stdarg.h>
#endif


namespace cocos2d {

#if ND_MOD
	static char g_GBKConvUTF8Buf[5000] = {0};
#endif

	class CC_DLL CCString : public CCObject
	{
	public:
		std::string m_sString;
	public:
		CCString():m_sString("")
		{}
		CCString(const char * str)
		{
			m_sString = str;
		}
		virtual ~CCString(){ m_sString.clear(); }
		
		int toInt()
		{
			return atoi(m_sString.c_str());
		}
		unsigned int toUInt()
		{
			return (unsigned int)atoi(m_sString.c_str());
		}
		float toFloat()
		{
			return (float)atof(m_sString.c_str());
		}
		std::string toStdString()
		{
			return m_sString;
		}

		bool isEmpty()
		{
			return m_sString.empty();
		}

        virtual bool isEqual(const CCObject* pObject)
        {
            bool bRet = false;
            const CCString* pStr = dynamic_cast<const CCString*>(pObject);
            if (pStr != NULL)
            {
                if (0 == m_sString.compare(pStr->m_sString))
                {
                    bRet = true;
                }
            }
            return bRet;
        }

        /** @brief: Get string from a file.
        *   @return: a pointer which needs to be deleted manually by 'delete[]' .
        */
        static char* stringWithContentsOfFile(const char* pszFileName)
        {
            unsigned long size = 0;
            unsigned char* pData = 0;
            char* pszRet = 0;
            pData = CCFileUtils::getFileData(pszFileName, "rb", &size);
            do 
            {
                CC_BREAK_IF(!pData || size <= 0);
                pszRet = new char[size+1];
                pszRet[size] = '\0';
                memcpy(pszRet, pData, size);
                CC_SAFE_DELETE_ARRAY(pData);
            } while (false);
            return pszRet;
        }


#if ND_MOD
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
			string strSubString = "";

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

		/***
		* @brief 为了符合Objective-C语言上NSString的一些结构，所以对CCString
		*		 进行类NSString化扩展。
		*
		* @param pszFormat 动态参数。
		* @return CCString* 返回CCString类的指针
		* @retval 0 空指针即为动态参数中有空值
		* @author (DeNA)郭浩
		* @date 20120731
		* @warning 一定要析构掉获得的指针，否则会造成内存泄露
		*/
		static CCString* stringWithFormat(const char* pszFormat,...)
		{
			char szBuf[255] = {0};
			va_list kAp = 0;

			va_start(kAp, pszFormat);
			vsnprintf_s(szBuf, 255, 255, pszFormat, kAp);
			va_end(kAp);

			if (!*szBuf)
			{
				return 0;
			}

			CCString* pstrString = new CCString(szBuf);

			return pstrString;
		}
#endif //ND_MOD
		
	};
}// namespace cocos2d
#endif //__CCSTRING_H__