/*
 *  ScriptDataBase.h
 *  SMYS
 *
 *  Created by jhzheng on 12-2-17.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 *	说明：负责加载所有INI文件  
 */

#ifndef _SCRIPT_DATA_BASE_H_
#define _SCRIPT_DATA_BASE_H_

#include "Singleton.h"
#include <map>
#include <string>
#include "typedef.h"

//@loadini
#define ScriptDBObj	NDEngine::ScriptDB::GetSingleton()

NS_NDENGINE_BGN
	

class ScriptDB: public TSingleton<ScriptDB>
{
public:
	//加载ini
	void Load();
	bool LoadTable(const char* inifilename, const char* indexfilename);

	//获取key和值等
	unsigned int GetKey(const char* inifilename);
	int GetN(const char* inifilename, int nId, int nIndex);
	std::string GetS(const char* inifilename, int nId, int nIndex);
	bool GetIdList(const char* inifilename, ID_VEC& idlist);

	//log
	void LogOut(const char* inifilename, int nId);

private:
	typedef std::map<std::string, unsigned int> MAP_STR_INT;
	typedef MAP_STR_INT::iterator MAP_STR_INT_IT;
	typedef MAP_STR_INT::value_type MAP_STR_INT_VT;

	unsigned int m_uiIdGenerator;
	MAP_STR_INT m_mapFileKey;

private:
	unsigned int GenerateKey();

private:
	ScriptDB() { m_uiIdGenerator = 0; }
	~ScriptDB();
	friend class TSingleton<ScriptDB>;
};

NS_NDENGINE_END

#endif // _SCRIPT_DATA_BASE_H_
