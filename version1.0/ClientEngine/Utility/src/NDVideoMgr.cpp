#include "NDVideoMgr.h"
#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#endif

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
	if (0 == pszFilename || !*pszFilename)
	{
		return false;
	}

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
	return true;
}

bool NDVideoMgr::PlayVideoForWin32( const char* pszFilename )
{
	return true;
}

bool NDVideoMgr::PlayVideoForIOS( const char* pszFilename )
{
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