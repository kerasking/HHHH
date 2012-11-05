//
//  NDPath.mm
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#include "NDPath.h"
#include "define.h"

// todo

NS_NDENGINE_BGN

#define SZ_ROOT_SOURCE_DIR					"SimplifiedChineseRes"	//按语种划分资源根目录名

string NDPath::NDPath_ResPath			= "../SimplifiedChineseRes/res/";
string NDPath::NDPath_ImgPath			= "../SimplifiedChineseRes/res/Image/";
string NDPath::NDPath_ImgPath_BattleUI	= "../SimplifiedChineseRes/res/Image/battle_ui/";
string NDPath::NDPath_ImgPath_UINew		= "../SimplifiedChineseRes/res/Image/ui_new/";
string NDPath::NDPath_MapPath			= "../SimplifiedChineseRes/res/map/";
string NDPath::NDPath_AniPath			= "../SimplifiedChineseRes/res/animation/";
string NDPath::NDPath_SoundPath			= "../SimplifiedChineseRes/res/sound/";
string NDPath::NDPath_UIPath			= "../SimplifiedChineseRes/res/UI/";
string NDPath::NDPath_ScriptPath		= "../SimplifiedChineseRes/res/Script/";

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

const string& NDPath::GetResPath()
{
	return NDPath_ResPath;

//	string strPath = "../SimplifiedChineseRes/res/";
//	return strPath;

// #ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
// #else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/", [[NSBundle mainBundle] resourcePath]];
// #endif
// 		return string([path UTF8String]);
}

const string& NDPath::GetImagePath()
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
// 		return string([path UTF8String]);
}

const string& NDPath::GetMapPath()
{
	return NDPath_MapPath;
	//return "../SimplifiedChineseRes/res/map/";

// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/map/", [[NSBundle mainBundle] resourcePath]];
// 	#endif
// 		return string([path UTF8String]);
}

const string& NDPath::GetSoundPath()
{
	return NDPath_SoundPath;
	
// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/sound/", [[NSBundle mainBundle] resourcePath]];
// 	#endif
// 		return string([path UTF8String]);ss
}

const string& NDPath::GetAnimationPath()
{
	return NDPath_AniPath;
	
//	return string("../SimplifiedChineseRes/res/animation/");

// 	#ifdef TRADITION
// 		NSString *path = [NSString stringWithFormat:@"%@/TraditionalChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
// 	#else
// 		NSString *path = [NSString stringWithFormat:@"%@/SimplifiedChineseRes/res/animation/", [[NSBundle mainBundle] resourcePath]] ;
// 	#endif
// 		return string([path UTF8String]);
}

const string& NDPath::GetUIPath()
{
	return NDPath_UIPath;
}

const string& NDPath::GetUIPath( const char* fileName )
{
	return NDPath_UIPath += string(fileName);
}

const string& NDPath::GetImgPathBattleUI()
{
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
	return GetImgPath(pszFileName);
}

const string& NDPath::GetImgPath(const char* filename)
{
	static string ret;
	return ret = NDPath_ImgPath + filename;

	//return string(GetResPath()+"image/"+filename).c_str();

// 	string strRes = string(GetResPath() + "image/" + filename);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
}

const string& NDPath::GetImgPathBattleUI(const char* fileName)
{
	static string ret;
	return ret = NDPath_ImgPath_BattleUI + fileName;

// 	string strRes = string(GetResPath() + "image/battle_ui/" + fileName);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
	//return string(GetResPath()+"image/battle_ui/"+fileName).c_str();
}


const string& NDPath::GetAniPath(const char* fileName)
{
	static string ret;
	return ret = GetAnimationPath() + fileName;

//	return string(GetResPath() + "animation/" + fileName).c_str();
}

// 新界面资源统一放在 res/image/ui_new
const string& NDPath::GetImgPathUINew(const char* fileName)
{
	static string ret;
	return ret = NDPath_ImgPath_UINew + fileName;

// 	string strRes = string(GetResPath() + "image/ui_new/" + fileName);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
// 	//return string(GetResPath()+"image/ui_new/"+fileName).c_str();
}

// 新界面高分辨率资源统一放在 res/image/ui_new/advance
const string& NDPath::GetImgPathUINewAdvance(const char* fileName)
{
	static string ret;
	return ret = NDPath_ImgPath_UINew + "advance/" + fileName;

// 	string strRes = string(
// 			GetResPath() + "image/ui_new/advance/" + fileName);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
//	//	return string(GetResPath()+"image/ui_new/advance/"+fileName).c_str();
}

const string& NDPath::GetMapPath(const char* fileName)
{
	static string ret;
	return ret = NDPath_MapPath + fileName;
//	return string(GetResPath() + "map/" + fileName).c_str();
}

const string& NDPath::GetUIConfigPath(const char* filename)
{
	static string ret;
	return ret = NDPath_UIPath + filename;

// 	string strRes = string(GetResPath() + "UI/" + filename);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
}


const string& NDPath::GetUIImgPath(const char* uiFileNameWithPath)
{
	static string ret;

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
}

const string& NDPath::GetResPath(const char* fileName)
{
	static string ret;
	return ret = GetResPath() + fileName;
	

// 	string strRes = string(GetResPath() + fileName);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
// 	//return string(GetResPath()+fileName).c_str();
}

const string& NDPath::GetSMImgPath(const char* fileName)
{
	static string ret;
	return ret = NDPath_ImgPath + "Res00/" + fileName;

// 	string strRes = string(GetResPath() + "image/Res00/" + fileName);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
// 	//	return string(GetResPath()+"image/Res00/"+fileName).c_str();
}

const string& NDPath::GetScriptPath(const char* filename)
{
	static string ret;
	return ret = NDPath_ScriptPath + filename;

// 	string strRes = string(
// 			string("../SimplifiedChineseRes/res/") + "Script/" + filename);
// 	char* pszTemp = new char[255];
// 	memset(pszTemp, 0, sizeof(char) * 255);
// 	strcpy(pszTemp, strRes.c_str());
// 	return pszTemp;
// 	//return string(GetResPath()+"Script/"+filename).c_str();
}

const string& NDPath::GetScriptPath()
{
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

const string& NDPath::GetResourcePath()
{
	return string("");
}

const string& NDPath::GetImgPathNew( const char* fileName )
{
	return GetResPath() + string("/image/ui_new/") + string(fileName);
}

const string& NDPath::GetImgPathNewAdvance( const char* fileName )
{
	return GetResPath() + string("/image/ui_new/advance/") + string(fileName);
}

const string& NDPath::GetRootResPath()
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

std::string NDPath::GetCashesPath()
{
//     // NSError *error;
//     NSString *path1 = [NSHomeDirectory()stringByAppendingPathComponent:@"Library"];
//     NSString *CashesDirectory = [path1 stringByAppendingPathComponent:@"/Caches"];
//     return std::string([CashesDirectory UTF8String]) +"/";

	return string("");
}

NS_NDENGINE_END
