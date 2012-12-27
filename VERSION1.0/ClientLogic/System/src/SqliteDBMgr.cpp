//
//  SqliteDBMgr.m
//  SMYS
//
//  Created by user on 12-5-15.
//  Copyright 2012骞� __MyCompanyName__. All rights reserved.
//

#include "SqliteDBMgr.h"
#include <string>
#include "NDPath.h"

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

using namespace std;
using namespace NDEngine;

/////////////////////////////////////////////////////////
CSqliteDBMgr& CSqliteDBMgr::shareInstance()
{
	static CSqliteDBMgr rMgr;
	return rMgr;
}

/////////////////////////////////////////////////////////
CSqliteDBMgr::CSqliteDBMgr() :
m_pkDatabase(NULL)
{

}
/////////////////////////////////////////////////////////
CSqliteDBMgr::~CSqliteDBMgr()
{
	m_setRowData.clear();
	if (m_pkDatabase)
	{
		sqlite3_close (m_pkDatabase);
	}
}
/////////////////////////////////////////////////////////
void CSqliteDBMgr::InitDataBase(const char* pszDBName)
{
	if (0 == pszDBName || !*pszDBName)
	{
		LOGERROR("0 == pszDBName || !*pszDBName");
		return;
	}

	bool bSucceeded = false;

	m_strDBName = pszDBName;
	m_strPath = GetDBPath(pszDBName);

	if (sqlite3_open(m_strPath.c_str(), &m_pkDatabase) != SQLITE_OK)
	{
		return;
	}

	if (SQLITE_OK != sqlite3_rekey(m_pkDatabase,"1234",4))
	{
		return;
	}
}

/////////////////////////////////////////////////////////
int CSqliteDBMgr::SelectData(const char* pszSelectSql, int nColNum)
{
	m_setRowData.clear();
	if (!m_pkDatabase)
	{
		return 0;
	}

	sqlite3_stmt* pkStatement = 0;
	if (sqlite3_prepare_v2(m_pkDatabase, pszSelectSql, -1, &pkStatement, NULL)
			!= SQLITE_OK)
	{
		return 0;
	}

	int nRowNum = 0;
	while (sqlite3_step(pkStatement) == SQLITE_ROW)
	{
		VEC_COL_DATA setColData;
		for (int nCol = 0; nCol < nColNum; nCol++)
		{
			std::string strData = (const char*) sqlite3_column_text(pkStatement,
					nCol);
			setColData.push_back(strData);
		}
		m_setRowData.push_back(setColData);
		nRowNum++;
	}
	sqlite3_finalize(pkStatement);
	return nRowNum;
}

/////////////////////////////////////////////////////////
bool CSqliteDBMgr::IsExistTable(const char* pszTableName)
{
	if (!m_pkDatabase)
	{
		return false;
	}

	std::string strSelectSql = "select * from ";
	strSelectSql += pszTableName;
	char* szErrMsg = NULL;
	if (sqlite3_exec(m_pkDatabase, strSelectSql.c_str(), 0, 0, &szErrMsg)
			!= SQLITE_OK)
	{
		return false;
	}
	/*
	 sqlite3_stmt *statement = nil;
	 if (sqlite3_prepare_v2(m_database, strSelectSql.c_str(), -1, &statement, NULL)!=SQLITE_OK) {
	 return false;
	 }
	 
	 if(sqlite3_step(statement) == SQLITE_ROW) {
	 return true;
	 }else{
	 return false;
	 }
	 sqlite3_finalize(statement);
	 */
	return true;
}

/////////////////////////////////////////////////////////
bool CSqliteDBMgr::ExcuteSql(const char* pszSql)
{
	if (!pszSql)
	{
		return false;
	}

	if (!m_pkDatabase)
	{
		return false;
	}

	char* szErrMsg = NULL;
	if (sqlite3_exec(m_pkDatabase, pszSql, 0, 0, &szErrMsg) != SQLITE_OK)
	{
		return false;
	}

	return true;
}

/////////////////////////////////////////////////////////
int CSqliteDBMgr::GetColDataN(int nIdx, int nFieldIdx)
{
	if (nIdx < m_setRowData.size())
	{
		VEC_COL_DATA& rSetCol = m_setRowData[nIdx];
		if (nFieldIdx < rSetCol.size())
		{
			return atoi(rSetCol[nFieldIdx].c_str());
		}
	}
	return 0;
}

/////////////////////////////////////////////////////////
const char* CSqliteDBMgr::GetColDataS(int nIdx, int nFieldIdx)
{
	if (nIdx < m_setRowData.size())
	{
		VEC_COL_DATA& rSetCol = m_setRowData[nIdx];
		if (nFieldIdx < rSetCol.size())
		{
			return rSetCol[nFieldIdx].c_str();
		}
	}
	return NULL;
}

//private:
/////////////////////////////////////////////////////////
void CSqliteDBMgr::ReleaseData(void)
{
	m_setRowData.clear();
}
/////////////////////////////////////////////////////////
std::string CSqliteDBMgr::GetDBPath(const char* pszDBName)
{
	string strPath = "";
	string strFullDBPath = "";

	if (0 == pszDBName || !*pszDBName)
	{
		return strPath;
	}

	strPath = NDPath::GetDBPath();
	strFullDBPath = strPath + pszDBName;

	return strFullDBPath;
}