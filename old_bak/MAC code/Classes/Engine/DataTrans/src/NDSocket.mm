//
//  NDSocket.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDSocket.h"
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netdb.h>
#import <sys/ioctl.h>
#import <vector>
#import "NDUIDialog.h"
#import "NDMessageCenter.h"

namespace NDEngine
{
#define TCP_TIME_OUT 30 * 1000
	
#ifdef __USE_CFSOCKET__
	
	void CFSocketCallback (CFSocketRef s,
						   CFSocketCallBackType callbackType,
						   CFDataRef address,
						   const void *data,
						   void *info)
	{
		NDSocket * socket = (NDSocket*)info;
		if (socket) 
		{
			if (callbackType ==  kCFSocketConnectCallBack) 
			{
				if (data) 
				{					
					socket->Close();
					NDLog(@"CF failed connect to server or server disconnect!");
				}
			}
			else if (callbackType == kCFSocketDataCallBack) 
			{
				if (data) 
				{
					CFDataRef cfData = (CFDataRef)data;						
					if (!socket->DealReceivedData(CFDataGetBytePtr(cfData), CFDataGetLength(cfData)))
					{
						//NDLog(@"CF deal message error!");
						CFRunLoopStop(CFRunLoopGetCurrent());
					}
					else 
					{
						//NDLog(@"CF read data success, readed len :%d", CFDataGetLength(cfData));
					}
				}					
			}				
		}		
	}
#endif
	
	IMPLEMENT_CLASS(NDSocket, NDObject)
	
	NDSocket::NDSocket()
	{
		m_blocking = false;
#ifdef __USE_CFSOCKET__
		m_connected = false;
		m_socket = NULL;
		m_readStream = NULL;
		m_writeStream = NULL;
#else
		m_socket = new KTcpClientSocket();
#endif
        m_EncryptSnd = new CEncryptor;
        m_EncryptRcv = new CEncryptor;
	}
	
	NDSocket::~NDSocket()
	{
		Close();
#ifndef __USE_CFSOCKET__
		delete m_socket;
#endif
        delete m_EncryptSnd;
        delete m_EncryptRcv;
	}
	
	bool NDSocket::Connect(const char* address, unsigned short port, bool blocking)
	{
		m_blocking = blocking;
		m_address = address;
		m_port = port;
		
#ifdef __USE_CFSOCKET__
		//if socket is active must close first
		if (m_connected) 
		{
			Close();
		}	
		
		if (m_blocking) 
		{
			CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, 
											   (CFStringRef)[NSString stringWithUTF8String:address], 
											   port, 
											   &m_readStream, 
											   &m_writeStream);
			
			if (CFReadStreamOpen(m_readStream) && CFWriteStreamOpen(m_writeStream)) 
			{
				NDLog(@"CF connect server success! address:%s	port:%d", address, port);
				m_connected = true;
			}
			else 
			{
				NDLog(@"CF connect server failed! address:%s	port:%d", address, port);
				m_connected = false;
			}
			return m_connected;
		}
		else 
		{
			//create socket	
			CFSocketContext sc;
			sc.version = 0;
			sc.info = this;
			sc.retain = NULL;
			sc.release = NULL;
			sc.copyDescription = NULL;			
			
			m_socket = CFSocketCreate(kCFAllocatorDefault, 
									  PF_INET, 
									  SOCK_STREAM, 
									  IPPROTO_TCP, 
									  kCFSocketConnectCallBack | kCFSocketDataCallBack, 
									  CFSocketCallback, 
									  &sc);
			
			//connect to server
			if (m_socket) 
			{
				struct sockaddr_in sin;
				
				memset(&sin, 0, sizeof(sin));
				sin.sin_len = sizeof(sin);
				sin.sin_family = AF_INET;
				sin.sin_port = htons(port); 
				sin.sin_addr.s_addr = inet_addr(address);
				
				CFDataRef dataConn = CFDataCreate(NULL, (unsigned char*)&sin, sizeof(sin));
				
				CFSocketError e = CFSocketConnectToAddress(m_socket, dataConn, TCP_TIME_OUT);
				CFRelease(dataConn);
				
				if(e != kCFSocketSuccess )
				{
					NDLog(@"CF connect server failed! address:%s	port:%d", address, port);
					m_connected = false;
				}
				else
				{
					NDLog(@"CF connect server success! address:%s	port:%d", address, port);
					m_connected = true;
				}
			}	
			return m_connected;
		}		
#else		
		m_socket->setServer(address, port, m_blocking);
		if (!m_blocking) 
		{
			m_socket->getConn().setTimeout(0);
			
			int keepAlive = 1;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_KEEPALIVE, (void*)&keepAlive, sizeof(keepAlive));	
			
