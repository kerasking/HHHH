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
#include "CCPlatformConfig.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "NDUtility.h"
#endif

const char* NDLocalXmlString::GetCString(const char* szKeyName)
{
	if (!szKeyName)
	{
		return "error";
	}
	
	ITER_MAP_DATA it = mapData.find(string(szKeyName));
	
	if (it == mapData.end())
		return szKeyName;
		
	return (it->second).c_str();
}

bool NDLocalXmlString::LoadData()
{
	vector<string> vecLines;
	if (this->readLines( vecLines ))
	{
		this->parseLines( vecLines );
		//this->dump();
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////
bool NDLocalXmlString::readLines( vector<string>& vecLines )
{
	string strFile = NDEngine::NDPath::GetResPath("lyol.strings");

	// open file
	FILE *fp = fopen(strFile.c_str(), "r");
	if (!fp) return false;
	
	// file len
	fseek( fp, 0L, SEEK_END );
	int fileLen = ftell(fp);
	fseek( fp, 0L, SEEK_SET );

	// alloc buf, and read file
	char* buf = new char[fileLen + 1];
	fread( buf, 1, fileLen, fp );
	buf[fileLen] = 0;
	fclose(fp);

	// split buf into lines
	char line[1024] = "";
	char* pBuf = buf;
	while (1)
	{
		// find line feed
		char* pLineFeed = strchr( pBuf, '\r' );
		if (!pLineFeed)
			break;

		// copy line
		int lineLen = pLineFeed - pBuf;
		memcpy( line, pBuf, lineLen );
		line[ lineLen ] = 0;

		// move to next
		pBuf = pLineFeed + 1;
		while (*pBuf == '\r' || *pBuf == '\n') pBuf++;

		// save line
		if (this->isKey(line) || this->isVal(line))
			vecLines.push_back( line );	
	}

	SAFE_DELETE_ARRAY(buf);
	return true;
}

bool NDLocalXmlString::parseLines( vector<string>& vecLines )
{
	if (vecLines.size() < 2) return false;
	mapData.clear();

	bool ok = true;
	int index = 0;
	while (index < vecLines.size() - 2)
	{
		const string& keyLine = vecLines[ index ];
		const string& valLine = vecLines[ index + 1 ];

		if (isKey(keyLine.c_str()) && isVal(valLine.c_str()))
		{
			index += 2;

			ok &= addKeyValue( keyLine, valLine );
		}
		else
		{
			index++;

			//bad line!
			logErr( keyLine, valLine );
			ok = false;
		}
	}

	return ok;
}

void NDLocalXmlString::logErr( const string& keyLine, const string& valLine )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	WriteCon( "@@ NDLocalXmlString::parseLines(), bad lines: \r\n");
	WriteCon( "  errline: %s\r\n", keyLine.c_str());
	WriteCon( "  errline: %s\r\n", valLine.c_str());
#endif
}

bool NDLocalXmlString::addKeyValue( const string& keyLine, const string& valLine )
{
	string strKey, strValue;
	if (getMidString( keyLine, "<key>", "</key>", strKey )
		&& getMidString( valLine, "<string>", "</string>", strValue ))
	{
		mapData[ strKey ] = strValue;
		return true;
	}
	else
	{
		logErr( keyLine, valLine );
	}
	return false;
}

bool NDLocalXmlString::getMidString( const string& line, const string& left, const string& right, string& out_mid )
{
	if (line.length() > 0 && left.length() > 0 && right.length() > 0)
	{
		const char* p1 = strstr( line.c_str(), left.c_str() );
		if (!p1) return false;
		p1 += left.length();

		const char* p2 = strstr( p1, right.c_str() );
		if (!p2) return false;

		static char buf[1024] = "";
		int len = p2 - p1;
		memcpy( buf, p1, len );
		buf[len] = 0;
		
		out_mid = buf;
		return true;
	}
	return false;
}

bool NDLocalXmlString::isKey( const char* testLine )
{
	int len = 5; //"<key>"
	if (testLine && strlen(testLine) > len)
	{
		const char* p = testLine;
		if (memcmp(p, "<key>", len) == 0)
		{
			p += len;
			return strstr(p, "</key>") != 0;
		}
	}
	return false;
}

bool NDLocalXmlString::isVal( const char* testLine )
{
	int len = 8; //"<string>"
	if (testLine && strlen(testLine) > len)
	{
		const char* p = testLine;
		if (memcmp(p, "<string>", len) == 0)
		{
			p += len; //<string>
			return strstr( p, "</string>" ) != 0;
		}
	}
	return false;
}

void NDLocalXmlString::dump()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	WriteCon( "-------------- NDLocalXmlString -------------- \r\n" );
	WriteCon( "@@ has %d key/val\r\n", mapData.size());
	for (ITER_MAP_DATA iter = mapData.begin(); iter != mapData.end(); ++iter)
	{
		WriteCon( "[%s]=%s\r\n", iter->first.c_str(), iter->second.c_str() );
	}
	WriteCon( "\r\n" );
#endif
}