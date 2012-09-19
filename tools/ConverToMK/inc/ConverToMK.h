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

	bool m_bIsInit;

	StringVector m_kFilesPathData;

private:
};

#endif