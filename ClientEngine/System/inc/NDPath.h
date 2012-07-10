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
		static std::string GetResourcePath();
		static std::string GetImagePath();
		static std::string GetMapPath();
		static std::string GetAnimationPath();
		static std::string GetResPath();
		static std::string GetSoundPath();
		//－－－end
	};
}

#endif