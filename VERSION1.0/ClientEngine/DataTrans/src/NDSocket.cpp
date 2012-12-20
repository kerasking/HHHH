//
//  NDSocket.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "CCPlatformConfig.h"
#include "NDSocket.h"
#include <stdio.h>
#include <stdlib.h>

#define PROFILE_ENCRYPT_C2S 1

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/ioctl.h>
#include "NDUIDialog.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

#include <vector>

#include "NDMessageCenter.h"

namespace NDEngine
{
#define TCP_TIME_OUT 30 * 1000
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    bool InitSocket()
    {
		// 初始化网络
		WSADATA	wsaData;
		WORD    wVersionRequested= MAKEWORD( 2, 0 );
		int ret = ::WSAStartup(wVersionRequested, &wsaData);
		if (ret != 0)
		{
			cocos2d::CCLog("%s", "ERROR: Init WSAStartup() failed.");
			return false;
		}

		// 检查版本
		if (LOBYTE(wsaData.wVersion) != 0x02 || HIBYTE(wsaData.wVersion) != 0x00)
		{
			cocos2d::CCLog("%s", "ERROR: WSAStartup Version not match 2.0");
			return false;
		}
        return true;
    }
#endif
	
	IMPLEMENT_CLASS(NDSocket, NDObject)
	
	NDSocket::NDSocket()
	{
		m_blocking = false;

		m_socket = new KTcpClientSocket();

        m_EncryptSnd = new CEncryptor;
        m_EncryptRcv = new CEncryptor;
	}
	
	NDSocket::~NDSocket()
	{
		Close();
		SAFE_DELETE( m_socket );
        SAFE_DELETE( m_EncryptSnd );
        SAFE_DELETE( m_EncryptRcv );
	}
	
	bool NDSocket::Connect(const char* address, unsigned short port, bool blocking)
	{
		LOGD("Entry NDSocket::Connect,address = %s,port = %d",address,port);

		m_blocking = blocking;
		m_address = address;
		m_port = port;
		

		m_socket->setServer(address, port, m_blocking);

		LOGD("m_socket->setServer(address, port, m_blocking);");

		if (!m_blocking) 
		{
			m_socket->getConn().setTimeout(0);

			LOGD("m_socket->getConn().setTimeout(0);");

			int keepAlive = 1;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_KEEPALIVE, (const char*)&keepAlive, sizeof(keepAlive));	

			int nRecvBuf = 256 * 1024;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_RCVBUF, (const char*)&nRecvBuf, sizeof(int));

			int nSendBuf = 256 * 1024;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_SNDBUF, (const char*)&nSendBuf, sizeof(int));

			int connTimeOut = 30 * 1000;
			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_SNDTIMEO, (const char*)&connTimeOut, sizeof(int));			
			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_RCVTIMEO, (const char*)&connTimeOut, sizeof(int));
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			int	optval=1;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_NOSIGPIPE, (char *) &optval, sizeof(optval));
#endif
		}
		if (m_socket->connect()) 
		{		
			//NDLog(@"connect server success! address:%s	port:%d", address, port);
			return true;
		}
		else 
		{
			//NDLog(@"connect server failed! address:%s	port:%d", address, port);
			return false;
		}
	}
	
	bool NDSocket::Connected()
	{
		return m_socket->getConn().isLive();
	}
	
	void NDSocket::Close()
	{
		m_socket->close();
	}
    
    void NDSocket::ChangeCode(DWORD dwCode)
    {
        if(m_EncryptSnd)
        {
            m_EncryptSnd->ChangeCode(dwCode);
        }
    }
	
	bool NDSocket::Receive(unsigned char* data, int& iReadedLen, int iReadLen/*=512*/)
	{

		if (!Connected()) 
		{
			//NDLog(@"fail to connect server!");
			return false;
		}
		
		if (m_blocking) 
			iReadedLen = m_socket->getConn().readn(data, iReadLen, TCP_TIME_OUT);
		else 
			iReadedLen = m_socket->getConn().readn(data, iReadLen);
		if (iReadedLen == -1) 
		{
			//NDLog(@"read data error, maybe the net not in work!");
			if (Connected()) 
			{
				Close();
				//NDLog(@"close socket!");
			}
			return false;
		}
		else 
		{
			if (iReadedLen > 0) 
			{
#ifdef PROFILE_ENCRYPT_C2S
                if(this->m_EncryptRcv)
                    this->m_EncryptRcv->Decrypt(data, iReadedLen); // 解密封包
#endif
				//NDLog(@"read data success, readed len : %d", iReadedLen);			
			}				
			return true;
		}
	}
	
	bool NDSocket::Send(NDTransData* data)
	{
        data->SetPackageSize();
        unsigned short usSize = data->GetSize();
        
        // 加密封包
#ifdef PROFILE_ENCRYPT_C2S      
        if(this->m_EncryptSnd)
            this->m_EncryptSnd->Encrypt((unsigned char*)data->GetBuffer(), usSize);
#endif
        
		int ret;
		if (m_blocking) 
			ret = m_socket->getConn().writeData(data->GetBuffer(), data->GetSize(), TCP_TIME_OUT);
		else 
			ret = m_socket->getConn().writeData(data->GetBuffer(), data->GetSize());
		if (ret == -1) 
		{
			//NDLog(@"fail to connect server!");
			return false;
		}
		else if (ret < usSize)
		{
			//NDLog(@"write data time out, may be the net not in work!");
			if (Connected()) 
			{
				Close();
				//NDLog(@"close socket!");
			}
			return false;
		}
		else if (ret > 1024)
		{
			NDAsssert(0);
			return true;
		}
		else 
		{
			//NDLog(@"write data success, writed len : %d", data->GetSize());
			return true;
		}

		return false;
	}
}