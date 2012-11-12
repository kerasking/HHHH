//
//  SqliteDBMgr.m
//  SMYS
//
//  Created by user on 12-5-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#include "SqliteDBMgr.h"
//#include <Foundation/Foundation.h>
//#include <CoreLocation/CoreLocation.h>

/////////////////////////////////////////////////////////
CSqliteDBMgr& 
CSqliteDBMgr::shareInstance()
{
    static CSqliteDBMgr rMgr;
    return rMgr;
}

/////////////////////////////////////////////////////////
CSqliteDBMgr::CSqliteDBMgr()
//:m_database(NULL)
{
    
}
/////////////////////////////////////////////////////////
CSqliteDBMgr::~CSqliteDBMgr()
{
#if 0
	//tangziqin暂时注释 
    m_setRowData.clear();
    if(m_database){
      sqlite3_close(m_database);  
    }
#endif
}
/////////////////////////////////////////////////////////
void 
CSqliteDBMgr::InitDataBase(const char* pszDBName)
{
#if 0
	//tangziqin暂时注释
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *nsPath = [NSString  stringWithUTF8String:pszDBName];
    m_strDBName = pszDBName;
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:nsPath];
    /*success = */[fileManager fileExistsAtPath:writableDBPath];
    m_strPath = this->GetDBPath(pszDBName);
    if (sqlite3_open(m_strPath.c_str(),&m_database) != SQLITE_OK) {
        return;
    }
#endif
}

/////////////////////////////////////////////////////////
int  
CSqliteDBMgr::SelectData(const char* pszSelectSql, int nColNum)
{
#if 0
	tangziqin暂时注释
    m_setRowData.clear();
    if (!m_database) {
        return 0;
    }
    //连接数据库    
    sqlite3_stmt *statement = nil;
    if (sqlite3_prepare_v2(m_database, pszSelectSql, -1, &statement, NULL)!=SQLITE_OK) {
        return 0;
    }
    
    int nRowNum = 0;
    while (sqlite3_step(statement) == SQLITE_ROW) {
        VEC_COL_DATA    setColData;
        for (int nCol=0; nCol < nColNum; nCol++) {
            std::string strData=(const char*)sqlite3_column_text(statement, nCol);
            setColData.push_back(strData);
        }
        m_setRowData.push_back(setColData);
        nRowNum++;
    }
    sqlite3_finalize(statement);
    return nRowNum;
#endif

	return 0;


}

/////////////////////////////////////////////////////////
bool 
CSqliteDBMgr::IsExistTable(const char* pszTableName)
{
    #if 0
	//tangziqin暂时注释
if (!m_database) {
        return false;
    }
    //连接数据库    
    
    std::string strSelectSql="select * from ";
    strSelectSql+=pszTableName;
    char* szErrMsg=NULL;
    if (sqlite3_exec(m_database, strSelectSql.c_str(), 0, 0, &szErrMsg)!=SQLITE_OK) {
        return false;
    }
#endif
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
bool 
CSqliteDBMgr::ExcuteSql(const char* pszSql)
{
    #if 0
	//tangziqin暂时注释
if (!pszSql) {
        return false;
    }

    if (!m_database) {
        return false;
    }
    
    //连接数据库    
    char* szErrMsg=NULL;
    if (sqlite3_exec(m_database, pszSql, 0, 0, &szErrMsg)!=SQLITE_OK) {
        return false;
    }
#endif
    
    return true;
}

/////////////////////////////////////////////////////////
int  
CSqliteDBMgr::GetColDataN(int nIdx, int nFieldIdx)
{
#if 0
	//tangziqin暂时注释

    if (nIdx < m_setRowData.size()) {
        VEC_COL_DATA& rSetCol = m_setRowData[nIdx];
        if (nFieldIdx < rSetCol.size()) {
            return atoi(rSetCol[nFieldIdx].c_str());
        }
    }
#endif
    return 0;
}

/////////////////////////////////////////////////////////
const char* 
CSqliteDBMgr::GetColDataS(int nIdx, int nFieldIdx)
{
    if (nIdx < m_setRowData.size()) {
        VEC_COL_DATA& rSetCol = m_setRowData[nIdx];
        if (nFieldIdx < rSetCol.size()) {
            return rSetCol[nFieldIdx].c_str();
        }
    }
    return NULL;
}

//private:
/////////////////////////////////////////////////////////
void 
CSqliteDBMgr::ReleaseData(void)
{
    m_setRowData.clear();
}
/////////////////////////////////////////////////////////
std::string 
CSqliteDBMgr::GetDBPath(const char* pszDBName)
{
   #if 0
	//tangziqin暂时注释
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *nsPath = [NSString  stringWithUTF8String:pszDBName];
    NSString *db_documentsDirectory=[documentsDirectory stringByAppendingPathComponent:nsPath];
    return [db_documentsDirectory UTF8String];
#endif

	return "";
}