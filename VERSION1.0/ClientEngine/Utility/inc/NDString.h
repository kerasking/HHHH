//
//  NDString.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-9.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//



#ifndef __NDString_H
#define __NDString_H

#include <map>
#include <string>

using namespace std;

namespace NDEngine
{
#define NOT_FOUND -1
#define FIRST -2
#define FOUND 0
	
	static const char SPACE[] = " ";
	
	class NDString
	{
	public:
		NDString();
		NDString( const char* str );
		NDString( const char* buffer, int length );
		NDString( const NDString& data );
		NDString( const string& str );
		NDString( int value );
		NDString( unsigned int value );
		NDString( const char ch );
		NDString( float value );
		~NDString();
		
//		bool operator>( const NDString& ) const ;
//		bool operator<( const NDString& ) const;
		NDString& operator=( const char* str );
		NDString& operator=( const NDString& data );
		int HexToInt();
		const char* getData() const;
		
		/** getDataBuf differs from getData in that the resultant buffer is NOT NULL terminated */
		const char* getDataBuf() const;
		
		NDString substr( int start, int length = -1 ) const;
		char getChar( unsigned int i ) const;
		void setchar( unsigned int i, char c );
		char operator[]( unsigned int i );
		unsigned int length() const;
		bool operator==( const char* str ) const;
		bool operator==( const NDString& data ) const;
		bool operator!=( const char* str ) const;
		bool operator!=( const NDString& data ) const;
		
		NDString operator+( const NDString& data ) const;
		NDString operator+( const char* str ) const;
		NDString operator+( int val ) const;
		NDString operator+( unsigned int val ) const;
		
		void operator+=( const NDString& );
		void operator+=( const char* );
		void operator+=( int val );
		void operator+=( unsigned int val );
		void operator+=( char ch );
		
		void erase();
		
		operator string() const;
		
		operator const char*() const;
		
		operator int() const;
		
		int match( NDString match, NDString* data = NULL, bool replace = false, NDString replaceWith = "" );
		
		void replace( int startpos, int len, const NDString& replaceStr );
		
		void replace( const NDString& from, const NDString to );
		
		int findlast( const NDString& match, int stop=-1 ) const;
		
		int findlastNoCase( const NDString& match, int stop=-1 ) const;
		
		void removeSpaces();
		
		void removeTab();
		
		void clearSpaces();
		
		void inflate( int size, const NDString& fillval, bool before = true );
		
		void removeQuo();
		
		void expand( NDString startFrom, NDString findstr, NDString replstr, NDString delimiter );
		
		friend bool isEqualNoCase( const NDString& left, const NDString& right ) ;
		
		void deepCopy( const NDString &src, char ** bufPtr = 0, int *bufLenPtr = 0 );
		
		int find( const NDString& match, int start = 0 ) const;
		
		int findNoCase( const NDString& match, int star=0 );
		
		bool isEmpty() const;
		
		void removeCRLF();
		
		map< int, NDString > split( const NDString& sp, bool bCut=false ) const;
		
		static NDString xorString( const NDString& str1, const NDString& str2 );
		
		bool tobcd( char fillch );
		
		bool isNumeric();
		
		bool isEndWith( const NDString& str, bool bCase=true ) const;
		
		void fillFilePath();
		
		NDString getFilePath() const;
		
		void makePath( bool bUrl=false );
		
		NDString getFileName() const;
		
		NDString getExtName() const;
		
		void Format(const char* fmt, ...);
		
	private:
		string buf;
		
	public:
		void removeLastChar(char ch);
	};
}



#endif
