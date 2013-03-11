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
#include "NDUtil.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

const string NDLocalXmlString::GetCString(string szKeyName)
{
	if (szKeyName.empty())
	{
		return "error";
	}
	
	ITER_MAP_DATA it = mapData.find(szKeyName);
	
	if (it == mapData.end())
		return szKeyName;
		
	return it->second;
}

bool NDLocalXmlString::LoadData()
{
	string strFile = NDEngine::NDPath::GetResPath("lyol.strings");
	vector<string> vecLines;
	if ( this->readLines( strFile, vecLines ) )
	{
		this->parseLines( vecLines );
		//this->dump();
		return true;
	}
	return false;
}

//========================================================================
bool NDLocalXmlString::LoadLoginString()
{
	string strFile = NDEngine::NDPath::GetResPath("Login.strings");
	vector<string> vecLines;
	if (readLines( strFile, vecLines ) )
	{
		parseLines( vecLines );
		return true;
	}
	return false;
}

///////////////////////////////////////////////////////////////////////////
bool NDLocalXmlString::readLines( string & strFile, vector<string>& vecLines )
{
	// open file
	FILE *fp = fopen(strFile.c_str(), "r");

	if (!fp)
	{
		return false;
	}
	
	// file len
	fseek( fp, 0L, SEEK_END );
	int fileLen = ftell(fp);
	fseek( fp, 0L, SEEK_SET );

	// alloc buf, and read file
	char* buf = new char[fileLen + 1];
	int n = fread( buf, 1, fileLen, fp );
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

		// save line
		if (this->isKey(line) || this->isVal(line))
		{
			vecLines.push_back( line );	
		}
// 		else
// 		{
// 			WriteCon( "@@ read bad line:%s\r\n", line );
// 		}

// 		// trace line
// 		static int index = 0;
// 		CCLog( "xml line %d: %s\r\n", index++, line );

		// move to next: trim line feed & spaces.
		pBuf = pLineFeed + 1;
		while (*pBuf == '\r' || *pBuf == '\n' 
			|| *pBuf == 0x20 || *pBuf == '\t') pBuf++;
	}

	SAFE_DELETE_ARRAY(buf);
	return true;
}

bool NDLocalXmlString::parseLines( vector<string>& vecLines )
{
	if (vecLines.size() < 2) return false;
	mapData.clear();

	bool bOK = true;
	int index = 0;
	while (index < vecLines.size() - 1)
	{
		const string& keyLine = vecLines[ index ];
		const string& valLine = vecLines[ index + 1 ];

		if (isKey(keyLine.c_str()) && isVal(valLine.c_str()))
		{
			index += 2;

			bOK &= addKeyValue( keyLine, valLine );
		}
		else
		{
			index++;

			//bad line!
			logErr( keyLine, valLine );
			bOK = false;
		}
	}

	return bOK;
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