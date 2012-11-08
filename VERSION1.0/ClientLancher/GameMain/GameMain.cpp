/*
*
*/

#include "GameApp.h"
#include "CCString.h"
#include "XMLReader.h"
#include <NDGameApplication.h>
#include <LuaPlus.h>
#include <NDBaseDirector.h>
#include "NDConsole.h"
#include "NDSharedPtr.h"
#include "NDBaseNetMgr.h"
#include "MsgDefine\inc\NDNetMsg.h"

using namespace cocos2d;
using namespace NDEngine;
using namespace LuaPlus;

#ifndef CC_TARGET_PLATFORM
#define CC_TARGET_PLATFORM CC_PLATFORM_WIN32
#endif

void initClass()
{
	REGISTER_CLASS(NDBaseNetMgr,NDNetMsgPool);
}

int WINAPI WinMain (HINSTANCE hInstance, 
					HINSTANCE hPrevInstance, 
					PSTR szCmdLine, 
					int iCmdShow)
{
 	UNREFERENCED_PARAMETER(hPrevInstance);
 	UNREFERENCED_PARAMETER(szCmdLine);

	initClass();
 
 	InitGameInstance();

	NDConsole kConsole;
	kConsole.BeginReadLoop();

    // 手机平台堆栈会比较小, 以后要改用new
 	NDGameApplication kApp;
    NDBaseDirector kBaseDirector;
 
 	return CCApplication::sharedApplication().run();
}