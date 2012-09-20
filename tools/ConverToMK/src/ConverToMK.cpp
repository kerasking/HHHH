#include "stdafx.h"
#include "ConverToMK.h"

CConverToMK::CConverToMK( const char* pszVCProjectFile,const char* pszMKFile):
m_bIsInit(false),
m_pszVCProjectFile(0),
m_pszMKFile(0)
{
	m_pszVCProjectFile = new char[255];
	m_pszMKFile = new char[255];

	memset(m_pszMKFile,0,sizeof(char) * 255);
	memset(m_pszVCProjectFile,0,sizeof(char) * 255);

	if (0 == pszVCProjectFile || !*pszVCProjectFile ||
		0 == pszMKFile || !*pszMKFile)
	{
		return;
	}

	strcpy_s(m_pszMKFile,255,pszMKFile);
	strcpy_s(m_pszVCProjectFile,255,pszVCProjectFile);

	TiXmlDocument kDocument(pszVCProjectFile);

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
	SAFE_DELETE_ARRAY(m_pszVCProjectFile);
	SAFE_DELETE_ARRAY(m_pszMKFile);
}

CConverToMK* CConverToMK::initWithIniFile( const char* pszIniFile )
{
	if (0 == pszIniFile || !*pszIniFile)
	{
		return 0;
	}

	ptree kTree;
	read_ini(pszIniFile,kTree);

	string strVCProj = kTree.get<string>("PATH.VCProjectPath");
	string strMKFile = kTree.get<string>("PATH.MKFilePath");

	CConverToMK* pkMK = new CConverToMK(strVCProj.c_str(),strMKFile.c_str());

	if (!pkMK->GetInitialised())
	{
		return 0;
	}

	return pkMK;
}

bool CConverToMK::Parse( TiXmlElement* pkElement )
{
	if (0 == pkElement)
	{
		return false;
	}

	TiXmlElement* pkFilter = pkElement->FirstChildElement();

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

bool CConverToMK::WriteToMKFile( const char* pszFilename)
{
	if (0 == pszFilename || !*pszFilename)
	{
		return false;
	}

	return true;
}