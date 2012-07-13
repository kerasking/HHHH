/*
 *  ScriptGameData.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 */

#include "ScriptGameData.h"

/////////////////////////////////////////////////////////////////////////////////////////

unsigned int Get_VecScriptGameData_Size(VecScriptGameData& data)
{
	unsigned int nTotal	= 0;
	
	nTotal	+= (sizeof(int) + sizeof(ScriptGameData)) * data.size();
	
	return nTotal;
}

unsigned int Get_STSCRIPTGAMEDATA_Size(STSCRIPTGAMEDATA& data)
{
	unsigned int nTotal	= 0;
	
	nTotal	+= sizeof(data.nId);
	
	nTotal	+= Get_VecScriptGameData_Size(data.vData);
	
	for (std::map<int, ID_VEC>::iterator it = data.mapIDList.begin(); 
		 it != data.mapIDList.end();
		 it++) 
	{
		nTotal	+= sizeof(int);
		nTotal	+= sizeof(OBJID) * (it->second).size();
	}
	
	return nTotal;
}

void NDScriptGameData::LogOutMemory()
{
	unsigned int nTotal = 0;
	
	for(size_t i = 0;
		i < m_vMapGameScriptDataObject.size();
		i++)
	{
		MapGameScriptObject& MapGSO = m_vMapGameScriptDataObject[i];
		
		MapGameScriptObjectIt itMapGSO	= MapGSO.begin();
		for (; itMapGSO != MapGSO.end(); itMapGSO++) 
		{
			nTotal	+= sizeof(unsigned int);
			
			GameScriptDataSet& gsd	= itMapGSO->second;
			
			nTotal	+= Get_VecScriptGameData_Size(gsd.basicdata);
			
			VecMapScriptGameData& extradata = gsd.extradata;
			for (size_t j = 0; j < extradata.size(); j++) 
			{
				MapScriptGameData& msgd		= extradata[j];
				
				for (MapScriptGameDataIt it = msgd.begin(); it != msgd.end(); it++) 
				{
					nTotal		+= Get_STSCRIPTGAMEDATA_Size(*it);
				}
			}
		}
	}
	
	//printf("\n*************cur game data size [%d] kbyte, [%d] mbyte", nTotal / 1024, nTotal / 1024 / 1024);
}


void NDScriptGameData::LogOut(VecScriptGameData& vSGD)
{
	ID_VEC idVec;
	for (VecScriptGameDataIt it = vSGD.begin(); 
		 it != vSGD.end(); 
		 it++) 
	{
		idVec.push_back(it->first);
	}
	
	if (!idVec.empty())
	{
		std::sort(idVec.begin(), idVec.end());
		for (ID_VEC::iterator it = idVec.begin(); 
			 it != idVec.end(); 
			 it++) 
		{
			VecScriptGameDataIt itData = vSGD.find(*it);
			if (itData != vSGD.end())
			{
				ScriptGameData& sgd = itData->second;
				if (GDT_String == sgd.typeOfData)
				{
					NDLog("[index=%d,val=%s]", (*it), sgd.valueOfStr.c_str());
				}
				else
				{
					NDLog("[index=%d,val=%d]", (*it), sgd.valueOfNumber.ubigVal);
				}
			}
		}
	}
}

void NDScriptGameData::LogOut(eScriptData esd, unsigned int nKey, eRoleData e, int nId)
{
	if (esd < eScriptDataBegin || e < eRoleDataBasic)
	{
		return;
	}
	
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return;
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapGSO = mapGSO.find(nKey);
	
	if ( itMapGSO == mapGSO.end() )
		return;
	
	GameScriptDataSet& gsdt = itMapGSO->second;
	
	if (0 == (size_t)e)
	{
		LogOut(gsdt.basicdata);
		return;
	}
	
	if ( (size_t)(e - 1) >= gsdt.extradata.size() )
		return;
	
	MapScriptGameData& mapSGD = gsdt.extradata[e - 1];
	if (mapSGD.empty())
		return;
	
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		STSCRIPTGAMEDATA& stSG = *itMapSGD;
		if (nId == stSG.nId)
		{
			LogOut(stSG.vData);
			break;
		}
	}
}

bool 
NDScriptGameData::GetRoleDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList, ID_VEC& idVec)
{
	if (esd < eScriptDataBegin || e <= eRoleDataBasic || eList < eIDList_Begin)
	{
		return false;
	}
	
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size())
	{
		return false;
	}
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapSGO = mapGSO.find(nKey);
	
	if (itMapSGO == mapGSO.end())
	{
		return false;
	}
	
	GameScriptDataSet& gsds = mapGSO[nKey];
	
	VecMapScriptGameData& vMSGD = gsds.extradata;
	
	size_t eIndex = e - 1;	
	
	if ( eIndex >= vMSGD.size() )
	{
		return false;
	}
	
	MapScriptGameData& mapSGD = vMSGD[eIndex];
	
	bool bFind = false;
	
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		if ((*itMapSGD).nId == (unsigned int)nRoleId)
		{
			bFind = true;
			break;
		}
	}
	
	if (!bFind)
	{
		return false;
	}
	
	STSCRIPTGAMEDATA& st	= *itMapSGD;
	
	std::map<int, ID_VEC>& mapIdList			= st.mapIDList;
	std::map<int, ID_VEC>::iterator itIDList	= mapIdList.find(eList);
	
	if (itIDList == mapIdList.end())
	{
		return false;
	}
	
	idVec = mapIdList[eList];
	
	return true;
}

