//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "NDPath.h"

// todo

namespace NDEngine
{
	static std::string NDPath_ResPath = "";
	static std::string NDPath_ImgPath = "";
	static std::string NDPath_MapPath = "";
	static std::string NDPath_AniPath = "";
	static std::string NDPath_SoundPath = "";
	IMPLEMENT_CLASS(NDPath, NDObject)
	
	NDPath::NDPath()
	{
	}
	NDPath::~NDPath()
	{
	}
	
	std::string NDPath::GetResourcePath()
	{
		return NDPath_ResPath;
// 		NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetResPath()
	{
		return NDPath_ResPath;
// #ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
// #else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
// #endif
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetImagePath()
	{
		return NDPath_ImgPath;

// 		NSString *path = NULL;
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
		return NDPath_MapPath;
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
// 	#endif
// 		return std::string([path UTF8String]);
	}
	
	std::string NDPath::GetSoundPath()
	{
		return NDPath_SoundPath;
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
// 	#endif
// 		return std::string([path UTF8String]);ss
	}
	
	std::string NDPath::GetAnimationPath()
	{
		return NDPath_AniPath;
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
// 	#endif
// 		return std::string([path UTF8String]);
	}

	void NDPath::SetImagePath(const char* szPath)
	{
		if (!szPath)
		{
			return;
		}
		
		NDPath_ImgPath = szPath;
	}
	void NDPath::SetMapPath(const char* szPath)
	{
		if (!szPath)
		{
			return;
		}

		NDPath_MapPath = szPath;
	}
	void NDPath::SetAnimationPath(const char* szPath)
	{
		if (!szPath)
		{
			return;
		}

		NDPath_AniPath = szPath;
	}
	void NDPath::SetResPath(const char* szPath)
	{
		if (!szPath)
		{
			return;
		}

		NDPath_ResPath = szPath;
	}
	void NDPath::SetSoundPath(const char* szPath)
	{
		if (!szPath)
		{
			return;
		}

		NDPath_SoundPath = szPath;
	}

    const char* NDPath::GetImgPath(const char* filename)
    {
		return std::string(GetResPath()+"image/"+filename).c_str();
    }
	
    
    const char* NDPath::GetImgPathBattleUI(const char* fileName)
	{
		return std::string(GetResPath()+"image/battle_ui/"+fileName).c_str();
    }
    
    
    const char* NDPath::GetAniPath(const char* fileName)
	{
		return std::string(GetResPath()+"animation/"+fileName).c_str();
    }
    
    // 新界面资源统一放在 res/image/ui_new
    const char* NDPath::GetImgPathNew(const char* fileName)
	{
		return std::string(GetResPath()+"image/ui_new/"+fileName).c_str();
    }
    // 新界面高分辨率资源统一放在 res/image/ui_new/advance
    const char* NDPath::GetImgPathNewAdvance(const char* fileName)
	{
		return std::string(GetResPath()+"image/ui_new/advance/"+fileName).c_str();
    }
    
    const char* NDPath::GetMapPath(const char* fileName)
	{
		return std::string(GetResPath()+"map/"+fileName).c_str();
    }
    
    const char* NDPath::GetUIConfigPath(const char* filename)
	{
		return std::string(GetResPath()+"UI/"+filename).c_str();
    }
    
    const char* NDPath::GetUIImgPath(const char* uiFileNameWithPath)
    {
#ifdef TRADITION
		return std::string(GetResourcePath()+"TraditionalChineseRes/"+uiFileNameWithPath).c_str();
#else

		return std::string(GetResourcePath()+"SimplifiedChineseRes/"+uiFileNameWithPath).c_str();
#endif        
    }
    
    
    const char* NDPath::GetResPath(const char* fileName)
	{
		return std::string(GetResPath()+fileName).c_str();
    }
    
    const char* NDPath::GetSMImgPath(const char* fileName)
	{
		return std::string(GetResPath()+"image/Res00/"+fileName).c_str();
    }
    
    const char* NDPath::GetScriptPath(const char* filename)
	{
		return std::string(GetResPath()+"Script/"+filename).c_str();
    }
}
