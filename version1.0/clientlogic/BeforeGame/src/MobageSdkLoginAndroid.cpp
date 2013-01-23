/*
 *  NDSdkLogin.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-14.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "MobageSdkLoginAndroid.h"
#include "ScriptGlobalEvent.h"
#include "NDDirector.h"
#include "ScriptMgr.h"

#include "NDBeforeGameMgr.h"
#include "SMLoginScene.h"
#include "SMGameScene.h"
#include "NDDataTransThread.h"

#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHua"
#define  LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

void MobageSdkLoginAndroid::onLoginComplete(int userId) {
	LOGD("@@login app delegate onLoginComplete userId %d", userId);
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	mgr.SetCurrentUser(userId);
    //ScriptMgrObj.excuteLuaFunc( "SetAccountID", "Login_ServerUI", userId );
//	ScriptMgrPtr->excuteLuaFunc( "ShowUI", "Entry", userId );
	LOGD("SetAccountID success!");
}

void MobageSdkLoginAndroid::onLoginError() {
    
}

void MobageSdkLoginAndroid::onLogout() {
    quitGame();
}
