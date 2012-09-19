#include "stdafx.h"
#include "ConverToMK.h"

CConverToMK::CConverToMK( const char* pszIniFile ):
m_bIsInit(false)
{
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

	TiXmlElement* pkFilter = pkFiles->FirstChildElement();

	if (0 == pkFilter)
	{
		return;
	}

	do
	{
		TiXmlAttribute* pkAttr = pkFilter->FirstAttribute();

		string strName = pkAttr->Value();

		if (strcmp("Framework",strName.c_str()) != 0)
		{
			continue;
		}

		TiXmlElement* pkFileElement = pkFilter->FirstChildElement();

		if (0 == pkFileElement)
		{
			continue;
		}

		do
		{
			TiXmlAttribute* pkFileAttr = pkFileElement->FirstAttribute();

			if (0 == pkFileAttr)
			{
				continue;
			}

			string strName = pkFileAttr->Value();

			m_kFilesPathData.push_back(strName);
		} while (pkFileElement = pkFileElement->NextSiblingElement());
	} while (pkFilter = pkFilter->NextSiblingElement());

	m_bIsInit = true;
}

CConverToMK::~CConverToMK(){}

CConverToMK* CConverToMK::initWithIniFile( const char* pszIniFile )
{
	CConverToMK* pkMK = new CConverToMK(pszIniFile);

	if (!pkMK->GetInitialised())
	{
		return 0;
	}

	return pkMK;
}