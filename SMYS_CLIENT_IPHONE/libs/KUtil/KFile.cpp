#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <iostream>
#include "KFile.h"


KFile::KFile() : _bOpen( false )
{

}

KFile::KFile( const KData& path, const KData& fileName, int mode )
        : _fileName( fileName ), _path( path ), _bOpen( false )
{
	replaceAll( _path );
	replaceAll( _fileName );
	if ( _path.length()>0 && _path[ _path.length()-1] != '/' )
    {
        _path += "/";
    }
	open( mode );
}


KFile::KFile( KData fullFilePath, int mode ) : _bOpen( false )
{
	setFile( fullFilePath, mode );
}


bool KFile::open( int mode )
{
	if ( mode & KFILE_NONE )
	{
		return true;;
	}
	if( mode & KFILE_READ )
	{
		hFile = fopen( getFullName().getData(), "rb" );
		if ( hFile == NULL )
		{
			if ( mode & KFILE_CREATE )
			{
				hFile = fopen( getFullName().getData(), "wb+" );
				fclose( hFile );
				hFile = fopen( getFullName().getData(), "rb" );
			}
		}		
	}
	else if( mode&KFILE_READWRITE )
	{
		hFile = fopen( getFullName(), "wb+" );
	}
	else if( mode&KFILE_MODIFY )
	{
		hFile = fopen( getFullName(), "r+b" );
		if ( hFile==NULL && mode&KFILE_CREATE )
		{
			hFile = fopen( getFullName(), "wb+" );
			fclose( hFile );
			hFile = fopen( getFullName(), "r+b" );
		}
	}
	else if( mode&KFILE_READWRITE && mode&KFILE_CREATE )
	{
		if( NULL != (hFile=fopen(getFullName(),"rb") ) )
		{
			fclose( hFile );
			return false;
		}
		hFile = fopen( getFullName(), "wb+" );
	}
	else if( mode & KFILE_APPEND )
	{
		hFile = fopen( getFullName(), "ab+" );
	}
	else
	{
		return false;
	}
	if ( hFile == 0 )
	{
		return false;
	}
	else
	{
		_bOpen = true;
	}
	return true;
}


KFile::~KFile()
{
	if( _bOpen )
		fclose( hFile );
}

void KFile::replaceAll( KData& str )
{
	int pos;
	KData dtKData = "\\";
	while ( (pos=str.find(dtKData)) != -1 )
    {
        str.replace( pos, 1, "/" );
    }
}


bool KFile::setFile( const KData& path, const KData& filename, int mode )
{
	return setFile( path+filename, mode );
}

bool KFile::setFile( KData fullFilePath, int mode )
{
	if ( _bOpen )
	{
		fclose( hFile );
		_bOpen = false;
	}
	replaceAll( fullFilePath );
    if ( fullFilePath.find( "/" ) == -1 )			//»Áπ˚≤ª¥Ê‘⁄ƒø¬º√˚
    {
        _path = "./";
        _fileName = fullFilePath;
    }
    else
    {
        KData tStr = fullFilePath;
		if( tStr[tStr.length()-1] == '/' )
        {
			return false;
        }
        else
        {
			int pos = tStr.findlast( "/" );
            _path = tStr.substr( 0, pos+1 );
			_fileName = tStr.substr( pos+1, tStr.length()-pos-1 );
        }
    }
	return open( mode );
}


bool KFile::seekTo( int to, int orign )
{
	if ( fseek(hFile,to,orign) == 0 )
		return true;
	else
		return false;
}


int KFile::read( unsigned char *buf, int len )
{
	int iLeft = len;
	while ( iLeft > 0 )
	{
		if ( feof(hFile) || ferror(hFile) )
			return len-iLeft;
		iLeft -= fread( buf+(len-iLeft), 1, iLeft, hFile );
	}
	return len;
}


int KFile::readLine( char *buff, int maxlen )
{
	char ch;
	for ( int i=0; i<maxlen; i++ )
	{
		if ( fread(&ch,1,1,hFile) == 0 )
		{
			buff[i] = '\0';
			if ( i > 0 )
				return i;
			else
				return -1;
		}
		if ( ch=='\n' )
		{
			if ( i>0 && buff[i-1]=='\r' )
			{
				buff[i-1] = '\0';
				return i-1;
			}
			else
			{
				buff[i] = '\0';
				return  i;
			}
		}
		else
		{
			buff[i] = ch;
		}
	}
	return maxlen;
}

int KFile::readLine( KData& dtLine, int maxlen )
{
	char tmp[8192];
	memset( tmp, 0, 8192 );
	int iRet = readLine( tmp, maxlen );
	dtLine = tmp;
	return iRet;
}
	
