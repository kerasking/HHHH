#include "NDUtil.h"
#include<iostream>
#include "ObjectTracker.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "NDConsole.h"
#endif

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
//#include <io.h>
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace std;
using namespace NDEngine;

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDUtil, NDObject)

bool IsPointInside(cocos2d::CCPoint kPoint, cocos2d::CCRect kRect)
{
	return (kPoint.x >= kRect.origin.x && kPoint.y >= kRect.origin.y
		&& kPoint.x <= kRect.size.width + kRect.origin.x
		&& kPoint.y <= kRect.size.height + kRect.origin.y);
}

NDUtil::NDUtil()
{
	INC_NDOBJ_RTCLS
}

NDUtil::~NDUtil()
{
	DEC_NDOBJ_RTCLS
}

STRING_VEC NDUtil::ErgodicFolderForSpceialFileExtName(const char* pszPath,
													  const char* pszExtFilename)
{
	STRING_VEC kStringVec;

	if (0 == pszPath || !*pszPath)
	{
		return kStringVec;
	}

	return kStringVec;
}

void NDUtil::QuitGameToServerList()
{

}

NS_NDENGINE_END


void WriteCon(const char * pszFormat, ...)
{
	if (!pszFormat) return;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	HANDLE hOut = NDConsole::instance().getOutputHandle();
	if (!hOut) return;

	static char szBuf[1024] = {0};
	va_list ap;
	va_start(ap, pszFormat);
	vsnprintf_s(szBuf, 1024, 1024, pszFormat, ap);
	va_end(ap);

	DWORD n = 0;
	WriteConsoleA( hOut, szBuf, strlen(szBuf), &n, NULL );
#endif
}
