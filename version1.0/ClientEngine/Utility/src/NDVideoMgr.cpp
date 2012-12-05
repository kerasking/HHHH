#include "NDVideoMgr.h"
#include "CCPlatformConfig.h"
#include <string>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android/jni/JniHelper.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#endif

using namespace std;

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDVideoMgr,NDObject)

NDVideoMgr::NDVideoMgr()
{
	m_vecVideoListener.clear();
}

NDVideoMgr::~NDVideoMgr()
{
	ms_spVideoManager = 0;
}

NDVideoMgr* NDVideoMgr::GetVideoMgrSingleton()
{
	if (0 == ms_spVideoManager)
	{
		ms_spVideoManager = new NDVideoMgr;
	}

	return ms_spVideoManager;
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
	if (0 == pszFilename)
	{
		return false;
	}

	string strRet = "";
	JniMethodInfo kMethodInfo;
	memset(&kMethodInfo,0,sizeof(JniMethodInfo));



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

NS_NDENGINE_END