#include "text_input_node/CCIMEDispatcher.h"
#include "CCDirector.h"
#include "../CCApplication.h"
#include "platform/CCFileUtils.h"
#include "CCEventType.h"
#include "support/CCNotificationCenter.h"
#include "JniHelper.h"
#include <android/log.h>
#include <jni.h>

#if 0
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define LOGD(...)
#endif

using namespace cocos2d;

extern "C" {
    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeRender(JNIEnv* env) {
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeRender");
        cocos2d::CCDirector::sharedDirector()->mainLoop();
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnPause() {
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnPause");
        CCApplication::sharedApplication()->applicationDidEnterBackground();

        CCNotificationCenter::sharedNotificationCenter()->postNotification(EVENT_COME_TO_BACKGROUND, NULL);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnResume() {
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnResume");
        if (CCDirector::sharedDirector()->getOpenGLView()) {
			LOGD("CCDirector::sharedDirector()->getOpenGLView() has value");
            CCApplication::sharedApplication()->applicationWillEnterForeground();
        }
		LOGD("leave Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeOnResume");
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInsertText(JNIEnv* env, jobject thiz, jstring text) {
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInsertText");
        const char* pszText = env->GetStringUTFChars(text, NULL);
        cocos2d::CCIMEDispatcher::sharedDispatcher()->dispatchInsertText(pszText, strlen(pszText));
        env->ReleaseStringUTFChars(text, pszText);
    }

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeDeleteBackward(JNIEnv* env, jobject thiz) {
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeDeleteBackward");
        cocos2d::CCIMEDispatcher::sharedDispatcher()->dispatchDeleteBackward();
    }

    JNIEXPORT jstring JNICALL Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeGetContentText() {
        JNIEnv * env = 0;
		LOGD("entry Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeGetContentText");
        if (JniHelper::getJavaVM()->GetEnv((void**)&env, JNI_VERSION_1_4) != JNI_OK || ! env) {
            return 0;
        }
        const char * pszText = cocos2d::CCIMEDispatcher::sharedDispatcher()->getContentText();
        return env->NewStringUTF(pszText);
    }
}
