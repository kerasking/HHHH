/*
*
*/

#ifndef CONVERTOMK_H
#define CONVERTOMK_H

class CConverToMK:public noncopyable
{
public:

	struct ModuleInfo
	{
		char szModuleName[255];
		char szVCProjFile[255];
	};

	struct MKFileInfo
	{
		char szLocalPath[1024];
		char szInclude[255][1024];
		char szLocalCIncludes[1024];
		char szLocalLDLibs[1024];
	};

	typedef vector<string> StringVector,*StringVectorPtr;
	typedef map<unsigned int,ModuleInfo> ModuleInfoMap,*ModuleInfoMapPtr;
	typedef map<string,StringVector> StringVectorMap,*StringVectorMapPtr;

	CConverToMK(const char* pszXMLFile);
	virtual ~CConverToMK();

	static CConverToMK* initWithIniFile(const char* pszIniFile);

	bool WriteToMKFile();
	CConverToMK::StringVector GetHelpComment();

	inline bool GetInitialised(){return m_bIsInit;}

protected:

	bool InitialiseHelp();
	bool ProcessKeyWord(const char* pszKeyword);
	bool CheckFileExist(const char* pszFile);
	bool ParseVCProjectFile();
	bool ParseMKFile();
	bool ProcessPath(const char* pszVCPath,const char* pszPath,string& strRes);
	bool ParseFilterInVCProjectFile(TiXmlElement* pkElement,StringVector& kVector);
	bool IsFilterWord(const char* pszFilter);

	bool m_bIsInit;
	char* m_pszMKFile;
	char* m_pszHelpFile;
	char* m_pszConfigFile;

	StringVectorMap m_kFilesPathData;
	StringVector m_kMKFileData;
	StringVector m_kFilterWord;
	StringVector m_kHelpData;
	ModuleInfoMap m_kModuleInfoMap;
	MKFileInfo m_kMKFileInfo;

	unsigned int m_uiKeyStringPosition;

private:
};

#endif