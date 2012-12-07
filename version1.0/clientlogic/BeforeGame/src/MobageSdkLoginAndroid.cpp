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

#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHua"
#define  LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

void MobageSdkLoginAndroid::onLoginComplete(int userId) {
	LOGD("app delegate onLoginComplete userId %d", userId);
    ScriptMgrObj.excuteLuaFunc( "SetAccountID", "Login_ServerUI", userId );
	LOGD("SetAccountID success!");
}

void MobageSdkLoginAndroid::onLoginError() {
	CSMLoginScene* pScene = (CSMLoginScene*)NDDirector::DefaultDirector()->GetSceneByTag(SMLOGINSCENE_TAG);
	if(pScene)
	{
		return pScene->OnEvent_LoginError(0);
	}
}

