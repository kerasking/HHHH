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
#include "VldHook.h"
#include "LuaStateMgr.h"
#include "ScriptDefine.h"
#include "NDProfile.h"
#include "ScriptGameData_NewUtil.h"
#include "NDLocalXmlString.h"

using namespace cocos2d;
using namespace NDEngine;
using namespace LuaPlus;

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

#ifndef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_WIN32
#endif

//不要删除,留着跟踪全局变量初始化.
struct XX { XX() {
		int xx = 0;
		xx++;
	}} xx;

int WINAPI WinMain (HINSTANCE hInstance, 
					HINSTANCE hPrevInstance, 
					PSTR szCmdLine, 
					int iCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(szCmdLine);

	VLD_HOOK;

	//InitGameInstance();
	NDConsole::instance().BeginReadLoop();

	// 手机平台堆栈会比较小, 以后要改用new
	NDGameApplication kApp;
	NDBaseDirector kBaseDirector;

	CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	eglView->SetTitle("大话龙将");
	eglView->setFrameSize(480, 320); 
	//eglView->setFrameSize(320, 480); 

#if 0
	return CCApplication::sharedApplication()->run();
#else
	int ret = CCApplication::sharedApplication()->run();
	{
		NDProfile::Instance().destroy();
		NDGameDataUtil::destroyAll();
		NDLocalXmlString::GetSingleton().destroy();
	}
	return ret;
#endif
}
#elif defined(ANDROID)

#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "globaldef.h"
#include "NDDebugOpt.h"
#include "MobageSdkLoginAndroid.h"
#include "NDMapMgr.h"

#define  LOG_TAG    "DaHua"
#define  LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;
using namespace NDEngine;

extern "C"
{
    //jstring to char*
    char* jstringTostring(JNIEnv* env, jstring jstr)
    {
        char* rtn = NULL;
        jclass clsstring = env->FindClass("java/lang/String");
        jstring strencode = env->NewStringUTF("utf-8");
        jmethodID mid = env->GetMethodID(clsstring, "getBytes", "(Ljava/lang/String;)[B");
        jbyteArray barr= (jbyteArray)env->CallObjectMethod(jstr, mid, strencode);
        jsize alen = env->GetArrayLength(barr);
        jbyte* ba = env->GetByteArrayElements(barr, JNI_FALSE);
        if (alen > 0)
        {
            rtn = (char*)malloc(alen + 1);
            memcpy(rtn, ba, alen);
            rtn[alen] = 0;
        }
        env->ReleaseByteArrayElements(barr, ba, 0);
        return rtn;
    }
    //char* to jstring
    jstring stoJstring(JNIEnv* env, const char* pat)
    {
        //jclass strClass = env->FindClass("Ljava/lang/String;");
        jclass strClass = env->FindClass("java/lang/String");
        jmethodID ctorID = env->GetMethodID(strClass, "<init>", "([BLjava/lang/String;)V");
        jbyteArray bytes = env->NewByteArray(strlen(pat));
        env->SetByteArrayRegion(bytes, 0, strlen(pat), (jbyte*)pat);
        jstring encoding = env->NewStringUTF("utf-8");
        return (jstring)env->NewObject(strClass, ctorID, bytes, encoding);
    }
    
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
    
	void Java_org_DeNA_DHLJ_DaHuaLongJiang_onLoginComplete(JNIEnv*  env, jobject thiz, jint userid)
	{
		LOGD("Enter Java_org_DeNA_DHLJ_DaHuaLongJiang_onLoginComplete,value is %d",(int)userid);
        MobageSdkLoginAndroid::onLoginComplete(userid);
		LOGD("Leave Java_org_DeNA_DHLJ_DaHuaLongJiang_onLoginComplete,value is %d",(int)userid);
	}
    
	void Java_org_DeNA_DHLJ_DaHuaLongJiang_onLoginError(JNIEnv*  env, jobject thiz, jstring error)
	{
		LOGD("Enter Java_org_DeNA_DHLJ_DaHuaLongJiang_onLoginError");
        MobageSdkLoginAndroid::onLoginError();
		LOGD("Leave Java_org_DeNA_DHLJ_DaHuaLongJiang_onLoginError");
	}
    
    //auth
	void Java_org_DeNA_DHLJ_SocialUtils_onAuthSuccess(JNIEnv*  env, jobject thiz, jstring verifier)
	{
        NDMapMgrObj.ProcessJavaonAuthSuccess(jstringTostring(env, verifier));
    }
    
	void Java_org_DeNA_DHLJ_SocialUtils_onAuthError(JNIEnv*  env, jobject thiz, jstring error)
	{
        NDMapMgrObj.ProcessJavaonAuthError(jstringTostring(env, error));
    }
    
    //continue transaction
	void Java_org_DeNA_DHLJ_SocialUtils_onContinueTransactionSuccess(JNIEnv*  env, jobject thiz, jstring transid)
	{
        NDMapMgrObj.ProcessJavaonContinueTransactionSuccess(jstringTostring(env, transid));
    }
    
	void Java_org_DeNA_DHLJ_SocialUtils_onContinueTransactionError(JNIEnv*  env, jobject thiz, jstring error)
	{
        NDMapMgrObj.ProcessJavaonContinueTransactionError(jstringTostring(env, error));
    }
    
	void Java_org_DeNA_DHLJ_SocialUtils_onContinueTransactionCancel(JNIEnv*  env, jobject thiz)
	{
        NDMapMgrObj.ProcessJavaonContinueTransactionCancel();
    }
    
    //cancel transaction
	void Java_org_DeNA_DHLJ_SocialUtils_onCancelTransactionSuccess(JNIEnv*  env, jobject thiz, jstring transid)
	{
        NDMapMgrObj.ProcessJavaonCancelTransactionSuccess(jstringTostring(env, transid));
    }
    
	void Java_org_DeNA_DHLJ_SocialUtils_onCancelTransactionError(JNIEnv*  env, jobject thiz, jstring error)
	{
        NDMapMgrObj.ProcessJavaonCancelTransactionError(jstringTostring(env, error));
    }
}

#endif