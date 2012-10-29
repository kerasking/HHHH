/*
 *  SystemSetMgr.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SystemSetMgr.h"
//#import "NDUISynLayer.h"
#include "SqliteDBMgr.h"
#include "globaldef.h"

//using namespace NDEngine;

SystemSetMgr::SystemSetMgr() {

}

SystemSetMgr::~SystemSetMgr() {

}

bool SystemSetMgr::initSystemSetTable()
{
	if(!CSqliteDBMgr::shareInstance().IsExistTable("system_set")){
        char *sql = "CREATE TABLE system_set(name text primary key,value1 integer,value2 text)";
        if(!CSqliteDBMgr::shareInstance().ExcuteSql(sql)){
            NDLog("创建系统设置表失败!");
            return false;
        }
	}
	return true;
}
bool SystemSetMgr::Set(const char *key,int value)
{
	if(initSystemSetTable())
	{
		char *sql = "REPLACE INTO system_set(name,value1,value2) VALUES";
		
		char str_value[256]="";
		
		std::string str="";

		sprintf(str_value,"(\'%s\',%d,\'%s\');",key,value,str.c_str());
		
		
		std::string strSql = sql;
		strSql+=str_value;
		
		if(!CSqliteDBMgr::shareInstance().ExcuteSql(strSql.c_str())){
			NDLog("系统设置失败!%s",key);
			return false;
		}
	}else {
		return false;
	}
	
	return true;

}


bool SystemSetMgr::Set(const char *key,bool value)
{
	if(initSystemSetTable())
	{
		char *sql = "REPLACE INTO system_set(name,value1,value2) VALUES";
		
		char str_value[256]="";
		int int_value=0;
		if (value){
			int_value=1;
		}
		std::string str="";

		sprintf(str_value,"(\'%s\',%d,\'%s\');",key,int_value,str.c_str());
		
		
		std::string strSql = sql;
		strSql+=str_value;
		
		if(!CSqliteDBMgr::shareInstance().ExcuteSql(strSql.c_str())){
			NDLog("系统设置失败!%s",key);
			return false;
		}
	}else {
		return false;
	}
	
	return true;
}
bool SystemSetMgr::Set(const char *key,const char *value)
{
	if(initSystemSetTable())
	{
		char *sql = "REPLACE INTO system_set(name,value1,value2) VALUES";
		
		char str_value[256]="";
		
		sprintf(str_value,"(\'%s\',%d,\'%s\');",key,0,value);
		
		
		std::string strSql = sql;
		strSql+=str_value;
		
		if(!CSqliteDBMgr::shareInstance().ExcuteSql(strSql.c_str())){
			NDLog("系统设置失败!%s",key);
			return false;
		}
	}else {
		return false;
	}
	
	return true;
}
int SystemSetMgr::GetNumber(const char *key,int default_value/*=0*/)
{
	if(initSystemSetTable())
	{
		const char* selSql = "SELECT value1 FROM system_set where name =\'";
		std::string strSql = selSql;
        strSql += key;
        strSql += "\';";
        int nRowNum = CSqliteDBMgr::shareInstance().SelectData(strSql.c_str(),1);
        if (nRowNum < 1){
			NDLog("系统设置获取失败!%s",key);
            return default_value;
        }
		
		return CSqliteDBMgr::shareInstance().GetColDataN(0, 0);
	}else {
		return default_value;
	}

}
bool SystemSetMgr::GetBoolean(const char *key,bool default_value/*=false*/)
{
	if(initSystemSetTable())
	{
		const char* selSql = "SELECT value1 FROM system_set where name =\'";
		std::string strSql = selSql;
        strSql += key;
        strSql += "\';";
        int nRowNum = CSqliteDBMgr::shareInstance().SelectData(strSql.c_str(),1);
        if (nRowNum < 1){
			NDLog("系统设置获取失败!%s",key);
            return default_value;
        }
		
		int n=CSqliteDBMgr::shareInstance().GetColDataN(0, 0);
		if (n<=0){
			return false;
		}else {
			return true;
		}

			
	}else {
		return default_value;
	}
}
const char *SystemSetMgr::GetString(const char *key,const char *default_value/*=NULL*/)
{
	if(initSystemSetTable())
	{
		const char* selSql = "SELECT value2 FROM system_set where name =\'";
		std::string strSql = selSql;
        strSql += key;
        strSql += "\';";
        int nRowNum = CSqliteDBMgr::shareInstance().SelectData(strSql.c_str(),1);
        if (nRowNum < 1){
			NDLog("系统设置获取失败!%s",key);
            return default_value;
        }

		return CSqliteDBMgr::shareInstance().GetColDataS(0, 0);
		
	}else {
		return default_value;
	}
}

