/*
 *  BattleFieldMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-4.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BATTLE_FIELD_MGR_H_
#define _BATTLE_FIELD_MGR_H_

#include "Singleton.h"
#include "NDNetMsg.h"
#include "NDObject.h"
#include "NDUIDialog.h"

#define BattleFieldMgrObj	BattleFieldMgr::GetSingleton()
#define BattleFieldMgrPtr	BattleFieldMgr::GetSingletonPtr()

using namespace NDEngine;

class BattleFieldMgr :
public TSingleton<BattleFieldMgr>,
public NDMsgObject,
public NDObject,
public NDUIDialogDelegate
{
	DECLARE_CLASS(BattleFieldMgr)
public:
	BattleFieldMgr();
	~BattleFieldMgr();
	
	void OnDialogClose(NDUIDialog* dialog); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	/*处理感兴趣的网络消息*/
	bool process(MSGID msgID, NDTransData* data, int len); override
	
	void processShopBattle(NDTransData& data);
	
	void processShopBattleGoodsType(NDTransData& data);
	
	void processBattleFieldList(NDTransData& data);
	
	void processBattleFieldSignUp(NDTransData& data);
	
	void processBattleFieldUpdateSignIn(NDTransData& data);
	
	void processBattleFieldIntro(NDTransData& data);
	
	void processBattleFieldSignIn(NDTransData& data);
	
	void processBattleFieldRelive(NDTransData& data);
	
	void processBattleFieldConfirm(NDTransData& data);
	
	void SendRequestApplyInfo(int bfType, bool bAttachRule);
	
	void SendSign(int bfType, int seq, bool apply);
	
	void SendRequestBfDesc();
	
	void SendRequestBfBackStory(int bfType);
	
	void SendRequestBfRelive(bool reliveInCurPlace);
	
private:

	NDUIDialog					*m_dlgEnterBFConfirm;
};
#endif // _BATTLE_FIELD_MGR_H_