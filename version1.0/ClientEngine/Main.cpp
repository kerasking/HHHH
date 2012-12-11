#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "NDVideoMgr.h"

#define  LOG_TAG    "DaHua"
#define  LOGD(...)

using namespace NDEngine;
using namespace cocos2d;

extern "C"
{
//	jint JNI_OnLoad(JavaVM *vm, void *reserved)
//	{
//		JniHelper::setJavaVM(vm);
//
//		return JNI_VERSION_1_4;
//	}
	
	JNIEXPORT void JNICALL Java_org_DeNA_DHLJ_NDVideoControl_onCompletionCallback()
	{
		VideoMgrPtr->StopVideo();
	}
}