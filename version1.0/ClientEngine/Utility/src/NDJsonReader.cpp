#include "NDJsonReader.h"
#include "CCPlatformConfig.h"
#include "CCFileUtils.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android\jni\JniHelper.h"
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace cocos2d;

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDJsonReader,NDObject)

NDJsonReader::NDJsonReader():
m_pszFilePath(0)
{
	
}

NDJsonReader::NDJsonReader(const char* pszFilePath):
m_pszFilePath(0)
{
	int nLength = strlen(pszFilePath);

	if (0 == nLength)
	{
		return;
	}

	m_pszFilePath = new char [nLength + 1];
	memset(m_pszFilePath,0,sizeof(char) * (nLength + 1));
	strcpy(m_pszFilePath,pszFilePath);
}

NDJsonReader::~NDJsonReader()
{
	SAFE_DELETE_ARRAY(m_pszFilePath);
}

void NDJsonReader::setPath( const char* pszFilePath )
{
	if (0 == pszFilePath || !*pszFilePath)
	{
		return;
	}

	int nLength = strlen(pszFilePath);
	SAFE_DELETE_ARRAY(m_pszFilePath);

	m_pszFilePath = new char[nLength + 1];
	memset(m_pszFilePath,0,sizeof(char) * (nLength + 1));

	strcpy(m_pszFilePath,pszFilePath);
}

string NDJsonReader::readData( const char* pszName )
{
	LOGD("Entry NDJsonReader::readData");

	string strRet = "";
	unsigned long ulSize = 0;

	if (0 == pszName || !*pszName)
	{
		LOGERROR("pszName is null");
		return strRet;
	}

	string strBuffer = (const char*)(CCFileUtils::sharedFileUtils()->
		getFileData(m_pszFilePath,"rb",&ulSize));

	LOGD("strBuffer is %s",strBuffer.c_str());

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"getStringFromJasonFile",
		"(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;"))
	{
		jstring stringArg_1 = t.env->NewStringUTF(strBuffer.c_str());
		jstring stringArg_2 = t.env->NewStringUTF(pszName);
		jstring retFromJava = (jstring) t.env->CallStaticObjectMethod(t.classID,
			t.methodID, stringArg_1,stringArg_2);
		const char* str = t.env->GetStringUTFChars(retFromJava, 0);
		strRet = str;

		t.env->ReleaseStringUTFChars(retFromJava, str);
		t.env->DeleteLocalRef(stringArg_1);
		t.env->DeleteLocalRef(stringArg_2);
		t.env->DeleteLocalRef(t.classID);
	}
	else
	{
		LOGERROR("Cant' find java function:getTextFromStringXML");
	}
#endif

	LOGD("strRet is %s",strRet.c_str());
	return strRet;
}

NS_NDENGINE_END