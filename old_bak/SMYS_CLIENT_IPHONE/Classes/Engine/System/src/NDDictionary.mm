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

@implementation DictionaryObject

@synthesize ndObject = _ndObject;

-(id) init
{
	if( (self=[super init]) ) {
		_ndObject = NULL;
	}
	
	return self;
}

- (void) dealloc
{
	SAFE_DELETE(_ndObject);
	[super dealloc];
}

@end



namespace NDEngine
{
	IMPLEMENT_CLASS(NDDictionary, NDObject)
	
	NDDictionary::NDDictionary()
	{
		m_nsDictionary = [[NSMutableDictionary alloc] init];
	}
	
	NDDictionary::~NDDictionary()
	{
		this->RemoveAllObjects();
		[m_nsDictionary release];
	}
	
	void NDDictionary::SetObject(NDObject* obj, const char* key)
	{
		if (obj) 
		{
			DictionaryObject *dictObj = [[DictionaryObject alloc] init];
			dictObj.ndObject = obj;
			[m_nsDictionary setObject:dictObj forKey:[NSString stringWithUTF8String:key]];
			[dictObj release];
		}
	}
	
	NDObject* NDDictionary::Object(const char* key)
	{
		DictionaryObject *dictObj = [m_nsDictionary objectForKey:[NSString stringWithUTF8String:key]];
		if (dictObj) 
		{
			return dictObj.ndObject;
		}
		return NULL;
	}
	
	void NDDictionary::RemoveObject(const char* key)
	{
		DictionaryObject *dictObj = [m_nsDictionary objectForKey:[NSString stringWithUTF8String:key]];
		if (dictObj) 
		{
			delete dictObj.ndObject;
			dictObj.ndObject = NULL;
			[m_nsDictionary removeObjectForKey:[NSString stringWithUTF8String:key]];
		}		
	}
	
	void NDDictionary::RemoveAllObjects()
	{
		NSArray* allValues = [m_nsDictionary allValues];
		for (NSUInteger i = 0; i < [allValues count]; i++) 
		{
			DictionaryObject *dictObj = [allValues objectAtIndex:i];
			delete dictObj.ndObject;
			dictObj.ndObject = NULL;
		}
		
		[m_nsDictionary removeAllObjects];
	}
}
