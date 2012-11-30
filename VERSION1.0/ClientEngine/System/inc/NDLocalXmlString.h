/*
 *  NDLocalXmlString.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-23.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#pragma once

#include <map>
#include <string>
#include "CCString.h"
#include "define.h"
#include "CCString.h"

using namespace cocos2d;

class NDLocalXmlString
{
public:
	static NDLocalXmlString& GetSingleton();
	
	static void purge();
	
	~NDLocalXmlString();
	
	const char* GetCString(const char* szKeyName);
	//++Guosen 2012.8.10//改为在程序运行后加载数据，避免静态加载
	bool LoadData();
private:
	NDLocalXmlString();
	
	void Init();
	
	bool GetValue(const std::string str, bool& isKey, std::string& resValue);
	
private:
	typedef std::map<std::string, std::string>		map_data;
	typedef map_data::iterator						map_data_it;
	typedef std::pair<std::string, std::string>		pair_data_it;
	
	map_data m_data;
};