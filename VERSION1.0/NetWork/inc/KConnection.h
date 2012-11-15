#ifndef __KT_CONNECTION_H
#define __KT_CONNECTION_H

#include <string.h>
#include <string>
#include <sys/types.h>

#ifdef WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#elif defined(TARGET_OS_IPHONE)
#include <sys/socket.h>
#include <sys/uio.h>
#include <netinet/in.h>
#endif

#include "KData.h"
#include "KMutex.h"


class KTcpServerSocket;
class KTcpClientSocket;

typedef struct sockaddr SA;
#define MAXLINE   256

class KConnection
{
public:
	KConnection( bool blocking = true )
	{
		_blocking = blocking;
		_connId = 0;
		useNum = NULL;
		_timeout = -1;
		_live = false;
		_connAddrLen = 0;
	}
	
	KConnection( int connId, bool blocking = true )
	{
		_connId = connId;
		_live = true;
		_connAddrLen = 0;
		_blocking = blocking;
		_timeout = -1;
		setState();
	}
	
	void setConnId( int connid )
	{
		_connId = connid;
		setState();
	}

	inline int getConnId() const
	{
		return _connId;
	}

	inline struct sockaddr_in getConnAddr() const
	{
		return _connAddr;
	}

	inline socklen_t getConnAddrLen() const
	{
		return _connAddrLen;
	}
	
	KConnection( const KConnection& other );

	virtual ~KConnection();
	
	KConnection& operator=( const KConnection& other );
	
	bool operator==( const KConnection& other )
	{
		return ( _connId == other._connId );
	}
	
	bool operator!=( const KConnection& other )
	{
		return ( _connId != other._connId );
	}
	
	int readLine( void* data, int maxlen, int timeout=-1 );
	
	/**Reads nchar from the connection.
	Returns 0 if timeout
	Returns -1 if connection is closed */
	int readData( void* data, int nchar, int &bytesRead, int timeout = -1 );


	int readn( void *data, int nchar, int timeout=-1 );
	
	/** Writes data to the connection
	Returns 0 if timeout
	Returns 1 if connection is closed **/
	int writeData( const void* data, int n, int timeout=-1 );
	
	int writeData( const string& data, int timeout=-1 );

	int writeData( const KData& data, int timeout=-1 );
	
	//Gets the connection description IP_ADDRESSS:Port
	string getDescription() const;
	
	///Gets the IP of the destination 
	string getIp() const;

	unsigned short getPort() const;
	
	inline bool isLive() const
	{
		return _live;
	}
	
	void close();

	static KMutex closeMutex;

	int* useNum;
	
	///Check if data is ready to be read within given seconds and microseconds
	bool isReadReady( int mSeconds=-1 ) const;
	bool isWriteReady( int mSeconds=500 ) const;
	void setBlocking( bool block = true );
	void setTimeout( int timeout );
	
private:
	int _timeout;
	void setState();
	friend class KTcpServerSocket;
	friend class KTcpClientSocket;
	int _connId;
	bool _live;
	socklen_t _connAddrLen;
	struct sockaddr_in _connAddr;
	bool _blocking;
};

#endif
