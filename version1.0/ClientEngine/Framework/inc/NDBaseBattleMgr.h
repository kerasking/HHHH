/*
*
*/

#ifndef NDBASEBATTLEMGR_H
#define NDBASEBATTLEMGR_H

#include "define.h"
#include "NDObject.h"
#include "NDBaseNetMgr.h"
#include "NDTimer.h"
#include "EnumDef.h"

NS_NDENGINE_BGN

class NDBaseBattleMgr:
	public NDObject,
	public TSingleton<NDBaseBattleMgr>,
	public NDMsgObject,
	public ITimerCallback
{
	DECLARE_CLASS(NDBaseBattleMgr)

public:

	NDBaseBattleMgr();
	virtual ~NDBaseBattleMgr();

	virtual bool process( unsigned short msgID, NDEngine::NDTransData*, int len );
	virtual void quitBattle(bool bEraseOut = true);
	virtual void OnTimer( OBJID tag );
	virtual void showBattleScene();

protected:
private:
};

NS_NDENGINE_END

#define NDBattleBaseMgrObj NDBaseBattleMgr::GetBackSingleton("BattleMgr")

#endif