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

	bool Parse(TiXmlElement* pkElement);

	bool m_bIsInit;
	char* m_pszVCProjectFile;
	char* m_pszMKFile;

	StringVector m_kFilesPathData;

private:
};

#endif