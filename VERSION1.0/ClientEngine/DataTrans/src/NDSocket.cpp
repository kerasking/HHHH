/******************************************************************************
 *  FileName:		NDSocket.cpp
 *  Author:			Guosen
 *  Create Date:	2012-3-30
 *  
 *****************************************************************************/

#include "NDSocket.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#pragma comment(lib, "ws2_32.lib")
#endif  // CC_PLATFORM_WIN32

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <sys/signal.h>
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <netdb.h>
#define INVALID_SOCKET			(-1)
#define SOCKET_ERROR            (-1)
#endif  // CC_PLATFORM_IOS

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <netdb.h>
#define INVALID_SOCKET			(-1)
#define SOCKET_ERROR            (-1)
#endif  // CC_PLATFORM_ANDROID

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WOPHONE)
#endif  // CC_PLATFORM_WOPHONE

#if (CC_TARGET_PLATFORM == CC_PLATFORM_MARMALADE)
#endif  // CC_PLATFORM_MARMALADE

#if (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
#endif  // CC_PLATFORM_LINUX

#if (CC_TARGET_PLATFORM == CC_PLATFORM_BADA)
#endif  // CC_PLATFORM_BADA

#if (CC_TARGET_PLATFORM == CC_PLATFORM_QNX)
#endif // CC_PLATFORM_QNX\


//////////////////////////////////////////////////////////////////////////

namespace NDEngine
{

#define TCP_TIME_OUT 30 * 1000


	IMPLEMENT_CLASS(NDSocket, NDObject)
		
//===========================================================================
	NDSocket::NDSocket()
	{
		m_bBlocking = false;
		m_bConnected = false;
	}

