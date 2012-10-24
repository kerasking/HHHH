//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NDPath.h"
#include "NDUtility.h"
////////////////////////////////////////////////////////////
#define SZ_ROOT_SOURCE_DIR					"SimplifiedChineseRes"	//按语种划分资源根目录名


////////////////////////////////////////////////////////////
namespace NDEngine
{
	IMPLEMENT_CLASS(NDPath, NDObject)
	
	int NDPath::s_iResDirPos = 0;
	
	NDPath::NDPath()
	{
	}
	NDPath::~NDPath()
	{
	}
	
//===========================================================================
    //get caches path
    std::string NDPath::GetCashesPath()
	{
        //NSFileManager *fileManager = [NSFileManager defaultManager];
        // NSError *error;
        NSString *path1 = [NSHomeDirectory()stringByAppendingPathComponent:@"Library"];
        NSString *CashesDirectory = [path1 stringByAppendingPathComponent:@"/Caches"];
        return std::string([CashesDirectory UTF8String]) +"/";
        /*
         NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
         return std::string([path UTF8String]);
         */
	}
//===========================================================================
	//获得 document 的路径
	std::string NDPath::GetResourcePath()
	{
        //NSFileManager *fileManager = [NSFileManager defaultManager];
       // NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        return std::string([documentsDirectory UTF8String]) + "/";
        /*
		NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
		return std::string([path UTF8String]);
         */
	}
	
    std::string NDPath::GetResourceFilePath(const char* filename)
    {
        return NDPath::GetResourcePath() + filename;
    }
    
//===========================================================================
    std::string NDPath::GetAppPath()
    {
    	return std::string([[[NSBundle mainBundle] resourcePath] UTF8String]) + "/";
    }
    //获得 XXXX.app 目录下的文件路径
    std::string NDPath::GetAppResFilePath(const char* filename)
    {
        return NDPath::GetAppPath() + filename;
    }
    
    //获取资源根路径
    std::string NDPath::GetRootResPath()
    {
		if ( s_iResDirPos == 0 )
		{
			return NDPath::GetAppPath() + SZ_ROOT_SOURCE_DIR + "/";
		}
		else
		{
#ifdef DOCUMENT
			return NDPath::GetResourcePath() + SZ_ROOT_SOURCE_DIR + "/";
#else
			return NDPath::GetCashesPath() + SZ_ROOT_SOURCE_DIR + "/";
#endif
		}
    }
    
    //获取资源路径
	std::string NDPath::GetResPath()
	{
		return NDPath::GetRootResPath() + "res/";
	}
	
	std::string NDPath::GetImagePath()
	{
		return NDPath::GetResPath() + "image/";
	}
	
    const char* NDPath::GetImgPath(const char* filename)
    {
        return [[NSString stringWithFormat:@"%@/image/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:filename]] UTF8String];
    }
	
	std::string NDPath::GetMapPath()
	{
		return NDPath::GetResPath() + "map/";
	}
	
    std::string NDPath::GetMapResPath()
	{
		return NDPath::GetResPath();
	}
	
	std::string NDPath::GetSoundPath()
	{
		return NDPath::GetResPath() + "sound/";
	}
	
	std::string NDPath::GetAnimationPath()
	{
		return NDPath::GetResPath() + "animation/";
	}
	
    const char* NDPath::GetImgPathBattleUI(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/image/battle_ui/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    const char* NDPath::GetAniPath(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/animation/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    // 新界面资源统一放在 res/image/ui_new
    const char* NDPath::GetImgPathNew(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/image/ui_new/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    // 新界面高分辨率资源统一放在 res/image/ui_new/advance
    const char* NDPath::GetImgPathNewAdvance(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/image/ui_new/advance/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    const char* NDPath::GetMapPath(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/map/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    const char* NDPath::GetUIConfigPath(const char* filename)
    {
        return [[NSString stringWithFormat:@"%@/UI/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:filename]] UTF8String];
    }
    
    const char* NDPath::GetUIImgPath(const char* uiFileNameWithPath)
    {
        return [[NSString stringWithFormat:@"%@%@", [NSString stringWithUTF8String:(NDPath::GetRootResPath()).c_str()], [NSString stringWithUTF8String:uiFileNameWithPath]] UTF8String];
    }
    
    const char* NDPath::GetResPath(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    const char* NDPath::GetSMImgPath(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/image/Res00/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    const char* NDPath::GetScriptPath(const char* filename)
    {
		return [[NSString stringWithFormat:@"%@/Script/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:filename]] UTF8String];

    }
    
    const char* NDPath::GetSMVideoPath(const char* fileName)
    {
        return [[NSString stringWithFormat:@"%@/Video/%@", [NSString stringWithUTF8String:(NDPath::GetResPath()).c_str()], [NSString stringWithUTF8String:fileName]] UTF8String];
    }
    
    //++Guosen 2012.8.9
    void NDPath::SetResDirPos( int iPos )
    {
    	NDPath::s_iResDirPos = iPos;
    }
	const char* NDPath::GetRootResDirName()
	{
		return SZ_ROOT_SOURCE_DIR;
	}
}
