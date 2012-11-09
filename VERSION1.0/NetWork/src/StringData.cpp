#include <cstdio>
#include <ctype.h>
#include <stdlib.h>
#include "StringData.h"
#include "KData.h"
#include "Kathy.h"


StringData::StringData()
{}

StringData::StringData( const char* str, int length ) : buf( str, length )
{

}

StringData::StringData( const char* str )
{
    buf = str;
}

StringData::StringData( const char ch )
{
	buf = ch;
}

StringData::StringData( unsigned int value )
{
	char buff[16];
	sprintf( buff, "%u", value );
	buf = buff;
}

StringData::StringData( float fvalue )
{
	char buff[16];
	sprintf( buff, "%f", fvalue );
	buf = buff;
}

StringData::StringData( const string& str)
{
    buf = str.c_str();;
}

StringData::StringData( int value )
{
    char str[256];
    sprintf( str, "%d", value );
    buf = str;
}

StringData::StringData( const StringData& data )
{
    buf = data.buf;
}

StringData&
StringData::operator=( const char* str )
{
    buf = str;
    return (*this);
}

StringData&
StringData::operator=( const StringData& data )
{
    if (this != &data)
    {
        buf = data.buf;
    }

    return (*this);
}

const char*
StringData::getData() const
{
    return buf.c_str();
}

const char*
StringData::getDataBuf() const
{
    return buf.c_str();
}

void
StringData::operator+=( char ch )
{
	buf += ch;
}

StringData StringData::substr( int start, int length ) const
{
    if ( ( start<0 ) || (length<1 && length!=-1) )
    {
		return StringData();
    }
    else
    {
		return StringData( buf.substr( start, length ) );
    }
}

char
StringData::getChar( unsigned int i ) const
{
    if ( i > buf.size() )
        return 0;
    return buf[i];
}

void StringData::setchar( unsigned int i, char c )
{
    if ( i > buf.size() )
		return;
    else
        buf[i] = c;
}

char
StringData::operator[]( unsigned int i )
{
    char ch;
    ch = getChar( i );
    return ch;
}

unsigned int
StringData::length() const
{
    return buf.size();
}

bool StringData::operator==( const char* str) const
{
    return ( buf == str );
}

bool StringData::operator==( const StringData& data ) const
{
    return ( buf == data.buf );
}

bool StringData::operator!=( const char* str ) const
{
    return ( buf != str);
}

bool StringData::operator!=( const StringData& data ) const
{
    return ( buf != data.buf );
}

void getDataSection( const StringData& data, unsigned int& start, StringData& dtRet, bool& bIsNumric )
{
	bIsNumric = ( data[start] <= '9' && data[start]>='0' );
	while( start < data.length() )
	{
		if ( bIsNumric )
		{
			if ( !(data[start] <= '9' && data[start]>='0') )
				break;
		}
		else
		{
			if ( data[start] <= '9' && data[start]>='0' )
				break;
		}
		dtRet += data[start++];
	}
}

bool
StringData::operator>( const StringData& data ) const
{
	if ( length()>0 && data.length()==0 )
		return true;
	if ( length()==0 && data.length()>0 )
		return false;
	if ( length()==0 && data.length()==0 )
		return false;

	unsigned int pos1 = 0;
	unsigned int pos2 = 0;
	while ( true )
	{
		if ( pos1==length() && pos2==data.buf.length() )
			return false;
		if ( pos1==length() && pos2<data.buf.length() )
			return false;
		if ( pos2==length() && pos1<length() )
			return true;

		KData dtData1,dtData2;
		bool isNumeric1, isNumeric2;
		getDataSection( *this, pos1, dtData1, isNumeric1 );
		getDataSection( data, pos2, dtData2, isNumeric2 );
		if ( isNumeric1 && !isNumeric2 )
			return false;
		else if ( !isNumeric1 && isNumeric2 )
			return true;
		else if ( isNumeric1 && isNumeric2 )
		{
			if ( dtData1.length() > dtData2.length() )
			{
				return true;
			}
			else if ( dtData2.length() > dtData1.length() )
			{
				return false;
			}
			else
			{
				if ( dtData1.buf == dtData2.buf )
					continue;
				else
					return (dtData1.buf>dtData2.buf);
			}
		}
		else if ( !isNumeric1 && !isNumeric2 )
		{
			unsigned int len = min( dtData1.length(), dtData2.length() );
			for( unsigned int i=0; i<len; i++ )
			{
				char ch1 = dtData1[i];
				char ch2 = dtData2[i];
				bool bUpcase1,bUpcase2;
				if ( ch1>='A' && ch1<='Z' )
				{
					bUpcase1 = true;
					ch1 += ('a'-'A');
				}
				else
				{
					bUpcase1 = false;
				}
				if ( ch2>='A' && ch2<='Z' )
				{
					bUpcase2 = true;
					ch2 += ('a'-'A');
				}
				else
				{
					bUpcase2 = false;
				}
				if ( ch2 == ch1 )
				{
					if ( bUpcase1 == bUpcase2 )
						continue;
					else if ( bUpcase1 )
						return true;
					else
						return false;
				}
				else
				{
					return ch1>ch2;
				}
			}
			if ( dtData1.length() == dtData2.length() )
				continue;
			else if ( dtData1.length() > dtData2.length() )
				return true;
			else
				return false;
		}
	}
}

