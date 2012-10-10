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
	StringVectorMap m_kKeyWordMap;

	unsigned int m_uiKeyStringPosition;

private:
};

#endif