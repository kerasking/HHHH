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
		const char* pszFilter);
	virtual ~CConverToMK();

	static CConverToMK* initWithIniFile(const char* pszIniFile);

	bool WriteToMKFile();

	inline bool GetInitialised(){return m_bIsInit;}

	void SetFilterWord(const char* pszWord);

protected:

	bool ParseVCProjectFile();
	bool ParseMKFile();
	bool ParseFilterInVCProjectFile(TiXmlElement* pkElement);
	bool IsFilterWord(const char* pszFilter);

	bool m_bIsInit;
	char* m_pszVCProjectFile;
	char* m_pszMKFile;
	char* m_pszFilterWord;

	StringVector m_kFilesPathData;
	StringVector m_kMKFileData;

	unsigned int m_uiKeyStringPosition;

private:
};

#endif