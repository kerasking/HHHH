/******************************************************************************
 *  File Name:		NDWideString.h
 *  Author:			Guosen
 *  Create Date:	2012-4-10
 *  
 *****************************************************************************/

#ifndef _NDWideString_H_2012_04_10_18_41_09_
#define _NDWideString_H_2012_04_10_18_41_09_
/////////////////////////////////////////////////////////////////////////////

#include "string.h"
#include <string>


/////////////////////////////////////////////////////////////////////////////

#define UTF8CHR	unsigned char		//UTF8 char//
#define UNICCHR	unsigned short		//UNICODE char//

//UTF8编码的字符串类
typedef std::basic_string< UTF8CHR, std::char_traits<UTF8CHR>, std::allocator<UTF8CHR> >	UTF8String;
typedef std::basic_string< UNICCHR, std::char_traits<UNICCHR>, std::allocator<UNICCHR> >	UNICString;

/////////////////////////////////////////////////////////////////////////////
//UTF8 UNCODE 编码转换的字符串类
class NDWideString
{
protected:
	UTF8String			m_szUTF8;			//UTF8编码的字符串
	UNICString			m_szUNICODE;		//UNICODE编码的字符串
	bool				m_bInit;			//是否已成功初始化

public:
	explicit NDWideString():m_bInit(false){}
	explicit NDWideString( const UTF8CHR * szUTF8 );
	explicit NDWideString( const UTF8String & szUTF8 );
	explicit NDWideString( const UNICCHR * szUNICODE );
	explicit NDWideString( const UNICString & szUNICODE );

public:
	bool InitializeWithUTF8String( const UTF8CHR * szUTF8 );
	bool InitializeWithUTF8String( const UTF8String & szUTF8 );
	bool InitializeWithUNICODEString( const UNICCHR * szUNICODE );
	bool InitializeWithUNICODEString( const UNICString & szUNICODE );

public:
	//取得UTF8编码的字符串
	const UTF8CHR * GetUTF8String(){ return m_szUTF8.c_str(); }
	//取得UNICODE编码的字符串
	const UNICCHR * GetUnicodeString(){ return m_szUNICODE.c_str(); }

	//得到UTF8编码的字符个数
	unsigned int GetUTF8Numbers(){ return m_szUTF8.size(); }
	//得到UNICODE编码的字符个数
	unsigned int GetUnicodeNumbers(){ return m_szUNICODE.size(); }

	//得到UTF8编码字符串所占的字节数
	unsigned int GetLengthOfBytesUsingUTF8(){ return m_szUTF8.size() * sizeof(UTF8CHR); }
	//得到UNICODE编码字符串所占的字节数
	unsigned int GetLengthOfBytesUsingUnicode(){ return m_szUNICODE.size() * sizeof(wchar_t); }

protected:
	void ConvertUTF8ToUnicode();
	void ConvertUnicodeToUTF8();

};

/////////////////////////////////////////////////////////////////////////////
#endif //_NDWideString_H_2012_04_10_18_41_09_
