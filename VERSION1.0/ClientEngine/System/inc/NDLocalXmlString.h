/*
 *  NDLocalXmlString.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-23.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
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
	
	//NSString *GetString(NSString nsKeyName);
	const char* GetCString(const char* szKeyName);
private:
	NDLocalXmlString();
	
	void Init();
	
	//todo(zjh)
	string GetDocumensDirectory();
	
	bool GetValue(const std::string str, bool& isKey, std::string& resValue);
	
private:
	typedef std::map<std::string, std::string>		map_data;
	typedef map_data::iterator						map_data_it;
	typedef std::pair<std::string, std::string>		pair_data_it;
	
	map_data m_data;
};