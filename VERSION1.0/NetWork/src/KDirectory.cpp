#ifdef WIN32
#else
#include <dirent.h>
#include <unistd.h>
#endif
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "KDirectory.h"
KDirectory::KDirectory()
{
	_bIncludeFile = false;
	_bExcludeFile = false;
}


KDirectory::KDirectory( const KData& dir, bool create )
{
	open( dir, create );
}


KData KDirectory::getPath()
{
	return _directory;
}


bool
KDirectory::isDirectoryExist( const KData& dir  )
{	
	struct stat statbuf;
	if ( stat(dir.getData(),&statbuf) == -1 )
		return false;
	if ( S_ISDIR(statbuf.st_mode) )
		return true;
	else
		return false;
}


bool KDirectory::createDir( const KData& dir )
{
	int pos = 0;
	while ( true )
	{
		if ( (pos=dir.find("/",pos)) == -1 )
			pos = dir.length();
		KData dtDir = dir.substr( 0,pos );
		pos++;
		if ( !dtDir.isEmpty() )
		{
			if ( !isDirectoryExist(dtDir) )
			{
				/*
				if ( -1 == mkdir(dtDir.getData(),S_IRWXU|S_IRWXG|S_IRWXO) )
				{
					return false;
				}
				*/
				if (MKDIR(dtDir.getData())!= 0)
				{
					return false;
				} 

			}
		}
		if ( pos >= (int)dir.length() )
			break;
	}	
	return true;	
}

bool KDirectory::createFileDir( const KData& dir )
{
	int pos = 0;
	while ( true )
	{
		if ( (pos=dir.find("/",pos)) == -1 )
			break;
		KData dtDir = dir.substr( 0,pos );
		pos++;
		if ( !dtDir.isEmpty() )
		{
			if ( !isDirectoryExist(dtDir) )
			{
				/*
				if ( -1 == mkdir(dtDir.getData(),S_IRWXU|S_IRWXG|S_IRWXO) )
				{
					return false;
				}
				*/
				if (MKDIR(dtDir.getData())!= 0)
				{
					return false;
				} 
			}
		}
	}	
	return true;
}


bool KDirectory::chDir( const KData& dir )
{
	if ( chdir(dir.getData()) == 0 )
		return true;
	else
		return false;
}

struct CopyParam
{
	KData dtTarDir;
};
/*
bool CopyFileFunc( KFile& spFile, const KData& relaDir, void* pParam )
{
	CopyParam* pCopyParam = (CopyParam*)pParam;
	KData dtTarFile = pCopyParam->dtTarDir + relaDir + spFile.getFileName();
	return spFile.copyTo( dtTarFile );
}

bool CreateDirFunc( const KData& folder, void* pParam )
{
	CopyParam* pCopyParam = (CopyParam*)pParam;
	return KDirectory::createDir( pCopyParam->dtTarDir+folder );
}
*/
/*
bool KDirectory::copyDir( const KData& srcDir, const KData& tarDir )
{
	KData dtSrcDir = srcDir;
	dtSrcDir.makePath();
	KData dtTarDir = tarDir;
	dtTarDir.makePath();

	CopyParam param;
	param.dtTarDir = dtTarDir;
	createDir( tarDir );
	return EnumAllFunc( dtSrcDir, "", CopyFileFunc, CreateDirFunc, KFile::KFILE_READ, &param );
}
*/
/*
bool KDirectory::isDirEmpty( const KData& fullDir )
{
	KData dtDir = fullDir;
	dtDir.makePath( true );
	DIR* dir;
	if ( (dir=opendir(dtDir.getData())) == NULL )
		return false;
	struct dirent *pDirent;
	while( ( pDirent = readdir(dir) ) != NULL  )
	{
		struct stat statbuf;
		KData dtPath = dtDir;
		dtPath += pDirent->d_name;
		if ( stat(dtPath.getData(),&statbuf) == -1 )
			continue;
		if ( S_ISDIR(statbuf.st_mode) )
		{
			if ( pDirent->d_name && strcmp(pDirent->d_name,".") && strcmp(pDirent->d_name,"..") )
			{
				if ( !isDirEmpty(dtPath) )
				{
					closedir( dir );
					return false;
				}
			}
		}
		else
		{
			closedir( dir );
			return false;
		}
	}
	closedir( dir );
	return true;

}
*/
bool KDirectory::open( const KData& directory, bool create )
{
	if ( directory.isEmpty() )
	{
		return false;
	}

	KData dir = directory;
	int pos;
	KData dtKData = "\\";
	while ( (pos=dir.find(dtKData)) != -1 )
    {
        dir.replace( pos, 1, "/" );
    }
	_directory.erase();

	bool bDirExist = isDirectoryExist( dir );
	if ( !bDirExist )
	{
		if ( create )
		{
			if ( !createDir(dir) )
				return false;
		}
		else
		{
			return false;
		}
	}
	_directory = dir;
	_directory.makePath();
	return true;
}


bool KDirectory::rename( const KData& from, const KData& to )
{
	if ( rename(from.getData(),to.getData()) == 0 )
		return true;
	else
		return false;
}

