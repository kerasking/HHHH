/*
 *  NDMsgLogin.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-27.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_MSG_LOGIN_H_
#define _ND_MSG_LOGIN_H_

#include "NDTransData.h"
#include "NDNetMsg.h"

class NDMsgLogin : public NDMsgObject
{
public:
	NDMsgLogin(){};
	~NDMsgLogin(){};
public:
	void process(int nMsgID, NDEngine::NDTransData*, int len)
private:

public:
	/** 交换密钥 */
	static void sendClientKey(); 
	
	static void generateClientKey(); 
	
};

#endif // _ND_MSG_LOGIN_H_