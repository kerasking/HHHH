/*
 *  ScriptNetMsg.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
#include "ScriptNetMsg.h"
#include "ScriptInc.h"
#include "NDTransData.h"
#include "NDUtility.h"
#include <map>

using namespace NDEngine;
using namespace LuaPlus;

std::map<MSGID, LuaObject> mapNetMsgHandler;

// lua注册网络消息使用注释如下:
// lua回调函数原型(LuaCallBack) : bool (NDTransData*);
// lua注册函数原型: bool RegisterNetMsgHandler(MSGID, char*, LuaCallBack)

int RegisterNetMsgHandler(LuaState* state)
{
	LuaStack args(state);
	LuaObject loId = args[1];
	LuaObject loStr = args[2];
	LuaObject loLuaFunc = args[3];
	
	if (!loId.IsInteger()	||
		!loStr.IsString()	||
		!loLuaFunc.IsFunction())
	{
		state->PushBoolean(false);
		
		return 1;
	}
	
	ScriptMgrObj.DebugOutPut("RegisterNetMsgHandler : [%d][%s]", 
							 loId.GetInteger() ,loStr.GetString());
	
	std::map<MSGID, LuaObject>::iterator 
	it = mapNetMsgHandler.find(loId.GetNumber());
	
	if (it != mapNetMsgHandler.end())
	{
		NDAsssert(0);
	
		state->PushBoolean(false);
		
		return 1;
	}
	
	mapNetMsgHandler.insert(
	std::pair<MSGID, LuaObject>(
	loId.GetNumber(), loLuaFunc) );
	
	state->PushBoolean(true);
	
	return 1;
}

void SendMsg(NDTransData* data)
{
	if (!data)
	{
		return;
	}
	SEND_DATA(*data);
}

void ScriptNetMsg::OnLoad()
{
	ETLUAFUNC("RegisterNetMsgHandler", RegisterNetMsgHandler)
	ETCFUNC("SendMsg", SendMsg)
}

bool ScriptNetMsg::Process(MSGID msgID, NDTransData* data)
{
	std::map<MSGID, LuaObject>::iterator 
	itFun = mapNetMsgHandler.find(msgID);
	
	if (itFun == mapNetMsgHandler.end()) 
		return false;
	
	LuaObject& fun = itFun->second;
	if (!fun.IsFunction()) 
		return true;
	
	LuaFunction<int> luaFunc(fun);
	
	int nRet = luaFunc(data);
	
	return true;
}

// 网络数据处理类导出
ETCLASSBEGIN(NDTransData)

ETCONSTRUCTARG1("createNDTransData", int)
ETDESTRUCT("Free")

ETMEMBERFUNC("ReadByte", &NDTransData::ReadByte)
ETMEMBERFUNC("ReadInt", &NDTransData::ReadInt)
ETMEMBERFUNC("ReadShort", &NDTransData::ReadShort)
ETMEMBERFUNC("ReadUnicodeString", (std::string (NDTransData::*)())&NDTransData::ReadUnicodeString)
ETMEMBERFUNC("WriteByte", &NDTransData::WriteByte)
ETMEMBERFUNC("WriteShort", &NDTransData::WriteShort)
ETMEMBERFUNC("WriteInt", &NDTransData::WriteInt)
ETMEMBERFUNC("WriteStr", (void (NDTransData::*)(const char*))&NDTransData::WriteUnicodeString)
ETCLASSEND(NDTransData)