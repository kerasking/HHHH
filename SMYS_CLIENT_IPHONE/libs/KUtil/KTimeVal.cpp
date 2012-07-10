#include <cassert>
#include <stdio.h>
#include <sys/timeb.h>
#include <time.h>
#include "KTimeVal.h"


const char Days[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

KTimeVal::KTimeVal()
{
    clear();
}


KTimeVal::KTimeVal( int src )
{
    clear();
    operator+=( src );
}


KTimeVal::KTimeVal( const KTimeVal& src )
{
    copy( src );
    normalize();
}


KTimeVal::~KTimeVal()
{
}


KTimeVal &
KTimeVal::operator=( const KTimeVal & src )
{
    if ( this != & src )
    {
        copy( src );
        normalize();
    }
    return ( *this );
}


const KTimeVal &
KTimeVal::now()
{
	timeval v;
    int rc = gettimeofday( &v, 0 );
    assert( rc == 0 );
	tv_sec = v.tv_sec;
	tv_usec = v.tv_usec;
	return ( *this );
}


unsigned long long
KTimeVal::milliseconds() const
{
    return ( (unsigned long long)tv_sec*1000 + (unsigned long long)tv_usec/1000 );
}


KTimeVal
KTimeVal::operator+( const KTimeVal & right ) const
{
    KTimeVal left( *this );
    return ( left += right );
}


KTimeVal
KTimeVal::operator+( int right ) const
{
    KTimeVal left( *this );
    return ( left += right );
}


KTimeVal &
KTimeVal::operator+=( const KTimeVal & src )
{
    tv_sec += src.tv_sec;
    tv_usec += src.tv_usec;
    normalize();
    return ( *this );
}


KTimeVal &
KTimeVal::operator+=( int src )
{
    tv_sec += src / 1000;
    tv_usec += (src%1000)*1000;
    normalize();
    return ( *this );
}


KTimeVal
KTimeVal::operator-( const KTimeVal & right ) const
{
    KTimeVal left( *this );
    return ( left -= right );
}


KTimeVal
KTimeVal::operator-( int right ) const
{
    KTimeVal left( *this );
    return ( left -= right );
}


KTimeVal&
KTimeVal::operator-=( const KTimeVal & src )
{
    tv_sec -= src.tv_sec;
    tv_usec -= src.tv_usec;
    normalize();
    return ( *this );
}


KTimeVal &
KTimeVal::operator-=( int src )
{
    tv_sec -= src / 1000;
    tv_usec -= (src%1000)*1000;
    normalize();
    return (*this);
}


bool
KTimeVal::operator==( const KTimeVal & src ) const
{
    KTimeVal right( src );
    return ( tv_sec==right.tv_sec && tv_usec==right.tv_usec );
}


bool
KTimeVal::operator<( const KTimeVal & src ) const
{
    KTimeVal right( src );
    if ( tv_sec < right.tv_sec )
    {
        return true;
    }
    else if ( (tv_sec == right.tv_sec) && (tv_usec < right.tv_usec) )
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool
KTimeVal::operator>( const KTimeVal &src ) const
{
	KTimeVal right( src );
	if ( tv_sec > right.tv_sec )
	{
		return true;
	}
	else if ( (tv_sec == right.tv_sec) && ( tv_usec > right.tv_usec ) )
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool
KTimeVal::operator<( int right ) const
{
    if ( (tv_sec * 1000 + tv_usec/1000 ) < right )
    	return true;
    else
    	return false;
}

bool
KTimeVal::operator>( int right ) const
{
    if ( (tv_sec * 1000 + tv_usec/1000 ) > right )
    	return true;
    else
    	return false;
}

bool
KTimeVal::operator<=( int right ) const
{
    if ( (tv_sec * 1000 + tv_usec/1000 ) <= right )
    	return true;
    else
    	return false;
}

bool
KTimeVal::operator>=( int right ) const
{
    if ( (tv_sec * 1000 + tv_usec/1000 ) >= right )
    	return true;
    else
    	return false;
}

bool
KTimeVal::operator<=( const KTimeVal & src ) const
{
    // Create a normalize value for the KTimeVal to simplify comparison.
    KTimeVal right( src );

    if ( tv_sec < right.tv_sec )
    {
        return ( true );
    }
    else if ( (tv_sec == right.tv_sec) && (tv_usec <= right.tv_usec) )
    {
        return ( true );
    }
    else
    {
        return ( false );
    }
}


bool
KTimeVal::operator>=( const KTimeVal & src ) const
{
    KTimeVal right(src);
    if ( tv_sec > right.tv_sec )
    {
        return ( true );
    }
    else if ( (tv_sec == right.tv_sec) && (tv_usec >= right.tv_usec) )
    {
        return true;
    }
    else
    {
        return false;
    }
}


void
KTimeVal::clear()
{
    tv_sec = tv_usec = 0;
}


bool
KTimeVal::isClear()
{
	if ( tv_sec==0 && tv_usec==0 )
		return true;
	else
		return false;
}


void
KTimeVal::copy( const KTimeVal & src )
{
    tv_sec = src.tv_sec;
    tv_usec = src.tv_usec;
}


void
KTimeVal::normalize()
{
    if ( tv_usec < 0 )
    {
        long num_sec = ( -tv_usec / 1000000) + 1;
        assert(num_sec > 0);
        tv_sec -= num_sec;
        tv_usec += num_sec * 1000000;
    }

    if ( tv_usec >= 1000000 )
    {
        tv_sec += tv_usec / 1000000;
        tv_usec %= 1000000;
    }
}


ostream &
KTimeVal::writeTo( ostream & out ) const
{
    return ( out << "{ " << tv_sec << ", " << tv_usec << " }" );
}

KData
KTimeVal::strftime( const KData& format )
{
    time_t now = tv_sec;
    char datebuf[256];
	struct tm* ptm = localtime( &now );
    ::strftime( datebuf, 256, format.getData(), ptm );
    return KData( datebuf );
}

int
KTimeVal::getMinute()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	return ptm->tm_min;
}

int
KTimeVal::getHour()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	return ptm->tm_hour;
}

int
KTimeVal::getYear()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	int val = 1900 + ptm->tm_year; 
	return val;
}

int
KTimeVal::getSecond()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	return ptm->tm_sec;
}

int
KTimeVal::getMonth()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	return ptm->tm_mon+1;
}

int
KTimeVal::getMonthDay()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	return ptm->tm_mday;
}

int
KTimeVal::getWeekDay()
{
	time_t t = tv_sec;
	struct tm* ptm = localtime( &t );
	return ptm->tm_wday;	
}

