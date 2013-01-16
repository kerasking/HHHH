/*
*
*/

#ifndef NDMAINLOGIC_H
#define NDMAINLOGIC_H

#include "NDPackageDefine.h"

class NDMainLogic
{
public:

	NDMainLogic();
	virtual ~NDMainLogic();

	NDMainLogic* sharedMainLogic();

	bool zipDirectory(const char* pszSrcFolder,const char* pszTargetPath,const char* pszTargetFilename);

protected:

	static NDMainLogic* ms_pkMainLogic;

private:
};

#endif