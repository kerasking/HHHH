/*
 *  ScriptGameDataLua.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "ScriptGameData.h"
#include "ScriptInc.h"
#include "ScriptDataBase.h"
#include "SqliteDBMgr.h"
#include "NDLocalization.h"
#include "ScriptGameDataLua.h"

using namespace NDEngine;

//#pragma mark 获取ID列表
int GetGameDataIdList(LuaState* state)
{
	lua_State* L = state->GetCState();
	
	if (!L)
	{
		state->PushNil();
		return 1;
	}
	
	lua_newtable(L);
	
	LuaStack args(state);
	// eScriptData
	LuaObject scriptdata = args[1];
	// nKey
	LuaObject key = args[2];
	// eRoleData
	LuaObject roledata = args[3];
	
	if (!scriptdata.IsNumber()	||
		!key.IsNumber()			||
		!roledata.IsNumber())
	{
		return 1;
	}
	
	ID_VEC idVec;
	if (!ScriptGameDataObj.GetDataIdList(
		(eScriptData)scriptdata.GetInteger(), 
		key.GetInteger(), 
		(eRoleData)roledata.GetInteger(), 
		idVec))
	{
	}
	
	size_t size = idVec.size();
	for (size_t i = 0; i < size; i++) 
	{
		lua_pushnumber(L, i + 1);
		lua_pushnumber(L, idVec[i]);
		lua_settable(L, -3);
	}
	return 1;
}

//#pragma mark 获取角色基本数据

double GetRoleBasicDataN(int nRoleId, int dataIndex)
{
	return GRDBasicN(nRoleId, dataIndex);
}

double GetRoleBasicDataF(int nRoleId, int dataIndex)
{
	return GRDBasicF(nRoleId, dataIndex);
}

const char* GetRoleBasicDataS(int nRoleId, int dataIndex)
{
	return GRDBasicS(nRoleId, dataIndex).c_str();
}

int GetRoleBasicDataBig(LuaState* state)
{
	LuaStack args(state);
	LuaObject nRoleId = args[1];
	LuaObject nDataIndex = args[2];
	
	if ( !(nRoleId.IsNumber() && nDataIndex.IsNumber()) )
	{
		state->PushNumber(0);
		state->PushNumber(0);
	}
	else
	{
		unsigned long long ull = 
		GRDBasicN(nRoleId.GetNumber(), 
				  nDataIndex.GetNumber());
		
		state->PushNumber(ull >> 32);
		state->PushNumber(ull);
	}
	
	return 2;
}

//#pragma mark 设置角色基本数据
void SetRoleBasicDataN(int nRoleId, int dataIndex, double ulVal)
{
	return SRDBasic(nRoleId, dataIndex, ulVal);
}

void SetRoleBasicDataF(int nRoleId, int dataIndex, double dVal)
{
	return SRDBasic(nRoleId, dataIndex, dVal);
}

void SetRoleBasicDataS(int nRoleId, int dataIndex, const char* szVal)
{
	return SRDBasic(nRoleId, dataIndex, szVal);
}

void SetGameDataN(int esd, unsigned int nKey, int e,  int nId, unsigned short index, double uiVal)
{
	return ScriptGameDataObj.SetData((eScriptData)esd, nKey, (eRoleData)e, nId, index, uiVal);
}

void SetGameDataF(int esd, unsigned int nKey, int e,  int nId, unsigned short index, float fVal)
{
	return ScriptGameDataObj.SetData((eScriptData)esd, nKey, (eRoleData)e, nId, index, fVal);
}

void SetGameDataS(int esd, unsigned int nKey, int e,  int nId, unsigned short index, const char* szVal)
{
	return ScriptGameDataObj.SetData((eScriptData)esd, nKey, (eRoleData)e, nId, index, szVal);
}

double GetGameDataN(int esd, unsigned int nKey, int e,  int nId, unsigned short index)
{
	double ulVal = ScriptGameDataObj.GetData<double>((eScriptData)esd, nKey, (eRoleData)e, nId, index);
	return ulVal;
}

double GetGameDataF(int esd, unsigned int nKey, int e,  int nId, unsigned short index)
{
	float fVal = ScriptGameDataObj.GetData<double>((eScriptData)esd, nKey, (eRoleData)e, nId, index);
	return fVal;
}

std::string GetGameDataS(int esd, unsigned int nKey, int e,  int nId, unsigned short index)
{
	std::string strVal = ScriptGameDataObj.GetData<std::string>((eScriptData)esd, nKey, (eRoleData)e, nId, index);
	return strVal;
}

void DelRoleSubGameDataById(int esd, unsigned int nKey, int e, int nId)
{
	ScriptGameDataObj.DelData((eScriptData)esd, nKey, (eRoleData)e, nId);
}

void DelRoleSubGameData(int esd, unsigned int nKey, int e)
{
	ScriptGameDataObj.DelData((eScriptData)esd, nKey, (eRoleData)e);
}

void DelRoleGameDataById(int esd, unsigned int nKey)
{
	ScriptGameDataObj.DelData((eScriptData)esd, nKey);
}

void DelRoleGameData(int esd)
{
	ScriptGameDataObj.DelData((eScriptData)esd);
} 

void DelGameData()
{
	ScriptGameDataObj.DelAllData();
}

void DumpGameData(int esd, unsigned int nKey, int e, int nId)
{
	ScriptGameDataObj.LogOut((eScriptData)esd, nKey, (eRoleData)e, nId);
}

void DumpDataBaseData(const char* filename, int nId)
{
	ScriptDBObj.LogOut(filename, nId);
}

int GetRoleDataIdTable(LuaState* state)
{
	lua_State* L = state->GetCState();
	
	if (!L)
	{
		state->PushNil();
		return 1;
	}
	
	lua_newtable(L);
	
	LuaStack args(state);
	// eScriptData
	LuaObject esd = args[1];
	// nKey
	LuaObject nKey = args[2];
	// eRoleData
	LuaObject e = args[3];
	
	LuaObject nRoleId = args[4];
	
	LuaObject eList = args[5];
	
	if (!esd.IsNumber()			||
		!nKey.IsNumber()		||
		!e.IsNumber()			||
		!nRoleId.IsNumber()		||
		!eList.IsNumber())
	{
		return 1;
	}
	
	ID_VEC idVec;
	ScriptGameDataObj.GetRoleDataIdList((eScriptData)esd.GetInteger(), 
					nKey.GetInteger(), (eRoleData)e.GetInteger(), 
					nRoleId.GetInteger(),(eIDList)eList.GetInteger(), idVec);
					
	size_t size = idVec.size();
	
	for (size_t i = 0; i < size; i++) 
	{
		lua_pushnumber(L, i + 1);
		lua_pushnumber(L, idVec[i]);
		lua_settable(L, -3);
	}
	return 1;
}

void AddRoleDataId(int esd, unsigned int nKey, int e, int nRoleId, int eList, int nId)
{
	ScriptGameDataObj.PushRoleDataId((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList, nId);
}

void DelRoleDataId(int esd, unsigned int nKey, int e, int nRoleId, int eList, int nId)
{
	ScriptGameDataObj.PopRoleDataId((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList, nId);
}

void DelRoleDataIdList(int esd, unsigned int nKey, int e, int nRoleId, int eList)
{
	ScriptGameDataObj.DelRoleDataIdList((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList);
}

void LogOutRoleDataIdTable(int esd, unsigned int nKey, int e, int nRoleId, eIDList eList)
{
	ScriptGameDataObj.LogOutRoleDataIdList((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList);
}
int Sqlite_SelectData(const char* pszSql, int nColNum)
{
    return CSqliteDBMgr::shareInstance().SelectData(pszSql, nColNum);
}
bool Sqlite_ExcuteSql(const char* pszSql)
{
    return CSqliteDBMgr::shareInstance().ExcuteSql(pszSql);
}
int Sqlite_GetColDataN(int nRowIdx, int nFieldIdx)
{
    return CSqliteDBMgr::shareInstance().GetColDataN(nRowIdx, nFieldIdx);
}
std::string Sqlite_GetColDataS(int nRowIdx, int nFieldIdx)
{
    return std::string(CSqliteDBMgr::shareInstance().GetColDataS(nRowIdx, nFieldIdx));
}
bool Sqlite_IsExistTable(const char* pszTableName)
{
    return CSqliteDBMgr::shareInstance().IsExistTable(pszTableName);
}
std::string GetTxtPub(const char* pszTableName)
{
    return NDCommonCString(pszTableName);
	//GetTxtPri(pszTableName);
}
std::string GetTxtPri(const char* pszTableName)
{	
	return NDCommonCString2(pszTableName);
}

//NS_NDENGINE_BGN
void NDScriptGameData::Load()
{
	/*
	ETCFUNC("GetRoleBasicDataN", GetRoleBasicDataN);
	ETCFUNC("GetRoleBasicDataF", GetRoleBasicDataF);
	ETCFUNC("GetRoleBasicDataS", GetRoleBasicDataS);
	ETLUAFUNC("GetRoleBasicDataBig", GetRoleBasicDataBig);
	*/
	ETLUAFUNC("GetGameDataIdList", GetGameDataIdList);
	ETCFUNC("SetGameDataN", SetGameDataN);
	ETCFUNC("SetGameDataF", SetGameDataF);
	ETCFUNC("SetGameDataS", SetGameDataS);
	ETCFUNC("GetGameDataN", GetGameDataN);
	ETCFUNC("GetGameDataF", GetGameDataF);
	ETCFUNC("GetGameDataS", GetGameDataS);
	ETCFUNC("DelRoleSubGameDataById", DelRoleSubGameDataById);
	ETCFUNC("DelRoleSubGameData", DelRoleSubGameData);
	ETCFUNC("DelRoleGameDataById", DelRoleGameDataById);
	ETCFUNC("DelRoleGameData", DelRoleGameData);
	ETCFUNC("DelGameData", DelGameData);
	ETCFUNC("DumpGameData", DumpGameData);
	ETCFUNC("DumpDataBaseData", DumpDataBaseData);
	ETLUAFUNC("GetRoleDataIdTable", GetRoleDataIdTable);
	ETCFUNC("AddRoleDataId", AddRoleDataId);
	ETCFUNC("DelRoleDataId", DelRoleDataId);
	ETCFUNC("LogOutRoleDataIdTable", LogOutRoleDataIdTable);
	ETCFUNC("Sqlite_SelectData", Sqlite_SelectData);
	ETCFUNC("Sqlite_ExcuteSql", Sqlite_ExcuteSql);
	ETCFUNC("Sqlite_GetColDataN", Sqlite_GetColDataN);
	ETCFUNC("Sqlite_GetColDataS", Sqlite_GetColDataS);
	ETCFUNC("Sqlite_IsExistTable", Sqlite_IsExistTable);
	ETCFUNC("GetTxtPub", GetTxtPub);
	ETCFUNC("GetTxtPri", GetTxtPri);
}
