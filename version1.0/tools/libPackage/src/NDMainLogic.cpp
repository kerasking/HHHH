#include "NDMainLogic.h"
#include <string>

using namespace std;

NDMainLogic* NDMainLogic::ms_pkMainLogic = 0;

NDMainLogic::NDMainLogic()
{

}

NDMainLogic::~NDMainLogic()
{

}

NDMainLogic* NDMainLogic::sharedMainLogic()
{
	if (0 == ms_pkMainLogic)
	{
		ms_pkMainLogic = new NDMainLogic;
	}

	return ms_pkMainLogic;
}

bool NDMainLogic::zipDirectory( const char* pszSrcFolder,
							   const char* pszTargetPath,
							   const char* pszTargetFilename )
{
	if (0 == pszTargetFilename ||
		!*pszTargetFilename ||
		0 == pszSrcFolder ||
		!*pszSrcFolder ||
		0 == pszTargetPath ||
		!*pszTargetPath)
	{
		return false;
	}

	return true;
}