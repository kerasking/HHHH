//
//  NDSocket.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
/*
 套接字操作类包含两种实现方式：1 bsd socket; 2 cfsocket 
 开关在于 __USE_CFSOCKET__
 */

#ifndef __NDSocket_H
#define __NDSocket_H

#include "NDObject.h"
#include "NDTransData.h"
#include "KTcpClientSocket.h"
#include "TEncryptor.h"
#include "KConnection.h"
#include <vector>

typedef	net::TEncryptClient<0x20, 0xFD, 0x07, 0x1F, 0x7A, 0xCF, 0xE5, 0x3F>	CEncryptor;

namespace NDEngine
{ 
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    bool InitSocket();
#endif

	class NDSocket : public NDObject
	{
		DECLARE_CLASS(NDSocket)
		NDSocket();
		~NDSocket();
	public:
		bool Connect(const char* address, unsigned short port, bool blocking = false);
		bool Connected();
		bool Receive(unsigned char* data, int& iReadedLen, int iReadLen=512);
		bool Send(NDTransData* data);		
		bool DealReceivedData(const unsigned char* data, unsigned int dataLen);
		void Close();
		
		std::string GetIpAddress(){ return m_address; }
		unsigned short GetPort(){ return m_port; }
        void ChangeCode(DWORD dwCode);
	private:
		KTcpClientSocket *m_socket;

		bool m_blocking;
		std::vector<unsigned char> m_data;
		std::string m_address;
		unsigned short m_port;
        
        CEncryptor* m_EncryptSnd;
        CEncryptor* m_EncryptRcv;        
	};
}

#endif
