#include <string>
#include "ZipUnZip.h"
#include "myunzip.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

typedef struct tagDECOMPRESSPARAM
{
	void* pDlg;
	void* appData;
	const char* lpszDecompressFile;
	const char* lpszDestDir;
	bool bResult;
} DECOMPRESSPARAM, *PDECOMPRESSPARAM;

typedef struct tagZipContent
{
	int index;
	unsigned int dwAttributes;
	std::string strFileName;

} ZipContent, *PZipContent, RarContent;

bool CZipUnZip::InputZipPassword(char* password)
{
	return false;
}

bool CZipUnZip::Unzip(const char* lpszZip, const char* lpszDestDir,
					  void* lpParam, void* appData, vector<string>* pvtFile,
					  const char* lpszPreName)
{
	LOGD("Entry CZipUnZip::Unzip,lpszZip is %s,lpszDestDir is %s",lpszZip,lpszDestDir);

	if (lpszZip == NULL)
	{
		LOGERROR("lpszZip == NULL");
		return false;
	}

	bool bUnzip = true;
	char szPassword[128] = { 0 };

	bool bGetPassword = false;

	do
	{
		if (bGetPassword)
		{
			bGetPassword = false;
		}

		HZIP hz = OpenZip(lpszZip, szPassword);
		if (hz == NULL)
		{
			LOGERROR("hz == NULL");
			return false;
		}

		if (lpszDestDir != NULL)
		{
			SetUnzipBaseDir(hz, lpszDestDir);
		}

		ZIPENTRY kZipEntry = {0};
		GetZipItem(hz, -1, &kZipEntry);
		int nNumItems = kZipEntry.index;
		for (int zi = 0; zi < nNumItems; zi++)
		{
			ZIPENTRY kTempEntry = {0};
			GetZipItem(hz, zi, &kTempEntry);

			if (lpszPreName)
			{
				char szName[MAX_PATH] = { 0 };

				LOGD("%s%s", lpszPreName, kTempEntry.name);
				printf(szName, "%s%s", lpszPreName, kTempEntry.name);
				strcpy(kTempEntry.name, szName);
			}

			if (pvtFile)
			{
				std::string strFile(kTempEntry.name);
				pvtFile->push_back(strFile);
			}

			ZRESULT uiResult = UnzipItem(hz, zi, kTempEntry.name);

			if (uiResult != ZR_OK && kTempEntry.comp_size)
			{
				//NDLog("UnZipFile Error %s", ze.name);
				if (uiResult == ZR_PASSWORD)
				{
					if (InputZipPassword(szPassword))
					{
						bGetPassword = true;
						break;
					}
				}

				bUnzip = false;
				break;
			}

			UnzipPercent(nNumItems, zi);
		}

		CloseZip(hz);

	} while (bGetPassword);

	LOGD("Leave CZipUnZip::Unzip");
	return bUnzip;
}

bool CZipUnZip::UnzipProc(void* lpParameter)
{
	LOGD("Entry UnzipProc");
	PDECOMPRESSPARAM pDecompress = (PDECOMPRESSPARAM) lpParameter;

	if (pDecompress == NULL)
	{
		LOGERROR("pDecompress == NULL");
		return false;
	}

	if (Unzip(pDecompress->lpszDecompressFile, pDecompress->lpszDestDir,
		pDecompress->pDlg, pDecompress->appData))
	{
		pDecompress->bResult = true;
	}
	else
	{
		pDecompress->bResult = false;
	}

	return true;
}

bool CZipUnZip::DecompressZipSync(const char* lpszZip, const char* lpszDestDir,
								  const char* lpszDecFile, const char* lpszReName, void* appData)
{
	LOGD("Entry DecompressZipSync,lpszZip is %s,lpszDestDir is %s,lpszDecFile is %s,lpszReName is %s,appData value is %d",
		lpszZip,lpszDestDir,lpszDecFile,lpszReName,(int)appData);

	if (lpszZip == NULL)
	{
		LOGERROR("lpszZip == NULL");
		return false;
	}

	if (lpszDecFile != NULL)
	{
		LOGERROR("lpszDecFile != NULL");
		return false;
		//return DecompressZipSyncByFileName(lpszZip, lpszDestDir, lpszDecFile, lpszReName);
	}

	DECOMPRESSPARAM deParam =
	{ NULL, appData, lpszZip, lpszDestDir, false };

	UnzipProc(&deParam);

	return deParam.bResult;
}

////////////////////////////////CZipUnZip////////////////////////////////////////////
CZipUnZip::CZipUnZip(void)
{
	m_bResult = false;
	m_pnStatus = 0;
}

CZipUnZip::~CZipUnZip(void)
{
}

void* CZipUnZip::UnzipThreadExcute( void* ptr )
{
	LOGD("Entry UnzipThreadExcute,ptr value is %d",(int)ptr);

	bool bResult = false;
	CZipUnZip* pkUnZip = (CZipUnZip*) ptr;
	LOGD("pkUnZip value is %d",(int)pkUnZip);

	if (pkUnZip)
	{
		bResult = pkUnZip->DecompressZipSync(pkUnZip->m_pszZipFileName.c_str(),
			pkUnZip->m_pszDestDirName.c_str());
		pkUnZip->UnzipStatus(bResult);

		if (pkUnZip->m_pnStatus)
		{
			*(pkUnZip->m_pnStatus) = bResult ? 1 : -1;
		}
	}

	return NULL;
}

void CZipUnZip::UnZipFile(const char* pszZipFileName,
						  const char* pszDestDirName)
{
	LOGD("Entry UnZipFile,Zip file name is %s,Dest dir name is %s",pszZipFileName,pszDestDirName);

	if ((pszZipFileName == NULL) || (pszDestDirName == NULL))
	{
		LOGERROR("pszZipFileName == NULL) || (pszDestDirName == NULL");
		return;
	}

	m_pszZipFileName = pszZipFileName;
	m_pszDestDirName = pszDestDirName;

	pthread_t pid = {0};
	pthread_create(&pid, NULL, UnzipThreadExcute, this);
}