bool
StringData::operator<( const StringData& data ) const
{	
	if ( *this>data || *this==data )
		return  false;
	else
		return true;
}

StringData
StringData::operator+( const StringData& data ) const
{
    return ( buf + data.buf );
}

StringData
StringData::operator+( int val ) const
{
	char buff[10];
	sprintf( buff, "%d", val );
	return buf + buff;
}

StringData
StringData::operator+( unsigned int val ) const
{
	char buff[10];
	sprintf( buff, "%u", val );
	return buf + buff;
}

StringData
StringData::operator+( const char* str ) const
{
    return ( buf + str );
}


void
StringData::operator+=( const StringData& data )
{
	buf += data.buf;
}


void
StringData::operator+=( const char* str )
{
	buf += str;
}

void
StringData::operator+=( int val )
{
	char buff[10];
	sprintf( buff, "%d", val );
	buf += buff;
}

void
StringData::operator+=( unsigned int val )
{
	char buff[10];
	sprintf( buff, "%u", val );
	buf += buff;
}

StringData::~StringData()
{}

void
StringData::erase()
{
    buf.erase();
}


StringData::operator string() const
{
    return buf;
}

StringData::operator const char*() const
{
    return buf.c_str();
}

StringData::operator int() const
{
    return atoi( buf.c_str() );
}

int StringData::HexToInt()
{
	int val = 0;
	int j = 0;
	string buff;
	bool bNega = false;
	if ( buf[0] == '-' )
	{
		buff = buf.substr( 1 );
		bNega = true;
	}
	else
	{	
		buff = buf;
	}
	for ( int i=buff.length()-1; i>=0; i--,j++ )
	{
		char ch = buff[i];
		if ( ch>='a' && ch <='f')
		{
			val += ( (ch-'a'+0xa) << (j<<2) );
		}
		else if ( ch>='A' && ch <='F' )
		{
			val += ( (ch-'A'+0xa) << (j<<2) );
		}
		else if ( ch>='0' && ch <='9' )
		{
			val += ( (ch-'0') << (j<<2) );
		}
		else
		{
			return 0;
		}
	}
	if ( bNega )
		return -val;
	else
		return val;
}

int StringData::find( const StringData& match, int start ) const
{
    return buf.find( match.buf, start );
}

int
StringData::findNoCase( const StringData& match, int start/*=0*/ )
{
	const char* pStrCompare = match.getDataBuf();
	const char* pStr = getDataBuf();
	int iLen = match.length();
	int iMaxLen = length();
	for ( int i=0; i<=iMaxLen-iLen; i++ )
	{
		if ( !compareNoCase( pStr+i, pStrCompare, iLen ) )
			return i;
	}
	return -1;
}

void
StringData::removeQuo()
{
	unsigned int first=0,end=buf.length();
	unsigned int i = 0;
	for ( i=0; i<buf.length()-1; i++ )
	{
		if( buf[i] == '"')
			first = i+1;
		else
			break;
	}
	for ( i=buf.length(); i>first; i-- )
	{
		if( buf[i] == '"')
			end = i;
		else
			break;
	}
	buf = buf.substr( first, end-first );
}


int StringData::match( StringData match, StringData* retModifiedData, bool replace, StringData replaceWith )
{
    int retVal = FIRST;
    int pos = buf.find( match.buf );
    if ( pos == -1 )
    {
        return NOT_FOUND;
    }
	else
	{
		if( pos != 0 )
			retVal = FOUND;
	}
    unsigned int replacePos = pos + match.length();
    if ( retModifiedData )
    {
        (*retModifiedData) = buf.substr( 0, pos );
    }
    if ( replace )
    {
        if ( replacePos <= buf.size() )
        {
            buf.replace( 0, replacePos, replaceWith.buf );
        }
    }
    return retVal;

}


void
StringData::replace( int startpos, int len, const StringData& replaceStr )
{
	buf.replace( startpos, len, replaceStr.buf );
}

