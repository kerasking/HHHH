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
		//以下方法供逻辑层使用－－－begin
		//......
		static std::string GetAppPath();
		static std::string GetResourcePath();
		static std::string GetImagePath();
		static std::string GetMapPath();
        static std::string GetMapResPath();
		static std::string GetAnimationPath();
		static std::string GetResPath();
		static std::string GetSoundPath();
        static const char* GetImgPathBattleUI(const char* fileName);
        static const char* GetImgPath(const char* fileName);
        static const char* GetImgPathNew(const char* fileName);
        static const char* GetImgPathNewAdvance(const char* fileName);
        static const char* GetAniPath(const char* fileName);
        static const char* GetMapPath(const char* fileName);
        static const char* GetUIConfigPath(const char* filename);
        static const char* GetUIImgPath(const char* uiFileNameWithPath);
        static const char* GetResPath(const char* fileName);
        static const char* GetSMImgPath(const char* fileName);
        static std::string GetRootResPath();
        static const char* GetScriptPath(const char* filename);
        static std::string GetAppResFilePath(const char* filename);
        static std::string GetResourceFilePath(const char* filename);
        static const char* GetSMVideoPath(const char* fileName);
		//－－－end
		static void SetResDirPos( int iPos );//
		static int GetResDirPos(){ return s_iResDirPos; }
        static std::string GetCashesPath();
        static const char* GetRootResDirName();
	protected:
		static int		s_iResDirPos;//资源目录所处位置 0:App目录下,1:Document目录下
	};
}

#endif