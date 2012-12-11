/*
 *  ScriptDataBase.mm
 *  SMYS
 *
 *  Created by jhzheng on 12-2-17.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 *	说明：负责加载所有INI文件 @loader
 */

#include "ScriptDataBase.h"
#include "ScriptInc.h"
#include "ScriptGameData.h"
#include "ScriptGameData_NewUtil.h"
#include "NDUtility.h"
#include "NDPath.h"
#include <stdio.h>
#include <sstream>
#include "NDProfile.h"
#include "ScriptMgr.h"

NS_NDENGINE_BGN

//@loadini
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
		
		size_t len = (unsigned int)(ucHight << 8) + ucLow;
		if (len == 0)
		{
			return false;
		}
		
		static unsigned char tmp[4096] = {0};
		size_t read = fread(&tmp, 1, len, f);
		if (read != len)
		{
			return false;
		}
		tmp[len] = 0;
		
		strData = (char*)&tmp;
		return true;
	}

	//@db
	//	return static read only pointer.
	//	only for tmp use.
	//	DON'T save this pointer!
	const char* ReadUtf8_Fast(FILE* f)
	{
		if (!f) return false;

		FileOp op;
		unsigned char ucHight	= 0;
		unsigned char ucLow		= 0;

		if (!op.ReadUChar(f, ucHight) || !op.ReadUChar(f, ucLow))
		{
			return NULL;
		}

		size_t len = (unsigned int)(ucHight << 8) + ucLow;
		if (len == 0)
		{
			return NULL;
		}

		static unsigned char tmp[4096] = {0};
		size_t read = fread(&tmp, 1, len, f);
		if (read != len)
		{
			return NULL;
		}

		tmp[len] = 0;
		return (const char*) tmp;
	}
};//class FileOp


/////////////////////////////////////////////////////////////////////////
// 用来读取一张配置表
struct NDTableLoader
{
	//读字段信息
	NDTableLoader& ReadFieldsInfo(FILE* f)
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

#if WITH_NEW_DB
	//读一行记录
	bool ReadRecord_New( FILE* f, NDRecord* pRecord )
	{
		if (!f || !pRecord) return false;

		FileOp op;
		size_t fieldCount = m_vType.size();
		for (size_t fieldIndex = 0; fieldIndex < fieldCount; fieldIndex ++) 
		{
			NDField* pField = pRecord->getAt( fieldIndex );
			NDAsssert(pField);

			switch (m_vType[fieldIndex]) 
			{
			case 0: //字符串
				{
					pField->setString( op.ReadUtf8_Fast(f));
				}
				break;
			case 1: //UCHAR
				{
 					unsigned char ucData = 0;
 					op.ReadUChar(f, ucData);
					pField->setUChar( ucData );
				}
				break;
			case 2: //USHORT
				{
					unsigned short usData = 0;
					op.ReadUShort(f, usData);
					pField->setUShort( usData );
				}
				break;
			case 4: //UINT
				{
					unsigned int unData = 0;
					op.ReadUInt(f, unData);
					pField->setUInt( unData );
				}
				break;
			case 8: //I64
				{
					unsigned long long bigData = 0;
					op.ReadU64(f, bigData);
					pField->setUBigInt( bigData );
				}
				break;
			default:
				NDAsssert(0); //居然不支持int!?
			}//switch
		}//for

		return true;
	}

#else

