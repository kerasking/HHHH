/*
*
*/

#ifndef NDJSONREADER_H
#define NDJSONREADER_H

#include <string>
#include "define.h"
#include "NDObject.h"

using namespace std;

NS_NDENGINE_BGN

class NDJsonReader:public NDObject
{
	DECLARE_CLASS(NDJsonReader)

public:

	NDJsonReader();
	virtual ~NDJsonReader();

	bool readJsonFile(const char* pszFilePath);

	const char* readData(const char* pszName);

protected:

	char* m_pszFilePath;
	char* m_pszBuffer;
	unsigned long m_ulFileSize;

private:
};

NS_NDENGINE_END

#endif