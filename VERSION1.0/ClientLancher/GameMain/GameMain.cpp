/*
*
*/

#include <windows.h>
#include "GameApp.h"
#include "CCString.h"
#include "XMLReader.h"

using namespace cocos2d;

int WINAPI WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
	XMLReader kReader;
	kReader.initWithFile("data.plist");

	return InitGameInstance();
}