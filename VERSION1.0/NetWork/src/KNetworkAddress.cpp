#include <CCPlatformConfig.h>
#include <string>

#ifdef WIN32
#include <winsock2.h>
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h> 
#include <netdb.h>
#include <sys/param.h> 
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#endif


#include <iostream>
#include <cassert>
#include "KNetworkAddress.h"



unsigned int KNetworkAddress::m_netmask = 0;

KNetworkAddress::KNetworkAddress() : ipAddressSet( false )
{
	char hostname[256];
	memset(hostname, 0, 256);
#ifdef WIN32
	strcpy_s( hostname, "localhost" );
#elif defined(__IOS_PLATFORM__) || defined(__ANDROID_PALTFORM__)
	strcpy( hostname, "localhost" );
#endif
	
	setHostName( hostname );
    aPort = 0;
}


KNetworkAddress::KNetworkAddress( const KData& hostName, unsigned short port ) : ipAddressSet(false)
{
    setPort( port );
    setHostName( hostName );
}


void
KNetworkAddress::setHostName( const KData& theAddress )
{
    const char* cstrAddress;
    KData sAddress, sPort;
    unsigned int length = theAddress.length();
    unsigned int colonPos = length;
    cstrAddress = theAddress.getData();
    for ( int i = 0; *cstrAddress != '\0'; cstrAddress++, i++ )
    {
        if ( *cstrAddress == ':' )
        {
            colonPos = i;
            break;
        }
    }
    if ( colonPos != length )
    {
        sAddress = theAddress.substr( 0, colonPos );
        sPort = theAddress.substr( colonPos+1, length-colonPos-1 );
        colonPos = atoi( sPort.getData() );
        if ( colonPos )
        {
            aPort = colonPos;
        }
        else
        {
        }
    }
    else // No ':' in input string;
    {
        sAddress = theAddress;
    }
    rawHostName = sAddress;
    ipAddressSet = false;
}


void
KNetworkAddress::setIp4Addr( unsigned int addr, unsigned short port )
{
	memcpy( ipAddress, (void*)&addr, IPV4_LENGTH );
	aPort = port;
	ipAddressSet = true;	
}


void
KNetworkAddress::setPort( unsigned short iPort )
{
    aPort = iPort;
}


KData
KNetworkAddress::getHostName() const
{
    KData hostName;
    struct hostent * pxHostEnt = 0;
    initIpAddress();
    pxHostEnt = gethostbyaddr( ipAddress, IPV4_LENGTH, AF_INET );
    if ( pxHostEnt )
        hostName = pxHostEnt->h_name;
    else
        hostName = getIpName();
    return hostName;
}


KData
KNetworkAddress::getIpName() const
{
    KData ipName;
    struct in_addr temp;
    initIpAddress();
    memcpy( (void *)&temp.s_addr, ipAddress, IPV4_LENGTH );
    ipName = inet_ntoa( temp );
    return ipName;
}


KData
KNetworkAddress::getPortName() const
{
	return KData(aPort);
}


KData
KNetworkAddress::getIpPortName() const
{
	return (getIpName()+getPortName());
}


unsigned int
KNetworkAddress::getIp4Address() const
{
    unsigned int uiTmp;
    initIpAddress();
    memcpy( (void *) &uiTmp, ipAddress, IPV4_LENGTH );
    return uiTmp;
}


void
KNetworkAddress::getSockAddr( struct sockaddr& socka ) const
{
    short tmp_s = htons( aPort );
    char *tmp_p;
    tmp_p = (char*)&tmp_s;
    socka.sa_family = AF_INET;
    socka.sa_data[0] = tmp_p[0];
    socka.sa_data[1] = tmp_p[1];
    initIpAddress();
    memcpy( (void *)&socka.sa_data[2], ipAddress, IPV4_LENGTH );
    return ;
}


unsigned short
KNetworkAddress::getPort() const
{
    return aPort;
}


bool
operator < ( const KNetworkAddress & xAddress, const KNetworkAddress & yAddress )
{
    xAddress.initIpAddress();
    yAddress.initIpAddress();
    for (int i = 0 ; i <= IPV4_LENGTH; i++ )
    {
        if ( xAddress.ipAddress[i] < yAddress.ipAddress[i])
        {
            return true;
        }
        if ( xAddress.ipAddress[i] > yAddress.ipAddress[i])
        {
            return false;
        }
    }
    return xAddress.aPort < yAddress.aPort ;
}


bool
operator == ( const KNetworkAddress& xAddress, const KNetworkAddress& yAddress )
{
    xAddress.initIpAddress();
    yAddress.initIpAddress();
    for ( int i = 0 ; i < IPV4_LENGTH ; i++ )
    {
        if ( xAddress.ipAddress[i] != yAddress.ipAddress[i])
        {
            return false;
        }
    }
    return xAddress.aPort == yAddress.aPort ;
}


