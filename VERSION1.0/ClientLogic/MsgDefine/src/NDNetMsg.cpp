//  NDNetMsg.mm
/*
 *  NDNetMsg.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-27.
 *  Copyright 2010 (ÍøÁú))DeNA. All rights reserved.
 *
 */

#include "NDNetMsg.h"
#include "NDMsgDefine.h"
#include "NDTransData.h"
//#include "BeatHeart.h"
#include "ScriptNetMsg.h"
#include "globaldef.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

using namespace NDEngine;

#define REG_MSG(ID, OBJ)													\
do																			\
{																			\
	map_class_callback_it it = m_mapCallBack.find(ID);						\
	if (it != m_mapCallBack.end() || !(OBJ))								\
		break;																\
	m_mapCallBack.insert(map_class_callback_pair(ID,(NDMsgObject*)(OBJ)));	\
}while(0);

NDNetMsgPool::NDNetMsgPool()
{
}

NDNetMsgPool::~NDNetMsgPool()
{
	m_mapCallBack.clear();
}

bool NDNetMsgPool::Process(NDTransData* data)
{
	if (!data)
	{
		return false;
	}

	int nMsgLen = data->GetSize();


	if (nMsgLen<ND_C_HEAD_SIZE)  //if (nMsgLen < 6)
	{
		return false;
	}

	int nMsgID = data->ReadShort();

	if (nMsgID != _MSG_GAME_QUIT)
	{
		//BeatHeartMgrObj.HadServerMsgArrive();
	}

	return Process(nMsgID, data, nMsgLen - ND_C_HEAD_SIZE);
}

bool NDNetMsgPool::Process(MSGID msgID, NDTransData* data, int len)
{
	LOGD(
			"\n---------------------------------------------<--½ÓÊÕid[%d],len[%d]-----------------------",
			msgID, len + ND_C_HEAD_SIZE);

	if (len + ND_C_HEAD_SIZE > 1024)
	{
		NDAsssert(0);
	}

	// script dispatch first
	if (ScriptNetMsg::Process(msgID, data))
	{
		return true;
	}

	map_class_callback_it it = m_mapCallBack.find(msgID);
	if (it == m_mapCallBack.end())
	{
		return false;
	}

	NDMsgObject* obj = it->second;
	if (!obj)
	{
		return false;
	}
	obj->process(msgID, data, len);

	return true;
}

bool NDNetMsgPool::RegMsg(MSGID msgID, NDMsgObject* msgObj)
{
	/*
	 REG_MSG(NDServerCode::SWAP_KEY, NDBeforeGameMgrPtr)
	 REG_MSG(NDServerCode::NOTIFY, NDBeforeGameMgrPtr)
	 REG_MSG(NDServerCode::_MSG_USERINFO, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_ITEMINFO, NDMapMgrPtr)
	 REG_MSG(NDServerCode::ACQUIRE_SERVER_INFO_RECIEVE, NDBeforeGameMgrPtr)
	 REG_MSG(NDServerCode::_MSG_USERATTRIB, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_WALK, NDMapMgrPtr)
	 REG_MSG(NDServerCode::KICK_BACK, NDMapMgrPtr)
	 REG_MSG(NDServerCode::CHANGE_ROOM, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_PLAYER, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_PLAYER_EXT, NDMapMgrPtr)
	 REG_MSG(NDServerCode::MSG_DISAPPEAR, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_NPCINFO_LIST, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_NPC_STATUS, NDMapMgrPtr)
	 REG_MSG(NDServerCode::_MSG_MONSTER_INFO, NDMapMgrPtr)
	 */

	map_class_callback_it it = m_mapCallBack.find(msgID);

	if (it != m_mapCallBack.end() || !(msgObj))
	{
		return false;
	}

	m_mapCallBack.insert(
			map_class_callback_pair(msgID, (NDMsgObject*) (msgObj)));

	return true;
}

void NDNetMsgPool::UnRegMsg(MSGID msgID)
{
	m_mapCallBack.erase(msgID);
}

NDNetMsgPool* NDNetMsgPool::GetNetMsgPool()
{
	if (0 == ms_pkSingleton)
	{
		ms_pkSingleton = new NDNetMsgPool;//CREATE_CLASS(NDBaseNetMgr,"NDNetMsgPool");
	}

	return (NDNetMsgPool*)ms_pkSingleton;
}