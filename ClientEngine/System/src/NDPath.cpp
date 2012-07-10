//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDPath.h"
#include "NDUtility.h"

// todo

namespace NDEngine
{
	IMPLEMENT_CLASS(NDPath, NDObject)
	
	NDPath::NDPath()
	{
	}
	NDPath::~NDPath()
	{
	}
	
	std::string NDPath::GetResourcePath()
	{
		return "";
// 		NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetResPath()
	{
		return "";
// #ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
// #else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
// #endif
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetImagePath()
	{
		return "";

// 		NSString *path = nil;
// 
// 		{
// 		#ifdef TRADITION
// 			path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/image/", [[NSBundle mainBundle] resourcePath]];
// 		#else
// 			path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/image/", [[NSBundle mainBundle] resourcePath]];
// 		#endif
// 		}
// 		
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetMapPath()
	{
		return "";
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
// 	#endif
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetSoundPath()
	{
		return "";
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
// 	#endif
// 		return std::string([path UTF8String]);ss
	}
	
	std::string NDPath::GetAnimationPath()
	{
		return "";
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
// 	#endif
// 		return std::string([path UTF8String]);
	}
}
