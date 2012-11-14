#define _LIBCPP_FUNCTIONAL
#include <fstream>
#include <assert.h>
#include <errno.h>
#include <iostream>
#include <stdio.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>
#include "KUdpStack.h"




KUdpStack::KUdpStack()
{
	
}

bool KUdpStack::init( const KNetworkAddress* pDesHost, int minPort, int maxPort, bool block, KUdpMode udpMode, bool isMulticast )
{
	localPort = -1;
	numBytesReceived = 0;
	numPacketsReceived = 0;
	numBytesTransmitted = 0;
	numPacketsTransmitted = 0;
	_block = block;
	mode = udpMode;
    _socketFd = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
    if ( _socketFd < 0 )
        return false;
    
	setBlock( _block );

    int buf1 = 1;
    int len1 = sizeof( buf1 );
    
	#ifdef __linux__
    struct protoent *protoent;
    protoent = getprotobyname( "icmp" );
    if ( !protoent )
    {
        fprintf( stderr, "Cannot get icmp protocol\n" );
    }
    else
    {
        if ( setsockopt( _socketFd, protoent->p_proto, SO_BSDCOMPAT, (char*)&buf1, len1) == -1 )
        {
            fprintf( stderr, "setsockopt error SO_BSDCOMPAT :%s\n", strerror(errno) );
        }
    }
	#endif
    if ( isMulticast )
    {
        // set option to get rid of the "Address already in use" error
        if ( setsockopt( _socketFd, SOL_SOCKET, SO_REUSEADDR, (char*)&buf1, len1 ) == -1 )
        {
            fprintf( stderr, "setsockopt error SO_REUSEADDR :%s", strerror(errno) );
        }
    }

    // set up addresses
    memset( (void*)&(_localAddr), 0, sizeof( _localAddr ) );
    ( _localAddr ).sin_family = AF_INET;
    ( _localAddr ).sin_addr.s_addr = htonl( INADDR_ANY );

    memset( (void*)&(_remoteAddr), 0, sizeof(_remoteAddr) );
    _remoteAddr.sin_family = AF_INET;
    _remoteAddr.sin_addr.s_addr = htonl( INADDR_ANY );

	bool bVal = true;
    switch ( mode )
    {
	case inactive :
		if ( pDesHost )
			bVal = doClient( *pDesHost );
        break;
	case sendonly :			//∑¢ÀÕƒ£ Ω
		if ( pDesHost )
			bVal = doClient( *pDesHost );
        break;
	case recvonly:			//Ω” ’ƒ£ Ω
		bVal = doServer( minPort, maxPort );
		if ( bVal && pDesHost )
			doClient( *pDesHost );
        break;
	case sendrecv:			//∑¢ÀÕΩ” ‹ƒ£ Ω
		bVal = doServer( minPort, maxPort );
		if ( bVal && pDesHost )
			doClient( *pDesHost );
        break;
	default :
        break;
    }

	if ( !bVal )
	{
		close();
		return false;
	}
	else
	{
		return true;
	}
}

///¥”ø™ ºµΩΩ· ¯∂Àø⁄≤È’“ø…”√∂Àø⁄≤¢∞Û∂®º‡Ã˝
bool
KUdpStack::doServer( int minPort, int maxPort )
{
    if ( ( minPort == -1 ) && ( maxPort == -1 ) )
    {
        minPort = 1024;
        maxPort = 65534;
    }
    if ( maxPort == -1 )
        maxPort = minPort;

    int portOk = false;
    int err = 0;
    for ( localPort = minPort; localPort <= maxPort; localPort++ )
    {
        _localAddr.sin_port = htons( (unsigned short)localPort );
        if ( bind( _socketFd, (struct sockaddr*)&_localAddr, sizeof(_localAddr) ) != 0 )
        {
            err = errno;
            if ( err == EADDRINUSE )
                continue;
			return false;
        }
        else
        {
			portOk = true;
			break;
        }
    }
    if ( !portOk )
    {
        localPort = -1;
        return false;
    }
	return true;
}


bool
KUdpStack::doClient( const KNetworkAddress& desHost )
{
	_remoteAddr.sin_addr.s_addr = desHost.getIp4Address();
    _remoteAddr.sin_port = htons( desHost.getPort() );
	if ( connect( _socketFd, (struct sockaddr*)&_remoteAddr, sizeof(sockaddr) ) != 0 )
	{
		//cpLog( LOG_ERR, "KUdpStack during socket connect %s", strerror(errno) );
		return false;
	}
	return true;
}



KNetworkAddress
KUdpStack::getDestinationHost() const
{
    KNetworkAddress desHost;
	desHost.setIp4Addr( _remoteAddr.sin_addr.s_addr, ntohs(_remoteAddr.sin_port) );
    return desHost;
}

KNetworkAddress
KUdpStack::getLocalHost() const
{
	struct sockaddr_in addr;
	int len = sizeof( sockaddr_in );
	getsockname( _socketFd, (sockaddr*)&addr, (socklen_t*)&len );
	KNetworkAddress tarAddr;
	tarAddr.setIp4Addr( addr.sin_addr.s_addr, ntohs(addr.sin_port) );
	return tarAddr;
}


