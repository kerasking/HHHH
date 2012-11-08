#include "NDBaseNetMgr.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDBaseNetMgr,NDObject)

NDBaseNetMgr::NDBaseNetMgr()
{

}

NDBaseNetMgr::~NDBaseNetMgr()
{

}

bool NDBaseNetMgr::Process( NDEngine::NDTransData* data )
{
	return true;
}

bool NDBaseNetMgr::Process( unsigned short msgID, NDEngine::NDTransData* data, int len )
{
	return true;
}

bool NDBaseNetMgr::RegMsg( unsigned short msgID, NDMsgObject* msgObj )
{
	return true;
}

void NDBaseNetMgr::UnRegMsg( unsigned short msgID )
{

}

NS_NDENGINE_END