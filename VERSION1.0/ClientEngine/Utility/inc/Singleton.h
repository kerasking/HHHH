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

template<typename T>
class TSingleton
{
public:
	TSingleton() 
	{
		//NDAsssert(NULL == ms_pkSingleton);
		ms_pkSingleton = static_cast<T*> (this);
	}
	
	~TSingleton() 
	{
		//NDAsssert(NULL != ms_pkSingleton);
		ms_pkSingleton = NULL;
	}
	
	static T& GetSingleton() 
	{
		//assert(NULL != _singleton);
		//return *_singleton;
		if (NULL == ms_pkSingleton)
			new T();
		return *ms_pkSingleton;
	}
	
	static T* GetSingletonPtr()
	{
		NDAsssert(NULL != ms_pkSingleton);
		return ms_pkSingleton;
	}
	
private:

	static T* ms_pkSingleton;
};

template<typename T>
T* TSingleton<T>::ms_pkSingleton = NULL;

#endif