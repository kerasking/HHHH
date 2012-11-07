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
#include "define.h"

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
	static string GetAppPath();
	static string GetResourcePath();
	static string GetImagePath();
	static string GetMapPath();
	static string GetMapResPath();
	static string GetAnimationPath();
	static string GetResPath();
	static string GetSoundPath();
	static string GetImgPathBattleUI(const char* fileName);
	static string GetImgPathBattleUI();
	static string GetImgPath(const char* fileName);
	static string GetImgPathNew(const char* fileName);
	static string GetImgPathNewAdvance(const char* fileName);
	static string GetAniPath(const char* fileName);
	static string GetMapPath(const char* fileName);
	static string GetUIConfigPath(const char* filename);
	static string GetUIImgPath(const char* uiFileNameWithPath);
	static string GetResPath(const char* fileName);
	static string GetSMImgPath(const char* fileName);
	static string GetRootResPath();
	static string GetScriptPath(const char* filename);
	static string GetScriptPath();
	static string GetAppResFilePath(const char* filename);
	static string GetResourceFilePath(const char* filename);
	static string GetSMVideoPath(const char* fileName);
	static string GetImgPathUINew(const char* fileName);
	static string GetImgPathUINewAdvance(const char* fileName);
 	static string GetFullImagepath(const char* fileName);
 	static string GetUIPath(const char* fileName);
	static string GetUIPath();
	//－－－end
	static void SetImagePath(const char* szPath);
	static void SetResDirPos( int iPos );//
	static int GetResDirPos(){ return s_iResDirPos; }
	static std::string GetCashesPath();
	static void SetAnimationPath(const char* szPath);
	static void SetMapPath(const char* szPath);
	static const char* GetRootResDirName();
	static void SetResPath(const char* szPath);

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

	static int s_iResDirPos;
};

NS_NDENGINE_END

#endif