bool			
NDScriptGameData::DelRoleDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList)
{
	if (esd < eScriptDataBegin || e <= eRoleDataBasic || eList < eIDList_Begin)
	{
		return false;
	}
	
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size())
	{
		return false;
	}
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapSGO = mapGSO.find(nKey);
	
	if (itMapSGO == mapGSO.end())
	{
		return false;
	}
	
	GameScriptDataSet& gsds = mapGSO[nKey];
	
	VecMapScriptGameData& vMSGD = gsds.extradata;
	
	size_t eIndex = e - 1;	
	
	if ( eIndex >= vMSGD.size() )
	{
		return false;
	}
	
	MapScriptGameData& mapSGD = vMSGD[eIndex];
	
	bool bFind = false;
	
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		if ((*itMapSGD).nId == (unsigned int)nRoleId)
		{
			bFind = true;
			break;
		}
	}
	
	if (!bFind)
	{
		return false;
	}
	
	STSCRIPTGAMEDATA& st	= *itMapSGD;
	
	std::map<int, ID_VEC>& mapIdList			= st.mapIDList;
	std::map<int, ID_VEC>::iterator itIDList	= mapIdList.find(eList);
	
	if (itIDList == mapIdList.end())
	{
		return false;
	}
	
	mapIdList.erase(itIDList);
	
	return true;
}

void			
NDScriptGameData::PushRoleDataId(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList, int nId)
{
	if (esd < eScriptDataBegin || e <= eRoleDataBasic || eList < eIDList_Begin)
	{
		NDAsssert(0);
		return;
	}
	
	if ( (size_t)esd == m_vMapGameScriptDataObject.size())
	{
		m_vMapGameScriptDataObject.push_back(MapGameScriptObject());
	}
	else if ( (size_t)esd > m_vMapGameScriptDataObject.size() )
	{
		m_vMapGameScriptDataObject.resize(esd+1);
	}
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapSGO = mapGSO.find(nKey);
	
	if (itMapSGO == mapGSO.end())
	{
		GameScriptDataSet newGSDS;
		mapGSO.insert(MapGameScriptObjectPair(nKey, newGSDS));
	}
	
	GameScriptDataSet& gsds = mapGSO[nKey];
	
	VecMapScriptGameData& vMSGD = gsds.extradata;
	
	size_t eIndex = e - 1;	
	
	if ( eIndex == vMSGD.size() )
	{
		vMSGD.push_back(MapScriptGameData());
	}
	else if ( eIndex > vMSGD.size() )
	{
		vMSGD.resize(eIndex + 1);
	}
	
	MapScriptGameData& mapSGD = vMSGD[eIndex];
	
	STSCRIPTGAMEDATA& st	= GetVecScriptGameDataByMap(mapSGD, nRoleId);
	
	std::map<int, ID_VEC>& mapIdList			= st.mapIDList;
	std::map<int, ID_VEC>::iterator itIDList	= mapIdList.find(eList);
	
	if (itIDList == mapIdList.end())
	{
		ID_VEC idList;
		mapIdList.insert(std::make_pair(eList, idList));
	}
	
	ID_VEC& vId = mapIdList[eList];
	size_t size = vId.size();
	vId.push_back(nId);
}

void			
NDScriptGameData::PopRoleDataId(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList, int nId)
{
	if (esd < eScriptDataBegin || e <= eRoleDataBasic || eList < eIDList_Begin)
	{
		return;
	}
	
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size())
	{
		return;
	}
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapSGO = mapGSO.find(nKey);
	
	if (itMapSGO == mapGSO.end())
	{
		return;
	}
	
	GameScriptDataSet& gsds = mapGSO[nKey];
	
	VecMapScriptGameData& vMSGD = gsds.extradata;
	
	size_t eIndex = e - 1;	
	
	if ( eIndex >= vMSGD.size() )
	{
		return;
	}
	
	MapScriptGameData& mapSGD = vMSGD[eIndex];
	
	bool bFind = false;
	
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		if ((*itMapSGD).nId == nRoleId)
		{
			bFind = true;
			break;
		}
	}
	
	if (!bFind)
	{
		return;
	}
	
	STSCRIPTGAMEDATA& st	= *itMapSGD;
	
	std::map<int, ID_VEC>& mapIdList			= st.mapIDList;
	std::map<int, ID_VEC>::iterator itIDList	= mapIdList.find(eList);
	
	if (itIDList == mapIdList.end())
	{
		return;
	}
	
	ID_VEC& idVec = itIDList->second;
	
	ID_VEC::iterator itId = idVec.begin();
	
	int nNum = 0;
	
	while (itId != idVec.end()) 
	{
		if (nId == *itId)
		{
			itId = idVec.erase(itId);
			
			nNum++;
		}
		else
		{
			itId++;
		}
	}
	
	if (nNum > 1)
	{
		NDAsssert(0);
	}
	
	return;
}

