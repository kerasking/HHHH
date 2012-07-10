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
#include "KConnection.h"
#include <vector>

//#define __USE_CFSOCKET__

namespace NDEngine
{
	class NDSocket : public NDObject
	{
		DECLARE_CLASS(NDSocket)
		NDSocket();
		~NDSocket();
	public:
		bool Connect(const char* address, unsigned short port, bool blocking = false);
		bool Connected();
#ifdef __USE_CFSOCKET__
		void RunLoop();
		void StopLoop();
#endif
		bool Receive(unsigned char* data, int& iReadedLen, int iReadLen=512);
		bool Send(NDTransData* data);		
		bool DealReceivedData(const unsigned char* data, unsigned int dataLen);
		void Close();
		
		std::string GetIpAddress(){ return m_address; }
		unsigned short GetPort(){ return m_port; }
	private:
#ifdef __USE_CFSOCKET__
		CFSocketRef m_socket;
		CFReadStreamRef m_readStream;
		CFWriteStreamRef m_writeStream;	
		bool m_connected;
#else
		KTcpClientSocket *m_socket;
#endif
		bool m_blocking;
		std::vector<unsigned char> m_data;
		std::string m_address;
		unsigned short m_port;
	};
}

#endif