			int nRecvBuf = 256 * 1024;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_RCVBUF, (const char*)&nRecvBuf, sizeof(int));
			
			int nSendBuf = 256 * 1024;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_SNDBUF, (const char*)&nSendBuf, sizeof(int));
			
			int connTimeOut = 30 * 1000;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_SNDTIMEO, (const char*)&connTimeOut, sizeof(int));			
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_RCVTIMEO, (const char*)&connTimeOut, sizeof(int));
			
			int	optval=1;
			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_NOSIGPIPE, (char *) &optval, sizeof(optval));
		}
		if (m_socket->connect()) 
		{		
			NDLog(@"connect server success! address:%s	port:%d", address, port);
			return true;
		}
		else 
		{
			NDLog(@"connect server failed! address:%s	port:%d", address, port);
			return false;
		}
#endif
	}
	
	bool NDSocket::Connected()
	{
#ifdef __USE_CFSOCKET__
		return m_connected;
#else
		return m_socket->getConn().isLive();
#endif
	}
	
	void NDSocket::Close()
	{
#ifdef __USE_CFSOCKET__		
		if (m_readStream) 
		{
			CFReadStreamClose(m_readStream);
			m_readStream = NULL;
		}
		if (m_writeStream) 
		{
			CFWriteStreamClose(m_writeStream);
			m_writeStream = NULL;
		}
		if (m_socket) 
		{
			CFSocketInvalidate(m_socket);
			CFRelease(m_socket);
			m_socket = NULL;
		}
		m_connected = false;
#else
		m_socket->close();
#endif
	}
    
    void NDSocket::ChangeCode(DWORD dwCode)
    {
        if(m_EncryptSnd)
        {
            m_EncryptSnd->ChangeCode(dwCode);
        }
    }
	
#ifdef __USE_CFSOCKET__
	void NDSocket::RunLoop()
	{
		if (!m_blocking) 
		{
			NDLog(@"CF start run loop......");
			CFRunLoopRef runLoopRef = CFRunLoopGetCurrent();		
			CFRunLoopSourceRef runLoopSourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, m_socket, 0);		
			CFRunLoopAddSource(runLoopRef, runLoopSourceRef, kCFRunLoopCommonModes);		
			CFRelease(runLoopSourceRef);		
			CFRunLoopRun();			
		}		
		else 
		{
			NDLog(@"CF not in blocking state!");
		}
	}
	
	void NDSocket::StopLoop()
	{
		Close();
		CFRunLoopStop(CFRunLoopGetCurrent());
	}	
	
