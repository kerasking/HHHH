#include "NDMapMgr.h"

namespace NDEngine
{

IMPLEMENT_CLASS(NDMapMgr,NDObject);

NDMapMgr::NDMapMgr()
{

}

NDMapMgr::~NDMapMgr()
{

}

bool NDMapMgr::process( MSGID usMsgID, NDEngine::NDTransData* pkData, int nLength )
{
	switch (usMsgID)
	{
	case _MSG_CHG_PET_POINT:
		{
			int nBtAnswer = pkData->ReadByte();
		}
		break;
	default:
		break;
	}

	return true;
}

}