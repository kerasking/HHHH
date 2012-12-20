#include "CCString.h"
#include "platform/CCFileUtils.h"
#include "ccMacros.h"
#include <stdlib.h>
#include <stdio.h>

#if ND_MOD
#include "ObjectTracker.h"
#endif

NS_CC_BEGIN

#define kMaxStringLen (1024*100)

CCString::CCString()
    :m_sString("")
{
#if ND_MOD
	INC_CCOBJ("CCString");
#endif
}

CCString::CCString(const char * str)
    :m_sString(str)
{
#if ND_MOD
	INC_CCOBJ("CCString");
#endif
}

CCString::CCString(const std::string& str)
    :m_sString(str)
{
#if ND_MOD
	INC_CCOBJ("CCString");
#endif
}

CCString::CCString(const CCString& str)
    :m_sString(str.getCString())
{
#if ND_MOD
	INC_CCOBJ("CCString");
#endif
}

CCString::~CCString()
{ 
#if ND_MOD
	DEC_CCOBJ("CCString");
#endif
    m_sString.clear();
}

CCString& CCString::operator= (const CCString& other)
{
    m_sString = other.m_sString;
    return *this;
}

bool CCString::initWithFormatAndValist(const char* format, va_list ap)
{
    bool bRet = false;
    char* pBuf = (char*)malloc(kMaxStringLen);
    if (pBuf != NULL)
    {
        vsnprintf(pBuf, kMaxStringLen, format, ap);
        m_sString = pBuf;
        free(pBuf);
        bRet = true;
    }
    return bRet;
}

bool CCString::initWithFormat(const char* format, ...)
{
    bool bRet = false;
    m_sString.clear();

    va_list ap;
    va_start(ap, format);

    bRet = initWithFormatAndValist(format, ap);

    va_end(ap);

    return bRet;
}

int CCString::intValue() const
{
    if (length() == 0)
    {
        return 0;
    }
    return atoi(m_sString.c_str());
}

unsigned int CCString::uintValue() const
{
    if (length() == 0)
    {
        return 0;
    }
    return (unsigned int)atoi(m_sString.c_str());
}

float CCString::floatValue() const
{
    if (length() == 0)
    {
        return 0.0f;
    }
    return (float)atof(m_sString.c_str());
}

double CCString::doubleValue() const
{
    if (length() == 0)
    {
        return 0.0;
    }
    return atof(m_sString.c_str());
}

bool CCString::boolValue() const
{
    if (length() == 0)
    {
        return false;
    }

    if (0 == strcmp(m_sString.c_str(), "0") || 0 == strcmp(m_sString.c_str(), "false"))
    {
        return false;
    }
    return true;
}

const char* CCString::getCString() const
{
    return m_sString.c_str();
}

unsigned int CCString::length() const
{
    return m_sString.length();
}

int CCString::compare(const char * pStr) const
{
    return strcmp(getCString(), pStr);
}

CCObject* CCString::copyWithZone(CCZone* pZone)
{
    CCAssert(pZone == NULL, "CCString should not be inherited.");
    CCString* pStr = new CCString(m_sString.c_str());
    return pStr;
}

bool CCString::isEqual(const CCObject* pObject)
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

CCString* CCString::stringWithCString(const char* pStr)
{
    return CCString::create(pStr);
}

CCString* CCString::create(const std::string& str)
{
    CCString* pRet = new CCString(str);
    pRet->autorelease();
    return pRet;
}

CCString* CCString::stringWithString(const std::string& pStr)
{
    CCString* pRet = new CCString(pStr);
    pRet->autorelease();
    return pRet;
}

CCString* CCString::stringWithData(const unsigned char* pData, unsigned long nLen)
{
    return CCString::createWithData(pData, nLen);
}

CCString* CCString::createWithData(const unsigned char* pData, unsigned long nLen)
{
    CCString* pRet = NULL;
    if (pData != NULL)
    {
        char* pStr = (char*)malloc(nLen+1);
        if (pStr != NULL)
        {
            pStr[nLen] = '\0';
            if (nLen > 0)
            {
                memcpy(pStr, pData, nLen);
            }
            
            pRet = CCString::create(pStr);
            free(pStr);
        }
    }
    return pRet;
}

CCString* CCString::stringWithFormat(const char* format, ...)
{
    CCString* pRet = CCString::create("");
    va_list ap;
    va_start(ap, format);
    pRet->initWithFormatAndValist(format, ap);
    va_end(ap);

    return pRet;
}

CCString* CCString::createWithFormat(const char* format, ...)
{
    CCString* pRet = CCString::create("");
    va_list ap;
    va_start(ap, format);
    pRet->initWithFormatAndValist(format, ap);
    va_end(ap);

    return pRet;
}

CCString* CCString::stringWithContentsOfFile(const char* pszFileName)
{
    return CCString::createWithContentsOfFile(pszFileName);
}

CCString* CCString::createWithContentsOfFile(const char* pszFileName)
{
    unsigned long size = 0;
    unsigned char* pData = 0;
    CCString* pRet = NULL;
    pData = CCFileUtils::sharedFileUtils()->getFileData(pszFileName, "rb", &size);
    pRet = CCString::createWithData(pData, size);
    CC_SAFE_DELETE_ARRAY(pData);
    return pRet;
}


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#if ND_MOD

//备注：返回的指针式全局静态指针，不要保存指针
//		如果在函数调用中，多个参数用这个指针传递则会出错，会被覆盖掉！
const char* CCString::getUtf8String()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	static char g_GBKConvUTF8Buf_XX[5000] = {0};

	//const char* GBKToUTF8(const char *strChar)
	const char* strChar = this->getCString();
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
		memset(g_GBKConvUTF8Buf_XX, 0, sizeof(g_GBKConvUTF8Buf_XX));

		char* outbuf = (char*) malloc(outLength);
		char* pBuff = outbuf;
		memset( outbuf, 0, outLength);

		if (-1 == iconv(iconvH, &strChar, &strLength, &outbuf, &outLength))
		{
			free( outbuf );
			iconv_close(iconvH);
			return NULL;
		}

		memcpy(g_GBKConvUTF8Buf_XX,pBuff,copyLength);
		free(pBuff);
		iconv_close(iconvH);
		return g_GBKConvUTF8Buf_XX;
	}
#else
	return NULL;
#endif //CC_TARGET_PLATFORM
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
//备注：返回值指针必须用CCStringRef管理起来，否则内存泄露！
CCString* CCString::stringWithUTF8String(const char* pszUTF8)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	if (0 == pszUTF8 || !*pszUTF8)
	{
		return new CCString("");
	}

	if (isUTF8ChineseCharacter(pszUTF8))
	{
		iconv_t pConvert = 0;
		const char* pszInbuffer = pszUTF8;

		const int buflen = 2048;
		char* pszOutBuffer = new char[buflen]; //!!

		memset(pszOutBuffer,0,sizeof(char) * buflen);

		int nStatus = 0;
		size_t sizOutBuffer = buflen;
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

		CCString* ret = new CCString(pszOutBuffer);
		CC_SAFE_DELETE_ARRAY(pszOutBuffer); //!!
		return ret;
	}
	else
	{
		return new CCString(pszUTF8);
	}
#else
	return new CCString(pszUTF8);
#endif //CC_TARGET_PLATFORM
}

bool CCString::isUTF8ChineseCharacter(const char* pszText)
{
	if (!pszText) return false;

	unsigned int uiCharacterCodePage = 0;
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
		}//while
	}//if

	return false;
}

#endif //ND_MOD
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

NS_CC_END
