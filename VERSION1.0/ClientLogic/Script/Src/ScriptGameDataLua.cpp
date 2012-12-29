/*
 *  ScriptGameDataLua.cpp
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 *	说明：注册数据库LUA接口
 */

#include "ScriptGameData.h"
#include "ScriptGameData_NewUtil.h"
#include "ScriptInc.h"
#include "ScriptDataBase.h"
#include "SqliteDBMgr.h"
#include "NDLocalization.h"
#include "ScriptGameDataLua.h"

//@loadini
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

#if WITH_NEW_DB
	NDGameDataUtil::getDataIdList( 
		MAKE_NDTABLEPTR(
					scriptdata.GetInteger(), 
					key.GetInteger(), 
					roledata.GetInteger()),
		idVec);
#else
	ScriptGameDataObj.GetDataIdList(
		(eScriptData)scriptdata.GetInteger(), 
		key.GetInteger(), 
		(eRoleData)roledata.GetInteger(), 
		idVec);
#endif
	
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
// 未使用，LUA实现了同名函数.
// double GetRoleBasicDataN(int nRoleId, int dataIndex)
// {
// 	return GRDBasicN(nRoleId, dataIndex);
// }

// 未使用
// double GetRoleBasicDataF(int nRoleId, int dataIndex)
// {
// 	return GRDBasicF(nRoleId, dataIndex);
// }

// 未使用
// const char* GetRoleBasicDataS(int nRoleId, int dataIndex)
// {
// 	return GRDBasicS(nRoleId, dataIndex).c_str();
// }

// 未使用
// int GetRoleBasicDataBig(LuaState* state)
// {
// 	LuaStack args(state);
// 	LuaObject nRoleId = args[1];
// 	LuaObject nDataIndex = args[2];
// 	
// 	if ( !(nRoleId.IsNumber() && nDataIndex.IsNumber()) )
// 	{
// 		state->PushNumber(0);
// 		state->PushNumber(0);
// 	}
// 	else
// 	{
// 		unsigned long long ull = 
// 		GRDBasicN(nRoleId.GetNumber(), 
// 				  nDataIndex.GetNumber());
// 		
// 		state->PushNumber(ull >> 32);
// 		state->PushNumber(ull);
// 	}
// 	
// 	return 2;
// }


// 未使用！
// //#pragma mark 设置角色基本数据
// void SetRoleBasicDataN(int nRoleId, int dataIndex, double ulVal)
// {
// 	return SRDBasic(nRoleId, dataIndex, ulVal);
// }
// 
// void SetRoleBasicDataF(int nRoleId, int dataIndex, double dVal)
// {
// 	return SRDBasic(nRoleId, dataIndex, dVal);
// }
// 
// void SetRoleBasicDataS(int nRoleId, int dataIndex, const char* szVal)
// {
// 	return SRDBasic(nRoleId, dataIndex, szVal);
// }

#if WITH_NEW_DB
void ModifyParam(int esd, unsigned int nKey, int& e)
{
	//说明：
	//LUA传过来的参数，需要检查并稍作修改，之所以需要修改是因为LUA的调用很不规范：
	//如：local nVal = GetGameDataN(NScriptData.eDataBase, nKey, NRoleData.ePet, nDataId, nDataIndex);
	//上面这行是为了读取INI配置文件的一行，第3个参数本来应该是0，但是LUA传过来的NRoleData.ePet=1，后面在某个地方会-1变成0.

	if (esd == (int)eMJR_DataBase ||
		esd == (int)eMJR_TaskConfig)
	{
		e = 0;
	}
}
#endif

void SetGameDataN(int esd, unsigned int nKey, int e,  int nId, unsigned short index, double dVal)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	NDGameDataUtil::setDataN( MAKE_NDTABLEPTR( esd, nKey, e), 
									MAKE_CELLPTR( nId, index ), dVal );
#else
	return ScriptGameDataObj.SetData((eScriptData)esd, nKey, (eRoleData)e, nId, index, dVal);
#endif
}

void SetGameDataF(int esd, unsigned int nKey, int e,  int nId, unsigned short index, float fVal)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	NDGameDataUtil::setDataF( MAKE_NDTABLEPTR( esd, nKey, e), 
									MAKE_CELLPTR( nId, index ), fVal );
#else
	return ScriptGameDataObj.SetData((eScriptData)esd, nKey, (eRoleData)e, nId, index, fVal);
#endif
}

void SetGameDataS(int esd, unsigned int nKey, int e,  int nId, unsigned short index, const char* szVal)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	NDGameDataUtil::setDataS( MAKE_NDTABLEPTR( esd, nKey, e ), 
									MAKE_CELLPTR( nId, index ), szVal );
#else
	return ScriptGameDataObj.SetData((eScriptData)esd, nKey, (eRoleData)e, nId, index, szVal);
#endif
}

double GetGameDataN(int esd, unsigned int nKey, int e,  int nId, unsigned short index)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	return NDGameDataUtil::getDataN( MAKE_NDTABLEPTR( esd, nKey, e ), 
											MAKE_CELLPTR( nId, index ),false);
#else
	double ulVal = ScriptGameDataObj.GetData<double>((eScriptData)esd, nKey, (eRoleData)e, nId, index);
	return ulVal;
#endif
}

