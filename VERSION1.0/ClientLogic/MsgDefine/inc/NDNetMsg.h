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

NS_NDENGINE_BGN

class NDNetMsgPool:public NDBaseNetMgr
{
	DECLARE_CLASS(NDNetMsgPool)

	typedef map<unsigned short, NDMsgObject*> map_class_callback;
	typedef map_class_callback::iterator map_class_callback_it;
	typedef pair<unsigned short, NDMsgObject*> map_class_callback_pair;

public:
	NDNetMsgPool();
	~NDNetMsgPool();

	bool Process(NDEngine::NDTransData* data);
	bool Process(unsigned short msgID, NDEngine::NDTransData* data, int len);
	bool RegMsg(unsigned short msgID, NDMsgObject* msgObj);
	void UnRegMsg(unsigned short msgID);
private:
	map_class_callback m_mapCallBack;
private:

};

NS_NDENGINE_END

#endif // _ND_NET_MSG_H_
