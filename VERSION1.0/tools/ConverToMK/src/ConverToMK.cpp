#include "stdafx.h"
#include "ConverToMK.h"
#include <Windows.h>

CConverToMK::CConverToMK(const char* pszXMLFile):
m_bIsInit(false),
m_pszMKFile(0),
m_pszHelpFile(0),
m_pszConfigFile(0),
m_uiKeyStringPosition(0)
{
	m_pszMKFile = new char[255];
	m_pszHelpFile = new char[255];
	m_pszConfigFile = new char[255];

	memset(m_pszHelpFile,0,sizeof(char) * 255);
	memset(m_pszMKFile,0,sizeof(char) * 255);
	memset(m_pszConfigFile,0,sizeof(char) * 255);

	TiXmlDocument kDocument(pszXMLFile);

	if (!kDocument.LoadFile())
	{
		return;
	}

	TiXmlElement* pkConfElement = kDocument.RootElement();

	if (0 == pkConfElement)
	{
		return;
	}

	TiXmlElement* pkSubElement = pkConfElement->FirstChildElement("module");

	do
	{
		TiXmlAttribute* pkNameAttribute = pkSubElement->FirstAttribute();
		string strName = pkNameAttribute->Name();
		string strData;

		if (strcmp("name",strName.c_str()) != 0)
		{
			continue;
		}

		strData = pkNameAttribute->Value();
		ModuleInfo kInfo = {0};
		strcpy_s(kInfo.szModuleName,255,strData.c_str());

		TiXmlElement* pkVCProjectPath = pkSubElement->FirstChildElement("VCProjectPath");

		if (0 == pkVCProjectPath)
		{
			continue;
		}

		string strVCPath = pkVCProjectPath->GetText();

		strcpy_s(kInfo.szVCProjFile,255,strVCPath.c_str());

		crc_32_type kCrc32;
		kCrc32.process_bytes(kInfo.szModuleName,strlen(kInfo.szModuleName));
		unsigned int uiID = kCrc32.checksum();

		m_kModuleInfoMap.insert(make_pair(uiID,kInfo));
	} while (pkSubElement = pkSubElement->NextSiblingElement("module"));

	TiXmlElement* pkPathElement = pkConfElement->FirstChildElement("path");

	if (0 == pkPathElement)
	{
		return;
	}

	TiXmlElement* pkMKFilePath = pkPathElement->FirstChildElement("MKFilePath");
	TiXmlElement* pkHelpFilePath = pkPathElement->FirstChildElement("HelpFilePath");

	string strHelpFile = pkHelpFilePath->GetText();
	string strMKFile = pkMKFilePath->GetText();

	TiXmlElement* pkFilterElement = pkConfElement->FirstChildElement("filter");

	if (pkFilterElement)
	{
		TiXmlElement* pkSrcFileElement = pkFilterElement->FirstChildElement("SrcFile");

		do 
		{
			string strTemp = pkSrcFileElement->GetText();
			m_kFilterWord.push_back(strTemp);
		} while (pkSrcFileElement = pkSrcFileElement->NextSiblingElement("SrcFile"));
	}

	if (strHelpFile.length() != 0)
	{
		strcpy_s(m_pszHelpFile,255,strHelpFile.c_str());

		if (!InitialiseHelp())
		{
			return;
		}
	}

	if (0 == strMKFile.c_str())
	{
		return;
	}

	strcpy_s(m_pszMKFile,255,strMKFile.c_str());

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
	SAFE_DELETE_ARRAY(m_pszMKFile);
	SAFE_DELETE_ARRAY(m_pszHelpFile);
	SAFE_DELETE_ARRAY(m_pszConfigFile);
}

CConverToMK* CConverToMK::initWithIniFile( const char* pszIniFile )
{
	if (0 == pszIniFile || !*pszIniFile)
	{
		return 0;
	}

	CConverToMK* pkMK = new CConverToMK(pszIniFile);

	if (!pkMK->GetInitialised())
	{
		return 0;
	}

	return pkMK;
}

