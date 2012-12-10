#ifndef __KT_TCP_CLINET_H
#define __KT_TCP_CLINET_H

//#include <netinet/in.h> // renshk
#include "KConnection.h"
#include "KData.h"

class KNetworkAddress;

class KTcpClientSocket
{

public:

	KTcpClientSocket( const KData& hostName, bool blocking = true );
	
	KTcpClientSocket( const KData& hostName, int servPort, bool blocking = true );
	
	KTcpClientSocket( const KNetworkAddress& server, bool blocking = true );
	
	KTcpClientSocket( const KTcpClientSocket& );
	
	KTcpClientSocket& operator=( KTcpClientSocket& other );

	KTcpClientSocket( bool blocking=true );
	
	~KTcpClientSocket();

	bool connect();

	void setServer( const KData& server, int serverPort=-1, bool blocking=true );

	void setServer( struct sockaddr, bool blocking=true );

	void close();
	void initSocket();
	inline KConnection& getConn()
	{
		return _conn;
	};

private:
	
	KConnection _conn;
	struct sockaddr _addr;
	KData _hostName;
	int _serverPort;
	bool _blocking;
	bool _bAddr;
};

#endif
