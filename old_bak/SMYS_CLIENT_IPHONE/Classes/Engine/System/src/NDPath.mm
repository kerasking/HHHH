//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDPath.h"
#include "NDUtility.h"

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
		NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetResPath()
	{
#ifdef TRADITION
		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
#else
		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
#endif
		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetImagePath()
	{
		NSString *path = nil;

//		if ( IsTraditionalChinese() )
//		{
//			path = [NSString stringWithFormat:@"%@/res/TraditionalImage/image/", [[NSBundle mainBundle] resourcePath]];
//		}
//		else
		{
		#ifdef TRADITION
			path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/image/", [[NSBundle mainBundle] resourcePath]];
		#else
			path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/image/", [[NSBundle mainBundle] resourcePath]];
		#endif
		}
		
		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetMapPath()
	{
	#ifdef TRADITION
		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
	#else
		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
	#endif
		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetSoundPath()
	{
	#ifdef TRADITION
		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
	#else
		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
	#endif
		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetAnimationPath()
	{
	#ifdef TRADITION
		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
	#else
		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
	#endif
		return std::string([path UTF8String]);
	}
}
