//
//  NDBaseDirector.h
//  DragonDrive
//
//  Created by xiezhenghai on 10-12-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#ifndef _ND_BASE_DIRECTOR_H_
#define _ND_BASE_DIRECTOR_H_

#include "CCDirector.h"

class NDBaseDirector : public cocos2d::CCDisplayLinkDirector
{
public:
	virtual void mainLoop(void);

private:
	void OnIdle();
};

#endif