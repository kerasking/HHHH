/*
 *
 */

#ifndef NDGAMEAPPLICATION_H
#define NDGAMEAPPLICATION_H

#include <cocos2d.h>
#include "NDConsole.h"

using namespace cocos2d;

NS_NDENGINE_BGN

class NDGameApplication:
	private CCApplication,
	public NDConsoleListener
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
