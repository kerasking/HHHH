#include "NDMainLogic.h"

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