#endif
	bool NDSocket::Receive(unsigned char* data, int& iReadedLen, int iReadLen/*=512*/)
	{
#ifdef __USE_CFSOCKET__
		if (m_blocking) 
		{
			iReadedLen = CFReadStreamRead(m_readStream, data, iReadLen);
			if (iReadedLen > 0) 
			{
#ifdef PROFILE_ENCRYPT_C2S
                if(this->m_EncryptRcv)
                    this->m_EncryptRcv->Decrypt(data, iReadedLen); // 解密封包
#endif
				//NDLog(@"CF read data success, readed len : %d", iReadedLen);
				return true;
			}
			else if (iReadedLen == 0)
			{
				NDLog(@"CF read data time out!");
				return false;
			}
			else 
			{
				NDLog(@"CF read data failed!");
				return false;
			}			
		}
		else 
		{
			NDLog(@"CF read data failed, because not in blocking state!");
			return false;
		}
#else
		if (!Connected()) 
		{
			NDLog(@"fail to connect server!");
			return false;
		}
		
		if (m_blocking) 
			iReadedLen = m_socket->getConn().readn(data, iReadLen, TCP_TIME_OUT);
		else 
			iReadedLen = m_socket->getConn().readn(data, iReadLen);
		if (iReadedLen == -1) 
		{
			NDLog(@"read data error, maybe the net not in work!");
			if (Connected()) 
			{
				Close();
				NDLog(@"close socket!");
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
#endif
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
        
#ifdef __USE_CFSOCKET__
		if (m_blocking)
		{
			if (!m_connected) 
			{
				NDLog(@"CF fail connect to server!");
				return false;
			}
			
			int ret = CFWriteStreamWrite(m_writeStream, data->GetBuffer(), data->GetSize());
			if (ret == -1) 
			{
				NDLog(@"CF send data failed! maybe the stream not in open state or fail to connect server!");				
			}
			else if (ret == 0)
			{
				NDLog(@"CF stream is filled! can't write , please hold on!");
				return false;
			}
			else
			{
				//NDLog(@"CF send data success! sended len : %d", ret);
				return true;
			}
		}
		else 
		{
			if (!m_connected) 
			{
				NDLog(@"CF fail connect to server!");
				return false;
			}
			
			CFDataRef cfData = CFDataCreate(NULL, data->GetBuffer(), data->GetSize());
			CFSocketError err = CFSocketSEND_DATA(m_socket, NULL, cfData, TCP_TIME_OUT);
			CFRelease(cfData);
			if (err == kCFSocketSuccess) 
			{
				//NDLog(@"CF send data success!");
				return true;
			}
			else 
			{
				return false;
			}
		}			
#else
		int ret;
		if (m_blocking) 
			ret = m_socket->getConn().writeData(data->GetBuffer(), data->GetSize(), TCP_TIME_OUT);
		else 
			ret = m_socket->getConn().writeData(data->GetBuffer(), data->GetSize());
		if (ret == -1) 
		{
			NDLog(@"fail to connect server!");
			return false;
		}
		else if (ret < usSize)
		{
			NDLog(@"write data time out, may be the net not in work!");
			if (Connected()) 
			{
				Close();
				NDLog(@"close socket!");
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
#endif
		return false;
	}
	
	bool NDSocket::DealReceivedData(const unsigned char* data, unsigned int dataLen)
	{
		if (NDMessageCenter::DefaultMessageCenter()->CanAddMessage()) 
		{			
			if (m_data.size() + dataLen > 1024 * 10) 
			{
				NDLog(@"error: message content len is bigger than 10240");
				return false;
			}				
			
			//add received to the data
			for (unsigned int i = 0; i < dataLen; i++) 
			{
				m_data.push_back(data[i]);
			}
			
			while (true) 
			{
				//the fist bit and the second bit are message check code 
				//the third bit and the forth bit are message len
				//so message len must be bigger than 4, otherwise continue to receive data
				if (m_data.size() < 4)
					break;
				
				//check package head
				if (0xff != m_data[0] || 0xfe != m_data[1]) 
				{
					NDLog(@"received message not match protocol of we defined!");
					m_data.clear();
					break;
				}
				
				//get message len 
				unsigned int msgLen = (m_data[2] & 0xff) + ((m_data[3] & 0xff) << 8);
				
				if (msgLen == 967)
				{
					NDLog(@"\nmsg len 967");
					int a = 0;
					a++;
					a++;
				}
				
				if (m_data.size() >= msgLen) 
				{
					if (msgLen == 967)
					{
						NDLog(@"\ndeal msg len 967");
						int a = 0;
						a++;
						a++;
					}
					//get the message
					NDTransData *message = new NDTransData;
					unsigned char* buf = &m_data[4];
					message->Write(buf, msgLen - 4);						
					NDMessageCenter::DefaultMessageCenter()->AddMessage(message);
					
					//remove message from data
					m_data.erase(m_data.begin(), m_data.begin() + msgLen);
				}
				else 
				{
					break;
				}
			}
			
			return true;
		}
		else 
		{
			NDLog(@"can't add message to message center, maybe the pool si filled!");
			return false;
		}
	}
	
}