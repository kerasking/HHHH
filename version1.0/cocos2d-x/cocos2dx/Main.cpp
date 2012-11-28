#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHua"
#define  LOGD(...)

using namespace cocos2d;

extern "C"
{
	jint JNI_OnLoad(JavaVM *vm, void *reserved)
	{
		JniHelper::setJavaVM(vm);

		return JNI_VERSION_1_4;
	}
}