	NDSocket::~NDSocket()
	{
		Close();
	}
	
//===========================================================================
	bool NDSocket::Connect( const char* address, unsigned short port, bool blocking )
	{
		m_bBlocking = blocking;
		m_szIPAddress = address;
		m_port = port;
		if ( !StartupSocketLib() )
		{
			return false;
		}

		m_iSocket = ::socket( AF_INET, SOCK_STREAM, IPPROTO_IP );
		if( m_iSocket == INVALID_SOCKET )
		{
			CloseSocket( m_iSocket );
			return false;
		}

		int	keepAlive = 1;
		::setsockopt( m_iSocket, SOL_SOCKET, SO_KEEPALIVE, (char*)&keepAlive, sizeof(keepAlive) );

		int nSndBuf = 256 * 1024;
		if ( ::setsockopt( m_iSocket, SOL_SOCKET, SO_SNDBUF, (char*) &nSndBuf, sizeof(nSndBuf)) )
		{
			CloseSocket( m_iSocket );
			return false;
		}

		int nRcvBuf = 256 * 1024;
		if ( ::setsockopt( m_iSocket, SOL_SOCKET, SO_RCVBUF, (char*) &nRcvBuf, sizeof(nRcvBuf)) )
		{
			CloseSocket( m_iSocket );
			return false;
		}

		if ( !m_bBlocking )
		{
			SetSocketNotBlock( m_iSocket );
		}

		//
		unsigned int unAddr = ::inet_addr( m_szIPAddress.c_str() );			// 必须为 UINT, 以便与in_addr兼容
		if(unAddr == INADDR_NONE)
		{
			hostent* hp = NULL;
			hp = ::gethostbyname( m_szIPAddress.c_str() );
			if(hp == NULL)
			{
				cocos2d::CCLog( "Error: Get host by name[%s] failed!\n", m_szIPAddress.c_str() );
				return false;
			}

			struct in_addr* pAddr = (in_addr*)hp->h_addr;
			unAddr = (unsigned int)pAddr->s_addr;
		}
		sockaddr_in	addr_in;
		::memset((void *)&addr_in, 0, sizeof(addr_in));
		addr_in.sin_family = AF_INET;
		addr_in.sin_addr.s_addr = unAddr;
		addr_in.sin_port = htons( m_port );
		if ( ::connect( m_iSocket, (sockaddr*)&addr_in, sizeof(addr_in)) != 0 )
		{
			struct timeval _timeval;
			_timeval.tv_sec = 3;  // 检测时间3秒
			_timeval.tv_usec = 0;

			fd_set fdsWrite;
			FD_ZERO( &fdsWrite );
			FD_SET( m_iSocket, &fdsWrite );

			if( select( m_iSocket+1, NULL, &fdsWrite, NULL, &_timeval ) <= 0 )
			{
				int error;
				int size = sizeof(error);
				//::getsockopt( m_ClientSocket, SOL_SOCKET, SO_ERROR, (char*)&error, (socklen_t*)&size ); 
				::getsockopt( m_iSocket, SOL_SOCKET, SO_ERROR, (char*)&error, (int*)&size ); 
				if( error != 0 )
				{
					cocos2d::CCLog( "Error: connect to %s:%d failed!\n", m_szIPAddress.c_str(), m_port );
					return false;
				}
			}
		}
		m_bConnected = true;
		return true;
	}		

//		{
// 		m_bBlocking = blocking;
// 		m_szIPAddress = address;
// 		m_port = port;
// 		//m_socket->setServer(address, port, m_blocking);	//?????????????????????????
// 		if (!m_blocking) 
// 		{
// 			//m_socket->getConn().setTimeout(0);	//?????????????????????????
// 
// 			int keepAlive = 1;
// 			::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_KEEPALIVE, (void*)&keepAlive, sizeof(keepAlive));	//?????????????????????????
// 
// 			int nRecvBuf = 256 * 1024;
// 			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_RCVBUF, (const char*)&nRecvBuf, sizeof(int));	//?????????????????????????
// 
// 			int nSendBuf = 256 * 1024;
// 			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_SNDBUF, (const char*)&nSendBuf, sizeof(int));	//?????????????????????????
// 
// 			int connTimeOut = 30 * 1000;
// 			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_SNDTIMEO, (const char*)&connTimeOut, sizeof(int));	//?????????????????????????		
// 			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_RCVTIMEO, (const char*)&connTimeOut, sizeof(int));	//?????????????????????????
// 
// 			int	optval=1;
// 			//::setsockopt(m_socket->getConn().getConnId(), SOL_SOCKET, SO_NOSIGPIPE, (char *) &optval, sizeof(optval));	//????????????????????????? ios socket
// 		}
//		m_pSocket->Init();
//		//if (m_socket->connect()) 	//?????????????????????????
//		if ( m_pSocket->ConectTo( m_address.c_str(), m_port ) )
//		{		
//			//NDLog("connect server success! address:%s	port:%d", address, port);
//			cocos2d::CCLog( "connect server success! address:%s	port:%d", address, port );
//			return true;
//		}
//		else
//		{
//			//NDLog("connect server failed! address:%s	port:%d", address, port);
//			cocos2d::CCLog( "connect server failed! address:%s	port:%d", address, port );
//			return false;
//		}

// 		//== win32 socket 测试 ==//
// 		WSADATA  Ws;
// 		SOCKET CientSocket;
// 		struct sockaddr_in ServerAddr;
// 		int Ret = 0;
// 		int AddrLen = 0;
// 		HANDLE hThread = NULL;
// 		char SendBuffer[MAX_PATH];
// 
// 		//Init Windows Socket
// 		if ( WSAStartup(MAKEWORD(2,2), &Ws) != 0 )
// 		{
// 			cocos2d::CCLog( "Init Windows Socket Failed:%d", GetLastError() );
// 			return false;
// 		}
// 
// 		//Create Socket
// 		CientSocket = socket( AF_INET, SOCK_STREAM, IPPROTO_IP );
// 		if ( CientSocket == INVALID_SOCKET )
// 		{
// 			cocos2d::CCLog( "Create Socket Failed:%d", GetLastError() );
// 			return false;
// 		}
// 
// 		ServerAddr.sin_family = AF_INET;
// 		ServerAddr.sin_addr.s_addr = inet_addr( m_szIPAddress.c_str() );
// 		ServerAddr.sin_port = htons(port);
// 		memset(ServerAddr.sin_zero, 0x00, 8);
// 
// 		Ret = connect( CientSocket,(struct sockaddr*)&ServerAddr, sizeof(ServerAddr) );
// 		if ( Ret == SOCKET_ERROR )
// 		{
// 			cocos2d::CCLog( "Connect Error:%d", GetLastError() );
// 			return false;
// 		}
// 		else
// 		{
// 			cocos2d::CCLog( "connect server success! address:%s	port:%d", address, port );
// 			return true;
// 		}
//	}

//===========================================================================
	void NDSocket::Close()
	{
		m_bConnected = false;
		CloseSocket( m_iSocket );
		ClearupSocketLib();
	}
	
//===========================================================================
	bool NDSocket::Receive(unsigned char* data, int& iReadedLen, int iReadLen/*=512*/)
	{
		if ( !IsConnected() ) 
		{
			cocos2d::CCLog( "fail to connect server!" );
			return false;
		}
		
		//if (m_blocking)	//?????????????????????????
		//	iReadedLen = m_socket->getConn().readn(data, iReadLen, TCP_TIME_OUT);
		//else 
		//	iReadedLen = m_socket->getConn().readn(data, iReadLen);
		iReadedLen = Recv( (char *)data, iReadLen );
		if ( iReadedLen == SOCKET_ERROR ) 
		{
			cocos2d::CCLog( "read data error, maybe the net not in work!" );
			if ( IsConnected() ) 
			{
				Close();
				cocos2d::CCLog( "close socket!" );
			}
			return false;
		}
		else 
		{
			if ( iReadedLen > 0 ) 
			{
				cocos2d::CCLog( "read data success, readed len : %d", iReadedLen );		
			}				
			return true;
		}
	}

//===========================================================================
	int NDSocket::Recv( char* pBuffer, int nLen )
	{
		//使用select机制减少空转recv的开销
		fd_set	fdsRead;
		FD_ZERO( &fdsRead );
		FD_SET( m_iSocket, &fdsRead );
		struct timeval stTimeout = { 0, TCP_TIME_OUT };

		int ret = select( m_iSocket+1, &fdsRead, NULL, NULL, &stTimeout );
		switch(ret)
		{
		case -1:
			break;
		case 0:
			break;
		default:
			{
				if( FD_ISSET( m_iSocket, &fdsRead ) )
				{
					int lenRecv = ::recv( m_iSocket, pBuffer, nLen, 0 );
					if(lenRecv == SOCKET_ERROR)
					{
						int err;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
						err = ::GetLastError();

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
						err = errno;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
						err = errno;

#endif
						if( (err==EINTR) || (err==EAGAIN) )
						{
							ret = 0;
						}
						else
						{
							ret = SOCKET_ERROR;
						}
					}
					else if(lenRecv == 0)
					{
						ret = SOCKET_ERROR;
					}
					else
					{
						ret = lenRecv;
					}
				}
				else
				{
					ret = SOCKET_ERROR;
				}
			}
			break;
		}
		return ret;
	}
	
//===========================================================================
	bool NDSocket::Send( NDTransData* data )
	{
		int ret;
		//if (m_blocking)	//?????????????????????????
		//	ret = m_socket->getConn().writeData(data->GetBuffer(), data->GetSize(), TCP_TIME_OUT);
		//else 
		//	ret = m_socket->getConn().writeData(data->GetBuffer(), data->GetSize());
		ret = ::send( m_iSocket, (const char *)data->GetBuffer(), data->GetSize(), 0 );
		if ( ret == SOCKET_ERROR ) 
		{
			cocos2d::CCLog( "fail to connect server!" );
			return false;
		}
		else if ( ret < data->GetSize() )
		{
			cocos2d::CCLog( "write data time out, may be the net not in work!" );
			if ( IsConnected() ) 
			{
				Close();
				cocos2d::CCLog( "close socket!" );
			}
			return false;
		}
		else if ( ret > 1024 )
		{
			return true;
		}
		else 
		{
			cocos2d::CCLog( "write data success, writed len : %d", data->GetSize() );
			return true;
		}
		return false;
	}
	
//===========================================================================
//
	bool NDSocket::StartupSocketLib()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

