/*
 *  NDMsgNpc.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 10-12-29.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDMsgNpc.h"
#include "NDNpc.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"

const int LIST_ACTION_END = 1;
void NDMsgNpcList::Process(NDTransData* data, int len)
{
	unsigned char btAction = 0; (*data) >> btAction;
	unsigned char btCount = 0; (*data) >> btCount;
	for (int i = 0; i < btCount; i++)
	{
		int id = 0; (*data) >> id; // 4个字节 npc id
		int usLook = 0; (*data) >> usLook; // 4个字节
		unsigned short usCellX = 0; (*data) >> usCellX; // 2个字节
		unsigned short usCellY = 0; (*data) >> usCellY; // 2个字节
		unsigned char btState = 0;(*data) >>btState; // 1个字节表状态
		unsigned char btCamp = 0; (*data) >>btCamp;
		std::string name = data->ReadUnicodeString(); 
		//NSLog(@"%@", [NSString stringWithUTF8String:name.c_str()]);

		//Npc npc = new Npc(id, name, usLook, usCellX, usCellY);
		//npc.mapId = mapId;
		//npc.setState(btState);
		//npc.setCamp(btCamp);
		//npc.dataStr = in.readString2();
		std::string dataStr = data->ReadUnicodeString(); 
		//NSLog(@"%@", [NSString stringWithUTF8String:dataStr.c_str()]);
		//dynamicNpcArray.addElement(npc);
		
		NDNpc *npc = new NDNpc;
		npc->m_id = id;
		npc->col	= usCellX;
		npc->row	= usCellY;
		npc->look	= usLook;
		npc->camp = btCamp;
		npc->state = btState;
		npc->m_name = name;
		npc->Initialization(usLook);
		npc->SetPosition(ccp(usCellX*16, usCellY*16));
		NDMapMgrObj.m_vNpc.push_back(npc);
	}
	
	if (btAction == LIST_ACTION_END)
	{ // 收发结束
		NDMapMgrObj.AddAllNpcToMap();
		// Array staticNpcArray = Npc.getNpcsByMapId(mapId);
		// scene.addNpc(staticNpcArray); // 增加静态npc
		
		//scene.addNpc(dynamicNpcArray); // 增加动态npc
		//scene.initialAutoFindPath();
		// staticNpcArray.removeAllElements();
		//dynamicNpcArray.removeAllElements();
		// if (T.isTaskHasReceived) { // 防止没有收到Task_Done 信息就刷新当前地图
		// Npc.refreshNpcStateInMap();
		// }
	}
}

void NDMsgNpcState::Process(NDTransData* data, int len)
{
	if (true) {
		return;
	}
	int count = 0; count = data->ReadInt();
	
	for (int i = 0; i < count; i++)
	{
		int npcId = 0; npcId = data->ReadInt();
		unsigned char state = 0; (*data) >> state;
		//Npc.setNpcTaskStateById(npcId, (byte) in.read());
	}
}