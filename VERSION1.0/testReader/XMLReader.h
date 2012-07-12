/*
*
*/

#ifndef XMLREADER_H
#define XMLREADER_H

class XMLReader
{
public:

	XMLReader();
	virtual ~XMLReader();

	bool initWithFile(const char* pszFilename);
	bool initWithData(const char* pszData,int nSize);
	void* getObjectWithPath(string strPath,int* pnIndexArray,int nArraySize);

protected:

private:
};

#endif