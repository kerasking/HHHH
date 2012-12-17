#include "NDUtil.h"
#include<iostream>

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

}

NDUtil::~NDUtil()
{

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

NS_NDENGINE_END