void			
NDScriptGameData::LogOutRoleDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, int nRoleId, eIDList eList)
{
	ID_VEC idVec;
	if (!GetRoleDataIdList(esd, nKey, e, nRoleId, eList, idVec))
	{	
		return;
	}
	
	for (ID_VEC::iterator it = idVec.begin(); 
		 it != idVec.end(); 
		 it++) 
	{
		NDLog(" [%d]", *it);
	}
}

bool 
NDScriptGameData::GetDataIdList(eScriptData esd, unsigned int nKey, eRoleData e, ID_VEC& idVec)
{
	if (esd < eScriptDataBegin || e <= eRoleDataBasic)
	{
		return false;
	}
	
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return false;
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapGSO = mapGSO.find(nKey);
	
	if ( itMapGSO == mapGSO.end() )
		return false;
	
	GameScriptDataSet& gsdt = itMapGSO->second;
	
	if ( (size_t)(e - 1) >= gsdt.extradata.size() )
		return false;
		
	MapScriptGameData& mapSGD = gsdt.extradata[e - 1];
	if (mapSGD.empty())
		return false;
	
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		STSCRIPTGAMEDATA& stSG = *itMapSGD;
		idVec.push_back(stSG.nId);
	}
	
	return true;
}

int				
NDScriptGameData::GetIntData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index)
{
	ScriptGameData sgd;
	
	if (!GetScriptGameData(esd, nKey, e, nId, index, sgd))
		return 0;
	
	return GetScriptDataInt(sgd);
}

float			
NDScriptGameData::GetFloatData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index)
{
	ScriptGameData sgd;
	
	if (!GetScriptGameData(esd, nKey, e, nId, index, sgd))
		return 0.0f;
	
	return GetScriptDataFloat(sgd);
}

long long		
NDScriptGameData::GetBigIntData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index)
{
	ScriptGameData sgd;
	
	if (!GetScriptGameData(esd, nKey, e, nId, index, sgd))
		return 0;
	
	return GetScriptDataBigInt(sgd);
}

std::string		
NDScriptGameData::GetStrData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index)
{
	ScriptGameData sgd;
	
	if (!GetScriptGameData(esd, nKey, e, nId, index, sgd))
		return "";
	
	return GetScriptDataStr(sgd);
}