	//读一行记录
	bool ReadRecord(FILE* f, unsigned int nKey, unsigned int nId)
	{
		if (!f) return false;

		FileOp op;
		size_t size = m_vType.size();
		for (size_t i = 0; i < size; i ++) 
		{
			switch (m_vType[i]) 
			{
			case 0: //字符串
				{
					std::string strData;
					op.ReadUtf8(f, strData);
					ScriptGameDataObj.SetData(eScriptDataDataBase, nKey, eRoleDataPet, nId, i, strData);//@db
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
			}//switch
		}//for

		return true;
	}
#endif //WITH_NEW_DB

public:
	int getFieldCount() { return m_vType.size(); }

private:
	std::vector<unsigned char> m_vType;
};//ScriptDBTable




/////////////////////////////////////////////////////////////////////////

//@loader
bool ScriptDB::LoadTable(const char* inifilename, const char* indexfilename)
{
	char t[200] = ""; 
	sprintf( t, "ScriptDB::LoadTable(%s,%s)", inifilename,indexfilename);
	TIME_SLICE(t);

	if (!inifilename || !indexfilename)
	{
		ScriptMgrObj.DebugOutPut("!inifilename || !indexfilename");
		return false;
	}
		
	std::string indexFilePath = 
		NDPath::GetResPath((std::string("DBData/") + indexfilename + ".ini").c_str());

	std::string tableFilePath = 
		NDPath::GetResPath((std::string("DBData/") + inifilename + ".ini").c_str());
	
	// open table file
	FILE *fpTable = fopen(tableFilePath.c_str(), "rb");
	if (!fpTable)
	{
		std::stringstream ss;
		ss << "load " << inifilename << "failed";
		ScriptMgrObj.DebugOutPut(ss.str().c_str());
		return false;
	}

	// open index file
	FILE *fpIndex = fopen(indexFilePath.c_str(), "rb");
	if (!fpIndex)
	{
		std::stringstream ss;
		ss << "load " << indexfilename << "failed";
		ScriptMgrObj.DebugOutPut(ss.str().c_str());
		fclose(fpTable);
		return false;
	}

	// read fields
	NDTableLoader loader;
	loader.ReadFieldsInfo(fpIndex);

	if (feof(fpIndex))
	{
		ScriptMgrObj.DebugOutPut("feof(fIndex)");
		fclose(fpIndex); fclose(fpTable);
		return false;
	}

	// gen key
	unsigned int nKey = GenerateKey();
	m_mapFileKey.insert(MAP_STR_INT_VT(std::string(inifilename), nKey));

	// read record count
	FileOp op;

	unsigned int unRecord = 0;
	if (!op.ReadUInt(fpIndex, unRecord))
	{
		ScriptMgrObj.DebugOutPut("!op.ReadUInt(fIndex, unRecord)");
		fclose(fpIndex); fclose(fpTable);
		return false;
	}

#if WITH_NEW_DB
	// 数据库中创建一张表
	NDTableSetIni* pTableSetIni = NDGameDataUtil::getTableSet_ini();
	NDTable* pTable = pTableSetIni->addNew( nKey, loader.getFieldCount() );
	pTable->setDbgName( inifilename );
#endif

	// 读取每一条记录
	for (unsigned int i = 0; i < unRecord; i++)
	{
		unsigned int idRecord = 0;
		unsigned int offset = 0;

		if (!op.ReadUInt(fpIndex, idRecord))
		{
			break;
		}

		if (!op.ReadUInt(fpIndex, offset))
		{
			break;
		}

		fseek(fpTable, offset, SEEK_SET);

#if WITH_NEW_DB
		//添加一条记录
		NDRecord* pRecord = pTable->addNew( idRecord );
		loader.ReadRecord_New( fpTable, pRecord );
#else
		loader.ReadRecord( fpTable, nKey, idRecord );
#endif
	}

	fclose(fpIndex); fclose(fpTable);
	return true;
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

unsigned int ScriptDB::GetKey(const char* inifilename)
{
	if (!inifilename)
	{
		return 0;
	}

	MAP_STR_INT_IT it = m_mapFileKey.find(inifilename);
	if (m_mapFileKey.end() != it)
	{
		return it->second;
	}

	return 0;
}

//for lua
bool LoadDataBaseTable(const char* inifilename, const char* indexfilename)
{
	return ScriptDBObj.LoadTable(inifilename, indexfilename);
}

//for lua
int GetIniFileKey(const char* inifilename)
{
	return ScriptDBObj.GetKey(inifilename);
}

//for lua
void ScriptDB::Load()
{
	ETCFUNC("LoadDataBaseTable", LoadDataBaseTable)
	ETCFUNC("GetIniFileKey", GetIniFileKey)
}

//仅用于读取ini
bool ScriptDB::GetIdList(const char* inifilename, ID_VEC& idlist)
{
	if (!inifilename) return false;

	int nKey = GetKey(inifilename);
	if (0 == nKey)
	{
		if (std::string(inifilename) == "mapzone")
		{
			ScriptMgrObj.DebugOutPut("mapzone GetIdList failed");
		}
		return false;
	}

#if WITH_NEW_DB
	return NDGameDataUtil::getDataIdList( MAKE_NDTABLEPTR_INI(nKey), idlist );
#else
	return ScriptGameDataObj.GetDataIdList(eScriptDataDataBase, nKey, eRoleDataPet, idlist);       
#endif
}

//仅用于读取ini
int ScriptDB::GetN(const char* inifilename, int nId, int nIndex)
{
	int nKey = GetKey(inifilename);
	if (0 == nKey)
	{
		return 0;
	}

#if WITH_NEW_DB
	return NDGameDataUtil::getDataULL( MAKE_NDTABLEPTR_INI(nKey), NDCellPtr(nId, nIndex ));
#else
	return ScriptGameDataObj.GetData<unsigned long long>(eScriptDataDataBase, nKey, eRoleDataPet, nId, nIndex);
#endif
}

//仅用于读取ini
std::string ScriptDB::GetS(const char* inifilename, int nId, int nIndex)
{
	int nKey = GetKey(inifilename);
	if (0 == nKey)
	{
		return "";
	}

#if WITH_NEW_DB
	return NDGameDataUtil::getDataS( MAKE_NDTABLEPTR_INI(nKey), NDCellPtr(nId, nIndex ));
#else
	return ScriptGameDataObj.GetData<std::string>(eScriptDataDataBase, nKey, eRoleDataPet, nId, nIndex);
#endif
}

NS_NDENGINE_END