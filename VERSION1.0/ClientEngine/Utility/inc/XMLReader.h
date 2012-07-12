/*
*
*/

#ifndef XMLREADER_H
#define XMLREADER_H

#include <cocos2d.h>
#include <libxml/parser.h>
#include <libxml/xmlmemory.h>
#include <libxml/xmlwriter.h>
#include <map>
#include <vector>
#include <tinyxml.h>

using namespace cocos2d;
using namespace std;

class XMLReader
{
public:

	typedef map<string,xmlNodePtr> DocumentPointMap,*DocumentPointMapPtr;
	typedef vector<DocumentPointMap> DataVector;

	XMLReader();
	virtual ~XMLReader();

	bool initWithFile(const char* pszFilename);
	bool initWithData(const char* pszData,int nSize);

protected:

	void parseXML2Dictionary(xmlDocPtr pkCommands);
	void parseNodeOfDoc(xmlDocPtr pkCommands,xmlNodePtr pkRootNode,DataVector* pkDataMap);
	xmlNodePtr getXmlNode(xmlNodePtr& pkNode);
	xmlNodePtr getNextXmlNode(xmlNodePtr& pkNode);
	
	DataVector* m_pkDataMap;

private:
};

#endif