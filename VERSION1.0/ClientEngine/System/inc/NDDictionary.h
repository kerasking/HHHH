//
//  NDDictionary.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDDictionary_H
#define __NDDictionary_H

#include "NDObject.h"
#include "CCMutableDictionary.h"

class DictionaryObject : public cocos2d::CCObject
{
	CC_PROPERTY(NDEngine::NDObject*, m_NdObject, NdObject)
public:
	DictionaryObject();
	~DictionaryObject();
};

namespace NDEngine
{
	class NDDictionary : public NDObject
	{
		DECLARE_CLASS(NDDictionary)
		NDDictionary();
		~NDDictionary();
	public:
		void SetObject(NDObject* obj, const char* key);
		NDObject* Object(const char* key);
		void RemoveObject(const char* key);
		void RemoveAllObjects();
		
	protected:
		cocos2d::CCMutableDictionary<std::string, cocos2d::CCObject*> *m_nsDictionary;
	};
}

#endif

