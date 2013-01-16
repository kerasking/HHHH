#include "NDJsonReader.h"
#include "CCPlatformConfig.h"
#include "CCFileUtils.h"
#include "NDPath.h"
#include <json.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android/jni/JniHelper.h"
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
using namespace Json;

NS_NDENGINE_BGN
IMPLEMENT_CLASS(NDJsonReader,NDObject)

NDJsonReader::NDJsonReader():
m_pszFilePath(0),
m_pszBuffer(0),
m_ulFileSize(0)
{

}

NDJsonReader::~NDJsonReader()
{
	SAFE_DELETE_ARRAY(m_pszFilePath);
	SAFE_DELETE_ARRAY(m_pszBuffer);
}

string NDJsonReader::readData( const char* pszName )
{
	LOGD("Entry NDJsonReader::readData");

	string strRet = "";
	unsigned long ulSize = 0;
	Reader kReader;
	Value kValue;

	if (0 == pszName || !*pszName)
	{
		LOGERROR("pszName is null");
		return strRet;
	}

	if (0 == m_pszBuffer || !*m_pszBuffer)
	{
		LOGERROR("No read file!");
		return strRet;
	}

	if (!kReader.parse(m_pszBuffer,kValue))
	{
		LOGERROR("Can't parse the buffer!Buffer: %s",m_pszBuffer);
		return strRet;
	}

	strRet = kValue[pszName].asString();

	LOGD("strRet is %s",strRet.c_str());
	return strRet;
}

bool NDJsonReader::readJsonFile(const char* pszFilePath)
{
	if (0 == pszFilePath || !*pszFilePath)
	{
		return false;
	}

	int nLength = strlen(pszFilePath);

	if (0 == nLength)
	{
		return false;
	}

	SAFE_DELETE_ARRAY(m_pszFilePath);
	SAFE_DELETE_ARRAY(m_pszBuffer);

	m_pszFilePath = new char [nLength + 1];
	memset(m_pszFilePath,0,sizeof(char) * (nLength + 1));
	strcpy(m_pszFilePath,pszFilePath);

	unsigned char* pszData = CCFileUtils::sharedFileUtils()->
		getFileData(m_pszFilePath,"rb",&m_ulFileSize);

	if (0 == pszData)
	{
		return false;
	}

	string strBuffer = (const char*)(pszData);

	SAFE_DELETE_ARRAY(pszData);

	m_pszBuffer = new char[strBuffer.length() + 1];
	memset(m_pszBuffer,0,sizeof(char) * (strBuffer.length() + 1));
	strcpy(m_pszBuffer,strBuffer.c_str());

	LOGD("strBuffer is %s",m_pszBuffer);

	return true;
}

string NDJsonReader::getGameConfig( const char* pszTextName )
{
	string strRet = "";

	if (!readJsonFile(NDPath::GetGameConfigPath("GameConfig.json").c_str()))
	{
		return "";
	}

	strRet = readData(pszTextName);

	return strRet;
}

NS_NDENGINE_END
