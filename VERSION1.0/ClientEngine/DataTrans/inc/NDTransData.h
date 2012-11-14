/******************************************************************************
 *  FileName:		NDTransData.h
 *  Author:			Guosen
 *  Create Date:	2012-3-30
 *  
 *****************************************************************************/

#ifndef _NDTRANSDATA_H_2012_03_30_12_44_11_
#define _NDTRANSDATA_H_2012_03_30_12_44_11_
//////////////////////////////////////////////////////////////////////////

#include "NDObject.h"

#include <string>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#endif
//////////////////////////////////////////////////////////////////////////

namespace NDEngine
{	
#if (defined(USE_NDSDK) || defined(USE_MGSDK))
	const int ND_C_MSGID_BEGIN  = 2;
	const int ND_C_HEAD_SIZE   = 4;
#else
	const int ND_C_MSGID_BEGIN  = 4;
	const int ND_C_HEAD_SIZE   = 6;
#endif

	class NDTransData : public NDObject 
	{
		DECLARE_CLASS(NDTransData)
	public:
		explicit NDTransData();
		NDTransData(unsigned short code);
		~NDTransData();
		const unsigned char* GetBuffer() { return m_pBuffer; };
		
	public:
		/**加解密现在只有登陆消息需要,其它消息不需要*/
		bool encrypt(const std::string& strKey);
		bool decrypt(const std::string& strKey);

//		函数：Read
//		作用：从流中读取一段数据
//		参数：pBuffer(输出参数)数据，nLen数据长度
//		返回值：true读正确 false读错误
		bool Read(unsigned char* pBuffer, unsigned short nLen);

//		函数：Write
//		作用：向流中写入一段数据
//		参数：pBuffer数据，nLen数据长度
//		返回值：true写正确 false写失败
		bool Write(const unsigned char* pBuffer, unsigned short nLen);

//		函数：ReadByte
//		作用：从流中读取一字节
//		参数：无
//		返回值：一字节
		unsigned char ReadByte();

//		函数：ReadInt
//		作用：从流中读取一个整数，4字节
//		参数：无
//		返回值：整数
		int ReadInt();

//		函数：ReadShort
//		作用：从流中读取一个短整数，2字节
//		参数：无
//		返回值：短整数
		unsigned short ReadShort();
		
		long long ReadLong();
	
		//std::string ReadString();
		/**返回的字符串是utf8编码*/
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		NSString* ReadUnicodeNString();
        NSString* ReadUTF8NString();
#endif
		std::string ReadUnicodeString();
		std::string ReadUnicodeString2(bool bCareCode=true);
		bool		ReadUnicodeString(char* out, unsigned int& outLen);
		
		void WriteByte(unsigned char ucValue);

//		函数：WriteInt
//		作用：向流中写入一个整数
//		参数：nValue整数
//		返回值：无
		void WriteInt(const int nValue);

//		函数：WriteShort
//		作用：向流中写入一个短整数
//		参数：nValue短整数
//		返回值：无
		void WriteShort(const unsigned short nValue);
		//void WriteString(const std::string& strValue);
		void WriteUnicodeString(const std::string& strValue);
		void WriteUnicodeString(const char* strValue);
		
		//以下重载运算符方法可提供方便使用，功能与前几个方法类似
		//
		NDTransData& operator >>(int& nValue);
		NDTransData& operator >>(unsigned short& nValue);
		//NDTransData& operator >>(std::string& strValue);
		NDTransData& operator >>(unsigned char& cValue);
		
		
		NDTransData& operator <<(const int nValue);
		NDTransData& operator <<(const unsigned short nValue);
		//NDTransData& operator <<(const std::string& strValue);
		NDTransData& operator <<(const unsigned char cValue);
		
		NDTransData& operator <<(const long nValue);
		
		NDTransData& operator <<(const unsigned long nValue);
		
		NDTransData& operator =(const NDTransData& rhs);		

//		函数：Clear
//		作用：清空流
//		参数：无
//		返回值：无
		void Clear();

//		函数：GetSize
//		作用：获取流大小
//		参数：无
//		返回值：流大小
		unsigned short GetSize(){ return m_nSize; };
		
		unsigned short GetCode();
		void SetPackageSize();
	private:
        void SetSize(unsigned short newSize){ m_nSize = newSize;}
        bool SetBufSize(unsigned short newSize);
		void SetPackageHead();
		
	private:
		unsigned short m_nSize;
		unsigned short m_nBufSize;
		unsigned short m_nReadPos;
		unsigned short m_nWritePos;
		unsigned char* m_pBuffer;
		
	};	
}

//////////////////////////////////////////////////////////////////////////
#endif //_NDTRANSDATA_H_2012_03_30_12_44_11_
