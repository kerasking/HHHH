/*
 *  NDMsgNpc.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-29.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_MSG_NPC_H
#define _ND_MSG_NPC_H

#import "NDNetMsg.h"

class NDMsgNpcList 
{
public:
	NDMsgNpcList(){};
	~NDMsgNpcList(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgNpcState 
{
public:
	NDMsgNpcState(){};
	~NDMsgNpcState(){};
public:
	void Process(NDTransData* data, int len);
};


#endif // _ND_MSG_NPC_H

