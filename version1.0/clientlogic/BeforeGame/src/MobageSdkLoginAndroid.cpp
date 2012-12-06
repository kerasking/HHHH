/*
 *  NDSdkLogin.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "MobageSdkLoginAndroid.h"
#import "ScriptGlobalEvent.h"
#import "NDDirector.h"
#include "ScriptMgr.h"

#import "NDBeforeGameMgr.h"
#import "SMLoginScene.h"
#import "SMGameScene.h"

void MobageSdkLoginAndroid::onLoginComplete(int userId) {
//	NDLog("app delegate onLoginComplete userId %d", userId);
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	mgr.SetCurrentUser(userId);
    //ScriptGlobalEvent::OnEvent(GE_LOGINOK_NORMAL, [userId intValue]);
    CSMGameScene * pGameScene = (CSMGameScene *)NDDirector::DefaultDirector()->GetSceneByTag(SMGAMESCENE_TAG);
    if ( pGameScene )
    {
        ScriptMgrObj.excuteLuaFunc( "SetAccountID", "Login_ServerUI", userId );
        quitGame();
        return;
    }
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
        if( pScene->GetChild( 2068 ) )//Login_ServerUI
        {
            ScriptMgrObj.excuteLuaFunc( "LoginOK_Normal", "Login_ServerUI", userId );
            return;
        }
        else
			return pScene->OnEvent_LoginOKGuest(userId);
	}
}

void MobageSdkLoginAndroid::onLoginError() {
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
		return pScene->OnEvent_LoginError(0);
	}
}

