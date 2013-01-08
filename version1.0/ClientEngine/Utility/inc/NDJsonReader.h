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
	NDJsonReader(const char* pszFilePath);
	virtual ~NDJsonReader();

	void setPath(const char* pszFilePath);

	string readData(const char* pszName);

protected:

	char* m_pszFilePath;

private:
};

NS_NDENGINE_END

#endif