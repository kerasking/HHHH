
#import "NDTransData.h"
#import  "Des.h"
#include "cpLog.h"

namespace NDEngine
{
	const int ND_C_SET_UNCODE = 0;
	const int ND_C_SET_UTF8	= 1;
	const int ND_C_SET_ASCII  = 2;
	
	IMPLEMENT_CLASS(NDTransData, NDObject)

	NDTransData::NDTransData()
	{
		m_pBuffer = NULL;
		m_nSize	  = 0;
		Clear();
	}	
	
	NDTransData::NDTransData(unsigned short code)
	{
		m_pBuffer = NULL;
		m_nSize	  = 0;
		Clear();
		*this << code;
	}
	
	NDTransData::~NDTransData()
	{
		if (m_pBuffer)
			free(m_pBuffer);
	}	
	
	/** 数据发送之前调用*/
	bool NDTransData::encrypt(std::string key)
	{
		if ( key.empty() ) return false;
		
		if ( GetSize() == 6 ) return true; // 没有消息体需要加密
		
		unsigned short nMsgID = 0;
		memcpy(&nMsgID, m_pBuffer+4, 2);
		
		char tmpBuf[1046]={0};
		unsigned int len = 0;
		
		
		if( !CDes::Encrypt_Pad_PKCS_7(
									key.c_str(),
									 (unsigned char)key.size(),
									 (char*)(m_pBuffer+6), 
									 (unsigned int)(GetSize()-6),
									 tmpBuf,
									 len ) 
		   )
		   return false;
		   
		NDTransData tmp;
		tmp.WriteShort(nMsgID);
		tmp.Write((unsigned char*)tmpBuf, len);
		   
		(*this) = tmp;
		
		return true;
	}
	
	bool NDTransData::decrypt(std::string key)
	{
		
		if ( key.empty() ) return false;
		
		if ( GetSize() == 6 ) return true; // 没有消息体需要解密
		
		unsigned short nMsgID = 0;
		memcpy(&nMsgID, m_pBuffer+4, 2);
		
		char tmpBuf[1046]={0};
		unsigned int len = 0;
		
		if ( !CDes::Decrypt_Pad_PKCS_7( key.c_str(),
										key.size(),
									    (char*)(m_pBuffer+6), 
									    (unsigned int)(GetSize()-6),
									    tmpBuf,
									    len
									   )
			)
			return false;
		
		if (len > 1046) 
		{
			NDLog(@"解密出错");
			len = 32;
		}
		NDTransData tmp;
		tmp.WriteShort(nMsgID);
		tmp.Write((unsigned char*)tmpBuf, len);
		
		
		(*this) = tmp;
		
		//解密前已经读了消息; 
		ReadShort();
		
		return true;
	}

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
	
