/*
 *  NDMsgChangeMap.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-29.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_MSG_CHANGE_MAP_H_
#define _ND_MSG_CHANGE_MAP_H_

#import "NDNetMsg.h"

class NDMsgChangeMap
{
public:
	NDMsgChangeMap(){};
	~NDMsgChangeMap(){};
public:
	void Process(NDTransData* data, int len);
};

#endif // _ND_MSG_CHANGE_MAP_H_