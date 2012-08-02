/*
*
*/

#include <windows.h>
#include "GameApp.h"
#include "CCString.h"

using namespace cocos2d;

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
	CCMutableArray<CCObject*>* pkArray = new CCMutableArray<CCObject*>;

	return InitGameInstance();
}