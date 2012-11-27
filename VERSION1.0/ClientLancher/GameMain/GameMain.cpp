/*
*
*/
#include <LuaPlus.h>
#include <NDBaseDirector.h>
#include <NDGameApplication.h>
#include "NDSharedPtr.h"

#ifdef WIN32
#include "windows.h"
#include "GameApp.h"
//#include "CCString.h"
#include "XMLReader.h"
#include "NDConsole.h"
#include "NDBaseDirector.h"

using namespace cocos2d;
using namespace NDEngine;
using namespace LuaPlus;

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

#ifndef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_WIN32
#endif

int WINAPI WinMain (HINSTANCE hInstance, 
					HINSTANCE hPrevInstance, 
					PSTR szCmdLine, 
					int iCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(szCmdLine);

	//InitGameInstance();
	NDConsole kConsole;
	kConsole.BeginReadLoop();

	// 手机平台堆栈会比较小, 以后要改用new
	NDGameApplication kApp;
	NDBaseDirector kBaseDirector;

	CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	eglView->SetTitle("大话龙将");
	eglView->setFrameSize(480, 320); 
	//eglView->setFrameSize(320, 480); 

	return CCApplication::sharedApplication()->run();
}
#elif defined(ANDROID)

#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "globaldef.h"
#include "NDDebugOpt.h"

#define  LOG_TAG    "DaHua"
#define  LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;
using namespace NDEngine;

extern "C"
{
	jint JNI_OnLoad(JavaVM *vm, void *reserved)
	{
		JniHelper::setJavaVM(vm);

		return JNI_VERSION_1_4;
	}

	void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeInit(JNIEnv*  env, jobject thiz, jint w, jint h)
	{
		LOGD("Starting nativeInit");

		if (!CCDirector::sharedDirector()->getOpenGLView())
		{
			LOGD("Starting set CCEGLView");

			CCEGLView *view = CCEGLView::sharedOpenGLView();
			
			view->setFrameSize(w, h);
			LOGD("ready set frame size,w = %d,h = %d",w,h);
			NDSharedPtr<NDGameApplication> spApp = new NDGameApplication;
			LOGD("Starting CApplication run");
			CCApplication::sharedApplication()->run();
		}
		else
		{
			LOGD("ccDrawInit()");
			ccDrawInit();
			ccGLInvalidateStateCache();

			CCShaderCache::sharedShaderCache()->reloadDefaultShaders();
			CCTextureCache::reloadAllTextures();
			CCNotificationCenter::sharedNotificationCenter()->postNotification(EVNET_COME_TO_FOREGROUND, NULL);
			CCDirector::sharedDirector()->setGLDefaultValues(); 
		}
	}

	void Java_org_DeNA_DHLJ_DaHuaLongJiang_nativeInit(JNIEnv*  env, jobject thiz, jint w, jint h)
	{
		NDBaseDirector* spDirector = 0;
		spDirector = new NDBaseDirector;
		LOGD("Leave Java_org_DeNA_DHLJ_DaHuaLongJiang_nativeInit,value is %d",(int)spDirector);
	}

}

#endif