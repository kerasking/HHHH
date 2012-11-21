/*
 *  Singleton.h
 *  DragonDrive
 *
 *  Created by wq on 11/26/10.
 *  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef __SINGLETON_H__
#define __SINGLETON_H__

#include "basedefine.h"
#include "NDClassFactory.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "android/jni/SystemInfoJni.h"
#include <android/log.h>
#include <jni.h>

#define  LOG_TAG    "CCApplication_android Debug"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGDAHUA(...) __android_log_print(ANDROID_LOG_ERROR,"DaHua",__VA_ARGS__)

#endif


template<typename T>
class TSingleton
{
public:
	TSingleton() 
	{
		NDAsssert(NULL == ms_pkSingleton);
		ms_pkSingleton = static_cast<T*> (this);
	}
	
	~TSingleton() 
	{
		NDAsssert(NULL != ms_pkSingleton);
		ms_pkSingleton = NULL;
	}
	
	static T& GetSingleton() 
	{
		if (NULL == ms_pkSingleton)
			new T();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		LOGDAHUA("ms_pkSingleton value is %d",(int)ms_pkSingleton);
#endif

		return *ms_pkSingleton;
	}

	static T& GetBackSingleton(const char* pszSubClassName)
	{
		assert(pszSubClassName && *pszSubClassName);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		LOGDAHUA("enry GetBackSingleton()");
#endif

		if (NULL == ms_pkSingleton)
		{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			LOGDAHUA("ready to create ms_pkSingleton %d",(int)ms_pkSingleton);
#endif
			ms_pkSingleton = CREATE_CLASS(T,pszSubClassName);
		}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		LOGDAHUA("ms_pkSingleton value is %d",(int)ms_pkSingleton);
#endif

		return *ms_pkSingleton;
	}
	
	static T* GetSingletonPtr()
	{
		NDAsssert(NULL != ms_pkSingleton);
		return ms_pkSingleton;
	}
	
protected:

	static T* ms_pkSingleton;
};

template<typename T>
T* TSingleton<T>::ms_pkSingleton = NULL;

#endif