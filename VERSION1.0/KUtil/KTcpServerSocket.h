#ifndef __KT_TCP_SERVER_H
#define __KT_TCP_SERVER_H

#include <sys/socket.h>
#include <netinet/in.h>
#include "KConnection.h"

class KTcpServerSocket
{
public:
	KTcpServerSocket();

	KTcpServerSocket( const KTcpServerSocket& );
	
	KTcpServerSocket& operator=( KTcpServerSocket& other );

	virtual ~KTcpServerSocket();

	bool init( int servPort=-1, int lisQ=5 );

	/* Accept socket connection
	Return -1 if timeout or error */
	int accept( KConnection& con, int timeout = -1 );

	inline KConnection& getServerConn()
	{
		return m_serverConn;
	};

	short getServerPort();

private:
	KConnection m_serverConn;
	int m_listenQ;
	short m_srvPort;
};

#endif
