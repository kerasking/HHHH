#include "XMLReader.h"

XMLReader::XMLReader():
m_pkFileDataMap(0)
{
	m_pkFileDataMap = new FileData;
}

XMLReader::~XMLReader()
{
	for (FileData::iterator it = m_pkFileDataMap->begin();
		it != m_pkFileDataMap->end();++it)
	{
		const char* pszTemp = it->second;

		if (pszTemp)
		{
			delete [] pszTemp;
		}
	}

	delete m_pkFileDataMap;
}

XMLReader::FileDataPtr XMLReader::getArrayWithContentsOfFile()
{
	return 0;
}

bool XMLReader::initWithFile( const char* pszFilename )
{
	return true;
}

bool XMLReader::initWithData( const char* pszData,int nSize )
{
	return true;
}

void* XMLReader::getObjectWithPath( string strPath,
								   int* pnIndexArray,
								   int nArraySize )
{
	return 0;
}