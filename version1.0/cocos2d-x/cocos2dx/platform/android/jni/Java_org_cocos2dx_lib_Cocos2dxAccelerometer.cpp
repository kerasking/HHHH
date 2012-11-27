#include "cocoa/CCGeometry.h"
#include "platform/android/CCAccelerometer.h"
#include "../CCEGLView.h"
#include "JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "CCDirector.h"

#if 0
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define LOGD(...)
#endif

using namespace cocos2d;

extern "C" {
    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxAccelerometer_onSensorChanged(JNIEnv*  env, jobject thiz, jfloat x, jfloat y, jfloat z, jlong timeStamp) {
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxAccelerometer_onSensorChanged");
        CCDirector* pDirector = CCDirector::sharedDirector();
        pDirector->getAccelerometer()->update(x, y, z, timeStamp);
    }    
}
