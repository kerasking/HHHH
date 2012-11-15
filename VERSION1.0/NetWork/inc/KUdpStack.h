#ifndef __KT_UDPSTACK_H
#define __KT_UDPSTACK_H

#include <fstream>
#include <string>
#include <assert.h>
//#include <sys/select.h> // renshk
#include "KNetworkAddress.h"
#include "KFile.h"
#include "KMutex.h"
#if defined(TARGET_OS_IPHONE) || defined(__ANDROID_PALTFORM__)
#include <sys/_select.h> // renshk
#include <netinet/in.h>
#endif

template < class T >
class Sptr
{
private:
	mutable  T* ptr;
	mutable int* count;
	mutable KMutex* mutex;
	
	void increment()
	{
		if( ptr )
		{
			if( !count )
			{
				count = new int( 0 );
			}
			if( !mutex )
			{
				mutex = new KMutex;
			}
			mutex->lock();
			(*count)++;
			mutex->unlock();
		}
	}
	
	void decrement()
	{
		if( ptr && count )
		{
			bool countIsZero;
			mutex->lock();
			(*count)--;
			countIsZero = ( *count == 0 );
			mutex->unlock();
			if( countIsZero )
			{
				delete ptr; ptr = 0;
				delete count; count = 0;
				delete mutex; mutex = 0;
			}
		}
		ptr = 0;
		count = 0;
		mutex = 0;
	}
	
public:
	template < class T2 >
	operator Sptr<T2 > () 
	{
		return Sptr<T2>( ptr, count, mutex );
	}
	
	template < class T2 >
	operator const Sptr<T2 > () const
	{
		return Sptr < T2 >( ptr, count, mutex );
	}
	
	Sptr() : ptr( 0 ), count( 0 ), mutex( 0 )
	{ };
	
	Sptr( T* original, int* myCount = 0, KMutex* myMutex = 0 )
	: ptr( original ), count( myCount ), mutex( myMutex )
	{
		if( ptr )
		{
			increment();
		}
	};
	
	Sptr( const Sptr& x ) : ptr( x.ptr ), count( x.count ), mutex( x.mutex )
	{
		increment();
	};
	
	~Sptr()
	{
		{
			decrement();
		}
	}
	
	T& operator*() const
	{
		assert( ptr );
		return *ptr;
	}
	
	int operator!() const
	{
		if( ptr )
		{
			return ( ptr == 0 );
		}
		else
		{
			return true;
		}
	}
	
	T* operator->() const
	{
		return ptr;
	}
	
	template < class T2 > Sptr& dynamicCast( const Sptr < T2 > & x )
	{
		if( ptr == x.getPtr() ) 
		{
			return *this;
		}
		decrement();
		if( T* p = dynamic_cast< T* >( x.getPtr() ) )
		{
			count = x.getCount();
			mutex = x.getMutex();
			ptr = p;
			increment();
		}
		return *this;
	}
	
	template<class T2> Sptr& operator=( const Sptr< T2 > &x )
	{
		if( ptr == x.getPtr() )
		{
			return *this;
		}
		decrement();
		ptr = x.getPtr();
		count = x.getCount();
		mutex = x.getMutex();
		increment();
		return *this;
	}
	
	Sptr& operator=( T* original )
	{
		if( ptr == original )
		{
			return *this;
		}
		decrement();
		ptr = original;
		increment();
		return *this;
	};
	
	
	Sptr& operator=( const Sptr& x )
	{
		if( ptr == x.getPtr() )
			return * this;
		decrement();
		ptr = x.ptr;
		count = x.count;
		mutex = x.mutex;
		increment();
		return *this;
	}
	
	/// compare whether a pointer and a smart pointer point to different things
	friend bool operator!=( const void* y, const Sptr& x )
	{
		if( x.ptr != y )
			return true;
		else
			return false;
	}
	
	/// compare whether a smart pointer and a pointer point to different things
	friend bool operator!=( const Sptr& x, const void* y )
	{
		if( x.ptr != y )
			return true;
		else
			return false;
	}
	
	/// compare whether a pointer and a smart pointer point to the same thing
	friend bool operator==( const void* y, const Sptr& x )
	{
		if( x.ptr == y )
			return true;
		else
			return false;
	}
	
	/// compare whether a smart pointer and a pointer point to the same thing
	friend bool operator==( const Sptr& x, const void* y )
	{
		if( x.ptr == y )
			return true;
		else
			return false;
	}
	
