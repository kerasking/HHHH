/*
 *  ScriptGameDataLua.h
 *  DragonDrive
 *
 *  Created by jhzheng on 12-1-6.
 *  Copyright 2012 (网龙)DeNA. All rights reserved.
 *
 *	说明：注册数据库LUA接口
 */
#pragma once
#include "ScriptInc.h"
#include <string>
using namespace std;


//lyol.strings都是utf8格式
std::string GetTxtPub_Common(const char* pszTableName);	//"Common_"前缀
std::string GetTxtPri(const char* pszTableName);
