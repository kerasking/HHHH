#ifndef __KT_FILE_h
#define __KT_FILE_h

#include <time.h>
#include <stdio.h>
#include "KData.h"


class KFile
{
public:
	enum SEEKFLAG
	{
		KFILE_BEGIN = 0,
		KFILE_CUR,
		KFILE_END
	};

	enum OPENFLAG
	{
		KFILE_NONE = 1,
		KFILE_READ = 2,
		KFILE_READWRITE = 4,
		KFILE_APPEND = 8,
		KFILE_CREATE = 16,
		KFILE_MODIFY = 32,
	};

public:

	KFile();

	KFile( const KData& path, const KData& fileName, int mode = KFILE_NONE );

	KFile( KData fullFilePath, int mode = KFILE_NONE );
 
	virtual ~KFile();
		
	bool setFile( KData fullFilePath, int mode = KFILE_NONE );

	bool setFile( const KData& path, const KData& filename, int mode=KFILE_NONE );

	void closeFile();

	bool seekTo( int to, int orign );

	int read( unsigned char* buf, int len );

	int write( const unsigned char* buff, int len );

	int write( const KData& data );

	int writeLine( const KData& date="" );

	int readLine( char* buff, int maxlen=1024 );

	int readLine( KData& dtLine, int maxlen=1024 );

	void flush();

	inline bool isEof()
	{
		return ( feof( hFile ) != 0 );
	}

	KData getFileName() const;

	KData getPath() const;

	KData getExtName() const;

	KData getFirstName() const;
	
	KData getFullName() const;

	long getFileLen();

	bool operator<( const KFile& other );

	bool operator==( const KFile& other );

	static void replaceAll( KData& str );

	static bool isFileExist( const KData& fullFilePath );

	static bool deleteFile( const KData& fullFilePath );

	static bool isFileExist( KData path, KData fileName );

	static bool renameFile( const KData& from, const KData& to, bool replace=true );

	static bool copyFile( const KData& from, const KData& to, bool replace=true );

	long getFilePos();

	bool copyTo( const KData& target );

	int getAllFileData( char* pFileKData );

	bool isOpen()
	{
		return _bOpen;
	}

	static unsigned long long getLastWriteTime( const KData& path );

	static KData getLastWriteTimeStr( const KData& path );

	static unsigned long long getCreateTime( const KData& path );

	static KData getCreateTimeStr( const KData& path );

private:

	KFile( const KFile& vfile ){};
	bool open( int mode );
	KData _fileName;
	KData _path;
	int _type;
	bool _bOpen;
	FILE* hFile;

};

#endif
