/*
*
*/

#ifndef CONVERTOMK_H
#define CONVERTOMK_H

class CConverToMK
{
public:

	typedef vector<string> StringVector,*StringVectorPtr;

	CConverToMK( const char* pszIniFile );
	virtual ~CConverToMK();

	static CConverToMK* initWithIniFile(const char* pszIniFile);

	inline bool GetInitialised(){return m_bIsInit;}

protected:

	bool Parse(TiXmlElement* pkElement);

	bool m_bIsInit;
	char* m_pszIniFile;

	StringVector m_kFilesPathData;

private:
};

#endif