bool CConverToMK::ParseFilterInVCProjectFile( TiXmlElement* pkElement,
											 StringVector& kVector)
{
	if (0 == pkElement)
	{
		return false;
	}

	TiXmlElement* pkFilter = pkElement->FirstChildElement();

	if (0 == pkFilter)
	{
		return false;
	}

	do
	{
		TiXmlAttribute* pkAttr = pkFilter->FirstAttribute();

		string strType = pkFilter->Value();

		if (strcmp("Filter",strType.c_str()) == 0)
		{
			ParseFilterInVCProjectFile(pkFilter,kVector);
		}
		else if (strcmp("File",strType.c_str()) == 0)
		{
			string strName = pkAttr->Value();

			if (!IsFilterWord(strName.c_str()))
			{
				continue;
			}

			kVector.push_back(strName);
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

	for (ModuleInfoMap::iterator it = m_kModuleInfoMap.begin();
		it != m_kModuleInfoMap.end();it++)
	{
		ModuleInfo kInfo = it->second;
		StringVector kStringVector = m_kFilesPathData[string(kInfo.szModuleName)];

		for (unsigned int uiIndex = 0;uiIndex < kStringVector.size();uiIndex++)
		{
			string strFullPath = kStringVector[uiIndex];
			string strProcessedPath = "";

			if (!ProcessPath(kInfo.szVCProjFile,strFullPath.c_str(),strProcessedPath))
			{
				cout << "文件 " << strFullPath << " 找不到！请检查vcproj文件" << endl;
				continue;
			}

			replace_all(strProcessedPath,"\\","/");

			if (uiIndex != kStringVector.size() - 1)
			{
				strProcessedPath = strProcessedPath + string(" \\");
			}

			kPathSet.insert(kPathSet.begin() + uiPos,strProcessedPath);
			uiPos++;
		}
	}

	ofstream kOutStream("temp.mk");
	cout << "正在写入到" << "temp.mk" << "文件里" << endl;
	progress_display kProgressDisplay(kPathSet.size());

	for (unsigned int uiIndex = 0;uiIndex < kPathSet.size();uiIndex++)
	{
		kOutStream << kPathSet[uiIndex] << endl;
		++kProgressDisplay;
		Sleep(20);
	}

	kOutStream.close();

	cout << "已经写完并且关闭文件" << endl;

	return true;
}

bool CConverToMK::ParseVCProjectFile()
{
	for (ModuleInfoMap::iterator it = m_kModuleInfoMap.begin();
		it != m_kModuleInfoMap.end();it++)
	{
		ModuleInfo kInfo = it->second;
		StringVector kVector;

		TiXmlDocument kDocument(kInfo.szVCProjFile);

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

		ParseFilterInVCProjectFile(pkFiles,kVector);

		m_kFilesPathData.insert(make_pair(string(kInfo.szModuleName),kVector));
	}

	return true;
}

bool CConverToMK::ParseMKFile()
{
	if (!CheckFileExist(m_pszMKFile))
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

		if (strcmp(strFilter.c_str(),strExt.c_str()) == 0)
		{
			return true;
		}
	}

	return false;
}

bool CConverToMK::ProcessPath(const char* pszVCPath,
							  const char* pszPath,
							  string& strRes )
{
	if (0 == pszPath || !*pszPath)
	{
		return false;
	}

	if (strRes.size())
	{
		strRes = "";
	}

	filesystem::path kVCFile(pszVCPath);
	filesystem::path kMKFile(m_pszMKFile);
	filesystem::path kInputPath(pszPath);

	unsigned int uiParentFolderCount = 0;
	string strFilename = kInputPath.filename().string();

	kInputPath = kInputPath.parent_path();

	kVCFile = kVCFile.parent_path();
	kMKFile = kMKFile.parent_path();

	StringVector kVCSets;
	StringVector kMKSets;
	StringVector kTargetSets;
	StringVector kTempVC;

	BOOST_AUTO(pkInputPathPos,kInputPath.begin());
	BOOST_AUTO(pkVCPos,kVCFile.begin());
	BOOST_AUTO(pkMKPos,kMKFile.begin());

	while (pkInputPathPos != kInputPath.end())
	{
		string strPath = pkInputPathPos->string().c_str();

		if (strcmp(strPath.c_str(),"..") == 0)
		{
			uiParentFolderCount++;
			pkInputPathPos++;
			continue;
		}

		kTargetSets.push_back(strPath);
		pkInputPathPos++;
	}

	while (pkVCPos != kVCFile.end())
	{
		filesystem::path strVC = *pkVCPos;
		kVCSets.push_back(strVC.string());
		pkVCPos++;
	}

	kTempVC = kVCSets;

	while (0 < uiParentFolderCount)
	{
		kTempVC.pop_back();
		kVCSets.pop_back();
		uiParentFolderCount--;
	}

	while (pkMKPos != kMKFile.end())
	{
		string strVC = pkMKPos->string();
		kMKSets.push_back(strVC);
		pkMKPos++;
	}

	unsigned int uiMin = kMKSets.size() < kVCSets.size() ?
		kMKSets.size() : kVCSets.size();
	unsigned int uiIndex = 0;

	for (uiIndex = 0;uiIndex < uiMin;uiIndex++)
	{
		if (strcmp(kMKSets[uiIndex].c_str(),kVCSets[uiIndex].c_str()) != 0)
		{
			break;
		}
	}

	kMKSets.erase(kMKSets.begin(),kMKSets.begin() + uiIndex);
	kVCSets.erase(kVCSets.begin(),kVCSets.begin() + uiIndex);

	strRes += ".";
	string strPrePath = "";

	for (unsigned int uiIndex = 0;uiIndex < kTempVC.size();uiIndex++)
	{
		strPrePath += kTempVC[uiIndex];
		strPrePath += "\\";
	}

	for (unsigned int uiIndex = 0;uiIndex < kVCSets.size();uiIndex++)
	{
		strRes += "\\";
		strRes += kVCSets[uiIndex];
	}

	for (unsigned int uiIndex = 0;uiIndex < kTargetSets.size();uiIndex++)
	{
		strRes += "\\";
		strPrePath += kTargetSets[uiIndex];
		strPrePath += "\\";

		strRes += kTargetSets[uiIndex];
	}

	strRes += "\\";
	strRes += strFilename;
	strPrePath += strFilename;

	if (!CheckFileExist(strPrePath.c_str()))
	{
		return false;
	}

	return true;
}

bool CConverToMK::CheckFileExist( const char* pszFile )
{
	if (0 == pszFile || !*pszFile)
	{
		return false;
	}

	file_type eType = status(pszFile).type();

	if (regular_file != eType)
	{
		return false;
	}

	return true;
}

CConverToMK::StringVector CConverToMK::GetHelpComment()
{
	return m_kHelpData;
}

bool CConverToMK::InitialiseHelp()
{
	if (!CheckFileExist(m_pszHelpFile))
	{
		return false;
	}

	ifstream kInStream(m_pszHelpFile);

	if (!kInStream.is_open())
	{
		return false;
	}

	char szTempData[1024] = {0};

	while (kInStream.getline(szTempData,1024))
	{
		string strData = szTempData;
		m_kHelpData.push_back(strData);
	}

	return true;
}