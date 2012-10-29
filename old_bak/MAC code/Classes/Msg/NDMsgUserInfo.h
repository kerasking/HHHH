/*
 *  NDMsgUserInfo.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-28.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_MSG_USER_INFO_H_
#define _ND_MSG_USER_INFO_H_

#import "NDNetMsg.h"

/**User:英雄,Player:其它玩家*/

class NDMsgUserInfo 
{
public:
	NDMsgUserInfo(){};
	~NDMsgUserInfo(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgUserItemInfo 
{
public:
	NDMsgUserItemInfo(){};
	~NDMsgUserItemInfo(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgUserAttrib 
{
public:
	NDMsgUserAttrib(){};
	~NDMsgUserAttrib(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgUserWalk 
{
public:
	NDMsgUserWalk(){};
	~NDMsgUserWalk(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgKickBack 
{
public:
	NDMsgKickBack(){};
	~NDMsgKickBack(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgBrocastPlayer 
{
public:
	NDMsgBrocastPlayer(){};
	~NDMsgBrocastPlayer(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgPlayerExt 
{
public:
	NDMsgPlayerExt(){};
	~NDMsgPlayerExt(){};
public:
	void Process(NDTransData* data, int len);
};

class NDMsgPlayerDisappear 
{
public:
	NDMsgPlayerDisappear(){};
	~NDMsgPlayerDisappear(){};
public:
	void Process(NDTransData* data, int len);
};


#endif // _ND_MSG_USER_INFO_H_