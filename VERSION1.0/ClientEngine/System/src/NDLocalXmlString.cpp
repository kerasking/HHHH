/*
 *  NDLocalXmlString.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-12-23.
 *  Copyright 2011 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "NDLocalXmlString.h"
#include "globaldef.h"
#include "NDPath.h"
#include "NDSharedPtr.h"
#include "CCFileUtils.h"

static NDLocalXmlString* s_NDLocalXmlString = NULL;

NDLocalXmlString& NDLocalXmlString::GetSingleton()
{
	if (s_NDLocalXmlString == NULL)
	{
		s_NDLocalXmlString = new NDLocalXmlString;
	}
	
	return *s_NDLocalXmlString;
}

void NDLocalXmlString::purge()
{
	NDAsssert(s_NDLocalXmlString != NULL);
	
	CC_SAFE_DELETE(s_NDLocalXmlString);
}


const char* NDLocalXmlString::GetCString(const char* szKeyName)
{
	if (!szKeyName)
	{
		return "error";
	}
	
	map_data_it it = m_data.find(std::string(szKeyName));
	
	if (it == m_data.end())
		return szKeyName;
		
	return (it->second).c_str();
}

NDLocalXmlString::NDLocalXmlString()
{
	NDAsssert(s_NDLocalXmlString == NULL);
	//CCAutoreleasePool* pPool = new CCAutoreleasePool();
	//Init();
	//pPool->release();
}

NDLocalXmlString::~NDLocalXmlString()
{
	s_NDLocalXmlString = NULL;
}

bool NDLocalXmlString::LoadData()
{
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Init();
	//[pool release];
	return true;
}

void NDLocalXmlString::Init()
{
	string str = NDEngine::NDPath::GetResPath("lyol.strings");
	const char* pszTemp = str.c_str();

	FILE *fp_in = fopen(pszTemp, "rb");
	if (!fp_in) return;
	
	string document = NDEngine::NDPath::GetDocumentPath();
	tq::CString tmpFileName("%sxmltmp.txt", document.c_str());

	FILE *p = fopen(tmpFileName, "a");
	if (!p) return;
	
	char tmp[1025]={0};
	size_t read = 0;
	while(!feof(fp_in) && (read = fread(tmp, 1, 1024, fp_in)))
	{
		for (size_t i = 0; i < read; i++) 
		{
			if (tmp[i] == '\r')
			{
				tmp[i] = '\n';
			}
		}
		fwrite(tmp, 1, read, p);
	}
	fflush(p);
	fclose(p);
	fclose(fp_in);
	
	fp_in = fopen(tmpFileName, "rb");
	
	if (!fp_in) return;
	
	std::string curkey;
	
	while ( !feof(fp_in) )
	{
		char buf[1025] = { 0x00 };
		
		fgets(buf, 1024, fp_in);
		
		std::string line(buf);
		
		bool isKey = false;
		
		std::string resValue;
		
		if (!GetValue(line, isKey, resValue))
			continue;
			
		if (isKey)
		{
			curkey = resValue;
			
			continue;
		}
		
		if (m_data.find(curkey) != m_data.end())
		{
			NDLog("\n repeat key: %s", curkey.c_str());
			continue;
		}
		
		m_data.insert(pair_data_it(curkey, resValue));
	}
	
	fclose(fp_in);
	
	NDLog("\n local string key size: %u", m_data.size());
}

bool NDLocalXmlString::GetValue(const std::string str, bool& isKey, std::string& resValue)
{	
	if (str.empty()) return false;
	
	std::string line = str;
	
	bool resIsKey = true;
	
	string::size_type first = line.find("<key>", 0);
	
	if (string::npos == first)
	{
		if ( string::npos == (first = line.find("<string>", 0)) )
		{
			return false;
		}
		
		resIsKey = false;
	}
	
	string::size_type second;
	
	if (resIsKey)
	{
		second = line.find("</key>", 0);
		
		first += strlen("<key>");
	}
	else
	{
		second = line.find("</string>", 0);
		
		first += strlen("<string>");
	}
	
	if (first >= second)
	{
		NDLog("\nerror first >= second");
		return false;
	}
	
	resValue = line.substr(first, second - first);
	
	isKey = resIsKey;
	
	return true;
}
