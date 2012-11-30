/******************************************************************************
 *  FileName:		NDTransData.cpp
 *  Author:			Guosen
 *  Create Date:	2012-3-30
 *
 *****************************************************************************/

#include "NDTransData.h"

#include "Des.h"
#include "NDWideString.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "Foundation/Foundation.h"
#include "CCCommon.h"
#include "basedefine.h"
#endif

//////////////////////////////////////////////////////////////////////////
namespace NDEngine
{
const int ND_C_SET_UNCODE = 0;
const int ND_C_SET_UTF8 = 1;
const int ND_C_SET_ASCII = 2;

const int ND_C_BUF_SIZE = 256;

IMPLEMENT_CLASS(NDTransData, NDObject)

//======================================================================
NDTransData::NDTransData()
{
	m_pBuffer = NULL;
	m_nSize = 0;
	Clear();
}

//======================================================================
NDTransData::NDTransData(unsigned short code)
{
	m_nMsgType = code;
	m_pBuffer = NULL;
	m_nSize = 0;
	Clear();
	*this << code;
}

//======================================================================
NDTransData::~NDTransData()
{
	if (m_pBuffer)
		free (m_pBuffer);
}

//======================================================================
//	/**数据发送之前调用*/

bool NDTransData::encrypt(const std::string& strKey)
{
	if (strKey.empty())
		return false;

	if (GetSize() == ND_C_HEAD_SIZE)
		return true; //没有消息体需要加密

	unsigned short nMsgID = 0;
	memcpy(&nMsgID, m_pBuffer + ND_C_MSGID_BEGIN, 2);

	char szTempBuffer[1046] =
	{ 0 };
	unsigned int nLength = 0;

	if (!CDes::Encrypt_Pad_PKCS_7(strKey.c_str(), (unsigned char) strKey.size(),
			(char*) (m_pBuffer + ND_C_HEAD_SIZE),
			(unsigned int) (GetSize() - ND_C_HEAD_SIZE), szTempBuffer, nLength))
	{
		return false;
	}

	NDTransData kTempTrans;
	kTempTrans.WriteShort(nMsgID);
	kTempTrans.Write((unsigned char*) szTempBuffer, nLength);

	(*this) = kTempTrans;

	return true;
}

//======================================================================
bool NDTransData::decrypt(const std::string& strKey)
{

	if (strKey.empty())
		return false;

	if (GetSize() == 6)
		return true; //没有消息体需要解密

	unsigned short nMsgID = 0;
	memcpy(&nMsgID, m_pBuffer + 4, 2);

	char szTempBuffer[1046] =
	{ 0 };
	unsigned int nLength = 0;

	if (!CDes::Decrypt_Pad_PKCS_7(strKey.c_str(), strKey.size(),
			(char*) (m_pBuffer + ND_C_HEAD_SIZE),
			(unsigned int) (GetSize() - ND_C_HEAD_SIZE), szTempBuffer, nLength))
		return false;

	if (nLength > 1046)
	{
		cocos2d::CCLog("解密出错");
		nLength = 32;
	}
	NDTransData kTempTrans;
	kTempTrans.WriteShort(nMsgID);
	kTempTrans.Write((unsigned char*) szTempBuffer, nLength);

	(*this) = kTempTrans;

	//解密前已经读了消息;
	ReadShort();

	return true;
}

//======================================================================
bool NDTransData::Read(unsigned char* pBuffer, unsigned short nLen)
{
	if (m_nSize - m_nReadPos < nLen)
	{
		return false;
	}

	memcpy(pBuffer, m_pBuffer + m_nReadPos, nLen);
	m_nReadPos += nLen;
	return true;
}

//======================================================================
bool NDTransData::Write(const unsigned char* pBuffer, unsigned short nLen)
{
	if (pBuffer && nLen)
	{
		unsigned int nSize = m_nWritePos + nLen;
		if (nSize > m_nBufSize)
		{
			if (SetBufSize(nSize))
			{
				memcpy(m_pBuffer + m_nWritePos, pBuffer, nLen);
				m_nWritePos += nLen;
				SetSize(nSize);
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			memcpy(m_pBuffer + m_nWritePos, pBuffer, nLen);
			m_nWritePos += nLen;
			SetSize(nSize);
			return true;
		}
	}

	return false;
}

//======================================================================
unsigned char NDTransData::ReadByte()
{
	unsigned char ret = 0;
	operator >>(ret);
	return ret;
}

int NDTransData::ReadInt()
{
	int result = 0;
	operator >>(result);
	return result;
}

unsigned short NDTransData::ReadShort()
{
	unsigned short result = 0;
	operator >>(result);
	return result;
}

long long NDTransData::ReadLong()
{
	long long lVal = 0L;
	Read((unsigned char*) &lVal, sizeof(long long));
	return lVal;
}
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
NSString* NDTransData::ReadUnicodeNString()
{
    char buf = 0x00;
    if( !Read((unsigned char*)&buf, 1) || (int)buf != ND_C_SET_UNCODE ) return nil;
    
    unsigned short nLen = 0;
    nLen = ReadShort();
    
    if (nLen > 1024)
    {
        NDAsssert(0);
        return nil;
    }
    
    if (nLen == 0 || nLen % 2 != 0)
    {
        return nil;
    }
    
    char tmp[1024]={0};
    
    if (!Read((unsigned char*)tmp, nLen))
    {
        NDAsssert(0);
        return nil;
    }
    
    /*
     int n = (int)buf;
     for (int i = 0; i < nLen;) {
     int a = tmp[i++], b = tmp[i++];
     if (b == 0) {
     pOut[n++] = (unsigned char) a;
     } else {
     pOut[n++] = (unsigned char) (0xE0 | ((b & 0xF0) >> 4));
     pOut[n++] = (unsigned char) ((0x80 | ((b & 0x0F) << 2)) + ((a & 0xC0) >> 6));
     pOut[n++] = (unsigned char) (0x80 | (a & 0x3F));
     }
     }
     */
    
    NSString *nsstr = [NSString stringWithCharacters:(unichar*)tmp length:nLen/2];
    return nsstr;
}
NSString* NDTransData::ReadUTF8NString()
{
    char buf = 0x00;
    if( !Read((unsigned char*)&buf, 1) || (int)buf != ND_C_SET_UTF8 ) return nil;
    
    unsigned short nLen = 0;
    nLen = ReadShort();
    
    if (nLen > 1024)
    {
        NDAsssert(0);
        return nil;
    }
    
    if (nLen == 0)
    {
        return nil;
    }
    
    char tmp[1024]={0};
    
    if (!Read((unsigned char*)tmp, nLen))
    {
        NDAsssert(0);
        return nil;
    }
    
    NSData* nsdata =[NSData dataWithBytes:tmp length:nLen];
    NSString *nsstr = [[NSString alloc ]initWithData:nsdata encoding:NSUTF8StringEncoding];
    return nsstr;
}

//======================================================================
std::string NDTransData::ReadUnicodeString2(bool bCareCode)
{
	char buf = 0x00;
	if (!Read((unsigned char*) &buf, 1)
			|| ((int) buf != ND_C_SET_UNCODE && bCareCode))
	{
		return "";
	}

	char tmp[512] =
	{ 0 };
	unsigned short nLen = 0;
	nLen = ReadShort();

	if (nLen == 0 || (nLen % 2 != 0))
	{
		return "";
	}

	if (!Read((unsigned char*) tmp, nLen))
	{
		return "";
	}

	std::string curLocale = setlocale(LC_ALL, NULL);

	setlocale(LC_CTYPE, "UTF-8");

	UNICCHR c;
	UNICString wStr;
	for (int i = 0; i < nLen; i += 2)
	{
		c = ((tmp[i] & 0xff) | ((tmp[i + 1] & 0xff) << 8));
		wStr += c;
	}

	char szStr[513] =
	{ 0 };
	wcstombs(szStr, (const wchar_t*) wStr.c_str(), 512);

	setlocale(LC_ALL, curLocale.c_str());
	return std::string(szStr);
}
#endif

//======================================================================
//
std::string NDTransData::ReadUnicodeString()
{
	char buf = 0x00;
	if (!Read((unsigned char*) &buf, 1) || (int) buf != ND_C_SET_UNCODE)
		return "";

	unsigned short nLen = 0;
	nLen = ReadShort();

	if (nLen > 1024)
	{
		//NDAsssert(0);
		return "";
	}

	if (nLen == 0 || nLen % 2 != 0)
	{
		return "";
	}

	char szTemp[1024] =
	{ 0 };

	if (!Read((unsigned char*) szTemp, nLen))
	{
		//NDAsssert(0);
		return "";
	}

	NDWideString szOut((const UNICCHR *) szTemp);

	std::string res((const char *) szOut.GetUTF8String());

	return res;
}

//======================================================================
bool NDTransData::ReadUnicodeString(char* out, unsigned int& outLen)
{
	std::string tmp = ReadUnicodeString();
	if (tmp.empty())
	{
		return false;
	}

	outLen = tmp.size();
	memcpy(out, tmp.c_str(), outLen);
	return true;
}

//======================================================================
void NDTransData::WriteByte(unsigned char ucValue)
{
	operator <<(ucValue);
}

void NDTransData::WriteInt(const int nValue)
{
	operator <<(nValue);
}

void NDTransData::WriteShort(const unsigned short nValue)
{
	operator <<(nValue);
}

void NDTransData::WriteUnicodeString(const std::string& strValue)
{
	if (strValue.empty())
		return;

	if (!Write((unsigned char*) &ND_C_SET_UNCODE, 1))
		return;

	NDWideString szIn((const UTF8CHR *) strValue.c_str());
	unsigned int uiLen = szIn.GetLengthOfBytesUsingUnicode();
	const char* pszData = (const char *) szIn.GetUnicodeString();

	WriteShort((const unsigned short) uiLen);

	if (uiLen == 0 || !pszData)
	{
		return;
	}

	Write((unsigned char*) pszData, uiLen);
}

void NDTransData::WriteUnicodeString(const char* strValue)
{
	if (!strValue)
		return;
	std::string tmp(strValue);

	WriteUnicodeString(tmp);
}

//======================================================================
NDTransData& NDTransData::operator =(const NDTransData& rhs)
{
	if (&rhs != this)
	{
		SetBufSize(rhs.m_nSize);

		memcpy(m_pBuffer, rhs.m_pBuffer, rhs.m_nSize);
		m_nReadPos = rhs.m_nReadPos;
		m_nWritePos = rhs.m_nWritePos;
	}
	return *this;
}

NDTransData& NDTransData::operator >>(int& nValue)
{
	if (!Read((unsigned char*) &nValue, sizeof(int)))
	{
		nValue = 0;
	}

	return *this;
}

NDTransData& NDTransData::operator >>(unsigned short& nValue)
{
	unsigned char szBuffer[2] =
	{ 0x00 };
	if (Read(szBuffer, 2))
	{
		nValue = szBuffer[0] + (szBuffer[1] << 8);
	}
	else
	{
		nValue = 0;
	}

	return *this;
}

//	NDTransData& NDTransData::operator >>(std::string &strValue)
//	{
//		//先预先设定字符串长度的存储位为2位
//		unsigned short strLen = 0;
//		operator >> (strLen);
//		if (strLen > 0)
//		{
//			unsigned char* pBuffer = (unsigned char*)malloc(strLen + 1);
//			pBuffer[strLen] = 0x00;
//
//			if (Read(pBuffer, strLen))
//			{
//				strValue = std::string((const char*)pBuffer);
//			}
//
//			free(pBuffer);
//		}
//
//		return *this;
//	}

NDTransData& NDTransData::operator >>(unsigned char& cValue)
{
	if (!Read(&cValue, 1))
		cValue = 0;
	return *this;
}

NDTransData& NDTransData::operator <<(const int nValue)
{
	Write((unsigned char*) &nValue, sizeof(int));
	return *this;
}

NDTransData& NDTransData::operator <<(const long nValue)
{
	Write((unsigned char*) &nValue, sizeof(long));
	return *this;
}

NDTransData& NDTransData::operator <<(const unsigned long nValue)
{
	Write((unsigned char*) &nValue, sizeof(unsigned long));
	return *this;
}

NDTransData& NDTransData::operator <<(const unsigned short nValue)
{
	unsigned char buf[2] =
	{ 0x00 };
	buf[0] = nValue & 0xff;
	buf[1] = (nValue >> 8) & 0xff;

	Write(buf, 2);

	return *this;
}

//	NDTransData& NDTransData::operator <<(const std::string &strValue)
//	{
//		unsigned short strLen = strValue.size();
//
//		operator <<(strLen);
//
//		Write((unsigned char*)strValue.c_str(), strLen);
//
//		return *this;
//	}

NDTransData& NDTransData::operator <<(const unsigned char cValue)
{
	Write(&cValue, 1);
	return *this;
}

void NDTransData::Clear()
{
	if (m_pBuffer)
		free (m_pBuffer);

	m_pBuffer = NULL;
	m_nBufSize = 0;
	m_nReadPos = 0;
	m_nWritePos = 0;

	if (SetBufSize (ND_C_BUF_SIZE))
	{
		if (ND_C_MSGID_BEGIN == 4)
		{
			SetPackageHead();
		}

		SetSize (ND_C_MSGID_BEGIN);
		m_nReadPos = ND_C_MSGID_BEGIN;
		m_nWritePos = ND_C_MSGID_BEGIN;
	}
}

//======================================================================
void NDTransData::SetPackageSize()
{
	memcpy(&m_pBuffer[ND_C_MSGID_BEGIN - 2], &m_nSize, 2);
}

void NDTransData::SetPackageHead()
{
	m_pBuffer[0] = 0xff, m_pBuffer[1] = 0xfe;
}

bool NDTransData::SetBufSize(unsigned short newSize)
{
	if (m_pBuffer && (newSize == m_nBufSize))
		return true;

	unsigned short nLen = m_nBufSize;
	if (newSize > nLen)
		nLen = newSize;

	unsigned char* pNewBuffer = NULL;
	if (m_pBuffer)
		pNewBuffer = (unsigned char *) realloc(m_pBuffer, nLen);
	else
		pNewBuffer = (unsigned char *) malloc(nLen);

	if (pNewBuffer)
	{
		m_pBuffer = pNewBuffer;
		m_nBufSize = nLen;

		if (m_nReadPos > m_nBufSize)
			m_nReadPos = m_nBufSize;
		if (m_nWritePos > m_nBufSize)
			m_nWritePos = m_nBufSize;

		return true;
	}
	else
		return false;
}

//======================================================================
unsigned short NDTransData::GetCode()
{
	if (GetSize() < ND_C_HEAD_SIZE)
		return 0;

	return (unsigned short) (m_pBuffer[ND_C_MSGID_BEGIN]
			+ (m_pBuffer[ND_C_MSGID_BEGIN + 1] << 8));
}

}