void			
NDScriptGameData::DelData(eScriptData esd, unsigned int nKey, eRoleData e, int nId)
{
	if ( e <= eRoleDataBasic || (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return;
	
	MapGameScriptObject& mGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMGSO = mGSO.find(nKey);
	
	if (itMGSO == mGSO.end())
		return;
	
	VecMapScriptGameData& vMSGD = itMGSO->second.extradata;
	
	size_t eIndex = e - 1;
	
	if ( eIndex >= vMSGD.size() )
		return;
	
	MapScriptGameData& mapSGD = vMSGD[eIndex];

	/*
	MapScriptGameDataIt itMapSGD = mapSGD.find(nId);
	
	if (itMapSGD != mapSGD.end())
		mapSGD.erase(itMapSGD);
	*/
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		STSCRIPTGAMEDATA& stSG = *itMapSGD;
		if (stSG.nId == (unsigned int)nId)
		{
			mapSGD.erase(itMapSGD);
			break;
		}
	}
}

void			
NDScriptGameData::DelData(eScriptData esd, unsigned int nKey, eRoleData e)
{
	if ( e < eRoleDataBasic || (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return;
	
	MapGameScriptObject& mGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMGSO = mGSO.find(nKey);
	
	if (itMGSO == mGSO.end())
		return;
		
	GameScriptDataSet& gsds = itMGSO->second;
	
	if (e == eRoleDataBasic)
	{
		gsds.basicdata.clear();
		
		return;
	}
	
	size_t eIndex = e - 1;
	
	if ( eIndex < gsds.extradata.size() )
	{
		//gsds.extradata.erase(gsds.extradata.begin() + eIndex);
		gsds.extradata[eIndex] = MapScriptGameData();
	}
}

void			
NDScriptGameData::DelData(eScriptData esd, unsigned int nKey)
{
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return;
		
	MapGameScriptObject& mGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMGSO = mGSO.find(nKey);
	
	if (itMGSO == mGSO.end())
		return;
		
	mGSO.erase(itMGSO);
}

void			
NDScriptGameData::DelData(eScriptData esd)
{
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return;
		
	//m_vMapGameScriptDataObject.erase(
	//m_vMapGameScriptDataObject.begin() + esd );
	
	m_vMapGameScriptDataObject[esd] = MapGameScriptObject();
}

void			
NDScriptGameData::DelAllData()
{
	VecMapGameScriptDataObjectIt it = m_vMapGameScriptDataObject.begin();
	while (it != m_vMapGameScriptDataObject.end()) 
	{
		if (it != m_vMapGameScriptDataObject.begin())
		{
			it = m_vMapGameScriptDataObject.erase(it);
		}
		else
		{
			it++;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////

int				
NDScriptGameData::GetRoleBasicIntData(unsigned int nKey, unsigned short index)
{
	return GetIntData(eScriptDataRole, nKey, eRoleDataBasic, 0, index);
}

float 
NDScriptGameData::GetRoleBasicFloatData(unsigned int nKey, unsigned short index)
{
	return GetFloatData(eScriptDataRole, nKey, eRoleDataBasic, 0, index);
}

long long		
NDScriptGameData::GetRoleBasicBigIntData(unsigned int nKey, unsigned short index)
{
	return GetBigIntData(eScriptDataRole, nKey, eRoleDataBasic, 0, index);
}

std::string		
NDScriptGameData::GetRoleBasicStrData(unsigned int nKey, unsigned short index)
{
	return GetStrData(eScriptDataRole, nKey, eRoleDataBasic, 0, index);
}

void			
NDScriptGameData::DelRoleData(unsigned int nKey)
{
	DelData(eScriptDataRole, nKey);
}

/////////////////////////////////////////////////////////////////////////////////////////


int				
NDScriptGameData::GetRoleSkillIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetIntData(eScriptDataRole, nKey, eRoleDataSkill, nId, index);
}

float			
NDScriptGameData::GetRoleSkillFloatData(unsigned int nKey, int nId, unsigned short index)
{
	return GetFloatData(eScriptDataRole, nKey, eRoleDataSkill, nId, index);
}

long long		
NDScriptGameData::GetRoleSkillBigIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetBigIntData(eScriptDataRole, nKey, eRoleDataSkill, nId, index);
}

std::string		
NDScriptGameData::GetRoleSkillStrData(unsigned int nKey, int nId, unsigned short index)
{
	return GetStrData(eScriptDataRole, nKey, eRoleDataSkill, nId, index);
}

void			
NDScriptGameData::DelRoleSkillData(unsigned int nKey, int nId)
{
	DelData(eScriptDataRole, nKey, eRoleDataSkill, nId);
}

void			
NDScriptGameData::DelRoleSkillData(unsigned int nKey)
{
	DelData(eScriptDataRole, nKey, eRoleDataSkill);
}

/////////////////////////////////////////////////////////////////////////////////////////

int				
NDScriptGameData::GetRoleStateIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetIntData(eScriptDataRole, nKey, eRoleDataState, nId, index);
}

float			
NDScriptGameData::GetRoleStateFloatData(unsigned int nKey, int nId, unsigned short index)
{
	return GetFloatData(eScriptDataRole, nKey, eRoleDataState, nId, index);
}

long long		
NDScriptGameData::GetRoleStateBigIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetBigIntData(eScriptDataRole, nKey, eRoleDataState, nId, index);
}

std::string		
NDScriptGameData::GetRoleStateStrData(unsigned int nKey, int nId, unsigned short index)
{
	return GetStrData(eScriptDataRole, nKey, eRoleDataState, nId, index);
}

void			
NDScriptGameData::DelRoleStateData(unsigned int nKey, int nId)
{
	DelData(eScriptDataRole, nKey, eRoleDataState, nId);
}

void			
NDScriptGameData::DelRoleStateData(unsigned int nKey)
{
	DelData(eScriptDataRole, nKey, eRoleDataState);
}

/////////////////////////////////////////////////////////////////////////////////////////


int				
NDScriptGameData::GetRoleItemIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetIntData(eScriptDataRole, nKey, eRoleDataItem, nId, index);
}

float			
NDScriptGameData::GetRoleItemFloatData(unsigned int nKey, int nId, unsigned short index)
{
	return GetFloatData(eScriptDataRole, nKey, eRoleDataItem, nId, index);
}

long long		
NDScriptGameData::GetRoleItemBigIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetBigIntData(eScriptDataRole, nKey, eRoleDataItem, nId, index);
}

std::string		
NDScriptGameData::GetRoleItemStrData(unsigned int nKey, int nId, unsigned short index)
{
	return GetStrData(eScriptDataRole, nKey, eRoleDataItem, nId, index);
}

