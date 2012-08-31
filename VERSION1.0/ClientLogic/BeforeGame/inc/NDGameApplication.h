/*
 *
 */

#ifndef NDGAMEAPPLICATION_H
#define NDGAMEAPPLICATION_H

#include <cocos2d.h>

using namespace cocos2d;

namespace NDEngine
{
class NDGameApplication: private CCApplication
{
public:

	NDGameApplication();
	virtual ~NDGameApplication();

	virtual bool initInstance();
	virtual bool applicationDidFinishLaunching();
	virtual void applicationDidEnterBackground();
	virtual void applicationWillEnterForeground();

protected:
private:
};

}

#endif
