//
//  NDDictionary.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NDDictionary.h"
#include "define.h"

using namespace NDEngine;

DictionaryObject::DictionaryObject()
: m_NdObject(NULL)
{

}

DictionaryObject::~DictionaryObject()
{
	CC_SAFE_DELETE(m_NdObject);
}

namespace NDEngine
{
	IMPLEMENT_CLASS(NDDictionary, NDObject)
	
	NDDictionary::NDDictionary()
	{
		m_nsDictionary = new CCMutableArray<NDEngine::NDObject*>();
	}
	
	NDDictionary::~NDDictionary()
	{
		this->RemoveAllObjects();
		CC_SAFE_RELEASE(m_nsDictionary);
	}
	
	void NDDictionary::SetObject(NDObject* obj, const char* key)
	{
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
		DictionaryObject *dictObj = m_nsDictionary->objectForKey(key);
		if (dictObj) 
		{
			return dictObj->getNdObject();
		}
		return NULL;
	}
	
	void NDDictionary::RemoveObject(const char* key)
	{
		DictionaryObject *dictObj = m_nsDictionary->objectForKey(key);
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
