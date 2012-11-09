#include "NDBaseBattleMgr.h"

NS_NDENGINE_BGN

IMPLEMENT_CLASS(NDBaseBattleMgr,NDObject)

NDBaseBattleMgr::NDBaseBattleMgr()
{

}

NDBaseBattleMgr::~NDBaseBattleMgr()
{

}

bool NDBaseBattleMgr::process( unsigned short msgID, NDEngine::NDTransData*, int len )
{
	return true;
}

void NDBaseBattleMgr::OnTimer( OBJID tag )
{
}

void NDBaseBattleMgr::showBattleScene()
{
	
}

void NDBaseBattleMgr::quitBattle( bool bEraseOut /*= true*/ )
{

}

NS_NDENGINE_END