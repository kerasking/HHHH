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
	static const string GetAppPath();
	static const string GetImagePath();  
	static const string GetMapPath();
	static const string GetMapResPath();
	static const string GetAnimationPath();
	
	static const char*  GetResPath();
	static const string GetResPath(const char* fileName);
	static const char*  GetResourcePath();

	static const string GetSoundPath();
	static const string GetImgPathBattleUI(const char* fileName);
	static const string GetImgPathBattleUI();
	static const string GetImgPath(const char* fileName);
	static const string GetImgPathNew(const char* fileName);
	static const string GetImgPathNewAdvance(const char* fileName);
	static const string GetAniPath(const char* fileName);
	static const string GetMapPath(const char* fileName);
	static const string GetUIConfigPath(const char* filename);
	static const string GetUIImgPath(const char* uiFileNameWithPath);
	
	static const string GetSMImgPath(const char* fileName);
	static const string GetRootResPath();
	static const string GetScriptPath(const char* filename);
	static const string GetScriptPath();
	static const string GetAppResFilePath(const char* filename);
	static const string GetResourceFilePath(const char* filename);
	static const string GetSMVideoPath(const char* fileName);
	static const string GetImgPathUINew(const char* fileName);
	static const string GetImgPathUINewAdvance(const char* fileName);
 	static const string GetFullImagepath(const char* fileName);
 	static const string GetUIPath(const char* fileName);
	static const string GetUIPath();
	//－－－end
	static void SetImagePath(const char* szPath);
	static void SetResDirPos( int iPos );//
	static int GetResDirPos(){ return s_iResDirPos; }
	static std::string GetCashesPath();
	static void SetAnimationPath(const char* szPath);
	static void SetMapPath(const char* szPath);
	static const char* GetRootResDirName();
	static void SetResPath(const char* szPath);

	static const string GetLogPath();

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

	static string NDPath_LogPath;

};

NS_NDENGINE_END

#endif
