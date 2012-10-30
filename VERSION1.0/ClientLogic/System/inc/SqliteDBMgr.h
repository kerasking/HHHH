//
//  SqliteDBMgr.h
//  SMYS
//
//  Created by user on 12-5-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//不支持多线程操作

#ifndef SMYS_SqliteDBMgr_h
#define SMYS_SqliteDBMgr_h
//#include <sqlite3.h>
#include <vector>
#include <string>


class CSqliteDBMgr
{
public:
    static CSqliteDBMgr& shareInstance();

public:
    CSqliteDBMgr();
    ~CSqliteDBMgr();
    
public:
    void InitDataBase(const char* pszDBName);
    int  SelectData(const char* pszSelectSql, int nColNum);
    bool ExcuteSql(const char* pszSql);
    int  GetColDataN(int nIdx, int nFieldIdx);
    const char* GetColDataS(int nIdx, int nFieldIdx);
    bool IsExistTable(const char* pszTableName);
    
private:
    void ReleaseData(void);
    std::string GetDBPath(const char* pszDBName);
    
private:
    typedef std::vector<std::string> VEC_COL_DATA;
    typedef std::vector<VEC_COL_DATA> VEC_ROW_DATA;
    VEC_ROW_DATA    m_setRowData;
    std::string m_strPath;
    std::string m_strDBName;
    //sqlite3 *m_database;
};


#endif
