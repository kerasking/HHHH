/*
 *  LuaStateMgr.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
#pragma once

#define LUAPLUS_EXTENSIONS (1)
#include "LuaPlus.h"
#include "LuaPlusHelper.h"

using namespace LuaPlus;

namespace NDEngine {

	#define LuaStateMgrObj LuaStateMgr::GetSingle()

	typedef void (*FUNCEXCEPTOUTPUT)(const char * exceptinfo);
	
	class LuaStateMgr
	{
	public:
		~LuaStateMgr(void);
		
		static LuaStateMgr& GetSingle();
		
		LuaStateOwner& GetState();
		
		void SetExceptOutput(FUNCEXCEPTOUTPUT handler)
		{
			m_funExceptOutput = handler;
		}
		
		FUNCEXCEPTOUTPUT GetExceptOutput()
		{
			return m_funExceptOutput;
		}
	private:
		FUNCEXCEPTOUTPUT m_funExceptOutput;
		
	private:
		LuaStateMgr(void);
	};

}