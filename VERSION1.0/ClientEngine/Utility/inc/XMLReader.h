/*
*
*/

#ifndef XMLREADER_H
#define XMLREADER_H

#include <cocos2d.h>
#include <map>
#include <vector>
#include "..\..\TinyXML\inc\tinyxml.h"

using namespace cocos2d;
using namespace std;

class XMLReader
{
public:

	typedef map<const char*,const char*> FileData,*FileDataPtr;

	XMLReader();
	virtual ~XMLReader();

	bool initWithFile(const char* pszFilename);
	bool initWithData(const char* pszData,int nSize);
	void* getObjectWithPath(string strPath,int* pnIndexArray,int nArraySize);

	XMLReader::FileDataPtr getArrayWithContentsOfFile();

protected:

	FileDataPtr m_pkFileDataMap;

private:
};

#endif