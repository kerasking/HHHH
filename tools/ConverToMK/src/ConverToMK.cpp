#include "stdafx.h"
#include "ConverToMK.h"

CConverToMK::CConverToMK( const char* pszIniFile ):
m_bIsInit(false),
m_pszIniFile(0)
{
	m_pszIniFile = new char[MAX_PATH];
	memset(m_pszIniFile,0,sizeof(char) * MAX_PATH);

	if (0 == pszIniFile || !*pszIniFile)
	{
		return;
	}

	TiXmlDocument kDocument(pszIniFile);

	if (!kDocument.LoadFile())
	{
		return;
	}

	TiXmlElement* pkRootElement = kDocument.RootElement();

	if (0 == pkRootElement)
	{
		return;
	}

	TiXmlElement* pkFiles = pkRootElement->FirstChildElement("Files");

	if (0 == pkFiles)
	{
		return;
	}
	
	Parse(pkFiles);

	m_bIsInit = true;
}

CConverToMK::~CConverToMK()
{
	SAFE_DELETE_ARRAY(m_pszIniFile);
}

CConverToMK* CConverToMK::initWithIniFile( const char* pszIniFile )
{
	CConverToMK* pkMK = new CConverToMK(pszIniFile);

	if (!pkMK->GetInitialised())
	{
		return 0;
	}

	return pkMK;
}

bool CConverToMK::Parse( TiXmlElement* pkElement )
{
	TiXmlElement* pkFilter = pkElement->FirstChildElement();

	if (strcmp("Filter",pkFilter->Value()) != 0 || 0 == pkFilter)
	{
		return false;
	}

	do
	{
		TiXmlAttribute* pkAttr = pkFilter->FirstAttribute();

		string strType = pkFilter->Value();

		if (strcmp("Filter",strType.c_str()) == 0)
		{
			Parse(pkFilter);
		}
		else if (strcmp("File",strType.c_str()) == 0)
		{
			string strName = pkAttr->Value();
			m_kFilesPathData.push_back(strName);
		}
	} while (pkFilter = pkFilter->NextSiblingElement());

	return true;
}