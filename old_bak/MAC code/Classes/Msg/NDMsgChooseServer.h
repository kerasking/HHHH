/*
 *  NDMsgChooseServer.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_MSG_CHOOSE_SERVER_H
#define _ND_MSG_CHOOSE_SERVER_H

#import "NDNetMsg.h"

class NDMsgChooseServer 
{
public:
	NDMsgChooseServer(){};
	~NDMsgChooseServer(){};
public:
	void Process(NDTransData* data, int len);
	static void SendGetServerInfoRequest();
};

#endif // _ND_MSG_CHOOSE_SERVER_H