#include <errno.h>

#ifdef WIN32
#include <winsock2.h>
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#endif
#include <stdio.h>


#include "KTcpClientSocket.h"
#include "KNetworkAddress.h"

KTcpClientSocket::KTcpClientSocket( const KData& hostName, bool blocking )
					: _hostName( hostName ), _serverPort( -1 ), _blocking( blocking ), _bAddr(false)
{

}

KTcpClientSocket::KTcpClientSocket( bool blocking/*=true*/ )
						: _serverPort( -1 ), _blocking( blocking ), _bAddr(false)
{

}

KTcpClientSocket::KTcpClientSocket( const KData& hostName, int servPort, bool blocking )
								: _hostName( hostName ), _serverPort( servPort ), _blocking( blocking ),_bAddr(false)
{

}


KTcpClientSocket::KTcpClientSocket( const KNetworkAddress& server, bool blocking )
												: _blocking( blocking )
{
    _hostName = server.getHostName();
    _serverPort = server.getPort();
}


KTcpClientSocket::KTcpClientSocket( const KTcpClientSocket& other )
{
    _conn = other._conn;
	_hostName = other._hostName;
	_serverPort = other._serverPort;
	_blocking = other._blocking;
}


KTcpClientSocket&
KTcpClientSocket::operator=( KTcpClientSocket& other )
{
    if ( this != &other)
    {
        _conn = other._conn;
        _hostName = other._hostName;
        _serverPort = other._serverPort;
        _blocking = other._blocking;
    }
    return *this;
}


KTcpClientSocket::~KTcpClientSocket()
{
	close();
}


bool
KTcpClientSocket::connect()
{
	if ( _conn.isLive() )
	{
		return false;
	}
	int socketid = ::socket( AF_INET, SOCK_STREAM, 0 );
	if ( socketid == -1 )
	{
		return false;
	}

	memset( &_conn._connAddr, 0, sizeof(_conn._connAddr) );

	if ( _bAddr )
	{
		memcpy( &_conn._connAddr, &_addr, sizeof(sockaddr) );
	}
	else
	{
		KNetworkAddress na( _hostName, _serverPort );	
		_conn._connAddr.sin_family = AF_INET;
		_conn._connAddr.sin_addr.s_addr = inet_addr( na.getIpName() );
		_conn._connAddr.sin_port = htons( na.getPort() );
		if ( !na.isValid() )
		{
			return false;
		}
	}

	// 注释同步连接改成异步连接 jhzheng 2011 7.26
//	if ( ::connect( socketid, (SA*)&_conn._connAddr, sizeof(_conn._connAddr) ) < 0 )
//  {
//		::close( socketid );
//		return false;
//  }

	_conn._connId = socketid;
	_conn.setBlocking( false );

	if(::connect( socketid, (SA*)&_conn._connAddr, sizeof(_conn._connAddr) ) == -1)
	{
#ifdef WIN32
        if(WSAGetLastError() != WSAEWOULDBLOCK)
        {
            closesocket(socketid);
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
		if(errno != EINPROGRESS)
		{
			::close( socketid );
#endif
			return false;
		}

		timeval timeout;
		timeout.tv_sec	= 3;
		timeout.tv_usec	= 0;
		fd_set writeset, exceptset;
		FD_ZERO(&writeset);
		FD_ZERO(&exceptset);
		FD_SET(socketid, &writeset);
		FD_SET(socketid, &exceptset);
		
		int ret = select(FD_SETSIZE, NULL, &writeset, &exceptset, &timeout);
		if (ret == 0)
		{
#ifdef WIN32
            closesocket(socketid);
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
			::close( socketid );
#endif
			return false;
		}
		else if(ret < 0)
		{
#ifdef WIN32
            closesocket(socketid);
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
			::close( socketid );
#endif
			return false;
		}
		else
		{
			if(FD_ISSET(socketid, &exceptset))
			{
#ifdef  WIN32
                closesocket(socketid);
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
                ::close( socketid );
#endif
				return false;
			}
			
			int error = 0;
			socklen_t len = sizeof(error);
			if(getsockopt(socketid, SOL_SOCKET, SO_ERROR, (char*)&error, &len) < 0)
			{
#ifdef WIN32
                closesocket(socketid);
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
				::close( socketid );
#endif
				return false;
			}

#if defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
			if(error == ECONNREFUSED)
            {
//#ifdef WIN32
                //closesocket(socketid);

                ::close( socketid );

				return false;
			}
#endif
		}
	}
	
	
	_conn._connId = socketid;
	_conn.setBlocking( _blocking );
    _conn.setState();
	return true;
}


void
KTcpClientSocket::setServer( const KData& server, int serverPort, bool blocking )
{
	_bAddr = false;
	_hostName = server;
	_serverPort = serverPort;
	_blocking = blocking;
}

void
KTcpClientSocket::setServer( struct sockaddr addr, bool blocking )
{
	_bAddr = true;
	_addr = addr;
	_blocking = blocking;
}

void
KTcpClientSocket::close()
{
	_conn.close();
}
