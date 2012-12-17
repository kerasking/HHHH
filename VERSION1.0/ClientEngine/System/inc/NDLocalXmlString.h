/*
 *  NDLocalXmlString.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-23.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 *	说明：加载lyol.strings.
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

	const string GetCString(const string szKeyName);

	//装入仅 smloginscene.cpp 用到的文本，
	bool LoadLoginString();
	
private:
	bool readLines( string & strFile, vector<string>& vecLines );
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