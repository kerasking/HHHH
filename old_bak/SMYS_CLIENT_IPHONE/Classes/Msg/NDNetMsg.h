/*
 *  NDNetMsg.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-27.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ND_NET_MSG_H_
#define _ND_NET_MSG_H_

#include "Singleton.h"
#include "NDTransData.h"
#include <map>
#include "NDMsgDefine.h"

using namespace std;


class NDMsgObject
{
public:
	NDMsgObject(){}
	virtual ~NDMsgObject(){};
	virtual bool process(MSGID msgID, NDEngine::NDTransData*, int len) = 0;
};

class NDNetMsgPool  : public TSingleton<NDNetMsgPool> 
{	
	typedef map<MSGID, NDMsgObject*>			map_class_callback;
	typedef map_class_callback::iterator	map_class_callback_it;
	typedef pair<MSGID, NDMsgObject*>			map_class_callback_pair;
	
public:
	NDNetMsgPool();
	~NDNetMsgPool();
	
	bool Process(NDEngine::NDTransData* data);
	bool Process(MSGID msgID, NDEngine::NDTransData* data, int len);
	bool RegMsg(MSGID msgID, NDMsgObject* msgObj);
	void UnRegMsg(MSGID msgID);
private:
	map_class_callback m_mapCallBack;
private:
	
};

#define NDNetMsgPoolObj NDNetMsgPool::GetSingleton()

#endif // _ND_NET_MSG_H_
