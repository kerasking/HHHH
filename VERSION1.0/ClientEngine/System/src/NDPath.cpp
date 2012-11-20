//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDPath.h"
#include "define.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import <Foundation/Foundation.h>
#endif

NS_NDENGINE_BGN

#define SZ_ROOT_SOURCE_DIR					"SimplifiedChineseRes"	//按语种划分资源根目录名

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
string* s_ResRootPath = NULL;
string* s_ResBasePath = NULL;
#endif

string NDPath::NDPath_ResPath			= "../SimplifiedChineseRes/res/";
string NDPath::NDPath_ImgPath			= "../SimplifiedChineseRes/res/Image/";
string NDPath::NDPath_ImgPath_BattleUI	= "../SimplifiedChineseRes/res/Image/battle_ui/";
string NDPath::NDPath_ImgPath_UINew		= "../SimplifiedChineseRes/res/Image/ui_new/";
string NDPath::NDPath_MapPath			= "../SimplifiedChineseRes/res/map/";
string NDPath::NDPath_AniPath			= "../SimplifiedChineseRes/res/animation/";
string NDPath::NDPath_SoundPath			= "../SimplifiedChineseRes/res/sound/";
string NDPath::NDPath_UIPath			= "../SimplifiedChineseRes/res/UI/";
string NDPath::NDPath_ScriptPath		= "../SimplifiedChineseRes/res/Script/";
string NDPath::NDPath_LogPath			= "../log";

IMPLEMENT_CLASS(NDPath, NDObject)

int NDPath::s_iResDirPos = 0;

NDPath::NDPath()
{
}
NDPath::~NDPath()
{
}

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

const char* NDPath::GetResPath()
{
    //TraditionalChineseRes
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if(0 == s_ResRootPath)
    {
        s_ResRootPath = new string;
        NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
        *s_ResRootPath = [path UTF8String];
    }
    return s_ResRootPath->c_str();
    
#else
    return NDPath_ResPath.c_str();
#endif
}

const string& NDPath::GetImagePath()
{
	static string ret;
	ret = GetResPath()+string("Image/");
    return ret;
	return NDPath_ImgPath;
}

const string& NDPath::GetResPath2( const char* fileName )
{
	static string ret;
	ret = GetResPath() + string(fileName);
    return ret;
}

const string& NDPath::GetMapPath()
{
	static string ret;
    ret = GetResPath()+string("map/");
    return ret;
	return NDPath_MapPath;
}

const string& NDPath::GetSoundPath()
{
	static string ret;
    ret = GetResPath()+string("sound/");
    return ret;
	return NDPath_SoundPath;
}

const string& NDPath::GetAnimationPath()
{
	static string ret;
    ret = GetResPath()+string("animation/");
    return ret;
	return NDPath_AniPath;
}

const string& NDPath::GetUIPath()
{
	static string ret;
    ret = GetResPath()+string("UI/");
    return ret;
	return NDPath_UIPath;
}

const string& NDPath::GetUIPath( const char* fileName )
{
	static string ret;
	ret = GetUIPath() + string(fileName);
    return ret;
}