double GetGameDataF(int esd, unsigned int nKey, int e,  int nId, unsigned short index)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	return NDGameDataUtil::getDataF( MAKE_NDTABLEPTR( esd, nKey, e ), 
											MAKE_CELLPTR( nId, index ),false);
#else
	float fVal = ScriptGameDataObj.GetData<double>((eScriptData)esd, nKey, (eRoleData)e, nId, index);
	return fVal;
#endif
}

std::string GetGameDataS(int esd, unsigned int nKey, int e,  int nId, unsigned short index)
{
#if WITH_NEW_DB
	ModifyParam(esd,nKey,e);
	return NDGameDataUtil::getDataS( MAKE_NDTABLEPTR( esd, nKey, e ), 
											MAKE_CELLPTR( nId, index ),false);
#else
	std::string strVal = ScriptGameDataObj.GetData<std::string>((eScriptData)esd, nKey, (eRoleData)e, nId, index);
	return strVal;
#endif
}

//删除一条记录
void DelRoleSubGameDataById(int esd, unsigned int nKey, int e, int nId)
{
#if WITH_NEW_DB
	NDGameDataUtil::delRecordById( MAKE_NDTABLEPTR(esd, nKey, e), nId );
#else
	ScriptGameDataObj.DelData((eScriptData)esd, nKey, (eRoleData)e, nId);
#endif
}

//删除一张表
void DelRoleSubGameData(int esd, unsigned int nKey, int e)
{
#if WITH_NEW_DB
	NDGameDataUtil::delTable( MAKE_NDTABLEPTR(esd, nKey, e));
#else
	ScriptGameDataObj.DelData((eScriptData)esd, nKey, (eRoleData)e);
#endif
}

//删除表集（如某个role/monster对应的的表集）
void DelRoleGameDataById(int esd, unsigned int nKey)
{
#if WITH_NEW_DB
	NDGameDataUtil::delTableSet( (DATATYPE_MAJOR)esd, nKey );
#else
	ScriptGameDataObj.DelData((eScriptData)esd, nKey);
#endif
}

//删除某个主类的所有表（删除表集群）
void DelRoleGameData(int esd)
{
#if WITH_NEW_DB
	NDGameDataUtil::delTableSetGroup( (DATATYPE_MAJOR)esd );
#else
	ScriptGameDataObj.DelData((eScriptData)esd);
#endif
} 

//删除所有数据
void DelGameData()
{
#if WITH_NEW_DB
	NDGameDataUtil::destroyAll();
#else
	ScriptGameDataObj.DelAllData();
#endif
}

//测试
void DumpGameData(int esd, unsigned int nKey, int e, int nId)
{
#if WITH_NEW_DB
	//@todo..
#else
	ScriptGameDataObj.LogOut((eScriptData)esd, nKey, (eRoleData)e, nId);
#endif
}

//测试
void DumpDataBaseData(const char* filename, int nId)
{
#if WITH_NEW_DB
	//@todo..
#else
	ScriptDBObj.LogOut(filename, nId);
#endif
}

//测试
void LogOutRoleDataIdTable(int esd, unsigned int nKey, int e, int nRoleId, eIDList eList)
{
#if WITH_NEW_DB
	//@todo..
#else
	ScriptGameDataObj.LogOutRoleDataIdList((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList);
#endif
}

//获取角色id列表（这个角色所指的范围很广...）
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

#if WITH_NEW_DB
	NDGameDataUtil::getRoleDataIdList( MAKE_NDTABLEPTR(esd.GetInteger(),nKey.GetInteger(),e.GetInteger()), 
					nRoleId.GetInteger(),(eIDList)eList.GetInteger(), idVec);
#else
	ScriptGameDataObj.GetRoleDataIdList((eScriptData)esd.GetInteger(), 
					nKey.GetInteger(), (eRoleData)e.GetInteger(), 
					nRoleId.GetInteger(),(eIDList)eList.GetInteger(), idVec);
#endif
		
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
#if WITH_NEW_DB
	NDGameDataUtil::addRoleDataId( MAKE_NDTABLEPTR(esd,nKey,e), 
											nRoleId, eList, nId );
#else
	ScriptGameDataObj.PushRoleDataId((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList, nId);
#endif
}

void DelRoleDataId(int esd, unsigned int nKey, int e, int nRoleId, int eList, int nId)
{
#if WITH_NEW_DB
	NDGameDataUtil::delRoleDataId( MAKE_NDTABLEPTR(esd,nKey,e), 
											nRoleId, eList, nId );
#else
	ScriptGameDataObj.PopRoleDataId((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList, nId);
#endif
}

void DelRoleDataIdList(int esd, unsigned int nKey, int e, int nRoleId, int eList)
{
#if WITH_NEW_DB
	NDGameDataUtil::delRoleDataIdList( MAKE_NDTABLEPTR(esd,nKey,e), 
												nRoleId, eList );
#else
	ScriptGameDataObj.DelRoleDataIdList((eScriptData)esd, nKey, (eRoleData)e, nRoleId, (eIDList)eList);
#endif
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
std::string GetTxtPub_Common(const char* pszTableName)
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
	ETCFUNC("GetTxtPub", GetTxtPub_Common);
	ETCFUNC("GetTxtPri", GetTxtPri);
}
