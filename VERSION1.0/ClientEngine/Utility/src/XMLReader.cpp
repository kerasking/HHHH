#include "XMLReader.h"

XMLReader::XMLReader():
m_pkDataMap(0)
{
	m_pkDataMap = new DataVector;
}

XMLReader::~XMLReader()
{
	if (m_pkDataMap)
	{
		delete m_pkDataMap;
		m_pkDataMap = 0;
	}
}

bool XMLReader::initWithFile( const char* pszFilename )
{
	if (0 == pszFilename || !*pszFilename)
	{
		return false;
	}

	xmlKeepBlanksDefault(1);
	xmlDocPtr pkCommand = 0;

	pkCommand = xmlParseFile(pszFilename);

	return true;
}

void XMLReader::parseXML2Dictionary( xmlDocPtr pkCommands )
{
	if (0 == pkCommands)
	{
		CCLog("pkCommands ÊÇ¿ÕµÄ");
		return;
	}

	xmlNodePtr pkRootNode = xmlDocGetRootElement(pkCommands);

	if (pkRootNode)
	{

	}
}

void XMLReader::parseNodeOfDoc( xmlDocPtr pkCommands,xmlNodePtr pkRootNode,DataVector* pkDataMap )
{
	if (0 == pkRootNode || 0 == pkCommands || 0 == pkDataMap)
	{
		CCLog("Go die....");
		return;
	}

	xmlChar* pszVal = 0;
	xmlNodePtr pkCurNode = getXmlNode(pkRootNode->children);
	DataVector kSubDic;

	if (0 == pkCurNode && getXmlNode(pkCurNode->children))
	{
		while (pkCurNode)
		{
			string strNodeName = pkCurNode->name;
			xmlNodePtr pkObject = 0;
			pkObject = kSubDic[strNodeName];

			parseNodeOfDoc(pkCommands,pkCurNode,m_pkDataMap);

			pkCurNode = getNextXmlNode(pkCurNode);
		}
	}
}

xmlNodePtr XMLReader::getXmlNode( xmlNodePtr& pkNode )
{
	while (pkNode && xmlIsBlankNode(pkNode))
	{
		pkNode = pkNode->next;
	}

	return pkNode;
}

xmlNodePtr XMLReader::getNextXmlNode( xmlNodePtr& pkNode )
{
	do 
	{
		pkNode = pkNode->next;
	} while (pkNode && xmlIsBlankNode(pkNode));

	return pkNode;
}

bool XMLReader::initWithData( const char* pszData,int nSize )
{
	return true;
}