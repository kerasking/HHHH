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

protected:

	static NDMainLogic* ms_pkMainLogic;

private:
};

#endif