#ifndef _ZIPUNZIP_H_
#define _ZIPUNZIP_H_
#include <vector>
#include <pthread.h>
using namespace std;

class CZipUnZip
{
public:
	CZipUnZip(void);
	~CZipUnZip(void);
	void UnZipFile(const char* pszZipFileName, const char* pszDestDirName);
	bool InputZipPassword(char* password);
	bool Unzip(const char* lpszZip, const char* lpszDestDir, void* lpParam,
		void* appData = NULL, vector<string>* pvtFile = NULL,
		const char* lpszPreName = NULL);
	bool UnzipProc(void* lpParameter);
	bool DecompressZipSync(const char* lpszZip, const char* lpszDestDir = NULL,
		const char* lpszDecFile = NULL, const char* lpszReName = NULL,
		void* appData = NULL);
	virtual void UnzipPercent(int FileNum, int nFileIndex)
	{
	}

	virtual void UnzipStatus(bool bResult)
	{
		m_bResult = bResult;
	}

	virtual bool GetUnzipStatus()
	{
		return m_bResult;
	}

	virtual void SetExtStatus(int* pnStatus)
	{
		m_pnStatus = pnStatus;
	}

	int* m_pnStatus;

protected:

	static void* UnzipThreadExcute(void* ptr);

	std::string m_pszZipFileName;
	std::string m_pszDestDirName;

private:

	bool m_bResult;
};

#endif