		WSADATA	wsaData;
		WORD    wVersionRequested= MAKEWORD( 2, 0 );
		int ret = ::WSAStartup(wVersionRequested, &wsaData);
		if (ret != 0)
		{
			return false;
		}
		if (LOBYTE(wsaData.wVersion) != 0x02 || HIBYTE(wsaData.wVersion) != 0x00)
		{
			return false;
		}
		return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		return true;

#endif
	}
	
//===========================================================================
	bool NDSocket::ClearupSocketLib()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		::WSACleanup();
		return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		return true;

#endif
	}
	
//===========================================================================
	bool NDSocket::SetSocketNotBlock( unsigned int sock )
	{
		int	iConnTimeOut = 30 * 1000;
		::setsockopt( m_iSocket, SOL_SOCKET, SO_SNDTIMEO, (const char*)&iConnTimeOut, sizeof(int) );			
		::setsockopt( m_iSocket, SOL_SOCKET, SO_RCVTIMEO, (const char*)&iConnTimeOut, sizeof(int) );

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		unsigned long arg = 1;
		if (::ioctlsocket(sock, FIONBIO, &arg))
		{
			return false;
		}
		return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		unsigned long arg = 1;
		if (::ioctl(sock, FIONBIO, &arg, 1))
		{
			return false;
		}
		return true;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		unsigned long arg = 1;
		if (::ioctl(sock, FIONBIO, &arg, 1))
		{
			return false;
		}
		return true;

#endif

	}
	
