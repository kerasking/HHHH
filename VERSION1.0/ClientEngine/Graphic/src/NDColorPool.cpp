/*
 *  NDColorPool.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-7.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "NDColorPool.h"

NDColorPool::NDColorPool(){}
NDColorPool::~NDColorPool(){}

bool NDColorPool::GetColorFromPool(const char* colorFile, 
								   uint colorIndex,
								   VEC_COLOR_ARRAY& colorArray)
{
	PAIR_COLOR_KEY key(colorFile, colorIndex);
	MAP_COLOR_IT it = this->m_mapColors.find(key);

	if (it != this->m_mapColors.end())
	{
		colorArray = it->second;
		return true;
	} 
	else
	{
		this->LoadColor(colorFile);
		it = this->m_mapColors.find(key);

		if (it != this->m_mapColors.end())
		{
			colorArray = it->second;
			return true;
		}
	}
	return false;
}

void NDColorPool::LoadColor(const char* colorFile)
{
	/* todo
	NSString* strColorFile = [NSString stringWithUTF8String:colorFile];
	strColorFile = [strColorFile stringByReplacingCharactersInRange:[strColorFile rangeOfString:@"image"] withString:@"animation"];
	
	NSString* strColor = [NSString stringWithContentsOfFile:strColorFile encoding:NSUTF16LittleEndianStringEncoding error:NULL];
	
	NSString* lineSeparater = [NSString stringWithFormat:@"%s", "\r\n"];
	
	// 分割颜色数组
	NSArray* colorGroup = [strColor componentsSeparatedByString:lineSeparater];
	
	PAIR_COLOR_KEY colorKey;
	colorKey.first = colorFile;
	
	VEC_COLOR_ARRAY vColor;
	
	for (NSUInteger i = 0; i < [colorGroup count] - 1; i++) {
		NSString* aGroup = [colorGroup objectAtIndex:i];
		NSArray* arrColor = [aGroup componentsSeparatedByString:@","];
		vColor.clear();
		
		for (NSUInteger j = 0; j < [arrColor count]; j++) {
			NSString* val = [arrColor objectAtIndex:j];
			if (j == 0) {
				colorKey.second = atoi([val UTF8String]);
			} else {
				char* stop = NULL;
				vColor.push_back(strtol([val UTF8String], &stop, 16));
			}
		}
		
		this->m_mapColors[colorKey] = vColor;
	}
	*/
}