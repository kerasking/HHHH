/*
 *  NDLocalXmlString.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-23.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 *	ËµÃ÷£º¼ÓÔØlyol.strings.
 */

#pragma once

#include <map>
#include <vector>
#include <string>
using namespace std;



class NDLocalXmlString
{
private:
	NDLocalXmlString() {}

public:
	static NDLocalXmlString& GetSingleton()
	{
		static NDLocalXmlString* s_NDLocalXmlString = NULL;
		if (!s_NDLocalXmlString)
		{
			s_NDLocalXmlString = new NDLocalXmlString;
		}
		return *s_NDLocalXmlString;
	}
	
	void destroy()
	{
		delete this;
	}
	
	~NDLocalXmlString() {}
	
public:
	bool LoadData();

	const char* GetCString(const char* szKeyName);
	
private:
	bool readLines( vector<string>& vecLines );
	bool parseLines( vector<string>& vecLines );
	
	bool addKeyValue( const string& keyLine, const string& valLine );
	bool getMidString( const string& line, const string& left, const string& right, string& out_mid );

	bool isKey( const char* testLine );
	bool isVal( const char* testLine );

	void logErr( const string& keyLine, const string& valLine );
	void dump();
	
private:
	typedef map<string, string>		MAP_DATA;
	typedef map<string, string>::iterator ITER_MAP_DATA;
	MAP_DATA mapData;
};