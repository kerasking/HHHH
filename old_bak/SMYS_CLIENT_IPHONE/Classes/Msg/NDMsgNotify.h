/*
 *  MDMsgNotify.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
#ifndef _ND_MSG_NOTIFY_H
#define _ND_MSG_NOTIFY_H

#import "NDNetMsg.h"

class NDMsgNotify 
public:
	NDMsgNotify(){};
	~NDMsgNotify(){};
public:
	void Process(NDTransData* data, int len);
};

#endif //_ND_MSG_NOTIFY_H

