#include "PacksInfo.h"
#include "CCSAXParser.h"
#include "UpdateUtilitys.h"
#include <map>
#include <string>


CPacksInfo::CPacksInfo()
{
}

CPacksInfo::~CPacksInfo()
{

}



bool CPacksInfo::LoadFromXmlFile( const char* szFileName )
{
	cocos2d::CCSAXParser parser;

	if (false == parser.init("UTF-8") )
	{
		return false;
	}

	parser.setDelegator(this);

	return parser.parse(szFileName);;	
}

void CPacksInfo::startElement( void *ctx, const char *name, const char **atts )
{
	std::string strName = name;
	std::map<std::string, std::string> mapAttribDict;

	if(atts && atts[0])
	{
		for(int i = 0; atts[i]; i += 2) 
		{
			std::string key = (char*)atts[i];
			std::string value = (char*)atts[i+1];
			mapAttribDict[key] =  value;
		}
	}

	if(strName=="update")
	{
		m_strLatestVersion = mapAttribDict["latest"];
	}
	else if(strName=="pack")
	{
		t_PackInfo tmp;
		tmp.strVersionSrc = mapAttribDict["src"];
		tmp.strVersionDst = mapAttribDict["dst"];
		tmp.strFileName = mapAttribDict["filename"];
		tmp.strUri = mapAttribDict["uri"];

		m_VecPackInfo.push_back(tmp);
	}
	else
	{
		//
	}

}

void CPacksInfo::endElement( void *ctx, const char *name )
{

}

void CPacksInfo::textHandler( void *ctx, const char *s, int len )
{

}