void			
NDScriptGameData::DelRoleItemData(unsigned int nKey, int nId)
{
	DelData(eScriptDataRole, nKey, eRoleDataItem, nId);
}

void			
NDScriptGameData::DelRoleItemData(unsigned int nKey)
{
	DelData(eScriptDataRole, nKey, eRoleDataItem);
}

/////////////////////////////////////////////////////////////////////////////////////////


int				
NDScriptGameData::GetRolePetIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetIntData(eScriptDataRole, nKey, eRoleDataPet, nId, index);
}

float			
NDScriptGameData::GetRolePetFloatData(unsigned int nKey, int nId, unsigned short index)
{
	return GetFloatData(eScriptDataRole, nKey, eRoleDataPet, nId, index);
}

long long		
NDScriptGameData::GetRolePetBigIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetBigIntData(eScriptDataRole, nKey, eRoleDataPet, nId, index);
}

std::string		
NDScriptGameData::GetRolePetStrData(unsigned int nKey, int nId, unsigned short index)
{
	return GetStrData(eScriptDataRole, nKey, eRoleDataPet, nId, index);
}

void			
NDScriptGameData::DelRolePetData(unsigned int nKey, int nId)
{
	DelData(eScriptDataRole, nKey, eRoleDataPet, nId);
}

void			
NDScriptGameData::DelRolePetData(unsigned int nKey)
{
	DelData(eScriptDataRole, nKey, eRoleDataPet);
}

/////////////////////////////////////////////////////////////////////////////////////////


int				
NDScriptGameData::GetRoleTaskIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetIntData(eScriptDataRole, nKey, eRoleDataTask, nId, index);
}

float			
NDScriptGameData::GetRoleTaskFloatData(unsigned int nKey, int nId, unsigned short index)
{
	return GetFloatData(eScriptDataRole, nKey, eRoleDataTask, nId, index);
}

long long		
NDScriptGameData::GetRoleTaskBigIntData(unsigned int nKey, int nId, unsigned short index)
{
	return GetBigIntData(eScriptDataRole, nKey, eRoleDataTask, nId, index);
}

std::string		
NDScriptGameData::GetRoleTaskStrData(unsigned int nKey, int nId, unsigned short index)
{
	return GetStrData(eScriptDataRole, nKey, eRoleDataTask, nId, index);
}

void			
NDScriptGameData::DelRoleTaskData(unsigned int nKey, int nId)
{
	DelData(eScriptDataRole, nKey, eRoleDataTask, nId);
}

void			
NDScriptGameData::DelRoleTaskData(unsigned int nKey)
{
	DelData(eScriptDataRole, nKey, eRoleDataTask);
}

/////////////////////////////////////////////////////////////////////////////////////////


NDScriptGameData::NDScriptGameData()
{
}

ScriptGameData&			
NDScriptGameData::GetScriptGameDataByVec(VecScriptGameData& vSGD, unsigned short index)
{
	/*
	if (index == vSGD.size())
	{
		vSGD.push_back(ScriptGameData());
	}
	else if (index > vSGD.size())
	{
		vSGD.resize(index+1);
	}
	
	return vSGD[index];
	*/
	if (vSGD.find(index) == vSGD.end())
	{
		ScriptGameData sgd;
		vSGD.insert(VecScriptGameDataVt(index, sgd));
	}
	
	return vSGD[index];
}

STSCRIPTGAMEDATA&		
NDScriptGameData::GetVecScriptGameDataByMap(MapScriptGameData& mapSGD, unsigned int nId)
{
	/*
	if (mapSGD.find(nId) == mapSGD.end())
	{
		VecScriptGameData vec;
		mapSGD.insert(MapScriptGameDataPair(nId, vec));
	}
	
	return mapSGD[nId];
	*/
	MapScriptGameDataIt itMapSGD = mapSGD.begin();
	for (; itMapSGD != mapSGD.end(); itMapSGD++) 
	{
		STSCRIPTGAMEDATA& stSG = *itMapSGD;
		if (stSG.nId == nId)
		{
			return *itMapSGD;
		}
	}
	
	VecScriptGameData vData;
	mapSGD.push_back(STSCRIPTGAMEDATA(nId, vData));
	return mapSGD.back();
}

