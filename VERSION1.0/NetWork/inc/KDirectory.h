#ifndef __KT_DIRECTORY_H
#define __KT_DIRECTORY_H

#ifdef WIN32
#define S_ISREG(m) (((m) & 0170000) == (0100000))  
#define S_ISDIR(m) (((m) & 0170000) == (0040000))
#define S_IRWXU  0x000B
#define S_IRWXG  0x000B
#define S_IRWXO  0x000B
#define S_IRUSR  0x0000
#define S_IWUSR  0x0009
#define S_IXUSR  0x0009

#include <direct.h>
#include <io.h>
#else
#include <dirent.h>
#endif

#ifdef _WIN32
#define ACCESS _access
#define MKDIR(a) _mkdir((a))
#else
#define ACCESS access
#define MKDIR(a) mkdir((a),0755)
#endif


#include <sys/types.h>
#include <vector>
#include "KData.h"
#include "KFile.h"

typedef bool (*EnumFunc)( KFile& spFile, const KData& relaDir, void* pParam );
typedef bool (*FolderFunc)( const KData& folder, void* pParam );

class KDirectory
{
public:
	KDirectory();
	KDirectory( const KData& dir, bool create = false );
	bool open( const KData& directory, bool create = false );
	bool EnumFiles( EnumFunc func, int mode=KFile::KFILE_NONE, void* pParam=NULL );

	KData getPath();

	void getFiles();
	void getSubDirs();
	KData getFileName( unsigned int index );
	KData getDirName( unsigned int index );
	static bool removeAll( const KData& path, bool recursive=true );
	unsigned int getFileNum();
	unsigned int getDirNum();

	void setIncludeFile( vector<KData> vecFile );
	void setExcludeFile( vector<KData> vecFile );

	bool isIncludeFile( const KData& file );
	bool isExcludeFile( const KData& file );

	static bool rename( const KData& from, const KData& to );
	static bool EnumAllFunc( const KData& fullDir, const KData& relaDir, EnumFunc func, FolderFunc folderFunc=NULL, int mode = KFile::KFILE_NONE, void* pParam=NULL );
	static bool removeDir( const KData& dir );
	static bool isDirectoryExist( const KData& dir );
	static bool createDir( const KData& dir );
	static bool createFileDir( const KData& dir );
	static bool chDir( const KData& dir );
	static bool copyDir( const KData& srcDir, const KData& tarDir );
	static bool isDirEmpty( const KData& fullDir );

protected:
	KData _directory;
	vector< KData > _fileVec;
	vector< KData > _dirVec;
	vector< KData > _vecIncludeFile;
	vector< KData > _vecExcludeFile;
	bool _bIncludeFile;
	bool _bExcludeFile;
};

#endif
