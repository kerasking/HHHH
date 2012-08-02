#include "XMLReader.h"
#include "..\..\TinyXML\inc\tinyxml.h"

XMLReader::XMLReader():
m_pkFileDataMap(0)
{
	m_pkFileDataMap = new FileData;
}

XMLReader::~XMLReader()
{
	m_pkFileDataMap->clear();
	delete m_pkFileDataMap;
}

XMLReader::FileDataPtr XMLReader::getMapWithContentsOfFile()
{
	return 0;
}

bool XMLReader::initWithFile( const char* pszFilename )
{
	if (0 == pszFilename || !*pszFilename)
	{
		return false;
	}

	TiXmlDocument kDocument;
	kDocument.LoadFile(pszFilename);

	TiXmlElement* pkRootElement = kDocument.RootElement();

	if (0 == pkRootElement)
	{
		return false;
	}

	TiXmlElement* pkArrayElement = pkRootElement->FirstChildElement("array");

	if (0 == pkArrayElement)
	{
		return false;
	}

	TiXmlElement* pkDictElement = pkArrayElement->FirstChildElement("dict");

	if (0 == pkDictElement)
	{
		return false;
	}
	
	TiXmlElement* pkKeyElement = pkDictElement->FirstChildElement("key");
	TiXmlElement* pkStringElement = pkDictElement->FirstChildElement("string");

	if (0 == pkStringElement || 0 == pkStringElement)
	{
		return false;
	}

	while (pkStringElement && pkKeyElement)
	{
		string strKey = pkKeyElement->GetText();
		string strString = pkStringElement->GetText();

		m_pkFileDataMap->insert(make_pair(strKey,strString));

		pkKeyElement = pkKeyElement->NextSiblingElement("key");
		pkStringElement = pkStringElement->NextSiblingElement("string");
	}

	return true;
}

bool XMLReader::initWithData( const char* pszData,int nSize )
{
	if (0 == pszData || !*pszData)
	{
		return false;
	}

	return true;
}

void* XMLReader::getObjectWithPath( string strPath,
								   int* pnIndexArray,
								   int nArraySize )
{
	return 0;
}