/*
*
*/

#include <windows.h>
#include "GameApp.h"
#include "CCString.h"
#include "XMLReader.h"
#include "NDDirector.h"

using namespace cocos2d;
using namespace NDEngine;

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(szCmdLine);

	InitGameInstance();

	NDDirector* pkDirector = NDDirector::DefaultDirector();
	pkDirector->Initialization();

	return CCApplication::sharedApplication().run();
}