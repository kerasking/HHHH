/*
 *  ScriptGameData.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
 
#pragma once

#include <map>
#include <string>
#include <vector>

#include "Singleton.h"
#include "typedef.h"

//@loadini
#define ScriptGameDataObj (NDScriptGameData::GetSingleton())

//#pragma mark set role data 
//#pragma mark (设置角色数据,包括主角跟其它玩家)



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 设置角色基本数据
#define SRDBasic(nRoleId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetRoleBasicData(nRoleId, dataIndex, val)

// 设置角色技能数据
#define SRDSkill(nRoleId, nSkillId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetRoleSkillData(nRoleId, nSkillId, dataIndex, val)

// 设置角色状态数据
#define SRDState(nRoleId, nStateId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetRoleStateData(nRoleId, nStateId, dataIndex, val)

// 设置角色物品数据
#define SRDItem(nRoleId, nItemId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetRoleItemData(nRoleId, nItemId, dataIndex, val)

// 设置角色宠物数据
#define SRDPet(nRoleId, nPetId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetRolePetData(nRoleId, nPetId, dataIndex, val)

// 设置角色任务数据
#define SRDTask(nRoleId, nTaskId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetRoleTaskData(nRoleId, nTaskId, dataIndex, val)

//#pragma mark get role data 
//#pragma mark (获取角色数据,包括主角跟其它玩家)(以N结尾为数值型数据, 以F结尾为浮点型数据, 以S结尾为字符串型数据)

// 获取角色基本数据
#define GRDBasicN(nRoleId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleBasicData<unsigned long long>(nRoleId, dataIndex)
#define GRDBasicF(nRoleId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleBasicData<double>(nRoleId, dataIndex)
#define GRDBasicS(nRoleId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleBasicData<std::string>(nRoleId, dataIndex)

// 获取角色技能数据
#define GRDSkillN(nRoleId, nSkillId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleSkillData<unsigned long long>(nRoleId, nSkillId, dataIndex)
#define GRDSkillF(nRoleId, nSkillId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleSkillData<double>(nRoleId, nSkillId, dataIndex)
#define GRDSkillS(nRoleId, nSkillId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleSkillData<std::string>(nRoleId, nSkillId, dataIndex)

// 获取角色状态数据
#define GRDStateN(nRoleId, nStateId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleStateData<unsigned long long>(nRoleId, nStateId, dataIndex)
#define GRDStateF(nRoleId, nStateId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleStateData<double>(nRoleId, nStateId, dataIndex)
#define GRDStateS(nRoleId, nStateId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleStateData<std::string>(nRoleId, nStateId, dataIndex)

// 获取角色物品数据
#define GRDItemN(nRoleId, nItemId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleItemData<unsigned long long>(nRoleId, nItemId, dataIndex)
#define GRDItemF(nRoleId, nItemId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleItemData<double>(nRoleId, nItemId, dataIndex)
#define GRDItemS(nRoleId, nItemId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleItemData<std::string>(nRoleId, nItemId, dataIndex)

// 获取角色宠物数据
#define GRDPetN(nRoleId, nPetId, dataIndex) \
NDScriptGameData::GetSingleton().GetRolePetData<unsigned long long>(nRoleId, nPetId, dataIndex)
#define GRDPetF(nRoleId, nPetId, dataIndex) \
NDScriptGameData::GetSingleton().GetRolePetData<double>(nRoleId, nPetId, dataIndex)
#define GRDPetS(nRoleId, nPetId, dataIndex) \
NDScriptGameData::GetSingleton().GetRolePetData<std::string>(nRoleId, nPetId, dataIndex)

// 获取角色任务数据
#define GRDTaskN(nRoleId, nTaskId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleTaskData<unsigned long long>(nRoleId, nTaskId, dataIndex)
#define GRDTaskF(nRoleId, nTaskId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleTaskData<double>(nRoleId, nTaskId, dataIndex)
#define GRDTaskS(nRoleId, nTaskId, dataIndex) \
NDScriptGameData::GetSingleton().GetRoleTaskData<std::string>(nRoleId, nTaskId, dataIndex)

//#pragma mark del role data
//#pragma mark 删除角色数据

#define DRD(nRoleId) \
NDScriptGameData::GetSingleton().DelRoleData(nRoleId)

//#pragma mark set npc data
//#pragma mark 设置NPC数据

// 设置NPC基本数据
#define SNPCDBasic(nNpcId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetData(eScriptDataNpc, nNpcId, eRoleDataBasic, 0, dataIndex, val)

// 设置NPC其它数据... ToDo

//#pragma mark get npc data
//#pragma mark 获取NPC数据

// 获取NPC基本数据
#define GNPCDBasicN(nNpcId, dataIndex) \
NDScriptGameData::GetSingleton().GetData<unsigned long long>(eScriptDataNpc, nNpcId, eRoleDataBasic, 0, dataIndex)
#define GNPCDBasicF(nNpcId, dataIndex) \
NDScriptGameData::GetSingleton().GetData<double>(eScriptDataNpc, nNpcId, eRoleDataBasic, 0, dataIndex)
#define GNPCDBasicS(nNpcId, dataIndex) \
NDScriptGameData::GetSingleton().GetData<std::string>(eScriptDataNpc, nNpcId, eRoleDataBasic, 0, dataIndex)

//#pragma mark del npc data
//#pragma mark 删除 npc 数据

// 删除NPC数据
#define DNPCD(nNpcId) \
NDScriptGameData::GetSingleton().DelData(eScriptDataNpc, nNpcId)


//#pragma mark set monster data
//#pragma mark 设置怪物数据

// 设置怪物基本数据
#define SMonsterDBasic(nMonsterId, dataIndex, val) \
NDScriptGameData::GetSingleton().SetData(eScriptDataMonster, nMonsterId, eRoleDataBasic, 0, dataIndex, val)

// 设置怪物其它数据... ToDo

//#pragma mark get monster data
//#pragma mark 获取怪物数据

// 获取怪物基本数据
#define GMonsterDBasicN(nMonsterId, dataIndex) \
NDScriptGameData::GetSingleton().GetData<unsigned long long>(eScriptDataMonster, nMonsterId, eRoleDataBasic, 0, dataIndex)
#define GMonsterDBasicF(nMonsterId, dataIndex) \
NDScriptGameData::GetSingleton().GetData<double>(eScriptDataMonster, nMonsterId, eRoleDataBasic, 0, dataIndex)
#define GMonsterDBasicS(nMonsterId, dataIndex) \
NDScriptGameData::GetSingleton().GetData<std::string>(eScriptDataMonster, nMonsterId, eRoleDataBasic, 0, dataIndex)

//#pragma mark del mosnter data
//#pragma mark 删除 怪物 数据

// 删除怪物数据
#define DMonsterD(nMonsterId) \
NDScriptGameData::GetSingleton().DelData(eScriptDataMonster, nMonsterId)


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// together use with lua
typedef enum
{
	eScriptDataBegin					= 0,
	eScriptDataDataBase					= eScriptDataBegin,
	eScriptDataRole						= 1,
	eScriptDataNpc						= 2,
	eScriptDataMonster					= 3,
	eScriptDataTaskConfig				= 4,
	eItemInfo							= 5,
	eSysItem							= 6,
	// other type of script data ...
}eScriptData;

// together use with lua
typedef enum 
{
	eRoleDataBasic						= 0,
	eRoleDataPet						= 1,
	eRoleDataSkill						= 2,
	eRoleDataState						= 3,
	eRoleDataItem						= 4,
	eRoleDataTask						= 5,
	eRoleDataTaskCanAccept				= 6,
	// other Role data ...
}eRoleData;

typedef enum
{
	eIDList_Begin						= 0,
	eIDList_Type1						= eIDList_Begin,
	eIDList_Type2,
	eIDList_Type3,
}eIDList;

// together use with lua
typedef enum 
{
	GDT_None,
	GDT_Char,
	GDT_UChar,
	GDT_Short,
	GDT_UShort,
	GDT_Int,
	GDT_UInt,
	GDT_Float,
	GDT_Double,
	GDT_Int64,
	GDT_UInt64,
	GDT_String,
	GDT_End,
}GameDataType;

typedef struct 
_tagScriptGameData
{
	GameDataType typeOfData;
	char*  valueOfStr;
	union  
	{
		char				cVal;
		unsigned char		ucVal;
		short				sVal;
		unsigned short		usVal;
		int					iVal;
		unsigned int		uiVal;
		float				fVal;
		double				dVal;
		long long			bigVal;
		unsigned long long	ubigVal;
	}valueOfNumber;
	
	_tagScriptGameData()
	{
		typeOfData = GDT_None;
        valueOfStr = NULL;
	}
}ScriptGameData;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// 把存储类型由map改成vector
typedef std::map<unsigned int, ScriptGameData>				VecScriptGameData;
typedef VecScriptGameData::iterator							VecScriptGameDataIt;
typedef VecScriptGameData::value_type						VecScriptGameDataVt;

// 把存储类型由map改成vector,目的是每次获取出来的id列表都是有序的
typedef struct  _tagSTScriptGameData
{
	unsigned int nId;
	VecScriptGameData vData;
	std::map<int, ID_VEC> mapIDList;
	_tagSTScriptGameData(unsigned int nId, VecScriptGameData& vData)
	{
		this->nId			= nId;
		this->vData			= vData;
	}
	_tagSTScriptGameData()
	{
		this->nId			= 0;
	}
}STSCRIPTGAMEDATA;
typedef std::vector<STSCRIPTGAMEDATA>						MapScriptGameData;
typedef MapScriptGameData::iterator							MapScriptGameDataIt;
//typedef std::pair<unsigned int, VecScriptGameData>			MapScriptGameDataPair;

typedef std::vector<MapScriptGameData>						VecMapScriptGameData;
typedef VecMapScriptGameData::iterator						VecMapScriptGameDataIt;

typedef struct 
_tagGameScriptDataSet
{
	VecScriptGameData		basicdata;
	VecMapScriptGameData	extradata;
}GameScriptDataSet;

typedef std::map<unsigned int, GameScriptDataSet>			MapGameScriptObject;
typedef MapGameScriptObject::iterator						MapGameScriptObjectIt;
typedef std::pair<unsigned int, GameScriptDataSet>			MapGameScriptObjectPair;

typedef std::vector<MapGameScriptObject>					VecMapGameScriptDataObject;
typedef VecMapGameScriptDataObject::iterator				VecMapGameScriptDataObjectIt;
typedef std::vector<char*>                                  VecGlobalStr;
typedef VecGlobalStr::iterator                              VecGlobalStrIt;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T>
inline GameDataType GetGameDataType(const T& data)											{ return GDT_None; }
template<typename T>
inline GameDataType GetGameDataType(const T* data)											{ return GDT_None; }
template<>
inline GameDataType GetGameDataType<char>(const char& data)								{ return GDT_Char; }
template<>
inline GameDataType GetGameDataType<unsigned char>(const unsigned char& data)				{ return GDT_UChar; }
template<>
inline GameDataType GetGameDataType<short>(const short& data)								{ return GDT_Short; }
template<>
inline GameDataType GetGameDataType<unsigned short>(const unsigned short& data)			{ return GDT_UShort; }
template<>
inline GameDataType GetGameDataType<int>(const int& data)									{ return GDT_Int; }
template<>
inline GameDataType GetGameDataType<unsigned int>(const unsigned int& data)				{ return GDT_UInt; }
template<>
inline GameDataType GetGameDataType<float>(const float& data)								{ return GDT_Float; }
template<>
inline GameDataType GetGameDataType<double>(const double& data)							{ return GDT_Double; }
template<>
inline GameDataType GetGameDataType<long long>(const long long& data)						{ return GDT_Int64; }
template<>
inline GameDataType GetGameDataType<unsigned long long>(const unsigned long long& data)	{ return GDT_UInt64; }
template<>
inline GameDataType GetGameDataType<std::string>(const std::string& data)					{ return GDT_String; }
template<>
inline GameDataType GetGameDataType<char>(const char* data)								{ return GDT_String; }


/////////////////////////////////////////////////////////////////////////////////////////////////////////
class NDScriptGameData  : public TSingleton<NDScriptGameData>
{
public:
	void Load();
	
	void LogOutMemory();
	
//#pragma mark 打印游戏数据
	void LogOut(eScriptData esd, unsigned int nKey, eRoleData e, int nId);
private:
	void LogOut(VecScriptGameData& vSGD);
	
//#pragma mark 角色数据id列表管理
public:
	bool			GetRoleDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList, ID_VEC& idVec);
	bool			DelRoleDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList);
	void			PushRoleDataId(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList, int nId);
	void			PopRoleDataId(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList, int nId);
	void			LogOutRoleDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList);

public:
//#pragma mark 获取id列表
	bool			GetDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, ID_VEC& idVec);
	
//#pragma mark 脚本数据接口
	template<typename T>
	void			SetData(eScriptData esd, unsigned int nKey, eRoleData e,  int nId, unsigned short index, const T& data);
	
	template<typename RT>
	RT				GetData(eScriptData esd, unsigned int nKey, eRoleData e,  int nId, unsigned short index);
	
	int				GetIntData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index);
	float			GetFloatData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index);
	long long		GetBigIntData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index);
	std::string		GetStrData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index);

	void			DelData(eScriptData esd, unsigned int nKey, eRoleData e, int nId);
	void			DelData(eScriptData esd, unsigned int nKey, eRoleData e);
	void			DelData(eScriptData esd, unsigned int nKey);
	void			DelData(eScriptData esd);
	void			DelAllData();

//#pragma mark 角色基础数据接口
	template<typename T>
	void			SetRoleBasicData(unsigned int nKey, unsigned short index, const T& data);
	template<typename RT>
	RT				GetRoleBasicData(unsigned int nKey, unsigned short index);
	int				GetRoleBasicIntData(unsigned int nKey, unsigned short index);
	float			GetRoleBasicFloatData(unsigned int nKey, unsigned short index);
	long long		GetRoleBasicBigIntData(unsigned int nKey, unsigned short index);
	std::string		GetRoleBasicStrData(unsigned int nKey, unsigned short index);
	void			DelRoleData(unsigned int nKey);
	
//#pragma mark 角色技能数据接口
	template<typename T>
	void			SetRoleSkillData(unsigned int nKey, int nId, unsigned short index, const T& data);
	template<typename RT>
	RT				GetRoleSkillData(unsigned int nKey, int nId, unsigned short index);
	int				GetRoleSkillIntData(unsigned int nKey, int nId, unsigned short index);
	float			GetRoleSkillFloatData(unsigned int nKey, int nId, unsigned short index);
	long long		GetRoleSkillBigIntData(unsigned int nKey, int nId, unsigned short index);
	std::string		GetRoleSkillStrData(unsigned int nKey, int nId, unsigned short index);
	void			DelRoleSkillData(unsigned int nKey, int nId);
	void			DelRoleSkillData(unsigned int nKey);
	
//#pragma mark 角色状态数据接口
	template<typename T>
	void			SetRoleStateData(unsigned int nKey, int nId, unsigned short index, const T& data);
	template<typename RT>
	RT				GetRoleStateData(unsigned int nKey, int nId, unsigned short index);
	int				GetRoleStateIntData(unsigned int nKey, int nId, unsigned short index);
	float			GetRoleStateFloatData(unsigned int nKey, int nId, unsigned short index);
	long long		GetRoleStateBigIntData(unsigned int nKey, int nId, unsigned short index);
	std::string		GetRoleStateStrData(unsigned int nKey, int nId, unsigned short index);
	void			DelRoleStateData(unsigned int nKey, int nId);
	void			DelRoleStateData(unsigned int nKey);

//#pragma mark 角色物品数据接口
	template<typename T>
	void			SetRoleItemData(unsigned int nKey, int nId, unsigned short index, const T& data);
	template<typename RT>
	RT				GetRoleItemData(unsigned int nKey, int nId, unsigned short index);
	int				GetRoleItemIntData(unsigned int nKey, int nId, unsigned short index);
	float			GetRoleItemFloatData(unsigned int nKey, int nId, unsigned short index);
	long long		GetRoleItemBigIntData(unsigned int nKey, int nId, unsigned short index);
	std::string		GetRoleItemStrData(unsigned int nKey, int nId, unsigned short index);
	void			DelRoleItemData(unsigned int nKey, int nId);
	void			DelRoleItemData(unsigned int nKey);
	
//#pragma mark 角色宠物数据接口
	template<typename T>
	void			SetRolePetData(unsigned int nKey, int nId, unsigned short index, const T& data);
	template<typename RT>
	RT				GetRolePetData(unsigned int nKey, int nId, unsigned short index);
	int				GetRolePetIntData(unsigned int nKey, int nId, unsigned short index);
	float			GetRolePetFloatData(unsigned int nKey, int nId, unsigned short index);
	long long		GetRolePetBigIntData(unsigned int nKey, int nId, unsigned short index);
	std::string		GetRolePetStrData(unsigned int nKey, int nId, unsigned short index);
	void			DelRolePetData(unsigned int nKey, int nId);
	void			DelRolePetData(unsigned int nKey);

//#pragma mark 角色任务数据接口
	template<typename T>
	void			SetRoleTaskData(unsigned int nKey, int nId, unsigned short index, const T& data);
	template<typename RT>
	RT				GetRoleTaskData(unsigned int nKey, int nId, unsigned short index);
	int				GetRoleTaskIntData(unsigned int nKey, int nId, unsigned short index);
	float			GetRoleTaskFloatData(unsigned int nKey, int nId, unsigned short index);
	long long		GetRoleTaskBigIntData(unsigned int nKey, int nId, unsigned short index);
	std::string		GetRoleTaskStrData(unsigned int nKey, int nId, unsigned short index);
	void			DelRoleTaskData(unsigned int nKey, int nId);
	void			DelRoleTaskData(unsigned int nKey);

private:
	VecMapGameScriptDataObject	m_vMapGameScriptDataObject;
    VecGlobalStr                m_vGlobalStr;
	
private:
	ScriptGameData&			GetScriptGameDataByVec(VecScriptGameData& vSGD, unsigned short index);
	STSCRIPTGAMEDATA&		GetVecScriptGameDataByMap(MapScriptGameData& mapSGD, unsigned int nId);
	
	bool					GetScriptGameData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index, ScriptGameData&	sgd);
	ScriptGameData&			GetScriptGameData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index);
	VecScriptGameData&		GetVecScriptGameData(eScriptData esd, unsigned int nKey, eRoleData e, int nId);
	
	template<typename T>
	void					SetScriptData(ScriptGameData& sgd, const T& data);
	
	template<typename T>
	void					SetScriptData(ScriptGameData& sgd, const T* data);

	int						GetScriptDataInt(ScriptGameData& sgd);
	double					GetScriptDataFloat(ScriptGameData& sgd);
	long long				GetScriptDataBigInt(ScriptGameData& sgd);
	std::string				GetScriptDataStr(ScriptGameData& sgd);
public:
	NDScriptGameData();
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template<typename T>
void NDScriptGameData::SetRoleBasicData(unsigned int nKey, unsigned short index, const T& data)
{
	SetData(eScriptDataRole, nKey, eRoleDataBasic, 0, index, data);
}

template<typename RT>
RT NDScriptGameData::GetRoleBasicData(unsigned int nKey, unsigned short index)
{
	return GetData<RT>(eScriptDataRole, nKey, eRoleDataBasic, 0, index);
}

template<typename T>
void NDScriptGameData::SetRoleSkillData(unsigned int nKey, int nId, unsigned short index, const T& data)
{
	SetData(eScriptDataRole, nKey, eRoleDataSkill, nId, index, data);
}

template<typename RT>
RT NDScriptGameData::GetRoleSkillData(unsigned int nKey, int nId, unsigned short index)
{
	return GetData<RT>(eScriptDataRole, nKey, eRoleDataSkill, nId, index);
}

template<typename T>
void NDScriptGameData::SetRoleStateData(unsigned int nKey, int nId, unsigned short index, const T& data)
{
	SetData(eScriptDataRole, nKey, eRoleDataState, nId, index, data);
}

template<typename RT>
RT NDScriptGameData::GetRoleStateData(unsigned int nKey, int nId, unsigned short index)
{
	return GetData<RT>(eScriptDataRole, nKey, eRoleDataState, nId, index);
}

template<typename T>
void NDScriptGameData::SetRoleItemData(unsigned int nKey, int nId, unsigned short index, const T& data)
{
	SetData(eScriptDataRole, nKey, eRoleDataItem, nId, index, data);
}

template<typename RT>
RT NDScriptGameData::GetRoleItemData(unsigned int nKey, int nId, unsigned short index)
{
	return GetData<RT>(eScriptDataRole, nKey, eRoleDataItem, nId, index);
}

template<typename T>
void NDScriptGameData::SetRolePetData(unsigned int nKey, int nId, unsigned short index, const T& data)
{
	SetData(eScriptDataRole, nKey, eRoleDataPet, nId, index, data);
}

template<typename RT>
RT NDScriptGameData::GetRolePetData(unsigned int nKey, int nId, unsigned short index)
{
	return GetData<RT>(eScriptDataRole, nKey, eRoleDataPet, nId, index);
}

template<typename T>
void NDScriptGameData::SetRoleTaskData(unsigned int nKey, int nId, unsigned short index, const T& data)
{
	SetData(eScriptDataRole, nKey, eRoleDataTask, nId, index, data);
}

template<typename RT>
RT NDScriptGameData::GetRoleTaskData(unsigned int nKey, int nId, unsigned short index)
{
	return GetData<RT>(eScriptDataRole, nKey, eRoleDataTask, nId, index);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template<typename T>
void NDScriptGameData::SetData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index, const T& data)
{	
	if (esd < eScriptDataBegin || e < eRoleDataBasic)
	{
		NDAsssert(0);
		return;
	}

	ScriptGameData& sgd = GetScriptGameData(esd, nKey, e, nId, index);

	SetScriptData(sgd, data);
}

//default version
template<typename T>
inline void NDScriptGameData::SetScriptData(ScriptGameData& sgd, const T& data)
{
	GameDataType gdt = GetGameDataType(data);
	if (gdt >= GDT_End || gdt <= GDT_None)
	{
		NDAsssert(0);
		return;
	}

	sgd.typeOfData = gdt;

	if (gdt == GDT_String)
	{
		int len = sizeof(T);
		sgd.valueOfStr = (char*)malloc(len+1);
		memcpy(sgd.valueOfStr, &data, len);
		sgd.valueOfStr[len] = 0;
		m_vGlobalStr.push_back(sgd.valueOfStr);
		//sgd.valueOfStr				= data;
	}
	else if (gdt == GDT_Float)
		sgd.valueOfNumber.fVal		= data;
	else if (gdt == GDT_Double)
		sgd.valueOfNumber.dVal		= data;
	else
		sgd.valueOfNumber.ubigVal	= (unsigned long long)data;	
}

//string version
template<>
inline void NDScriptGameData::SetScriptData<std::string>(ScriptGameData& sgd, const std::string& data)
{	
	sgd.typeOfData = GDT_String;

	int len = data.length();
	sgd.valueOfStr = (char*)malloc(len+1);
	if(len > 0)
		memcpy(sgd.valueOfStr, data.c_str(), len);
	sgd.valueOfStr[len] = 0;
	m_vGlobalStr.push_back(sgd.valueOfStr);
}

//char* version
template<>
inline void NDScriptGameData::SetScriptData<char>(ScriptGameData& sgd, const char* data)
{	
	if (!data) return;

	sgd.typeOfData = GDT_String;

	int len = strlen(data);
	sgd.valueOfStr = (char*)malloc(len+1);
	if(len > 0)
	{
		memcpy(sgd.valueOfStr, data, len);
	}
	sgd.valueOfStr[len] = 0;
	m_vGlobalStr.push_back(sgd.valueOfStr);
}

template<typename RT>
inline RT NDScriptGameData::GetData(eScriptData esd, unsigned int nKey, eRoleData e,  int nId, unsigned short index)
{
	ScriptGameData sgd;

	if (!GetScriptGameData(esd, nKey, e, nId, index, sgd))
		return 0;

	GameDataType gdt = sgd.typeOfData;

	if (gdt == GDT_Float || gdt == GDT_Double)
		return GetScriptDataFloat(sgd);

	if (gdt == GDT_UInt64 || gdt == GDT_Int64)
		return GetScriptDataBigInt(sgd);

	return GetScriptDataInt(sgd);
}

template<>
inline std::string NDScriptGameData::GetData(eScriptData esd, unsigned int nKey, eRoleData e,  int nId, unsigned short index)
{
	ScriptGameData sgd;

	if (!GetScriptGameData(esd, nKey, e, nId, index, sgd))
		return "";

	GameDataType gdt = sgd.typeOfData;

	if (gdt != GDT_String)
		return "";

	return GetScriptDataStr(sgd);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//@dirty @db
class FAST_CACHE 
{
public:
	FAST_CACHE() { memset( this, 0, sizeof(FAST_CACHE)); }

	struct PARAM {
		int p1, p2, p3, p4;
		void* ptr;
	} param;

	bool isMatch(int p1, int p2, int p3, int p4) {
		return p1 == param.p1
			&& p2 == param.p2
			&& p3 == param.p3
			&& p4 == param.p4;
	}

	void saveCache(int p1, int p2, int p3, int p4, void* ptr) {
		param.p1 = p1;
		param.p2 = p2;
		param.p3 = p3;
		param.p4 = p4;
		param.ptr = ptr;
	}

	void* getCachePtr(int p1, int p2, int p3, int p4) {
		if (this->isMatch(p1, p2, p3, p4))
			return param.ptr;
		return NULL;
	}

	void* getRawPtr() {
		return param.ptr;
	}
};
/////////////////////////////////////////////////////////////////////////////////////////
