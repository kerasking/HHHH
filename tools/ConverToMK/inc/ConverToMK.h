/*
*
*/

#ifndef CONVERTOMK_H
#define CONVERTOMK_H

class CConverToMK:public noncopyable
{
public:

	typedef vector<string> StringVector,*StringVectorPtr;

	CConverToMK( const char* pszVCProjectFile,const char* pszMKFile );
	virtual ~CConverToMK();

	static CConverToMK* initWithIniFile(const char* pszIniFile);

	bool WriteToMKFile();

	inline bool GetInitialised(){return m_bIsInit;}

protected:

	bool ParseVCProjectFile();
	bool ParseMKFile();
	bool ParseFilterInVCProjectFile(TiXmlElement* pkElement);

	bool m_bIsInit;
	char* m_pszVCProjectFile;
	char* m_pszMKFile;

	StringVector m_kFilesPathData;
	StringVector m_kMKFileData;

	unsigned int m_uiKeyStringPosition;

private:
};

#endif