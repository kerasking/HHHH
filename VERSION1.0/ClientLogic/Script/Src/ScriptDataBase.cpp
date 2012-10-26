/*
 *  ScriptDataBase.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-17.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "ScriptDataBase.h"
#include "ScriptInc.h"
#include "ScriptGameData.h"
#include "NDUtility.h"
#include "NDPath.h"
#include <stdio.h>
#include <sstream>

namespace NDEngine {
	
	/////////////////////////////////////////////////////////////////////////
	struct FileOp
	{
		bool ReadUChar(FILE* f, unsigned char& ucData)
		{
		
			if (!f) return false;
			size_t size = sizeof(unsigned char);
			ucData = 0;
			size_t read = fread(&ucData, 1, size, f);
			if (size != read)
			{
				return false;
			}
			return true;
		}
		bool ReadUShort(FILE* f, unsigned short& usData)
		{
			if (!f) return false;
			size_t size = sizeof(unsigned short);
			usData = 0;
			unsigned char shortBuf[2] = {0x00};
			size_t read = fread(&shortBuf, 1, size, f);
			if (size != read)
			{
				return false;
			}
			usData = ((unsigned short)shortBuf[0] << 8) + shortBuf[1];
			return true;
		}
		bool ReadUInt(FILE* f, unsigned int& unData)
		{
			if (!f) return false;
			size_t size = sizeof(unsigned int);
			unData = 0;
			unsigned char intBuf[4] = {0x00};
			size_t read = fread(&intBuf, 1, size, f);
			if (size != read)
			{
				return false;
			}
			unData = ((unsigned int)intBuf[0] << 24) +
					 ((unsigned int)intBuf[1] << 16) +
					 ((unsigned int)intBuf[2] << 8) +
					 ((unsigned int)intBuf[3]);
			return true;
		}
		bool ReadU64(FILE* f, unsigned long long& bigData)
		{
			if (!f) return false;
			size_t size = sizeof(unsigned long long);
			bigData = 0;
			unsigned char bigBuf[8] = {0x00};
			size_t read = fread(&bigBuf, 1, size, f);
			if (size != read)
			{
				return false;
			}
			bigData =	((unsigned long long)bigBuf[0] << 56) +
						((unsigned long long)bigBuf[1] << 48) +
						((unsigned long long)bigBuf[2] << 40) +
						((unsigned long long)bigBuf[3] << 32) +
						((unsigned long long)bigBuf[4] << 24) +
						((unsigned long long)bigBuf[5] << 16) +
						((unsigned long long)bigBuf[6] << 8) +
						((unsigned long long)bigBuf[7]);
			return true;
		}
		bool ReadUtf8(FILE* f, std::string& strData)
		{
			if (!f) return false;
			
			FileOp op;
			unsigned char ucHight	= 0;
			unsigned char ucLow		= 0;
			
			if (!op.ReadUChar(f, ucHight) || !op.ReadUChar(f, ucLow))
			{
				return false;
			}
			
			strData = "";
			
			size_t strlen = (unsigned int)(ucHight << 8) + ucLow;
			if (strlen == 0)
			{
				return false;
			}
			
			unsigned char tmp[4096] = {0};
			size_t read = fread(&tmp, 1, strlen, f);
			if (read != strlen)
			{
				return false;
			}
			
			strData = (char*)&tmp;
			return true;
		}
	};
	
	/////////////////////////////////////////////////////////////////////////
	struct ScriptDBTable
	{
		ScriptDBTable& ReadFieldsInfo(FILE* f)
		{
			if (!f) 
			{
				return *this;
			}
			
			m_vType.clear();
			
			FileOp op;
			unsigned char ucFields	= 0;
			if (!op.ReadUChar(f, ucFields))
			{
				return *this;
			}
			
			for (int i = 0; i < ucFields; i++) 
			{
				unsigned char ucType 	= 0;
				if (!op.ReadUChar(f, ucType))
				{
					return *this;
				}
				m_vType.push_back(ucType);
			}
			
			return *this;
		}
		
		ScriptDBTable& ReadFieldsData(FILE* f, unsigned int nKey, unsigned int nId)
	{
			if (!f)
			{
				return *this;
			}
			
			FileOp op;
			size_t size = m_vType.size();
			for (size_t i = 0; i < size; i ++) 
			{
				switch (m_vType[i]) {
					case 0: //×Ö·û´®
					{
						std::string strData = "";
						op.ReadUtf8(f, strData);
						ScriptGameDataObj.SetData(eScriptDataDataBase, nKey, eRoleDataPet, nId, i, strData);
					}
						break;
					case 1:
					{
						unsigned char ucData = 0;
						op.ReadUChar(f, ucData);
						ScriptGameDataObj.SetData(eScriptDataDataBase, nKey, eRoleDataPet, nId, i, ucData);
					}
						break;
					case 2:
					{
						unsigned short usData = 0;
						op.ReadUShort(f, usData);
						ScriptGameDataObj.SetData(eScriptDataDataBase, nKey, eRoleDataPet, nId, i, usData);
					}
						break;
					case 4:
					{
						unsigned int unData = 0;
						op.ReadUInt(f, unData);
						ScriptGameDataObj.SetData(eScriptDataDataBase, nKey, eRoleDataPet, nId, i, unData);
					}
						break;
					case 8:
					{
						unsigned long long bigData = 0;
						op.ReadU64(f, bigData);
						ScriptGameDataObj.SetData(eScriptDataDataBase, nKey, eRoleDataPet, nId, i, bigData);
					}
						break;
					default:
						break;
				}
			}
			
			return *this;
		}
		
	private:
		std::vector<unsigned char> m_vType;
	};	
	/////////////////////////////////////////////////////////////////////////

bool LoadDataBaseTable(const char* inifilename, const char* indexfilename)
{
	return ScriptDBObj.LoadTable(inifilename, indexfilename);
}

int GetIniFileKey(const char* inifilename)
{
	return ScriptDBObj.GetKey(inifilename);
}

void ScriptDB::Load()
{
	ETCFUNC("LoadDataBaseTable", LoadDataBaseTable)
	ETCFUNC("GetIniFileKey", GetIniFileKey)
}

bool ScriptDB::LoadTable(const char* inifilename, const char* indexfilename)
{
	if (!inifilename || !indexfilename)
	{
		ScriptMgrObj.DebugOutPut("!inifilename || !indexfilename");
		return false;
		}
		
		std::string indexFilePath		= 
			NDPath::GetResPath((std::string("DBData/") + indexfilename + ".ini").c_str());
		std::string tableFilePath		= 
			NDPath::GetResPath((std::string("DBData/") + inifilename + ".ini").c_str());
		
		FILE *fTable	= fopen(tableFilePath.c_str(), "rb");
		if (!fTable)
	{
		std::stringstream ss;
		ss << "load " << inifilename << "failed";
		ScriptMgrObj.DebugOutPut(ss.str().c_str());
		return false;
	}

	FILE *fIndex = fopen(indexFilePath.c_str(), "rb");
	if (!fIndex)
	{
		std::stringstream ss;
		ss << "load " << indexfilename << "failed";
		ScriptMgrObj.DebugOutPut(ss.str().c_str());
		return false;
	}

	ScriptDBTable table;
	table.ReadFieldsInfo(fIndex);

	if (feof(fIndex))
	{
		ScriptMgrObj.DebugOutPut("feof(fIndex)");
		fclose(fIndex);
		fclose(fTable);
		return false;
	}

	unsigned int nKey = GenerateKey();
	m_mapData.insert(MAP_STR_INT_VT(std::string(inifilename), nKey));

	FileOp op;

	unsigned int unRecord = 0;
	if (!op.ReadUInt(fIndex, unRecord))
	{
		ScriptMgrObj.DebugOutPut("!op.ReadUInt(fIndex, unRecord)");
		return false;
	}

	for (unsigned int i = 0; i < unRecord; i++)
	{
		unsigned int nID = 0;
		unsigned int nIndex = 0;

		if (!op.ReadUInt(fIndex, nID))
		{
			break;
		}

		if (!op.ReadUInt(fIndex, nIndex))
		{
			break;
		}

		fseek(fTable, nIndex, SEEK_SET);

		table.ReadFieldsData(fTable, nKey, nID);
	}

	fclose(fIndex);
	fclose(fTable);

	return true;
}

bool ScriptDB::GetIdList(const char* inifilename, ID_VEC& idlist)
{
	int nKey = GetKey(inifilename);
	if (0 == nKey)
	{
		if (std::string(inifilename) == "mapzone")
		{
			ScriptMgrObj.DebugOutPut("mapzone GetIdList failed");
		}
		return false;
		}
		
		return ScriptGameDataObj.GetDataIdList(eScriptDataDataBase, nKey, eRoleDataPet, idlist);
        
	}

unsigned int ScriptDB::GetKey(const char* inifilename)
{
	if (!inifilename)
	{
		return 0;
	}

	MAP_STR_INT_IT it = m_mapData.find(inifilename);
	if (m_mapData.end() != it)
	{
		return it->second;
	}

	return 0;
}

int ScriptDB::GetN(const char* inifilename, int nId, int nIndex)
{
	int nKey = GetKey(inifilename);
	if (0 == nKey)
	{
		return 0;
		}
		
		return ScriptGameDataObj.GetData<unsigned long long>(eScriptDataDataBase, nKey, eRoleDataPet, nId, nIndex);
	}
	
	std::string ScriptDB::GetS(const char* inifilename, int nId, int nIndex)
	{
		int nKey = GetKey(inifilename);
		if (0 == nKey)
		{
			return "";
		}
		
		return ScriptGameDataObj.GetData<std::string>(eScriptDataDataBase, nKey, eRoleDataPet, nId, nIndex);
	}
	
void ScriptDB::LogOut(const char* inifilename, int nId)
{
	int nKey = GetKey(inifilename);
	if (0 == nKey)
	{
		return;
	}

	ScriptGameDataObj.LogOut(eScriptDataDataBase, nKey, eRoleDataPet, nId);
}

unsigned int ScriptDB::GenerateKey()
{
	m_uiIdGenerator++;
	return m_uiIdGenerator;
}

ScriptDB::ScriptDB()
{
	m_uiIdGenerator = 0;
}

ScriptDB::~ScriptDB()
{
}

}