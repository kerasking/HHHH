/*
 *  NDNetMsg.h
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-27.
 *  Copyright 2010 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#ifndef _ND_NET_MSG_H_
#define _ND_NET_MSG_H_

#include "Singleton.h"
#include "NDTransData.h"
#include <map>
#include "NDMsgDefine.h"
#include "NDBaseNetMgr.h"

using namespace std;
using namespace NDEngine;

class NDNetMsgPool: public NDBaseNetMgr
{
	typedef map<MSGID, NDMsgObject*> map_class_callback;
	typedef map_class_callback::iterator map_class_callback_it;
	typedef pair<MSGID, NDMsgObject*> map_class_callback_pair;

public:

	NDNetMsgPool();
	~NDNetMsgPool();

	static NDNetMsgPool* GetNetMsgPool();

	bool Process(NDEngine::NDTransData* data);
	bool Process(MSGID msgID, NDEngine::NDTransData* data, int len);
	bool RegMsg(MSGID msgID, NDMsgObject* msgObj);
	void UnRegMsg(MSGID msgID);
private:
	map_class_callback m_mapCallBack;
private:

};

#define NDNetMsgPoolObj NDNetMsgPool::GetNetMsgPool()

#endif // _ND_NET_MSG_H_
