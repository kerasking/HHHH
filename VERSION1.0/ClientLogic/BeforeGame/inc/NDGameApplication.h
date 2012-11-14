/*
 *
 */

#ifndef NDGAMEAPPLICATION_H
#define NDGAMEAPPLICATION_H

#include "define.h"
#include "NDBaseDirector.h"

#include <cocos2d.h>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "NDConsole.h"
#endif

using namespace cocos2d;
static NDBaseDirector s_NDBaseDirector;
NS_NDENGINE_BGN

class NDGameApplication:
	private CCApplication
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	,public NDConsoleListener
#endif
{
public:

	NDGameApplication();
	virtual ~NDGameApplication();

	virtual bool applicationDidFinishLaunching();
	virtual void applicationDidEnterBackground();
	virtual void applicationWillEnterForeground();

	virtual bool processConsole( const char* pszInput );
	virtual bool processPM( const char* pszCmd );

protected:
private:
	virtual void MyInit(); //after applicationDidFinishLaunching() called.
};

NS_NDENGINE_END

#endif
