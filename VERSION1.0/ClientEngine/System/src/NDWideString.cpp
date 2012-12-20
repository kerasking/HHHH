/******************************************************************************
 *  File Name:		NDWideString.cpp
 *  Author:			Guosen
 *  Create Date:	2012-4-10
 *  
 *****************************************************************************/

#include "NDWideString.h"
#include "CCPlatformConfig.h"
#include "TQPlatform.h"
#include "ObjectTracker.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "windows.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#endif

/////////////////////////////////////////////////////////////////////////////

//===========================================================================

NDWideString::~NDWideString()
{
	DEC_NDOBJ("NDWideString");
}

NDWideString::NDWideString( const UTF8CHR * szUTF8 )
: m_bInit(false)
{
	INC_NDOBJ("NDWideString");

	if ( szUTF8 )
	{
		m_szUTF8 = szUTF8;
		ConvertUTF8ToUnicode();
		m_bInit = true;
	}
}

NDWideString::NDWideString( const UTF8String & szUTF8 )
: m_bInit(false)
{
	INC_NDOBJ("NDWideString");

	m_szUTF8 = szUTF8;
	ConvertUTF8ToUnicode();
	m_bInit = true;
}

NDWideString::NDWideString( const UNICCHR * szUNICODE )
: m_bInit(false)
{
	INC_NDOBJ("NDWideString");

	if ( szUNICODE )
	{
		m_szUNICODE = szUNICODE;
		ConvertUnicodeToUTF8();
		m_bInit = true;
	}
}

NDWideString::NDWideString( const UNICString & szUNICODE )
: m_bInit(false)
{
	INC_NDOBJ("NDWideString");

	m_szUNICODE = szUNICODE;
	ConvertUnicodeToUTF8();
	m_bInit = true;
}

//===========================================================================
bool NDWideString::InitializeWithUTF8String( const UTF8CHR * szUTF8 )
{
	if ( m_bInit || !szUTF8 )
	{
		return false;
	}
	m_szUTF8 = szUTF8;
	ConvertUTF8ToUnicode();
	m_bInit = true;
	return true;
}

bool NDWideString::InitializeWithUTF8String( const UTF8String & szUTF8 )
{
	if ( m_bInit || szUTF8.empty() )
	{
		return false;
	}
	m_szUTF8 = szUTF8;
	ConvertUTF8ToUnicode();
	m_bInit = true;
	return true;
}

bool NDWideString::InitializeWithUNICODEString( const UNICCHR * szUNICODE )
{
	if ( m_bInit || !szUNICODE )
	{
		return false;
	}
	m_szUNICODE = szUNICODE;
	ConvertUnicodeToUTF8();
	m_bInit = true;
	return true;
}

bool NDWideString::InitializeWithUNICODEString( const UNICString & szUNICODE )
{
	if ( m_bInit || szUNICODE.empty() )
	{
		return false;
	}
	m_szUNICODE = szUNICODE;
	ConvertUnicodeToUTF8();
	m_bInit = true;
	return true;
}

//===========================================================================
void NDWideString::ConvertUTF8ToUnicode()
{
	UTF8String::iterator	iter = m_szUTF8.begin();
	while ( iter != m_szUTF8.end() )
	{
		wchar_t		cUnic = 0;
		if ( *iter >= 0x00 && *iter <= 0x7f )
		{
			cUnic = *iter;
		}
		else if ( ( *iter & ( 0xff << 5 ) ) == 0xc0 )
		{
			UNICCHR t1 = 0;
			UNICCHR t2 = 0;

			t1 = *iter & ( 0xff >> 3 );
			iter++;
			t2 = *iter & ( 0xff >> 2 );

			cUnic = (t2 | ((t1 & (0xff >> 6)) << 6)) | (( t1 >> 2 ) << 8);

		}
		else if ( ( *iter & ( 0xff << 4  ) ) == 0xe0 )
		{
			UNICCHR t1 = 0;
			UNICCHR t2 = 0;
			UNICCHR t3 = 0;

			t1 = *iter & ( 0xff >> 3 );
			iter++;
			t2 = *iter & ( 0xff >> 2 );
			iter++;
			t3 = *iter & ( 0xff >> 2 );

			cUnic = (((t2 & (0xff >> 6)) << 6) | t3) | (((t1 << 4) | (t2 >> 2))<<8);
		}
		m_szUNICODE += cUnic;
		iter++;
	}
}

void NDWideString::ConvertUnicodeToUTF8()
{
	UNICString::iterator	iter = m_szUNICODE.begin();
	while ( iter != m_szUNICODE.end() )
	{
		UNICCHR unicode = *iter;
		UTF8CHR	cUTF8;
		if ( unicode >= 0x0000 && unicode <= 0x007f )
		{
			cUTF8 = (UTF8CHR)unicode;
			m_szUTF8 += cUTF8;
		}
		else if (unicode >= 0x0080 && unicode <= 0x07ff )
		{
			cUTF8 = 0xc0 | ( unicode >> 6 );
			m_szUTF8 += cUTF8;
			cUTF8 = 0x80 | ( unicode & (0xff >> 2) );
			m_szUTF8 += cUTF8;
		}
		else if ( unicode >= 0x0800 && unicode <= 0xffff )
		{
 			//cUTF8 = 0xe0 | ( ( unicode & 0xf000 ) >> 12 );
 			//m_szUTF8 += cUTF8;
 			//cUTF8 = 0x80 | ( ( unicode & 0x0fc0 ) >> 6 & 0x00ff );
 			//m_szUTF8 += cUTF8;
 			//cUTF8 = 0x80 | ( unicode & 0x3f );
 			//m_szUTF8 += cUTF8;

			char* pchar = (char *)&unicode;
 			m_szUTF8 += (0xE0 | ((pchar[1] & 0xF0) >> 4));
			m_szUTF8 += (0x80 | ((pchar[1] & 0x0F) << 2)) + ((pchar[0] & 0xC0) >> 6);
			m_szUTF8 += (0x80 | (pchar[0] & 0x3F));
		}
		iter++;
	}
}

//@zwq: 对比两个串是否相同（一个utf8编码，一个ansi）
bool NDWideString::IsEqual_UTF8_Ansi( const char* utf8, const char* ansi )
{
	// early out
	if (!utf8 || !ansi) return false;
	if (utf8[0] == 0 && ansi[0] == 0) return true;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	static wchar_t wbuf[1024] = {0};
	static char buf[1024] = {0};
	
	// multiBytes -> wide
	if (MultiByteToWideChar( CP_UTF8, 0, (LPCSTR)utf8, -1, wbuf, sizeof(wbuf)/sizeof(wchar_t)) > 0)
	{
		// wide -> ansi
		if (WideCharToMultiByte( CP_ACP, 0, wbuf, -1, buf, sizeof(buf), NULL, NULL ) > 0)
		{
			// compare by both ansi
			if (strcmp( buf, ansi ) == 0) 
				return true;
		}
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    NSString *sCompareUtf8 = [NSString stringWithUTF8String:utf8];
    NSStringEncoding enc=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *sAnsi2Utf8 = [NSString stringWithCString:ansi encoding:enc];

    if([sCompareUtf8 isEqualToString:sAnsi2Utf8])
        return true;
#else
    // compare by both ansi
    if (strcmp( utf8, GBKToUTF8(ansi) ) == 0)
        return true;
#endif
	return false;
}

//===========================================================================