int KFile::write( const unsigned char *buff, int len )
{
	return fwrite( buff, 1, len, hFile );
}

int KFile::write( const KData& data )
{
	const char* pKData = data.getDataBuf();
	int len = data.length();
	int iWrited = 0;
	while ( iWrited < len )
	{
		int iRet = write( (unsigned char*)(pKData+iWrited), len-iWrited );
		if ( iRet <= 0 )
			break;
		iWrited += iRet;
	}
	return iWrited;
}

int KFile::writeLine( const KData& date )
{
	return write( date + '\n' );
}

void KFile::flush()
{
	fflush( hFile );
}

KData KFile::getFileName() const
{
	return _fileName;
}

KData KFile::getExtName() const
{
	int pos = 0;
	if ( (pos=_fileName.findlast(".")) == -1 )
		return "";
	else
		return _fileName.substr( pos+1 );
}

KData KFile::getFirstName() const
{
	int pos = 0;
	if ( (pos=_fileName.findlast(".")) == -1 )
		return _fileName;
	else
		return _fileName.substr( 0, pos );
}

KData KFile::getPath() const
{
	return _path;
}

KData KFile::getFullName() const
{
	return( _path+_fileName );
}


bool KFile::operator<( const KFile& other )
{
	if( getFullName() < other.getFullName() )
		return true;
	return false;
}

bool KFile::operator==( const KFile& other )
{
	if( getFullName() == other.getFullName() ) 
		return true;
	return false;
}

bool KFile::isFileExist( const KData& fullFilePath )
{
	struct stat kstat;
	return lstat(fullFilePath.getData(), &kstat) != -1;
}

bool KFile::isFileExist( KData path, KData fileName )
{
	replaceAll( path );
	replaceAll( fileName );
	if( path.length()>0 && path[path.length()-1] != '/' )
    {
        path += "/";
    }
    while( path.find("//") != -1 )
    {
		int pos = path.find("//");
		path.replace( pos, pos+2, "/" );
    }
	return isFileExist( path+fileName );
}


bool KFile::deleteFile( const KData& fullFilePath )
{
	if ( remove(fullFilePath.getData()) == 0 )
		return true;
	else
		return false;
}


bool KFile::renameFile( const KData& from, const KData& to, bool replace )
{
	return rename( from.getData(), to.getData() );
}


long KFile::getFileLen()
{
	long lVal = getFilePos();
	seekTo( 0, KFile::KFILE_END );
	long fileLen = getFilePos();
	seekTo( lVal, KFILE_BEGIN );
	return fileLen;
}


long KFile::getFilePos()
{
	return ftell( hFile );
}

void KFile::closeFile()
{
	if ( _bOpen )
	{
		fclose( hFile );
		_bOpen = false;
	}
}

bool KFile::copyFile( const KData& from, const KData& to, bool replace )
{
	if ( replace )
	{
		KFile::deleteFile( to );
	}
	else
	{
		if ( isFileExist(to) )
			return false;
	}
	KFile file;
	if ( !file.setFile(from,KFILE_READ) )
		return false;
	if ( !file.copyTo(to) )
		return false;
	struct stat tstat;
	stat( from, &tstat );
	chmod( to, tstat.st_mode );

	return true;
}

bool KFile::copyTo( const KData& target )
{
	KFile tarFile;
	if ( !tarFile.setFile(target,KFILE_READWRITE) )
		return false;
	unsigned char buff[2048];
	int iRead;
	while( ( iRead=read( buff, 2048 ) ) > 0 )
	{
		tarFile.write( buff, iRead );
	}
	tarFile.closeFile();

	struct stat st;
	stat( getFullName().getData(), &st );
	chmod( target.getData(), st.st_mode );

	return true;
}

ostream& operator<<( ostream& os, const KFile& file )
{
	os << file.getFullName().getData();
    return os;
}


int
KFile::getAllFileData( char* pFileKData )
{
	int iRead = 0;
	long fileLen = getFileLen();
	seekTo( 0, KFILE_BEGIN );
	while ( iRead < fileLen )
	{
		int iReaded = 0;
		if ( (iReaded=read((unsigned char*)pFileKData+iRead, 2048)) > 0 )
		{
			iRead += iReaded;
		}
		else
		{
			break;
		}
	}
	if ( iRead != fileLen )
	{
		delete[] pFileKData;
		return -1;
	}
	else
	{
		return fileLen;
	}
}


unsigned long long
KFile::getLastWriteTime( const KData& path )
{
	return 0;
}

unsigned long long
KFile::getCreateTime( const KData& path )
{
	return 0;
}


KData
KFile::getLastWriteTimeStr( const KData& path )
{
	return "";
}


KData
KFile::getCreateTimeStr( const KData& path )
{
	return "";
}


