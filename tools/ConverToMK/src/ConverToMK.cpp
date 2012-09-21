#include "stdafx.h"
#include "ConverToMK.h"

CConverToMK::CConverToMK( const char* pszVCProjectFile,
						 const char* pszMKFile,
						 CConverToMK::StringVector kFilterWords):
m_bIsInit(false),
m_pszVCProjectFile(0),
m_pszMKFile(0),
m_uiKeyStringPosition(0)
{
	m_pszVCProjectFile = new char[255];
	m_pszMKFile = new char[255];

	if (kFilterWords.size())
	{
		m_kFilterWord = kFilterWords;
	}
	
	memset(m_pszMKFile,0,sizeof(char) * 255);
	memset(m_pszVCProjectFile,0,sizeof(char) * 255);

	if (0 == pszVCProjectFile || !*pszVCProjectFile ||
		0 == pszMKFile || !*pszMKFile)
	{
		return;
	}

	strcpy_s(m_pszMKFile,255,pszMKFile);
	strcpy_s(m_pszVCProjectFile,255,pszVCProjectFile);

	if (!ParseVCProjectFile())
	{
		return;
	}

	if (!ParseMKFile())
	{
		return;
	}

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
	read_xml(pszIniFile,kTree);
	StringVector kFilterWords;

	string strVCProj = kTree.get<string>("conf.path.VCProjectPath");
	string strMKFile = kTree.get<string>("conf.path.MKFilePath");

	BOOST_AUTO(child,kTree.get_child("conf.filter"));
	for (BOOST_AUTO(pkPos,child.begin());child.end() != pkPos;++pkPos)
	{
		string strTemp = pkPos->second.data();
		kFilterWords.push_back(strTemp);
	}

	CConverToMK* pkMK = new CConverToMK(strVCProj.c_str(),
		strMKFile.c_str(),kFilterWords);

	if (!pkMK->GetInitialised())
	{
		return 0;
	}

	return pkMK;
}

bool CConverToMK::ParseFilterInVCProjectFile( TiXmlElement* pkElement )
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
			ParseFilterInVCProjectFile(pkFilter);
		}
		else if (strcmp("File",strType.c_str()) == 0)
		{
			string strName = pkAttr->Value();

			if (!IsFilterWord(strName.c_str()))
			{
				continue;
			}

			m_kFilesPathData.push_back(strName);
		}
	} while (pkFilter = pkFilter->NextSiblingElement());

	return true;
}

bool CConverToMK::WriteToMKFile()
{
	filesystem::path kPath(m_pszMKFile);
	string strParentPath = kPath.parent_path().string();
	StringVector kPathSet = m_kMKFileData;
	StringVector::iterator pkIterator = kPathSet.begin();

	for (unsigned int i = 0;i < m_uiKeyStringPosition;i++)
	{
		pkIterator++;
	}

	kPathSet.insert(pkIterator,string("LOCAL_SRC_FILES := \\"));
	unsigned int uiPos = m_uiKeyStringPosition + 1;

	for (unsigned int uiIndex = 0;uiIndex < m_kFilesPathData.size();uiIndex++)
	{
		string strFull = m_kFilesPathData[uiIndex];

		replace_all(strFull,"\\","/");

		if (uiIndex != m_kFilesPathData.size() - 1)
		{
			strFull = strFull + string(" \\");
		}

		kPathSet.insert(kPathSet.begin() + uiPos,strFull);
		uiPos++;
	}

// 	for (unsigned int uiIndex = 0;uiIndex < kPathSet.size();uiIndex++)
// 	{
// 		string strFullPath = strParentPath + string("/") + kPathSet[uiIndex];
// 		file_type eFileType = status(strFullPath).type();
// 
// 		if (regular_file != eFileType)
// 		{
// 			kPathSet[uiIndex] = "";
// 			cout << "File not found :" << kPathSet[uiIndex] << endl;
// 			continue;;
// 		}
// 	}

	ofstream kOutStream("temp.mk");

	for (unsigned int uiIndex = 0;uiIndex < kPathSet.size();uiIndex++)
	{
		kOutStream << kPathSet[uiIndex] << endl;
	}

	kOutStream.close();

	return true;
}

bool CConverToMK::ParseVCProjectFile()
{
	TiXmlDocument kDocument(m_pszVCProjectFile);

	if (!kDocument.LoadFile())
	{
		return false;
	}

	TiXmlElement* pkRootElement = kDocument.RootElement();

	if (0 == pkRootElement)
	{
		return false;
	}

	TiXmlElement* pkFiles = pkRootElement->FirstChildElement("Files");

	if (0 == pkFiles)
	{
		return false;
	}

	ParseFilterInVCProjectFile(pkFiles);

	return true;
}

bool CConverToMK::ParseMKFile()
{
	file_type eType = status(m_pszMKFile).type();

	if (regular_file != eType)
	{
		return false;
	}

	ifstream kInStream(m_pszMKFile);

	if (!kInStream.is_open())
	{
		return false;
	}

	char szTempData[1024] = {0};

	while (kInStream.getline(szTempData,1024))
	{
		string strData = szTempData;
		m_kMKFileData.push_back(strData);
	}

	unsigned int uiEndPosition = -1;
	StringVector::iterator pkIterator = m_kMKFileData.begin();
	StringVector::iterator pkEndIterator = m_kMKFileData.begin();

	for (unsigned int i = 0;i < m_kMKFileData.size();i++)
	{
		iterator_range<string::iterator> kRange;
		kRange = find_first(m_kMKFileData[i],"LOCAL_SRC_FILES");

		if (kRange.size() != 0)
		{
			m_uiKeyStringPosition = i;
			break;
		}

		pkIterator++;
	}

	pkEndIterator = pkIterator;

	for (unsigned int i = m_uiKeyStringPosition;i < m_kMKFileData.size();i++)
	{
		iterator_range<string::iterator> kRange;
		kRange = find_first(m_kMKFileData[i],"\\");

		string strTemp;

		strTemp = m_kMKFileData[i];

		pkEndIterator++;

		if (kRange.size() == 0)
		{
			if (strTemp.length() == 0)
			{
				continue;
			}

			uiEndPosition = i;
			break;
		}

		if (m_uiKeyStringPosition == i)
		{
			continue;
		}
	}

	m_kMKFileData.erase(pkIterator,pkEndIterator);
	kInStream.close();

	return true;
}

bool CConverToMK::IsFilterWord( const char* pszFilter )
{
	if (0 == pszFilter || !*pszFilter)
	{
		return false;
	}

	filesystem::path kPath(pszFilter);

	string strExt = kPath.extension().string();

	for (unsigned int i = 0;i < m_kFilterWord.size();i++)
	{
		string strFilter = m_kFilterWord[i];

		if (strcmp(strFilter.c_str(),strExt.c_str()) != 0)
		{
			return false;
		}
	}

	return true;
}