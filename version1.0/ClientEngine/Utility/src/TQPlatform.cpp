/*
 *  platform.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-5-07.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "TQPlatform.h"
#include "CCImage.h"
#include "CCGeometry.h"
#include "basedefine.h"


#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "Foundation/Foundation.h"
#import "UIKit/UIFont.h"
#import "UIKit/UIStringDrawing.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "platform/android/jni/JniHelper.h"
#endif
using namespace cocos2d;


CCSize getStringSize(const char* in_utf8, unsigned int fontSize)
{
    CCSize outSize = CCSizeMake(0.0f, 0.0f);
	if (in_utf8 == 0 || in_utf8[0] == 0) return outSize;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	{
		CGSize sz = CGSizeMake(0.0f, 0.0f);
		NSString* str = [NSString stringWithUTF8String:in_utf8];	
		NSString* strfont = [NSString stringWithUTF8String:FONT_NAME];
		sz = [str sizeWithFont:[UIFont fontWithName:strfont size:fontSize]];
		outSize.width = sz.width;
		outSize.height = sz.height;
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	{
		int width = 0, height = 0;
		if (CCImage::getStringSize( in_utf8, 
			CCImage::kAlignLeft, FONT_NAME, fontSize,
			width, height ))
		{
			outSize.width = width;
			outSize.height = height;
		}
	}
#endif
    
	return outSize;     
}

CCSize getStringSizeMutiLine(const char* in_utf8, unsigned int fontSize, CCSize contentSize)
{
	CCSize outSize = CCSizeZero;

	if (!in_utf8 || in_utf8[0] == 0)
	{
		return outSize;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	NSString *nstext = [NSString stringWithUTF8String:in_utf8];
    NSString* strfont = [NSString stringWithUTF8String:FONT_NAME];
	outSize = [nstext sizeWithFont:[UIFont fontWithName:strfont size:fontSize] constrainedToSize:contentSize];

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	int width = 0, height = 0;
	if (CCImage::getStringSize( in_utf8, CCImage::kAlignLeft, FONT_NAME, fontSize, width, height ))
	{
		int rows = 1.0*width/contentSize.width + 1;

		if(1 == rows)
		{
			outSize.width = width;
			if(contentSize.height > height)
			{
				outSize.height =  height;
			}
			else
			{
				outSize.height =  contentSize.height;
			}
		}
		else
		{
			outSize.width = contentSize.width;
			if(contentSize.height > height*rows)
			{
				outSize.height =  height*rows;
			}
			else
			{
				outSize.height =  contentSize.height;
			}
		}
	}
#endif
	return outSize;
}