void StringData::replace( const StringData& from, const StringData to )
{
	int pos = 0;
	while ( (pos=find(from)) != -1 )
	{
		replace( pos, from.length(), to );
	}
}


int
StringData::findlast( const StringData& match, int stop ) const
{
	return buf.find_last_of( match.buf, stop );
}


int
StringData::findlastNoCase( const StringData& match, int stop/*=-1*/ ) const
{
	if ( stop >= (int)buf.size() || stop <= 0 )
		stop = buf.size()-1;
	const char* pStr = buf.c_str();
	const char* pCompare = match.getDataBuf();
	int len = match.length();
	for( int i=stop-len+1; i>=0; i-- )
	{
		if ( !compareNoCase( pStr+i, pCompare, len ) )
			return i;
	}
	return -1;
}


bool isEqualNoCase( const StringData& left, const StringData& right )
{
	if ( left.length() != right.length() )
		return false;
	for ( unsigned int i=0; i<left.length(); i++ )
    {
        if ( toupper(left[i]) != toupper(right[i]) )
            return false;
    }
    return true;
}

void StringData::removeSpaces()
{
    if ( buf.length() == 0 )
        return;
    while ( true )
    {
        if ( buf[0] == ' ' )
        {
			buf.replace( 0, strlen(SPACE) , "" );
        }
		else
		{
			break;
		}
        
    }
    while ( true )
    {
        if ( buf[ buf.length()-1 ] == ' ' )
        {
			buf.replace( buf.length()-1, strlen(SPACE) , "" );
        }
		else
		{
			break;
		}
    }
}

void StringData::clearSpaces()
{
    if ( buf.length() == 0 )
    {
        return ;
    }	
    int beforeval;
    do
    {
        beforeval = buf.find( SPACE );
        if( beforeval == -1 )
        {
            break;
        }
        buf.replace( beforeval, strlen( SPACE ) , "" );
    }
    while( beforeval == 0 );
}

void
StringData::expand( StringData startFrom, StringData findstr, StringData replstr, StringData delimiter )
{
    int startPos = buf.find( startFrom.getData() );
    if ( startPos < -1 )
    {
        int delimPos = buf.find( delimiter.getData(), startPos );
        int findPos = buf.find( findstr.getData(), startPos );
        while ( findPos < delimPos )
        {
            //found replstr, replace
            buf.replace( findPos, strlen(findstr.getData()), replstr.getData());
            //find next.
            //delimPos = buf.find( delimiter.getData(), findPos);
            delimPos = buf.find( delimiter.getData(), findPos + static_cast < string > (replstr.getData()).size() );
            findPos = buf.find( findstr.getData(), findPos);
        }
    }
}

void
StringData::deepCopy( const StringData &src, char ** bufPtr, int *bufLenPtr )
{
    // Three ways of doing this.
    // 1)  This is okay too.  eg.  str = char*
    /*    buf = src.getData(); */
    // 2)  This might be better.  This should perserve strings like "\0\0a".
    //     Why this?  Binary data handling.
    // Shallow copy first.
    buf = src.buf;
    // This will force string to do a deep copy.
    char p = src.buf[0];
    buf[0] = p;
    // 3) Using memcpy.  About the same as using char*
  	/*
        strBufLen = strlen(src.getData());
        strBuf = new char[strBufLen];
        memcpy (strBuf, src.getData(), strBufLen); 
        buf = strBuf; 
    */
    // debug.  prints out the buf, len and address
    // cerr << _T("buf =") << buf.c_str();
    // cerr << _T(" len = ") << strBufLen;
    // cerr << _T(" ,hex=0x") << (long)buf.c_str() << endl;
}

bool
StringData::isEmpty() const
{
	return buf.empty();
}

void
StringData::removeCRLF()
{
	unsigned int i = 0;
	while ( i < buf.length() ) 
	{
		if ( buf[i] == '\r' || buf[i]=='\n' )
			buf.replace( i,  1, "" );
		else
			i++;
	}
}

void
StringData::removeTab()
{
	unsigned int i = 0;
	while ( i < buf.length() ) 
	{
		if ( buf[i] == '\t' )
			buf.replace( i,  1, "" );
		else
			i++;
	}
}

StringData
StringData::xorString( const StringData& str1, const StringData& str2 )
{
	int maxLen = str1.length() > str2.length() ? str1.length() : str2.length();
	int minLen = str1.length() > str2.length() ? str2.length() : str1.length();
	char *buff = new char[maxLen];
	int i = 0;
	for( i=0; i<minLen; i++ )
	{
		buff[i] = str1[i] ^ str2[i];
	}

	if ( str1.length() > str2.length() )
	{
		for( i=minLen; i<maxLen; i++ )
			buff[i] = ~str1[i];
	}
	else
	{
		for( i=minLen; i<maxLen; i++ )
			buff[i] = ~str2[i];
	}
	StringData data = StringData( buff, maxLen );
	delete[] buff;
	return data;
}

