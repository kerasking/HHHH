/*
 *
 */

#ifndef NDGAMEAPPLICATION_H
#define NDGAMEAPPLICATION_H

#include "android/CCApplication_android.h"

#include "NDConsole.h"

using namespace cocos2d;

namespace NDEngine
{
class NDGameApplication:
	public CCApplication
#ifdef WIN32
	,public NDConsoleListener
#endif
{
public:

	NDGameApplication();
	virtual ~NDGameApplication();

	virtual bool initInstance();
	virtual bool applicationDidFinishLaunching();
	virtual void applicationDidEnterBackground();
	virtual void applicationWillEnterForeground();

	virtual bool processConsole( const char* pszInput );
	virtual bool processPM( const char* pszCmd );

protected:
private:
};

}

#endif