const string& NDPath::GetImgPathBattleUI()
{
	static string ret;
    ret = GetResPath2("image/battle_ui/");
    return ret;
	return NDPath_ImgPath_BattleUI;
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

// void NDPath::SetSoundPath(const char* szPath)
// {
// 	if (!szPath)
// 	{
// 		return;
// 	}
// 
// 	NDPath_SoundPath = szPath;
// }

const string& NDPath::GetFullImagepath(const char* pszFileName)
{
	static string ret;
	ret = GetImgPath(pszFileName);
    return ret;
}

const string& NDPath::GetImgPath(const char* filename)
{
	static string ret;
	return ret = GetImagePath() + filename;
}

const string& NDPath::GetImgPathBattleUI(const char* fileName)
{
	static string ret;
	return ret = GetResPath2("image/battle_ui/") + fileName;
}


const string& NDPath::GetAniPath(const char* fileName)
{
	static string ret;
	return ret = GetAnimationPath() + fileName;
}

// 新界面资源统一放在 res/image/ui_new
const string& NDPath::GetImgPathUINew(const char* fileName)
{
	static string ret;
	return ret = GetResPath2("image/ui_new/")+ fileName;
}

// 新界面高分辨率资源统一放在 res/image/ui_new/advance
const string& NDPath::GetImgPathUINewAdvance(const char* fileName)
{
	static string ret;
	return ret = GetResPath2("image/ui_new/advance/")+ fileName;
}

const string& NDPath::GetMapPath(const char* fileName)
{
	static string ret;
	return ret = GetResPath2("map/")+ fileName;
}

const string& NDPath::GetUIConfigPath(const char* filename)
{
	static string ret;
	return ret = GetUIPath() + filename;
}


const string& NDPath::GetUIImgPath(const char* uiFileNameWithPath)
{
	static string ret;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    ret = string(GetResourcePath())+"SimplifiedChineseRes"+uiFileNameWithPath;
    return ret;
#else

#ifdef TRADITION
	return ret = GetResPath() + "TraditionalChineseRes/" + uiFileNameWithPath;
#else

	//return string(GetResourcePath()+"SimplifiedChineseRes/"+uiFileNameWithPath).c_str();GetResPath()+

	string strRes = string(
			string("../SimplifiedChineseRes") + uiFileNameWithPath);
	NDString* pstrString = new NDString(strRes);

	//strRes = ReplaceString(strRes,"/","\\");

	char* pszTemp = new char[255];
	memset(pszTemp, 0, sizeof(char) * 255);
	strcpy(pszTemp, pstrString->getData());

	for (unsigned int i = 0; i < strlen(pszTemp); i++)
	{
		if (pszTemp[i] == '/')
		{
			pszTemp[i] = '\\';
		}
	}

	//return pszTemp;
	ret = pszTemp;
	return ret;
#endif        
#endif
}

const string& NDPath::GetResPath(const char* fileName)
{
	static string ret;
	return ret = GetResPath() + string(fileName);
}

const string& NDPath::GetSMImgPath(const char* fileName)
{
	static string ret;
	return ret = GetImagePath() + "Res00/" + fileName;
}

const string& NDPath::GetScriptPath(const char* filename)
{
	static string ret;
	return ret = GetScriptPath() + filename;
}

const string& NDPath::GetScriptPath()
{
	static string ret;
    ret = GetResPath2("Script/");
    return ret;
	return NDPath_ScriptPath;
}

const string& NDPath::GetAppPath()
{
#ifdef _DEBUG
	return string("../");
#else
	return string("../release/");
#endif
}

const char* NDPath::GetResourcePath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if(0 == s_ResBasePath)
    {
        s_ResBasePath = new string;
        NSString *path = [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]];
        *s_ResBasePath = [path UTF8String];
	}
	return s_ResBasePath->c_str();
#else
	return "";
#endif
}

const string& NDPath::GetImgPathNew( const char* fileName )
{
	static string ret;
	ret = GetResPath2("image/ui_new/") + string(fileName);
    return ret;
}

const string& NDPath::GetImgPathNewAdvance( const char* fileName )
{
	static string ret;
	ret = GetResPath2("image/ui_new/advance/") + string(fileName);
    return ret;
}

const string& NDPath::GetRootResPath()
{
    static string ret;
	if ( s_iResDirPos == 0 )
	{
		ret = NDPath::GetAppPath() + SZ_ROOT_SOURCE_DIR + "/";
	}
	else
	{
#ifdef DOCUMENT
		ret = NDPath::GetResourcePath() + SZ_ROOT_SOURCE_DIR + "/";
#else
		ret = NDPath::GetCashesPath() + SZ_ROOT_SOURCE_DIR + "/";
#endif
	}
    return ret;
}

std::string NDPath::GetCashesPath()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
     // NSError *error;
     NSString *path1 = [NSHomeDirectory()stringByAppendingPathComponent:@"Library"];
     NSString *CashesDirectory = [path1 stringByAppendingPathComponent:@"/Caches"];
     return std::string([CashesDirectory UTF8String]) +"/";
#else
	return string("");
#endif
}

const string& NDPath::GetLogPath()
{
	return NDPath_LogPath;
}

NS_NDENGINE_END
