#ifndef __STRINGDATA_H
#define __STRINGDATA_H

#include <map>
#include <string>

using namespace std;

#define NOT_FOUND -1
#define FIRST -2
#define FOUND 0

static const char SPACE[] = " ";

class StringData
{
public:
	StringData();
	StringData( const char* str );
	StringData( const char* buffer, int length );
	StringData( const StringData& data );
	StringData( const string& str );
	StringData( int value );
	StringData( unsigned int value );
	StringData( const char ch );
	StringData( float value );
	 ~StringData();

	bool operator>( const StringData& ) const ;
	bool operator<( const StringData& ) const;
	StringData& operator=( const char* str );
	StringData& operator=( const StringData& data );
	int HexToInt();
	const char* getData() const;

	/** getDataBuf differs from getData in that the resultant buffer is NOT NULL terminated */
	const char* getDataBuf() const;

	StringData substr( int start, int length = -1 ) const;
	char getChar( unsigned int i ) const;
	void setchar( unsigned int i, char c );
	char operator[]( unsigned int i );
	unsigned int length() const;
	bool operator==( const char* str ) const;
	bool operator==( const StringData& data ) const;
	bool operator!=( const char* str ) const;
	bool operator!=( const StringData& data ) const;

	StringData operator+( const StringData& data ) const;
	StringData operator+( const char* str ) const;
	StringData operator+( int val ) const;
	StringData operator+( unsigned int val ) const;

	void operator+=( const StringData& );
	void operator+=( const char* );
	void operator+=( int val );
	void operator+=( unsigned int val );
	void operator+=( char ch );

	void erase();

	operator string() const;

	operator const char*() const;

	operator int() const;

	int match( StringData match, StringData* data = NULL, bool replace = false, StringData replaceWith = "" );

	void replace( int startpos, int len, const StringData& replaceStr );

	void replace( const StringData& from, const StringData to );

	int findlast( const StringData& match, int stop=-1 ) const;

	int findlastNoCase( const StringData& match, int stop=-1 ) const;

	void removeSpaces();

	void removeTab();

	void clearSpaces();

	void inflate( int size, const StringData& fillval, bool before = true );

	void removeQuo();

	void expand( StringData startFrom, StringData findstr, StringData replstr, StringData delimiter );

	friend bool isEqualNoCase( const StringData& left, const StringData& right ) ;

	void deepCopy( const StringData &src, char ** bufPtr = 0, int *bufLenPtr = 0 );

	int find( const StringData& match, int start = 0 ) const;

	int findNoCase( const StringData& match, int star=0 );

	bool isEmpty() const;

	void removeCRLF();

	map< int, StringData > split( const StringData& sp, bool bCut=false ) const;

	static StringData xorString( const StringData& str1, const StringData& str2 );

	bool tobcd( char fillch );

	bool isNumeric();

	bool isEndWith( const StringData& str, bool bCase=true ) const;

	void fillFilePath();

	StringData getFilePath() const;

	void makePath( bool bUrl=false );

	StringData getFileName() const;

	StringData getExtName() const;

private:
	string buf;

public:
	void removeLastChar(char ch);
};

#endif