	bool NDTransData::Write(const unsigned char* pBuffer, unsigned short nLen)
	{		
		if (pBuffer && nLen)
		{
            unsigned int nSize = m_nWritePos + nLen;
            if (nSize > m_nSize)
			{
			    if (SetSize(nSize))
				{
					memcpy(m_pBuffer + m_nWritePos, pBuffer, nLen);
					m_nWritePos += nLen;
					
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		return false;
	}
	
	Byte NDTransData::ReadByte()
	{
		Byte ret = 0;
		operator >> (ret);
		return ret;
	}
	
	int NDTransData::ReadInt()
	{
		int result = 0;
		operator >> (result);
		return result;
	}
	
	unsigned short NDTransData::ReadShort()
	{
		unsigned short result = 0;
		operator >> (result);
		return result;
	}
	
	long long NDTransData::ReadLong()
	{
		long long lVal = 0L;
		Read((unsigned char*) &lVal, sizeof(long long));
		return lVal;
	}
	
	std::string NDTransData::ReadUnicodeString2(bool bCareCode/*=true*/)
	{
		char buf = 0x00;
		if( !Read((unsigned char*)&buf, 1) || ( (int)buf != ND_C_SET_UNCODE && bCareCode) ) 
		{
			return "";
		}
		
		char tmp[512]={0};
		unsigned short nLen = 0;
		nLen = ReadShort();
		
		if (nLen == 0 || (nLen %2 != 0)) 
		{
			return "";
		}
		
		if (!Read((unsigned char*)tmp, nLen))
		{
			return "";
		}
		
		std::string curLocale = setlocale(LC_ALL, NULL);
		
		setlocale(LC_CTYPE, "UTF-8");

		wchar_t c;
		std::wstring wStr;
		for (int i = 0; i < nLen; i += 2) {
			c = ((tmp[i] & 0xff) | ((tmp[i + 1] & 0xff) << 8));
			wStr += c;
		}
		
		char szStr[513] = { 0 };
		wcstombs(szStr, wStr.c_str(), 512);
		
		setlocale(LC_ALL, curLocale.c_str());
		return std::string(szStr);
	}
	
	std::string NDTransData::ReadUnicodeString()
	{
		char buf = 0x00;
		if( !Read((unsigned char*)&buf, 1) || (int)buf != ND_C_SET_UNCODE ) return "";
		
		unsigned short nLen = 0;
		nLen = ReadShort();
		
		if (nLen > 1024) 
		{
			NDAsssert(0);
			return "";
		}
		
		if (nLen == 0 || nLen % 2 != 0)
		{
			return "";
		}
		
		char tmp[1024]={0};
		
		if (!Read((unsigned char*)tmp, nLen))
		{
			NDAsssert(0);
			return "";
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
		
		if (nsstr == nil) return "";
		
		std::string res([nsstr UTF8String]);
		
		return res;
	}
	
	bool NDTransData::ReadUnicodeString(char* out, unsigned int& outLen)
	{
		std::string tmp = ReadUnicodeString();
		if (tmp.empty()) {
			return false;
		}
		
		outLen = tmp.size();
		memcpy(out, tmp.c_str(), outLen);
		return true;
	}
	
	void NDTransData::WriteByte(unsigned char ucValue)
	{
		operator << (ucValue);
	}
	
	void NDTransData::WriteInt(const int nValue)
	{
		operator << (nValue);
	}
	
	void NDTransData::WriteShort(const unsigned short nValue)
	{
		operator << (nValue);
	}
	
	void NDTransData::WriteUnicodeString(const std::string& strValue)
	{
		if (strValue.empty()) return;
		
		if ( !Write((unsigned char*)&ND_C_SET_UNCODE, 1) ) return;
		
		NSMutableString *tmpNSStr	= [NSMutableString stringWithUTF8String:strValue.c_str()];
		unsigned int uiLen			= [tmpNSStr lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
		const char* data			= [tmpNSStr cStringUsingEncoding:NSUnicodeStringEncoding];
		
		this->WriteShort((const unsigned short)uiLen);
		
		if ( uiLen == 0 || !data ) return;
		
		this->Write( (unsigned char*)data, uiLen );
	}
	
	void NDTransData::WriteUnicodeString(const char* strValue)
	{
		if ( !strValue ) return;
		std::string tmp(strValue);
		
		WriteUnicodeString(tmp);
	}
	
	NDTransData& NDTransData::operator =(const NDTransData& rhs)
	{
		if (&rhs != this)
		{
			SetSize(rhs.m_nSize);
			
			memcpy(m_pBuffer, rhs.m_pBuffer, rhs.m_nSize);
			m_nReadPos = rhs.m_nReadPos;
			m_nWritePos = rhs.m_nWritePos;			
		}
		return *this;
	}
	
    NDTransData& NDTransData::operator >>(int& nValue)
    {
		if (!Read((unsigned char*) &nValue, sizeof(int)))
			nValue = 0;
		
        return *this;
    }
	
    NDTransData& NDTransData::operator >>(unsigned short& nValue)
    {
		unsigned char buf[2] = {0x00};
        if (Read(buf, 2)) 
		{
			nValue = buf[0] + (buf[1] << 8);
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
//		
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
		Write((unsigned char*)&nValue, sizeof(int));
		return *this;
	}
	
	NDTransData& NDTransData::operator <<(const long nValue)
	{
		Write((unsigned char*)&nValue, sizeof(long));
		return *this;
	}
	
	NDTransData& NDTransData::operator <<(const unsigned long nValue)
	{
		Write((unsigned char*)&nValue, sizeof(unsigned long));
		return *this;
	}
	
	NDTransData& NDTransData::operator <<(const unsigned short nValue)
	{
		unsigned char buf[2] = {0x00};
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
			free(m_pBuffer);
		
		m_pBuffer = NULL;
		m_nSize	  = 0;
		
		if (SetSize(4))
		{
			SetPackageHead();
			
			m_nReadPos = 4;
			m_nWritePos = 4;
		}		
	}
	
	void NDTransData::SetPackageSize()
	{
		memcpy(&m_pBuffer[2], &m_nSize, 2);
	}
	
	void NDTransData::SetPackageHead()
	{
		m_pBuffer[0] = 0xff, m_pBuffer[1] = 0xfe;
	}
	
	bool NDTransData::SetSize(unsigned short newSize)
	{
		if (m_pBuffer && (newSize == m_nSize))
			return true;
		
		unsigned short nLen = GetSize();
		if (newSize > nLen)
			nLen = newSize;
		
		unsigned char* pNewBuffer = NULL;
		if (m_pBuffer)
			pNewBuffer = (unsigned char *)realloc(m_pBuffer, nLen);
		else
			pNewBuffer = (unsigned char *)malloc(nLen);
		
		if (pNewBuffer)
		{
			m_pBuffer = pNewBuffer;
			m_nSize = nLen;
			SetPackageSize();
			
			if (m_nReadPos > m_nSize)
				m_nReadPos = m_nSize;
			if (m_nWritePos > m_nSize)
				m_nWritePos = m_nSize;
			
			return true;
		}
		else
			return false;
	}
	
	unsigned short NDTransData::GetCode()
	{
		if (this->GetSize() < 6)
			return 0;
		
		return (unsigned short)( m_pBuffer[4] + (m_pBuffer[5] << 8) );
	}
	
}

