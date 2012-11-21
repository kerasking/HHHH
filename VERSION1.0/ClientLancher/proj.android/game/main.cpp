#include "NDGameApplication.h"
#include "GameLauncher.h"
#include "NDSharedPtr.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "NDBaseDirector.h"
#include "globaldef.h"
#include "NDDebugOpt.h"

#define  LOG_TAG    "DaHua"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;
using namespace NDEngine;

extern "C"
{

jint JNI_OnLoad(JavaVM *vm, void *reserved)
{
	JniHelper::setJavaVM(vm);

	printf("StartMain");

	return JNI_VERSION_1_4;
}

void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit(JNIEnv*  env, jobject thiz, jint w, jint h)
{
	for(int i = 0;i < 100;i++)
	{
		printf("StartMain");
	}

    if (!cocos2d::CCDirector::sharedDirector()->getOpenGLView())
    {
    	for(int i = 0;i < 100;i++)
    	{
    		printf("StartMain");
    	}

        NDBaseDirector* kBaseDirector = new NDBaseDirector;

    	cocos2d::CCEGLView *view = &cocos2d::CCEGLView::sharedOpenGLView();
        view->setFrameWidthAndHeight(w, h);
        // if you want to run in WVGA with HVGA resource, set it
        // view->create(480, 320);  Please change it to (320, 480) if you're in portrait mode.
        cocos2d::CCDirector::sharedDirector()->setOpenGLView(view);

        NDSharedPtr<GameLauncher> spGameLauncher = new GameLauncher;

        CCApplication::sharedApplication().run();
    }
    else
    {
        cocos2d::CCTextureCache::reloadAllTextures();
        cocos2d::CCDirector::sharedDirector()->setGLDefaultValues();
    }
}

void Java_org_DeNA_DHLJ_DaHuaLongJiang_nativeInit(JNIEnv*  env, jobject thiz, jint w, jint h)
{
	LOGD("Starting nativeInit");

	LOGD("Starting set CCEGLView");

	NDBaseDirector* pkBaseDirector = new NDBaseDirector;

	cocos2d::CCEGLView* view = cocos2d::CCEGLView::sharedOpenGLViewPtr();

	LOGD("view got! value is %d",(int)view);

    view->setFrameWidthAndHeight(w, h);
    LOGD(" view->setFrameWidthAndHeight(w, h);! w = %d , h = %d",w,h);
    view->create(480, 320); // Please change it to (320, 480) if you're in portrait mode.

    LOGD("view's width = %d,height = %d",view->getSize().width,view->getSize().height);

    cocos2d::CCDirector::sharedDirector()->setOpenGLView(view);

    LOGD("cocos2d::CCDirector::sharedDirector()->setOpenGLView(view); called over");

	NDGameApplication* pkGameLauncher = new NDGameApplication;

    LOGD("Starting set run");

    NDGameApplication::SetApp(pkGameLauncher);
    NDGameApplication::sharedApplication().run();
}

}
