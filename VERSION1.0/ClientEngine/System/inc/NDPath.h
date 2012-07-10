//
//  NDPath.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef __NDPath_H
#define __NDPath_H

#include "NDObject.h"
#include <string>

namespace NDEngine
{
	class NDPath : public NDObject 
	{
		DECLARE_CLASS(NDPath)
	public:
		NDPath();
		~NDPath();
		
	public:
		//ÒÔÏÂ·½·¨¹©Âß¼­²ãÊ¹ÓÃ£­£­£­begin
		//......
		static std::string GetResourcePath();
		static std::string GetImagePath();
		static std::string GetMapPath();
        static std::string GetMapResPath();
		static std::string GetAnimationPath();
		static std::string GetResPath();
		static std::string GetSoundPath();
        static const char* GetImgPathBattleUI(const char* fileName);

		static void SetImagePath(const char* szPath);
		static void SetMapPath(const char* szPath);
		static void SetAnimationPath(const char* szPath);
		static void SetResPath(const char* szPath);
		static void SetSoundPath(const char* szPath);
        static const char* GetImgPath(const char* fileName);
        // 新界面资源统一放在 res/image/ui_new
        static const char* GetImgPathNew(const char* fileName);
        // 新界面高分辨率资源统一放在 res/image/ui_new/advance
        static const char* GetImgPathNewAdvance(const char* fileName);
        static const char* GetAniPath(const char* fileName);
        static const char* GetMapPath(const char* fileName);
        static const char* GetUIConfigPath(const char* filename);
        static const char* GetUIImgPath(const char* uiFileNameWithPath);
        static const char* GetResPath(const char* fileName);
        static const char* GetSMImgPath(const char* fileName);
        //static const char* GetImgPath(const char* filename);
        static std::string GetRootResPath();
        static const char* GetScriptPath(const char* filename);
        static std::string GetAppResFilePath(const char* filename);
        static std::string GetResourceFilePath(const char* filename);
	};
}

#endif