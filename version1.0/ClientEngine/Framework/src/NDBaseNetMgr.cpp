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

bool NDBaseNetMgr::GetServerMsgPacket( NDTransData& data )
{
	return false;
}


bool NDBaseNetMgr::AddNetRawData(const unsigned char* data, unsigned int uilen, bool net/* = true*/)
{
	return false;
}

bool NDBaseNetMgr::AddBackToMenuPacket()
{
	return false;
}

NS_NDENGINE_END