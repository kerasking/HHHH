/*
*
*/

#ifndef CONVERTOMK_H
#define CONVERTOMK_H

class CConverToMK:public noncopyable
{
public:

	typedef vector<string> StringVector,*StringVectorPtr;

	CConverToMK( const char* pszVCProjectFile,const char* pszMKFile,
		CConverToMK::StringVector kFilterWords,const char* pszHelpFile = "");
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
	bool ProcessPath(const char* pszPath,string& strRes);
	bool ParseFilterInVCProjectFile(TiXmlElement* pkElement);
	bool IsFilterWord(const char* pszFilter);

	bool m_bIsInit;
	char* m_pszVCProjectFile;
	char* m_pszMKFile;
	char* m_pszFilterWord;
	char* m_pszHelpFile;

	StringVector m_kFilesPathData;
	StringVector m_kMKFileData;
	StringVector m_kFilterWord;
	StringVector m_kHelpData;

	unsigned int m_uiKeyStringPosition;

private:
};

#endif