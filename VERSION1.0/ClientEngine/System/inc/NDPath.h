//
//  NDPath.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 (网龙)DeNA. All rights reserved.
//

#ifndef __NDPath_H
#define __NDPath_H

#include "NDObject.h"
#include <string>

NS_NDENGINE_BGN

using namespace std;


class NDPath: public NDObject
{
	DECLARE_CLASS (NDPath)
public:
	NDPath();
	~NDPath();

public:

	// res path
	static const string& GetResPath();
	static const string& GetResPath(const char* fileName);
	static void SetResPath(const char* szPath);

	// map path
	static const string& GetMapPath();
	static const string& GetMapPath(const char* fileName);
	static void SetMapPath(const char* szPath);

	// animation path
	static const string& GetAnimationPath();
	static const string& GetAniPath(const char* fileName);
	static void SetAnimationPath(const char* szPath);

	// sound path
	static const string& GetSoundPath();
	static void SetSoundPath(const char* szPath);

	// script path
	static const string& GetScriptPath();
	static const string& GetScriptPath(const char* filename);

	// ui path
	static const string& GetUIPath();
	static const string& GetUIConfigPath(const char* filename);
	static const string& GetUIImgPath(const char* uiFileNameWithPath);

	// image path
	static const string& GetImagePath();
	static const string& GetImgPath(const char* fileName);
	static void SetImagePath(const char* szPath);
	static const string& GetFullImagepath(const char* pszFileName); 
	
	// image ui new
	static const string& GetImgPathUINew(const char* fileName); 
	static const string& GetImgPathUINewAdvance(const char* fileName);

	// image battle ui
	static const string& GetImgPathBattleUI();
	static const string& GetImgPathBattleUI(const char* fileName); 
	
	// etc
	static const string& GetSMImgPath(const char* fileName);

protected:

	static string NDPath_ResPath;
	static string NDPath_ImgPath;
	static string NDPath_ImgPath_UINew;
	static string NDPath_ImgPath_BattleUI;
	static string NDPath_MapPath;
	static string NDPath_AniPath;
	static string NDPath_SoundPath;
	static string NDPath_UIPath;
	static string NDPath_ScriptPath;
};

NS_NDENGINE_END

#endif