map< int, StringData >
StringData::split( const StringData& sp, bool bCut ) const
{
	StringData dtVal;
	map< int, StringData > mapVal;
	StringData data( *this );
	int i = 0;
	while( data.match( sp, &dtVal, true ) != NOT_FOUND )
	{
		mapVal[i++] = dtVal;
		if ( bCut )
		{
			while ( data.substr(0,sp.length()) == sp )
				data = data.substr( sp.length() );
		}
	}
	if( data.length() > 0 )
		mapVal[i] = data;
	return mapVal;
}

void
StringData::inflate( int size, const StringData &fillval, bool before )
{
	if ( (int)buf.length() >= size ) 
		return;
	StringData dtVal;
	int iInflateSize = size - buf.length();
	for( unsigned int i=0; i<iInflateSize/fillval.length(); i++ )
	{
		dtVal += fillval;
	}
	if ( iInflateSize%fillval.length() > 0 )
		dtVal += fillval.substr( 0, iInflateSize%fillval.length() );
	if ( before )
		operator =( dtVal + *this );
	else
		operator =( *this + dtVal );
}

bool StringData::tobcd( char fillch )
{
	int len;
	if ( buf.size() % 2 > 0 )
		len = buf.size() + 1;
	else
		len = buf.size();
	int bcdLen = len>>1;
	char* buff = new char[ len ];
	char* buff1 = new char[ bcdLen ];
	memcpy( buff, buf.c_str(), buf.size() );
	if ( len != (int)buf.size() )
		buff[ len-1 ] = fillch;
	bool bRet;
	if ( bRet = ascBcd( buff, (unsigned char*)buff1, bcdLen ) )
	{
		buf.assign( buff1, bcdLen );
	}
	delete[] buff;	delete[] buff1;
	return bRet;
}

bool StringData::isNumeric()
{
	if ( buf.size() == 0 )
		return false;
	for ( unsigned int i=0; i<buf.size(); i++ )
	{
		if ( buf[i]>'9' || buf[i]<'0' )
			return false;
	}
	return true;
}

void StringData::removeLastChar( char ch )
{
	int index = buf.length()-1;
	while ( true )
	{
		if ( buf[index] != '#' )
			break;
		index--;
	}
	buf = buf.substr( 0, index+1 );
}

bool StringData::isEndWith( const StringData& str, bool bCase ) const
{
	if ( buf.length() < str.length() )
		return false;
	StringData subStr = buf.substr( buf.length()-str.length() );
	if ( bCase )
	{
		if ( subStr == str )
			return true;
		else
			return false;
	}
	else
	{
		if ( compareNoCase(subStr.getData(), str.getData(), str.length()) == 0 )
			return true;
		else
			return false;
	}
}

void StringData::fillFilePath()
{
	if ( buf.empty() )
		return;
	if ( (int)buf.find( "/") != -1 )
	{
		if ( buf[buf.length()-1] != '/' )
		{
			buf += "/";
			return;
		}
	}
	else if ( (int)buf.find( "\\") != -1 )
	{
		if ( buf[buf.length()-1] != '\\' )
		{
			buf += "\\";
			return;
		}
	}
	else
	{
		buf += "/";
	}
}

StringData StringData::getFilePath() const
{
	int index = buf.find_last_of( "\\" );
	if ( index == -1 )
	{
		index = buf.find_last_of( "/" );
	}
	if ( index==-1 || index==((int)buf.length()-1) )
	{
		return *this;
	}
	else
	{
		StringData ret = substr( 0,index+1 );
		return ret;
	}
}

void StringData::makePath( bool bUrl )
{
	if ( buf.length() == 0 )
		return;
	char ch = buf[buf.length()-1];
	if ( ch!='\\' && ch!='/' )
	{
		if ( bUrl )
		{
			if ( (int)buf.find("\\")!=-1 )
				buf += '\\';
			else
				buf += '/';
		}
		else
		{
			if ( (int)buf.find("/") != -1 )
				buf += '/';
			else
				buf += '\\';
		}
	}		
}


StringData StringData::getFileName() const
{
	int index = buf.find_last_of( "\\" );
	if ( index == -1 )
		index = buf.find_last_of( "/" );
	if ( index==-1 )
		return *this;
	if ( index==((int)buf.length()-1) )
		return "";
	return substr( index+1 );
}


StringData StringData::getExtName() const
{
	StringData strExt;
	int index = findlast( "." );
	if ( index != -1 )
		strExt = substr( index+1 );
	return strExt;
}
