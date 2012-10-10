/*
 *  Singleton.h
 *  DragonDrive
 *
 *  Created by wq on 11/26/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SINGLETON_H__
#define __SINGLETON_H__

template<typename T>
class TSingleton {
public:
	TSingleton() {
		NDAsssert(NULL == _singleton);
		_singleton = static_cast<T*> (this);
	}
	
	~TSingleton() {
		NDAsssert(NULL != _singleton);
		_singleton = NULL;
	}
	
	static T& GetSingleton() {
		//assert(NULL != _singleton);
		//return *_singleton;
		if (NULL == _singleton)
			new T();
		return *_singleton;
	}
	
	static T* GetSingletonPtr() {
		NDAsssert(NULL != _singleton);
		return _singleton;
	}
	
private:
	static T* _singleton;
};

template<typename T>
T* TSingleton<T>::_singleton = NULL;

#endif