bool					
NDScriptGameData::GetScriptGameData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index, ScriptGameData& sgd)
{
	if ( (size_t)esd >= m_vMapGameScriptDataObject.size() )
		return false;
		
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapGSO = mapGSO.find(nKey);
	
	if ( itMapGSO == mapGSO.end() )
		return false;
	
	GameScriptDataSet& gsdt = itMapGSO->second;
	
	if ( e < eRoleDataBasic )
		return false;
	
	if (e == eRoleDataBasic)
	{
		VecScriptGameData& vSGD = gsdt.basicdata;
		/*
		if (index >= vSGD.size())
			return false;
		
		sgd = vSGD[index];
		*/
		if (vSGD.find(index) == vSGD.end())
		{
			return false;
		}
		sgd = vSGD[index];
	}
	else if ( e > eRoleDataBasic)
	{
		if ( (size_t)(e - 1) >= gsdt.extradata.size() )
			return false;
		
		MapScriptGameData& mapSGD = gsdt.extradata[e - 1];
		/*
		MapScriptGameDataIt itMapSGD = mapSGD.find(nId);
		
		if (itMapSGD == mapSGD.end())
			return false;
		
		VecScriptGameData& vSGD = itMapSGD->second;
		
		if (index >= vSGD.size())
			return false;
		
		sgd = vSGD[index];
		*/
		bool find = false;
		MapScriptGameDataIt itMapSGD = mapSGD.begin();
		for (; itMapSGD != mapSGD.end(); itMapSGD++) 
		{
			STSCRIPTGAMEDATA& stSG = *itMapSGD;
			if (stSG.nId == (unsigned int)nId)
			{
				VecScriptGameData& vSGD = stSG.vData;
				
				/*
				if (index >= vSGD.size())
					return false;
				
				sgd = vSGD[index];
				*/
				if (vSGD.find(index) == vSGD.end())
				{
					return false;
				}
				sgd = vSGD[index];
				
				find = true;
			}
		}
		
		if (!find)
		{
			return false;
		}
	}
	
	return true;
}

ScriptGameData& 
NDScriptGameData::GetScriptGameData(eScriptData esd, unsigned int nKey, eRoleData e, int nId, unsigned short index)
{
	if (esd < eScriptDataBegin || e < eRoleDataBasic)
	{
		NDAsssert(0);
	}
	
	VecScriptGameData& vSGD = GetVecScriptGameData(esd, nKey, e, nId);
	
	return GetScriptGameDataByVec(vSGD, index);	
}

VecScriptGameData& 
NDScriptGameData::GetVecScriptGameData(eScriptData esd, unsigned int nKey, eRoleData e, int nId)
{
	if (esd < eScriptDataBegin || e < eRoleDataBasic)
	{
		NDAsssert(0);
	}
	
	if ( (size_t)esd == m_vMapGameScriptDataObject.size())
	{
		m_vMapGameScriptDataObject.push_back(MapGameScriptObject());
	}
	else if ( (size_t)esd > m_vMapGameScriptDataObject.size() )
	{
		m_vMapGameScriptDataObject.resize(esd+1);
	}
	
	MapGameScriptObject& mapGSO = m_vMapGameScriptDataObject[esd];
	
	MapGameScriptObjectIt itMapSGO = mapGSO.find(nKey);
	
	if (itMapSGO == mapGSO.end())
	{
		GameScriptDataSet newGSDS;
		mapGSO.insert(MapGameScriptObjectPair(nKey, newGSDS));
	}
	
	GameScriptDataSet& gsds = mapGSO[nKey];
	
	if ( e == eRoleDataBasic )
		return gsds.basicdata;
	
	VecMapScriptGameData& vMSGD = gsds.extradata;
	
	size_t eIndex = e - 1;	
	
	if ( eIndex == vMSGD.size() )
	{
		vMSGD.push_back(MapScriptGameData());
	}
	else if ( eIndex > vMSGD.size() )
	{
		vMSGD.resize(eIndex + 1);
	}
	
	MapScriptGameData& mapSGD = vMSGD[eIndex];
	
	return GetVecScriptGameDataByMap(mapSGD, nId).vData;
}

int						
NDScriptGameData::GetScriptDataInt(ScriptGameData& sgd)
{
	if (sgd.typeOfData == GDT_None		||
		sgd.typeOfData == GDT_Float		||
		sgd.typeOfData == GDT_Double	||
		sgd.typeOfData == GDT_String	||
		sgd.typeOfData == GDT_Int64		||
		sgd.typeOfData == GDT_UInt64 )
		return 0;
	
	return sgd.valueOfNumber.iVal;
}

double					
NDScriptGameData::GetScriptDataFloat(ScriptGameData& sgd)
{
	if (sgd.typeOfData == GDT_Float)
		return sgd.valueOfNumber.fVal;
	else if (sgd.typeOfData == GDT_Double)
		return sgd.valueOfNumber.dVal;
	
	return 0.0f;
}

long long				
NDScriptGameData::GetScriptDataBigInt(ScriptGameData& sgd)
{
	if (sgd.typeOfData == GDT_Int64		||
		sgd.typeOfData == GDT_UInt64 )
		return sgd.valueOfNumber.bigVal;	
	
	return 0;
}

std::string				
NDScriptGameData::GetScriptDataStr(ScriptGameData& sgd)
{
	if (sgd.typeOfData != GDT_String)
		return "";
	
	return sgd.valueOfStr;
}