/*
bool KDirectory::EnumAllFunc( const KData& fullDir, const KData& relaDir, EnumFunc func, FolderFunc folderFunc, int mode, void* pParam )
{
	DIR* dir;
	if ( (dir=opendir(fullDir.getData())) == NULL )
		return false;
	struct dirent *pDirent;
	while( ( pDirent = readdir(dir) ) != NULL  )
	{
		struct stat statbuf;
		KData dtPath = fullDir;
		dtPath += pDirent->d_name;
		if ( stat(dtPath.getData(),&statbuf) == -1 )
			continue;
		if ( S_ISDIR(statbuf.st_mode) )
		{
			if ( pDirent->d_name && strcmp(pDirent->d_name,".")!=0 && strcmp(pDirent->d_name,"..")!=0 )
			{
				KData dtRelaPath = relaDir;
				dtRelaPath += pDirent->d_name;
				if ( folderFunc != NULL )
					folderFunc( dtRelaPath, pParam );
				if ( !EnumAllFunc(dtPath+"/",dtRelaPath+"/",func,folderFunc,mode,pParam) )
					return false;
			}
		}
		else
		{
			KFile file( dtPath, mode );
			if ( !func( file, relaDir, pParam ) )
				return false;
		}
	}
	closedir( dir );
	return true;
}
*/
/*
bool KDirectory::EnumFiles( EnumFunc func, int mode, void* pParam )
{
	bool bRet = true;

	DIR* dir;
	if ( (dir=opendir(_directory.getData())) == NULL )
	{
		return false;
	}
	struct dirent *pDirent;
	while( ( pDirent = readdir(dir) ) != NULL  )
	{
		KData dtDir = _directory;
		dtDir += pDirent->d_name;
		KFile file( dtDir.getData(), KFile::KFILE_READ );
		if ( !func( file, "", pParam ) )
		{
			bRet = false;
			break;
		}
	}
	closedir( dir );
	return bRet;
}
*/
/*
void KDirectory::getFiles()
{
	_fileVec.clear();
	if ( _directory.isEmpty() )
	{
		return;
	}
	
	DIR* dir;
	if ( (dir=opendir(_directory.getData())) == NULL )
		return;
	struct dirent *pDirent;
	while( ( pDirent = readdir(dir) ) != NULL  )
	{
		struct stat statbuf;
		KData dtPath = _directory;
		dtPath += pDirent->d_name;
		if ( stat(dtPath.getData(),&statbuf) == -1 )
			continue;
		if ( !S_ISDIR(statbuf.st_mode) )
		{
			if ( _bIncludeFile )
			{
				if ( !isIncludeFile(pDirent->d_name) )
					continue;
			}
			if ( _bExcludeFile )
			{
				if ( isExcludeFile(pDirent->d_name) )
					continue;
			}
			_fileVec.push_back( pDirent->d_name );
		}
	}
	closedir( dir );
}
*/
/*
void KDirectory::getSubDirs()
{
	_dirVec.clear();
	DIR* dir;
	if ( (dir=opendir(_directory.getData())) == NULL )
		return;
	struct dirent *pDirent;
	while( ( pDirent = readdir(dir) ) != NULL  )
	{
		struct stat statbuf;
		KData dtPath = _directory;
		dtPath += pDirent->d_name;
		if ( stat(dtPath.getData(),&statbuf) == -1 )
			continue;
		if (S_ISDIR(statbuf.st_mode) )		
		{
			if ( strcmp(pDirent->d_name,".")!=0 && strcmp(pDirent->d_name,"..")!=0 )
			{
				_dirVec.push_back( pDirent->d_name );
			}
		}
	}
	closedir( dir );
}
*/

KData KDirectory::getFileName( unsigned int index )
{
	if ( _fileVec.size() <= index )
		return "";
	return _fileVec[index];
}

KData KDirectory::getDirName( unsigned int index )
{
	if ( _dirVec.size() <= index )
		return "";
	return _dirVec[index];
}

unsigned KDirectory::getDirNum()
{
	return _dirVec.size();
}

unsigned int KDirectory::getFileNum()
{
	return _fileVec.size();
}
/*
bool KDirectory::removeAll( const KData& path, bool recursive )
{
	DIR* dir;
	if ( (dir=opendir(path.getData())) == NULL )
		return false;
	struct dirent *pDirent;
	KData dtPath = path;
	dtPath.makePath();
	while( ( pDirent=readdir(dir) ) != NULL  )
	{
		if ( strcmp(pDirent->d_name,".")==0 || strcmp(pDirent->d_name,"..")==0 )
			continue;
		KData dtVal = dtPath + KData(pDirent->d_name);
		struct stat statbuf;
		if ( stat(dtVal.getData(),&statbuf) == -1 )
		{
			closedir( dir );
			return false;
		}
		if ( S_ISDIR(statbuf.st_mode) )
		{
			if ( recursive )
			{
				if ( !removeAll( dtVal ) )
				{
					closedir( dir );
					return false;
				}
				if ( remove(dtVal.getData()) != 0 )
				{
					closedir( dir );
					return false;
				}
			}
		}
		else
		{
			if ( remove(dtVal.getData()) != 0 )
			{
				closedir( dir );
				return false;
			}
		}
	}
	closedir( dir );
	return true;
}

*/
/*
bool KDirectory::removeDir( const KData& dir )
{
	if ( removeAll( dir ) )
	{
		if ( remove(dir.getData()) )
			return true;
		else
			return false;
	}
	else
	{
		return false;
	}
}
*/
void KDirectory::setIncludeFile( vector<KData> vecFile )
{
	_bIncludeFile = true;
	_vecIncludeFile = vecFile;
}

void KDirectory::setExcludeFile( vector<KData> vecFile )
{
	_bExcludeFile = true;
	_vecExcludeFile = vecFile;
}

bool KDirectory::isIncludeFile( const KData& file )
{
	for ( vector<KData>::iterator iter=_vecIncludeFile.begin(); iter!=_vecIncludeFile.end(); iter++ )
	{
		if ( file.isEndWith(*iter,false) )
		{
			return true;
		}
	}
	return false;
}

bool KDirectory::isExcludeFile( const KData& file )
{
	for ( vector<KData>::iterator iter=_vecExcludeFile.begin(); iter!=_vecExcludeFile.end(); iter++ )
	{
		if ( file.isEndWith(*iter,false) )
			return true;
	}
	return false;
}