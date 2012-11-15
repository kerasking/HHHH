#define _LIBCPP_FUNCTIONAL
#include <errno.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <stdio.h>

#include "KTcpServerSocket.h"


KTcpServerSocket::KTcpServerSocket()
{
	
}


bool KTcpServerSocket::init( int servPort, int lisQ )
{
	m_srvPort = -1;
	m_listenQ = lisQ;
	m_serverConn._connId = ::socket( AF_INET, SOCK_STREAM, 0 );
	if ( m_serverConn._connId < 0 )
	{
        return false;
    }
	m_serverConn.setState();
  
	int on = 1;
    if ( setsockopt ( m_serverConn._connId, SOL_SOCKET, SO_REUSEADDR, &on, sizeof( on ) ) )
    {
        return false;
    }
    
    memset( &m_serverConn._connAddr, 0, sizeof(m_serverConn._connAddr) );
	
	unsigned short minport = 1024, maxport = 65535;
	if ( servPort != -1 )
		minport = maxport = servPort;

	for ( short port=minport; port<=maxport; port++ )
	{
		m_serverConn._connAddr.sin_family = AF_INET;
		m_serverConn._connAddr.sin_addr.s_addr = htonl( INADDR_ANY );
		m_serverConn._connAddr.sin_port = htons( port );
		if ( bind( m_serverConn._connId, (SA*)&m_serverConn._connAddr, sizeof(m_serverConn._connAddr)) != 0 ) 
		{
			if (  port == maxport )
			{
				return false;	
			}
		}
		else
		{
			m_srvPort = port;
			break;
		}
	}
	if ( ::listen(m_serverConn._connId, m_listenQ) )
    {
		return false;
    }
	return true;
}

short KTcpServerSocket::getServerPort()
{
	return m_srvPort;
}

KTcpServerSocket::KTcpServerSocket( const KTcpServerSocket& other )
{
	m_serverConn = other.m_serverConn;
	m_listenQ = other.m_listenQ;
	m_srvPort = other.m_srvPort;
}


KTcpServerSocket&
KTcpServerSocket::operator=( KTcpServerSocket& other )
{
    if ( this != &other )
    {
		m_serverConn = other.m_serverConn;
		m_listenQ = other.m_listenQ;
		m_srvPort = other.m_srvPort;
    }
	return *this;
}

int
KTcpServerSocket::accept( KConnection& con, int timeout )
{
	if ( !m_serverConn.isReadReady( timeout ) )
		return -1;
	con.close();
    con._connAddrLen = sizeof( con._connAddr );
    if ( ( con._connId = ::accept(m_serverConn._connId,(SA*)&con._connAddr,&con._connAddrLen) ) < 0 )
    {
		return -1;
    }

    con._live = true;
    con.setState();
    return con._connId;
}


KTcpServerSocket::~KTcpServerSocket()
{

}
