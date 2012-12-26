#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "NDVideoMgr.h"
#include "../cocos2d-x/cocos2dx/CCDirector.h"
#include "../cocos2d-x/CocosDenshion/include/SimpleAudioEngine.h"

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)

using namespace NDEngine;
using namespace cocos2d;
using namespace CocosDenshion;

extern "C"
{	
	JNIEXPORT void JNICALL Java_org_DeNA_DHLJ_NDVideoControl_onCompletionCallback()
	{
		LOGD("Entry Java_org_DeNA_DHLJ_NDVideoControl_onCompletionCallback");
		CCDirector::sharedDirector()->startAnimation();
		LOGD("Leave Java_org_DeNA_DHLJ_NDVideoControl_onCompletionCallback");
	}

	JNIEXPORT void JNICALL Java_org_DeNA_DHLJ_DaHuaLongJiang_pauseAllBackgroundMusic()
	{
		SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
	}

	JNIEXPORT void JNICALL Java_org_DeNA_DHLJ_DaHuaLongJiang_resumeBackgroundMusic()
	{
		SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
	}
}