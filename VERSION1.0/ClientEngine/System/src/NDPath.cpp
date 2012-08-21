//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDPath.h"

// todo

namespace NDEngine
{
	std::string NDPath::NDPath_ResPath = "./SimplifiedChineseRes/res/";
	std::string NDPath::NDPath_ImgPath = "./SimplifiedChineseRes/res/map/";
	std::string NDPath::NDPath_MapPath = "";
	std::string NDPath::NDPath_AniPath = "";
	std::string NDPath::NDPath_SoundPath = "";
	IMPLEMENT_CLASS(NDPath, NDObject)

	string ReplaceString( const string& inStr, const char* pSrc, const char* pReplace )
	{
		string str = inStr;
		string::size_type stStart = 0;
		string::iterator iter = str.begin();
		while( iter != str.end() )
		{
			// 从指定位置 查找下一个要替换的字符串的起始位置。
			string::size_type st = str.find( pSrc, stStart );
			if ( st == str.npos )
			{
				break;
			}
			iter = iter + st - stStart;
			// 将目标字符串全部替换。
			str.replace( iter, iter + strlen( pSrc ), pReplace );
			iter = iter + strlen( pReplace );
			// 替换的字符串下一个字符的位置
			stStart = st + strlen( pReplace );
		}
		return str;
	}
	
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
		std::string strPath = "./SimplifiedChineseRes/res/";
		return strPath;
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
		return "./SimplifiedChineseRes/res/map/";
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
		//return std::string(GetResPath()+"image/"+filename).c_str();

		string strRes = std::string(GetResPath()+"image/"+filename);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
    }
	
    
    const char* NDPath::GetImgPathBattleUI(const char* fileName)
	{
		string strRes = std::string(GetResPath()+"image/battle_ui/"+fileName);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
		//return std::string(GetResPath()+"image/battle_ui/"+fileName).c_str();
    }
    
    
    const char* NDPath::GetAniPath(const char* fileName)
	{
		return std::string(GetResPath()+"animation/"+fileName).c_str();
    }
    
    // 新界面资源统一放在 res/image/ui_new
    const char* NDPath::GetImgPathNew(const char* fileName)
	{
		string strRes = std::string(GetResPath()+"image/ui_new/"+fileName);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
		//return std::string(GetResPath()+"image/ui_new/"+fileName).c_str();
    }
    // 新界面高分辨率资源统一放在 res/image/ui_new/advance
    const char* NDPath::GetImgPathNewAdvance(const char* fileName)
	{
		string strRes = std::string(GetResPath()+"image/ui_new/advance/"+fileName);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
	//	return std::string(GetResPath()+"image/ui_new/advance/"+fileName).c_str();
    }
    
    const char* NDPath::GetMapPath(const char* fileName)
	{
		return std::string(GetResPath()+"map/"+fileName).c_str();
    }
    
    const char* NDPath::GetUIConfigPath(const char* filename)
	{
		string strRes = std::string(GetResPath()+"UI/"+filename);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
    }
    
    const char* NDPath::GetUIImgPath(const char* uiFileNameWithPath)
    {
#ifdef TRADITION
		return std::string(GetResourcePath()+"TraditionalChineseRes/"+uiFileNameWithPath).c_str();
#else

		//return std::string(GetResourcePath()+"SimplifiedChineseRes/"+uiFileNameWithPath).c_str();GetResPath()+

		string strRes = std::string(string("SimplifiedChineseRes") + uiFileNameWithPath);
		NDString* pstrString = new NDString(strRes);

		//strRes = ReplaceString(strRes,"/","\\");

		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,pstrString->getData());

		for (unsigned int i = 0;i < strlen(pszTemp);i++)
		{
			if (pszTemp[i] == '/')
			{
				pszTemp[i] = '\\';
			}
		}

		return pszTemp;
#endif        
    }
    
    
    const char* NDPath::GetResPath(const char* fileName)
	{
		string strRes = std::string(GetResPath() + fileName);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
		//return std::string(GetResPath()+fileName).c_str();
    }
    
    const char* NDPath::GetSMImgPath(const char* fileName)
	{
		string strRes = std::string(GetResPath()+"image/Res00/"+ fileName);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
	//	return std::string(GetResPath()+"image/Res00/"+fileName).c_str();
    }
    
    const char* NDPath::GetScriptPath(const char* filename)
	{
		string strRes = std::string(std::string("./SimplifiedChineseRes/res/") + "Script/" + filename);
		char* pszTemp = new char[255];
		memset(pszTemp,0,sizeof(char) * 255);
		strcpy(pszTemp,strRes.c_str());
		return pszTemp;
		//return std::string(GetResPath()+"Script/"+filename).c_str();
    }
}