bool
operator != ( const KNetworkAddress& xAddress, const KNetworkAddress& yAddress )
{
    return !( xAddress == yAddress );
}


KNetworkAddress& 
KNetworkAddress::operator=( const KNetworkAddress& x )
{
	aPort = x.aPort;
    memcpy( this->ipAddress, x.ipAddress, sizeof(this->ipAddress) );
    ipAddressSet = x.ipAddressSet;
    rawHostName = x.rawHostName;
    return ( *this );
}


ostream&
KNetworkAddress::print( ostream& xStr ) const
{
    struct hostent * pxHostEnt;
    struct in_addr temp;
    initIpAddress();
    memcpy((void *)&temp.s_addr, ipAddress, IPV4_LENGTH);
    char * cpBuf = (char *)inet_ntoa(temp);
    pxHostEnt = gethostbyaddr( ipAddress, IPV4_LENGTH, AF_INET );

    if ( pxHostEnt )
    {
        xStr << pxHostEnt->h_name << "(" << cpBuf << ")";
    }
    else
    {
        xStr << cpBuf;
    }
    if ( aPort )
        xStr << ":" << aPort;

    return xStr;
}

bool
KNetworkAddress::isValid()
{
	return ipAddressSet;
}

void
KNetworkAddress::initIpAddress() const
{
    if ( !ipAddressSet )
    {
        if ( true == is_valid_ip_addr( rawHostName, ipAddress ) )
        {
            ipAddressSet = true;
        }
        else
        {
			struct hostent * pxHostEnt = 0;
			
			pxHostEnt = gethostbyname( rawHostName.getData() );
			if ( pxHostEnt == NULL )
			{
				return;
			}
			memcpy( (void *)&ipAddress, (void *)pxHostEnt->h_addr, pxHostEnt->h_length );
			ipAddressSet = true;
        }
    }
}


bool
KNetworkAddress::is_valid_ip_addr( const KData& addr, char* retaddr )
{
	unsigned long maskcheck = ~255;
	const char *advancer = addr.getData();
	unsigned long octet;
	char *nextchar;
	char ipAddr[ IPV4_LENGTH ];
	if ( ( *(advancer) == 0 ) || (*(advancer) == ' ') || (*(advancer) == '\t') )
	{	
		return false;
	}
	octet = strtoul( advancer, &nextchar, 10 );
	if( (*nextchar != '.') || (octet & maskcheck) || (octet == 0) )
	{
		return false;
	}
	assert( octet < 256 );
	ipAddr[0] = (char)octet;
	
	advancer = nextchar + 1;
	if( (*(advancer) == 0) || (*(advancer) == ' ') || (*(advancer) == '\t') )
	{
     	return false;
	}
	octet = strtoul( advancer, &nextchar, 10 );
	if( (*nextchar != '.') || (octet & maskcheck) )
	{
		return false;
	}
	assert( octet < 256 );
	ipAddr[1] = (char)octet;
	advancer = nextchar+1;
	if( (*(advancer) == 0) || (*(advancer) == ' ') || (*(advancer) == '\t') )
	{
		return false;
	}
	octet = strtoul(advancer, &nextchar, 10);
	if((*nextchar != '.') || (octet & maskcheck))
	{
		return false;
	}
	assert( octet < 256 );
	ipAddr[2] = (char)octet;
    advancer = nextchar+1;
    if ((*(advancer) == 0) || (*(advancer) == ' ') || (*(advancer) == '\t'))
    {
        return false;
    }
    octet = strtoul(advancer, &nextchar, 10);
    if ( (*nextchar) || (octet & maskcheck) || (octet == 0) )
    {	
        return false;
    }
	assert( octet < 256 );
    ipAddr[3] = (char)octet;
	
	if ( NULL != retaddr )
	{
		memcpy( retaddr, ipAddr, IPV4_LENGTH );
	}
    return true;
}

bool
KNetworkAddress::isSameNetwork( const KNetworkAddress& dtIp )
{
	unsigned int ipaddr1 = getIp4Address();
	unsigned int ipaddr2 = dtIp.getIp4Address();
	unsigned int netmask = getNetmask();
	if ( (ipaddr1 & netmask) == (ipaddr2 & netmask ) )
		return true;
	else
		return false;
}

unsigned int
KNetworkAddress::getNetmask()
{
	return 0;
}

KData
KNetworkAddress::getNetmaskName()
{
	unsigned int netmask = getNetmask();
	return KData( inet_ntoa( *((struct in_addr *)&netmask )) );
}