int
KUdpStack::getSocketFD ()
{
    return _socketFd;
}

void
KUdpStack::addToFdSet( fd_set* set )
{
    assert(set);
    FD_SET( _socketFd, set );
}


int
KUdpStack::getMaxFD ( int prevMax )
{
    return ( getSocketFD() > prevMax ) ? getSocketFD() : prevMax;
}


bool
KUdpStack::checkIfSet( fd_set* set )
{
    assert(set);
    return FD_ISSET( _socketFd, set ) != 0;
}


void
KUdpStack::close()
{
	::close( _socketFd );
	_socketFd = -1;
	localPort = -1;
}


KUdpMode
KUdpStack::getMode ()
{
	return mode;
};

void
KUdpStack::setMode ( const KUdpMode theMode )
{
	mode = theMode;
};

unsigned short
KUdpStack::getLocalPort()
{
	return localPort;
};

unsigned short
KUdpStack::getDestinationPort()
{
	return ntohs( _remoteAddr.sin_port );
};

int
KUdpStack::receive( const void* buf, const int bufSize, long millsecond )
{
    if ( (mode==sendonly) || (mode==inactive) )
    {
        return -1;
    }
	if ( !isReadReady( millsecond ) )
		return 0;
    int len = recv( _socketFd, (char *)buf, bufSize, 0 );
    if ( len <= 0 )
    {
		return -1;
    }
    else
    {
        numBytesReceived += len;
        numPacketsReceived += 1;
		return len;
    }
}


int
KUdpStack::receiveFrom( const void* buffer, const int bufSize, KNetworkAddress* sender, long millsecond )
{
    if ( (mode==sendonly) || (mode==inactive) )
    {
        return -1;
    }
    KData hostname;
    struct sockaddr_in addr;
    int addrLen = sizeof( addr );
	if ( !isReadReady( millsecond ) )
		return 0;
    int len = recvfrom( _socketFd, (char *)buffer, bufSize, 0, (struct sockaddr*)&addr, (socklen_t*)&addrLen );
    if ( len <= 0 )
    {
		return -1;
    }
    else
    {
		if ( NULL != sender )
			sender->setIp4Addr( addr.sin_addr.s_addr, ntohs( addr.sin_port ) );
        numBytesReceived += len;
        numPacketsReceived += 1;
		return len;
    }
}


int
KUdpStack::receiveFrom( const void* buffer, const int bufSize, sockaddr_in* sender, long millsecond )
{
    if ( (mode==sendonly) || (mode==inactive) )
    {
        return -1;
    }
    unsigned int lenSrc = sizeof( sockaddr_in );
	if ( !isReadReady( millsecond ) )
		return 0;
    int len = recvfrom( _socketFd, (char *)buffer, bufSize, 0,
                         	(sockaddr*)sender, (socklen_t *)&lenSrc );
    if ( len <= 0 )
    {
		return -1;
    }
    else
    {
        numBytesReceived += len;
        numPacketsReceived += 1;
		return len;
    }
}


/** uses send() which is better to get ICMP msg back
 function returns a 0  normally **/
int
KUdpStack::transmit( const void* buffer, const int length, long millsecond )
{
    if ( (mode==recvonly) || (mode==inactive) )
    {
        return 0;
    }
    assert( buffer );
    assert( length > 0 );
	if ( !isWriteReady( millsecond ) )
		return 0;
    int count = send( _socketFd,(char *)buffer, length, 0 );
    if ( count < 0 )
    {
        int err = errno;
        switch ( err )
        {
            case ECONNREFUSED:
				break;
            case EHOSTDOWN:
				break;
            case EHOSTUNREACH:
				break;
            default:
				break;
        }
		return -1;
    }
    else
    {
        numBytesTransmitted += count;
        numPacketsTransmitted += 1;
		return count;
    }
}

int
KUdpStack::transmitTo( const void* buffer, const int length, const KNetworkAddress dest, long millsecond )
{
    if ( (mode==recvonly) || (mode==inactive) )
    {
        return 0;
    }
    assert( buffer );
    assert( length > 0 );

	if ( !isWriteReady( millsecond ) )
		return 0;  

    struct sockaddr_in addrDest;
    addrDest.sin_family = AF_INET;
    addrDest.sin_port = htons( dest.getPort() );
    addrDest.sin_addr.s_addr = dest.getIp4Address();
    int count = sendto( _socketFd, (char*)buffer, length, 0, (struct sockaddr*)&addrDest, sizeof(sockaddr_in) );
    if ( count < 0 )
    {
        int err = errno;
        KData errMsg = "KUdpStack transmit err :";
        switch ( err )
        {
		case ECONNREFUSED:
	        // This is the most common error - you get it if the host
		    // does not exist or is nor running a program to recevice
			// the packets. This is what you get with the other side
			// crashes.
			errMsg  += "UdConnection refused by destination host";
			break;
		case EHOSTDOWN:
			errMsg += "destination host is down";
			break;
		case EHOSTUNREACH:
			errMsg += "no route to to destination host";
			break;
		default:
			errMsg += strerror( err );
			break;
        }
		return -1;
    }
	else
	{
		if ( count != length )
		{
			KData errMsg = "KUdpStack transmit err :";
		}
		numBytesTransmitted += count;
        numPacketsTransmitted += 1;
		return count;
    }
}

