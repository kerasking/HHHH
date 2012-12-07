#ifndef __KTIME_VAL_DOT_H
#define __KTIME_VAL_DOT_H

#ifdef WIN32 
#include <time.h> 
#include <windows.h>
#else 
#include <sys/time.h>
#include <unistd.h>
#endif 
#include "KData.h"
#include <iostream>

class KTimeVal
{
public:
	KTimeVal();	
	KTimeVal( int );
	virtual ~KTimeVal();
	
	KTimeVal( const KTimeVal& src );
	KTimeVal & operator=( const KTimeVal & );
	
	const KTimeVal & now();

	int getMonth();
	int getMonthDay();
	int getWeekDay();
	int getYear();
	int getMinute();
	int getSecond();
	int getHour();
	
	unsigned long long milliseconds() const;
	
	KTimeVal operator+( const KTimeVal & ) const;
	KTimeVal operator+( int ) const;
	KTimeVal & operator+=( const KTimeVal & );
	KTimeVal & operator+=( int );
	KTimeVal operator-( const KTimeVal & ) const;
	KTimeVal operator-( int ) const;
	KTimeVal & operator-=( const KTimeVal & );
	KTimeVal & operator-=( int );
	bool	operator==( const KTimeVal & ) const;
	bool	operator< ( const KTimeVal & ) const;
	bool	operator<=( const KTimeVal & ) const;
	bool	operator< ( int right ) const;
	bool	operator<=( int right ) const;
	bool	operator> (const KTimeVal &) const;
	bool	operator>=(const KTimeVal &) const;
	bool	operator> ( int right ) const;
	bool	operator>= ( int right ) const;
	
	void	clear();
	bool	isClear();
	void	copy( const KTimeVal & );
	
	void	normalize();

	KData strftime( const KData & format );
	ostream & writeTo( ostream & ) const;

	long tv_sec;
	long tv_usec;

};

#endif