//===========================================================================
	int NDSocket::CloseSocket( int sock )
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		return ::closesocket(sock);

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		return ::close(sock);

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		return ::close(sock);

#endif
	}

	
//===========================================================================
// 	bool NDSocket::DealReceivedData(const unsigned char* data, unsigned int dataLen)
// 	{
// 		if (NDMessageCenter::DefaultMessageCenter()->CanAddMessage()) 
// 		{			
// 			if (m_data.size() + dataLen > 1024 * 10) 
// 			{
// 				NDLog("error: message content len is bigger than 10240");
// 				return false;
// 			}				
// 
// 			//add received to the data
// 			for (unsigned int i = 0; i < dataLen; i++) 
// 			{
// 				m_data.push_back(data[i]);
// 			}
// 
// 			while (true) 
// 			{
// 				//the fist bit and the second bit are message check code 
// 				//the third bit and the forth bit are message len
// 				//so message len must be bigger than 4, otherwise continue to receive data
// 				if (m_data.size() < 4)
// 					break;
// 
// 				//check package head
// 				if (0xff != m_data[0] || 0xfe != m_data[1]) 
// 				{
// 					NDLog("received message not match protocol of we defined!");
// 					m_data.clear();
// 					break;
// 				}
// 
// 				//get message len 
// 				unsigned int msgLen = (m_data[2] & 0xff) + ((m_data[3] & 0xff) << 8);
// 
// 				if (msgLen == 967)
// 				{
// 					NDLog("\nmsg len 967");
// 					int a = 0;
// 					a++;
// 					a++;
// 				}
// 
// 				if (m_data.size() >= msgLen) 
// 				{
// 					if (msgLen == 967)
// 					{
// 						NDLog("\ndeal msg len 967");
// 						int a = 0;
// 						a++;
// 						a++;
// 					}
// 					//get the message
// 					NDTransData *message = new NDTransData;
// 					unsigned char* buf = &m_data[4];
// 					message->Write(buf, msgLen - 4);						
// 					NDMessageCenter::DefaultMessageCenter()->AddMessage(message);
// 
// 					//remove message from data
// 					m_data.erase(m_data.begin(), m_data.begin() + msgLen);
// 				}
// 				else 
// 				{
// 					break;
// 				}
// 			}
// 
// 			return true;
// 		}
// 		else 
// 		{
// 			NDLog("can't add message to message center, maybe the pool si filled!");
// 			return false;
// 		}
// 	}

}