	/// compare whether two smart pointers point to the same thing
	bool operator==(const Sptr& x) const
	{
		if( x.ptr == ptr )
			return true;
		else
			return false;
	}
	
	/// compare whether two smart pointers point to the different things
	bool operator!=( const Sptr& x ) const
	{
		if( x.ptr != ptr )
			return true;
		else
			return false;
	}
	
	bool operator<( const Sptr& x ) const
	{
		if( x.ptr < ptr )
			return true;
		else
			return false;
	}
	
	bool operator>( const Sptr& x ) const
	{
		if( x.ptr > ptr )
			return true;
		else
			return false;
	}
	
	bool operator<=( const Sptr& x ) const
	{
		if( x.ptr <= ptr )
			return true;
		else
			return false;
	}
	
	bool operator>=( const Sptr& x ) const
	{
		if( x.ptr >= ptr )
			return true;
		else
			return false;
	}
	
	/**this interface is here because it may sometimes be
	 necessary.  DO NOT USE unless you must use it.
	 get the actual mutex of the smart pointer.*/
	KMutex* getMutex() const
	{
		return mutex;
	}
	
	/**this interface is here because it may sometimes be
	 necessary.  DO NOT USE unless you must use it.
	 get the value of the reference count of the smart pointer.*/
	int* getCount() const
	{
		return count;
	}
	
	/**this interface is here because it may sometimes be
	 necessary.  DO NOT USE unless you must use it.
	 get the pointer to which the smart pointer points.*/
	T* getPtr() const
	{
		return ptr;
	}
};


//////////////////////////////////

typedef enum udpmode
{
    inactive,
    sendonly,
    recvonly,
    sendrecv
} KUdpMode;

class KUdpStackPrivateData;

class KUdpStack
{
public:
	KUdpStack();

	bool init( const KNetworkAddress* pDesHost = NULL,
			int minPort = -1,						
			int maxPort = -1,			
			bool block = true,
			KUdpMode udpMode = sendrecv,	
			bool isMulticast = false );

	void close();

	KUdpMode getMode();
	
	unsigned short getLocalPort();
	
	unsigned short getDestinationPort ();
	
	KNetworkAddress getDestinationHost() const;

	KNetworkAddress getLocalHost() const;
	
	void setMode ( const KUdpMode theMode );
	
	int getSocketFD ();
	
	void addToFdSet ( fd_set* set );
	
	/// Find the max of any file descripts in this stack and the passed value
	int getMaxFD ( int prevMax = 0 );
	
	bool checkIfSet ( fd_set* set );
	
	/// Recive a datagram into the specifed buffer - returns size of mesg.
	/// Once connectPorts() is called, can't receive from other ports
	int receive ( const void* buffer, const int bufSize, long millsecond );
	
	int receiveFrom ( const void* buffer, const int bufSize, KNetworkAddress* sender, long millsecond=-1 );

	int receiveFrom ( const void* buffer, const int bufSize, sockaddr_in* sender, long millsecond=-1 );

	int transmit ( const void* buffer, const int length, long millsecond=-1 );
	
	int transmitTo ( const void* buffer, const int length, const KNetworkAddress dest, long millsecond=-1 );

	int transmitTo ( const void* buffer, const int length, const sockaddr_in dest, long millsecond=-1 );

	void joinMulticastGroup ( KNetworkAddress group, KNetworkAddress* iface = NULL, int ifaceInexe = 0 );
	
	void leaveMulticastGroup( KNetworkAddress group, KNetworkAddress* iface = NULL, int ifaceInexe = 0 );
	
	virtual ~KUdpStack ();

	void setBlock( bool bBlock );
	
	int getBytesTransmitted ();
	
	int getPacketsTransmitted ();
	
	int getBytesReceived ();
	
	int getPacketsReceived ();

	bool doServer ( int minPort, int maxPort );
	
	bool doClient ( const KNetworkAddress& desName );
	
private:
	
	KUdpStack( const KUdpStack& )
	{
		assert ( 0 );
	};

	bool isReadReady( int mSeconds ) const;

	bool isWriteReady( int mSeconds=500 ) const;
	
private:

	int localPort;										// port the stack is currently using

	bool bBlockMode;
	
	int numBytesReceived;								// number of bytes the stack has received
	
	int numPacketsReceived;							

	int numBytesTransmitted;					
	
	int numPacketsTransmitted;					
	
	KUdpMode mode;

	bool _block;
	
	int _socketFd;
	
	struct sockaddr_in _localAddr;
	
	struct sockaddr_in _remoteAddr;
	
	int rcvCount ;
	int sndCount ;
};


#endif
