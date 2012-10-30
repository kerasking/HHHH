/*
 *  SystemSetMgr.h
 *  DragonDrive
 *
 *  Created by cl on 12-4-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __SYSTEMSET_MGR_H__
#define __SYSTEMSET_MGR_H__

#include "Singleton.h"
#include "define.h"
#include "EnumDef.h"
#include <string>

//using namespace NDEngine;

#define SystemSetMgrObj SystemSetMgr::GetSingleton()



class SystemSetMgr : public TSingleton<SystemSetMgr>
{
public:
	SystemSetMgr();
	~SystemSetMgr();
	
	bool initSystemSetTable();
	bool Set(const char *key,int value);
	bool Set(const char *key,bool value);
	bool Set(const char *key,const char *value);
	int GetNumber(const char *key,int default_value=0);
	bool GetBoolean(const char *key,bool default_value=false);
	const char *GetString(const char *key,const char *default_value=NULL);
};

#endif