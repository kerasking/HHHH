//
//  NDDictionary.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-9.
//  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
//

#include "NDDictionary.h"
#include "ObjectTracker.h"

using namespace NDEngine;
using namespace cocos2d;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
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

DictionaryObject::DictionaryObject() :
m_NdObject(NULL)
{
}

DictionaryObject::~DictionaryObject()
{
	CC_SAFE_DELETE (m_NdObject);
}

namespace NDEngine
{
IMPLEMENT_CLASS(NDDictionary, NDObject)

NDDictionary::NDDictionary()
{
	INC_NDOBJ_RTCLS
	m_nsDictionary = new CCDictionary();
}

NDDictionary::~NDDictionary()
{
	DEC_NDOBJ_RTCLS
	this->RemoveAllObjects();
	CC_SAFE_RELEASE (m_nsDictionary);
}

void NDDictionary::SetObject(NDObject* obj, const char* key)
{
	//LOGD("entry NDDictionary::SetObject,obj is %d",(int)obj);

	if (obj)
	{
		DictionaryObject *dictObj = new DictionaryObject;
		dictObj->setNdObject(obj);
		m_nsDictionary->setObject(dictObj, key);
		dictObj->release();
	}
}

NDObject* NDDictionary::Object(const char* key)
{
	DictionaryObject *dictObj =
			(DictionaryObject *) m_nsDictionary->objectForKey(key);

	if (dictObj)
	{
		return dictObj->getNdObject();
	}

	return NULL;
}

void NDDictionary::RemoveObject(const char* key)
{
	DictionaryObject *dictObj =
			(DictionaryObject *) m_nsDictionary->objectForKey(key);
	if (dictObj)
	{
		delete dictObj->getNdObject();
		dictObj->setNdObject(NULL);
		m_nsDictionary->removeObjectForKey(key);
	}
}

void NDDictionary::RemoveAllObjects()
{
	m_nsDictionary->removeAllObjects();
}

}