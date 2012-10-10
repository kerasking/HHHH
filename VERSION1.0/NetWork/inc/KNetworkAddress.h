#ifndef __KT_NETWORKADDRESS_H
#define __KT_NETWORKADDRESS_H

#include <iostream>
#include <string>
//#include <netinet/in.h> // renshk
#include "KData.h"

#define IPV4_LENGTH 4

class KNetworkAddress
{
public:

	KNetworkAddress();
	
	KNetworkAddress( const KData& hostName, unsigned short port = 0 );
	
	void setHostName( const KData& theAddress );

	void setIp4Addr( unsigned int addr, unsigned short port=0 );
	
	void setPort( unsigned short port );
	
	KData getHostName() const;
	
	/// get IP address as a string in the form "192.168.4.5"
	KData getIpName() const;

	KData getPortName() const;

	KData getIpPortName() const;
	
	/** return the IP4 address packed as an unsigned int, in
	* network byte order. */
	unsigned int getIp4Address() const;

	/* return networkmask in network byte order */
	static unsigned int getNetmask();

	static KData getNetmaskName();

	static unsigned int m_netmask;
	
	/** return the address in a sockaddr.  This value is assigned
	* @param socka    returned address */
	void getSockAddr( struct sockaddr & socka ) const;
	
	unsigned short getPort() const;
	
	friend bool operator < ( const KNetworkAddress & xAddress, const KNetworkAddress & yAddress );

	friend bool operator == ( const KNetworkAddress & xAddress, const KNetworkAddress & yAddress );	
	
	friend bool operator!=( const KNetworkAddress & xAddress, const KNetworkAddress & yAddress );
	
	friend std::ostream & operator<< ( std::ostream & xStream, const KNetworkAddress& rxObj );
	
	KNetworkAddress& operator=( const KNetworkAddress& x );
	
	std::ostream & print( std::ostream & xStr ) const;

	bool isSameNetwork( const KNetworkAddress& dtIp );
	
	static bool is_valid_ip_addr( const KData& ip_addr, char* retaddr = NULL );

	bool isValid();

private:

	void initIpAddress() const;
	mutable char ipAddress[ IPV4_LENGTH ];  // it's in network byte order
	unsigned short aPort;
	KData rawHostName;
	mutable bool ipAddressSet;
};


inline std::ostream &
operator<< ( std::ostream & xStream, const KNetworkAddress& rxObj )
{
    return rxObj.print ( xStream );
}

#endif