int
KUdpStack::transmitTo( const void* buffer, const int length, const sockaddr_in dest, long millsecond )
{
	if ( (mode==recvonly) || (mode==inactive) )
    {
        return 0;
    }
    assert( buffer );
    assert( length > 0 );

	if ( !isWriteReady( millsecond ) )
		return 0;

    int count = sendto( _socketFd, (char*)buffer, length, 0, (struct sockaddr*)&dest, sizeof(sockaddr_in) );
    if ( count < 0 )
    {
        int err = errno;
        KData errMsg = "KUdpStack transmit err :";
        switch ( err )
        {
		case ECONNREFUSED:
	        // This is the most common error - you get it if the host
			// does not exist or is nor running a program to recevice
		    // the packets. This is what you get with the other side
			// crashes.
			errMsg  += "UdConnection refused by destination host";
            break;
		case EHOSTDOWN:
			errMsg += "destination host is down";
            break;
		case EHOSTUNREACH:
			errMsg += "no route to to destination host";
			return 3;
			break;
		default:
			errMsg += strerror( err );
			break;
        }
		return -1;
    }
	else
	{
		if ( count != length )
		{
			KData errMsg = "KUdpStack transmit err :";
		}
		numBytesTransmitted += count;
        numPacketsTransmitted += 1;
		return count;
    }
}


void
KUdpStack::setBlock( bool bBlock )
{
	if ( bBlock )
	{
		int flags;
		if( ( flags = fcntl( _socketFd, F_GETFL, 0 ) ) < 0 )
			return;
		flags &= ~O_NONBLOCK;
		fcntl( _socketFd, F_SETFL, flags );
	}
	else
	{
		int flags;
		if( ( flags = fcntl( _socketFd, F_GETFL, 0 ) ) < 0 )
			return;
		flags |= O_NONBLOCK;
		fcntl( _socketFd, F_SETFL, flags );
	}
}


void KUdpStack::joinMulticastGroup( KNetworkAddress group, KNetworkAddress* iface, int ifaceInexe )
{
	struct ip_mreq mreq;
    mreq.imr_multiaddr.s_addr = group.getIp4Address();
    mreq.imr_interface.s_addr = iface->getIp4Address();
    int ret;
    ret = setsockopt( getSocketFD(), IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*) & mreq, sizeof(struct ip_mreq) );
}


void KUdpStack::leaveMulticastGroup( KNetworkAddress group, KNetworkAddress* iface, int ifaceInexe )
{
	struct ip_mreq mreq;
    mreq.imr_multiaddr.s_addr = group.getIp4Address();
    mreq.imr_interface.s_addr = iface->getIp4Address();
    setsockopt( getSocketFD(), IPPROTO_IP, IP_DROP_MEMBERSHIP,
			   
			   (char*)&mreq, sizeof(struct ip_mreq) );
}

bool
KUdpStack::isReadReady( int mSeconds ) const
{
    fd_set rfds;
    struct timeval tv;
	struct timeval *ptv;
    int retval;
	FD_ZERO( &rfds );
	FD_SET( _socketFd, &rfds );
	if ( mSeconds < 0 )
	{
		ptv = NULL;
	}
	else
	{
		ptv = &tv;
		tv.tv_sec = mSeconds/1000;
		tv.tv_usec = ( mSeconds%1000 ) * 1000;
	}
    retval = select( _socketFd+1, &rfds, NULL, NULL, ptv );
    if ( retval > 0 && FD_ISSET( _socketFd, &rfds ) )
    {
        return true;
    }
	else
	{
		return false;
	}
}

bool
KUdpStack::isWriteReady( int mSeconds ) const
{
    fd_set wfds;
    struct timeval tv;
	struct timeval *ptv;
    int retval;
    FD_ZERO( &wfds );
    FD_SET( _socketFd, &wfds );
	if ( mSeconds < 0 )
	{
		ptv = NULL;
	}
	else
	{
		ptv = &tv;
		tv.tv_sec = mSeconds/1000;
		tv.tv_usec = (mSeconds%1000)*1000;
	}
    retval = select( _socketFd+1, NULL, &wfds, NULL, ptv );
    if ( retval > 0 && FD_ISSET( _socketFd, &wfds ) )
    {
        return true;
    }
    return false;
}


KUdpStack::~KUdpStack()
{
	close();
}


int
KUdpStack::getBytesReceived ()
{
    return numBytesReceived;
}

int
KUdpStack::getPacketsReceived ()
{
    return numPacketsReceived;
}

int
KUdpStack::getBytesTransmitted ()
{
    return numBytesTransmitted;
}

int
KUdpStack::getPacketsTransmitted ()
{
    return numPacketsTransmitted;
}
