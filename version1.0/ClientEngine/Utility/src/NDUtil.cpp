#include "NDUtil.h"
#include<iostream>
#include "ObjectTracker.h"
#include "myunzip.h"
#include "CCFileUtils.h"

using namespace cocos2d;

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

unsigned char* NDUtil::GetFileBufferFromSimplifiedChineseResZip( const char* pszPath,
																unsigned int* puiLength )
{
	LOGD("Entry GetFileBufferFromSimplifiedChineseResZip,pszPath is %s",pszPath);

	unsigned char* pszResult = 0;
	unsigned char* pszZipBuffer = 0;
	unsigned long ulFileSize = 0;
	int nFileIndex = 0;
	ZIPENTRY kZipEntry = {0};
	HZIP hZip = 0;

	if (0 == pszPath || !*pszPath || 0 == puiLength)
	{
		LOGERROR("pszResult is null or puiLength = 0");
		return 0;
	}

	pszZipBuffer = CCFileUtils::sharedFileUtils()->
		getFileData("assets/SimplifiedChineseRes.zip","rb",&ulFileSize);

	if (0 == pszZipBuffer)
	{
		LOGERROR("pszZipBuffer is null");
		return 0;
	}

	hZip = OpenZip((void*)pszZipBuffer,ulFileSize,0);

	if (0 == hZip)
	{
		SAFE_DELETE_ARRAY(pszZipBuffer);
		LOGERROR("hZip is null");
		return 0;
	}

	FindZipItem(hZip,pszPath,true,&nFileIndex,&kZipEntry);

	if (kZipEntry.unc_size == 0)
	{
		CloseZip(hZip);
		SAFE_DELETE_ARRAY(pszZipBuffer);
		LOGERROR("FindZipItem failed,Path is %s",pszPath);
		return 0;
	}

	pszResult = new unsigned char[kZipEntry.unc_size];
	memset(pszResult,0,sizeof(unsigned char) * (kZipEntry.unc_size));

	UnzipItem(hZip,nFileIndex,pszResult,kZipEntry.unc_size);

	*puiLength = kZipEntry.unc_size;

	if (0 == pszResult)
	{
		CloseZip(hZip);
		SAFE_DELETE_ARRAY(pszZipBuffer);
		LOGD("pszResult is Null");
	}

	CloseZip(hZip);
	SAFE_DELETE_ARRAY(pszZipBuffer);
	return pszResult;
}

NS_NDENGINE_END


void WriteCon(const char * pszFormat, ...)
{
	if (!pszFormat) return;

	static char szBuf[1024] = {0};
	va_list ap;
	va_start(ap, pszFormat);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	vsnprintf_s(szBuf, 1024, 1024, pszFormat, ap);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	vsnprintf(szBuf, 1024, pszFormat, ap);
#endif
	va_end(ap);	

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	HANDLE hOut = NDConsole::instance().getOutputHandle();
	if (hOut)
	{
		DWORD n = 0;
		WriteConsoleA( hOut, szBuf, strlen(szBuf), &n, NULL );
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	cocos2d::CCLog( "@@ %s\r\n", szBuf );
#endif
}