/////////////////////////////////////////////////////////////////////////////

/*
 // test
 
 char				cVal	= 127;
 unsigned char		ucVal	= 255;
 short				sVal	= 32767;
 unsigned short		usVal	= 65535;
 int					iVal	= 2147483647;
 unsigned int		uiVal	= 4294967295;
 float				fVal	= 1.1;
 double				dVal	= 2.2;
 long long			bigVal	= 9223372036854775807LL;
 unsigned long long	ubigVal = 18446744073709551615LLU;
 std::string			strVal	= "无所谓abc";
 
 int nRoleId = 123456;
 int dataIndex = 0;
 // 设置角色基本数据
 SRDBasic(nRoleId, dataIndex, ucVal);	dataIndex++;
 SRDBasic(nRoleId, dataIndex, fVal);		dataIndex++;
 SRDBasic(nRoleId, dataIndex, bigVal);	dataIndex++;
 SRDBasic(nRoleId, dataIndex, strVal);	dataIndex++;
 
 // 设置角色技能数据
 int nSkillId = 123;
 SRDSkill(nRoleId, nSkillId, dataIndex, ucVal-1); dataIndex++;
 SRDSkill(nRoleId, nSkillId, dataIndex, fVal-1); dataIndex++;
 SRDSkill(nRoleId, nSkillId, dataIndex, bigVal-1); dataIndex++;
 SRDSkill(nRoleId, nSkillId, dataIndex, "设置角色技能数据"); dataIndex++;
 
 // 设置角色状态数据
 int nStateId = 123;
 SRDState(nRoleId, nStateId, dataIndex, ucVal-2); dataIndex++;
 SRDState(nRoleId, nStateId, dataIndex, fVal-2); dataIndex++;
 SRDState(nRoleId, nStateId, dataIndex, bigVal-2); dataIndex++;
 SRDState(nRoleId, nStateId, dataIndex, "设置角色状态数据"); dataIndex++;
 
 // 设置角色物品数据
 nRoleId++;
 int nItemId = 234;
 SRDItem(nRoleId, nItemId, dataIndex, ucVal-3); dataIndex++;
 SRDItem(nRoleId, nItemId, dataIndex, fVal-3); dataIndex++;
 SRDItem(nRoleId, nItemId, dataIndex, bigVal-3); dataIndex++;
 SRDItem(nRoleId, nItemId, dataIndex, "设置角色物品数据"); dataIndex++;
 
 // 设置角色宠物数据
 int nPetId = 234;
 SRDPet(nRoleId, nPetId, dataIndex, ucVal-4); dataIndex++;
 SRDPet(nRoleId, nPetId, dataIndex, fVal-4); dataIndex++;
 SRDPet(nRoleId, nPetId, dataIndex, bigVal-4); dataIndex++;
 SRDPet(nRoleId, nPetId, dataIndex, "设置角色宠物数据"); dataIndex++;
 
 // 设置角色任务数据
 int nTaskId = 345;
 SRDTask(nRoleId, nTaskId, dataIndex, ucVal-5); dataIndex++;
 SRDTask(nRoleId, nTaskId, dataIndex, fVal-5); dataIndex++;
 SRDTask(nRoleId, nTaskId, dataIndex, bigVal-5); dataIndex++;
 SRDTask(nRoleId, nTaskId, dataIndex, "设置角色任务数据"); dataIndex++;
 
 DRD(nRoleId);
 
 do{
 
 int nRoleId = 123456;
 int dataIndex = 0;
 // 获取角色基本数据
 do {
 unsigned char		ucVal		= GRDBasicN(nRoleId, dataIndex); dataIndex++;
 float				fVal		= GRDBasicF(nRoleId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GRDBasicN(nRoleId, dataIndex); dataIndex++;
 std::string			strVal		= GRDBasicS(nRoleId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 // 获取角色技能数据
 do {
 int nSkillId = 123;
 unsigned char		ucVal		= GRDSkillN(nRoleId, nSkillId, dataIndex); dataIndex++;
 float				fVal		= GRDSkillF(nRoleId, nSkillId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GRDSkillN(nRoleId, nSkillId, dataIndex); dataIndex++;
 std::string			strVal		= GRDSkillS(nRoleId, nSkillId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 
 
 // 获取角色状态数据
 do {
 int nStateId = 123;
 unsigned char		ucVal		= GRDStateN(nRoleId, nStateId, dataIndex); dataIndex++;
 float				fVal		= GRDStateF(nRoleId, nStateId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GRDStateN(nRoleId, nStateId, dataIndex); dataIndex++;
 std::string			strVal		= GRDStateS(nRoleId, nStateId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 // 获取角色物品数据
 do {
 nRoleId++;
 int nItemId = 234;
 unsigned char		ucVal		= GRDItemN(nRoleId, nItemId, dataIndex); dataIndex++;
 float				fVal		= GRDItemF(nRoleId, nItemId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GRDItemN(nRoleId, nItemId, dataIndex); dataIndex++;
 std::string			strVal		= GRDItemS(nRoleId, nItemId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 // 获取角色宠物数据
 do {
 int nPetId = 234;
 unsigned char		ucVal		= GRDPetN(nRoleId, nPetId, dataIndex); dataIndex++;
 float				fVal		= GRDPetF(nRoleId, nPetId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GRDPetN(nRoleId, nPetId, dataIndex); dataIndex++;
 std::string			strVal		= GRDPetS(nRoleId, nPetId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 // 获取角色任务数据
 do {
 int nTaskId = 345;
 unsigned char		ucVal		= GRDTaskN(nRoleId, nTaskId, dataIndex); dataIndex++;
 float				fVal		= GRDTaskF(nRoleId, nTaskId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GRDTaskN(nRoleId, nTaskId, dataIndex); dataIndex++;
 std::string			strVal		= GRDTaskS(nRoleId, nTaskId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 }while(0);
 
 do {
 
 // 设置NPC基本数据
 int nNpcId = 123456;
 int dataIndex = 0;
 SNPCDBasic(nNpcId, dataIndex, ucVal-6);	dataIndex++;
 SNPCDBasic(nNpcId, dataIndex, fVal-6);		dataIndex++;
 SNPCDBasic(nNpcId, dataIndex, bigVal-6);	dataIndex++;
 SNPCDBasic(nNpcId, dataIndex, "设置NPC基本数据");	dataIndex++;
 
 nNpcId++;
 SNPCDBasic(nNpcId, dataIndex, ucVal-7);	dataIndex++;
 SNPCDBasic(nNpcId, dataIndex, fVal-7);		dataIndex++;
 SNPCDBasic(nNpcId, dataIndex, bigVal-7);	dataIndex++;
 SNPCDBasic(nNpcId, dataIndex, "设置NPC基本数据2");	dataIndex++;
 
 DNPCD(123456);
 
 do {
 int nNpcId = 123456;
 int dataIndex = 0;
 
 do {
 unsigned char		ucVal		= GNPCDBasicN(nNpcId, dataIndex); dataIndex++;
 float				fVal		= GNPCDBasicF(nNpcId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GNPCDBasicN(nNpcId, dataIndex); dataIndex++;
 std::string			strVal		= GNPCDBasicS(nNpcId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 nNpcId++;
 
 do {
 unsigned char		ucVal		= GNPCDBasicN(nNpcId, dataIndex); dataIndex++;
 float				fVal		= GNPCDBasicF(nNpcId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GNPCDBasicN(nNpcId, dataIndex); dataIndex++;
 std::string			strVal		= GNPCDBasicS(nNpcId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 }while(0);
 
 ////////////////////////
 do {
 
 int nMonsterId = 123456;
 int dataIndex = 0;
 SMonsterDBasic(nMonsterId, dataIndex, ucVal-8);	dataIndex++;
 SMonsterDBasic(nMonsterId, dataIndex, fVal-8);		dataIndex++;
 SMonsterDBasic(nMonsterId, dataIndex, bigVal-8);	dataIndex++;
 SMonsterDBasic(nMonsterId, dataIndex, "设置怪物基本数据");	dataIndex++;
 
 nMonsterId++;
 SMonsterDBasic(nMonsterId, dataIndex, ucVal-9);	dataIndex++;
 SMonsterDBasic(nMonsterId, dataIndex, fVal-9);		dataIndex++;
 SMonsterDBasic(nMonsterId, dataIndex, bigVal-9);	dataIndex++;
 SMonsterDBasic(nMonsterId, dataIndex, "设置怪物基本数据2");	dataIndex++;
 
 DMonsterD(123456);
 
 do {
 int nMonsterId = 123456;
 int dataIndex = 0;
 
 do {
 unsigned char		ucVal		= GMonsterDBasicN(nMonsterId, dataIndex); dataIndex++;
 float				fVal		= GMonsterDBasicF(nMonsterId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GMonsterDBasicN(nMonsterId, dataIndex); dataIndex++;
 std::string			strVal		= GMonsterDBasicS(nMonsterId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 nMonsterId++;
 
 do {
 unsigned char		ucVal		= GMonsterDBasicN(nMonsterId, dataIndex); dataIndex++;
 float				fVal		= GMonsterDBasicF(nMonsterId, dataIndex); dataIndex++;
 unsigned long long	bigVal		= GMonsterDBasicN(nMonsterId, dataIndex); dataIndex++;
 std::string			strVal		= GMonsterDBasicS(nMonsterId, dataIndex); dataIndex++;
 NDLog("%@", [NSString stringWithUTF8String:strVal.c_str()]);
 }while(0);
 
 }while(0);
 
 }while(0);
 
 }while(0);


*/