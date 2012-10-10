//
//  NDDictionary.h
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef __NDDictionary_H
#define __NDDictionary_H

#import	<Foundation/Foundation.h>
#include "NDObject.h"

@interface DictionaryObject : NSObject
{
	NDEngine::NDObject* _ndObject;
}
@property (nonatomic, assign)NDEngine::NDObject* ndObject;

@end

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
		NSMutableDictionary *m_nsDictionary;
	};
}

#endif

