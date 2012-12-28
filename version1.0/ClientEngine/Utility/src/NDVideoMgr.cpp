#include "NDVideoMgr.h"
#include "CCPlatformConfig.h"
#include <string>
#include "ObjectTracker.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace std;
using namespace cocos2d;

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDVideoMgr,NDObject)

NDVideoMgr* NDVideoMgr::ms_pkVideoManager = 0;

NDVideoMgr::NDVideoMgr()
{
	INC_NDOBJ_RTCLS
	m_vecVideoListener.clear();
}

NDVideoMgr::~NDVideoMgr()
{
	DEC_NDOBJ_RTCLS
	SAFE_DELETE(ms_pkVideoManager);
}

NDVideoMgr* NDVideoMgr::GetVideoMgrSingleton()
{
	if (0 == ms_pkVideoManager)
	{
		ms_pkVideoManager = new NDVideoMgr;
	}

	return ms_pkVideoManager;
}

bool NDVideoMgr::PlayVideo( const char* pszFilename )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return PlayVideoForAndroid(pszFilename);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return PlayVideoForIOS(pszFilename);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	return PlayVideoForWin32(pszFilename);
#endif

	return false;
}

bool NDVideoMgr::PlayVideoForAndroid( const char* pszFilename )
{
	LOGD("Entry PlayVideoForAndroid");

	if (0 == pszFilename)
	{
		LOGERROR("pszFilename is null!");
		return false;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	string strRet = "";
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"playVideo",
		"(Ljava/lang/String;)I"))
	{
		LOGD("the t value is:env = %d,classID = %d,methodID = %d",(int)t.env,(int)t.classID,(int)t.methodID);

		jstring stringArg1;
		stringArg1 = t.env->NewStringUTF(pszFilename);

		jint retFromJava = (jint) t.env->CallStaticObjectMethod(t.classID,
			t.methodID, stringArg1);

		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(t.classID);
	}

#endif

	LOGD("Leave PlayVideoForAndroid");
	return true;
}

bool NDVideoMgr::PlayVideoForWin32( const char* pszFilename )
{
	if (0 == pszFilename)
	{
		return false;
	}

	return true;
}

bool NDVideoMgr::PlayVideoForIOS( const char* pszFilename )
{
	if (0 == pszFilename)
	{
		return false;
	}

	return true;
}

bool NDVideoMgr::RegisterVideoListener( NDVideoEventListener* pkVideoListener )
{
	if (0 == pkVideoListener)
	{
		return false;
	}

	NDSharedPtr<NDVideoEventListener> spListener = pkVideoListener;
	m_vecVideoListener.push_back(spListener);

	return true;
}

bool NDVideoMgr::StopVideo()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	string strRet = "";
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"playVideo",
		"(Ljava/lang/String;)I"))
	{
		LOGD("the t value is:env = %d,classID = %d,methodID = %d",(int)t.env,(int)t.classID,(int)t.methodID);

		jstring stringArg1;
		stringArg1 = t.env->NewStringUTF("");

		jint retFromJava = (jint) t.env->CallStaticObjectMethod(t.classID,
			t.methodID, stringArg1);

		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(t.classID);
	}

#endif

	return true;
}

NS_NDENGINE_END