#include <string>
#include "ZipUnZip.h"
#include "unzip.h"

typedef struct tagDECOMPRESSPARAM{
	void* pDlg;
	void* appData;
	const char* lpszDecompressFile;
	const char* lpszDestDir;
	bool bResult;
}DECOMPRESSPARAM,*PDECOMPRESSPARAM;

typedef struct tagZipContent
{
	int index; 
	unsigned int dwAttributes;		
    std::string strFileName;

}ZipContent, *PZipContent, RarContent;

bool CZipUnZip::InputZipPassword(char* password)
{
	return false;
}

bool CZipUnZip::Unzip(const char* lpszZip,const char* lpszDestDir,void* lpParam, void* appData, vector<string>* pvtFile ,const char* lpszPreName)
{
	if (lpszZip == NULL)
	{
		return false;
	}
	bool bUnzip = true;
	char password[128]={0};
	bool bGetPassword = false;
	do{
		if(bGetPassword)
			bGetPassword = false;
		HZIP hz = OpenZip(lpszZip,password);
		if(hz == NULL)
			return false;

		if(lpszDestDir != NULL)
		{
			SetUnzipBaseDir(hz,lpszDestDir);
		}

		ZIPENTRY ze; 
		GetZipItem(hz,-1,&ze);
		int numitems=ze.index;
		for (int zi=0; zi<numitems; zi++)
		{
			ZIPENTRY ze;
			GetZipItem(hz,zi,&ze);
			if( lpszPreName )
			{
				TCHAR szName[MAX_PATH]={0};
				printf(szName, "%s%s", lpszPreName, ze.name);
				strcpy(ze.name,szName);
			}
			if( pvtFile )
			{
				std::string strFile(ze.name);
				pvtFile->push_back(strFile);
			}
			ZRESULT zres = UnzipItem(hz, zi, ze.name);
			if(zres != ZR_OK && ze.comp_size)
			{
				//NDLog("UnZipFile Error %s", ze.name);
				if(zres == ZR_PASSWORD)
				{
					if(InputZipPassword(password)){
						bGetPassword = true;
						break;
					}
				}
				bUnzip = false;
				break;
			}
            UnzipPercent(numitems, zi);
		}
		CloseZip(hz);
	}while(bGetPassword);
	return bUnzip;
}


bool CZipUnZip::UnzipProc(void* lpParameter)
{
	PDECOMPRESSPARAM pDecompress = (PDECOMPRESSPARAM)lpParameter;
	if(pDecompress == NULL)
		return false;

	if(Unzip(pDecompress->lpszDecompressFile,pDecompress->lpszDestDir,pDecompress->pDlg, pDecompress->appData))
		pDecompress->bResult = true;
	else
		pDecompress->bResult = false;

	return true;
}

bool CZipUnZip::DecompressZipSync(const char* lpszZip, const char* lpszDestDir , const char* lpszDecFile , const char* lpszReName , void* appData )
{
	if(lpszZip == NULL)
	{
		return false;
	}

	if(lpszDecFile != NULL)
	{
		return false;
		//return DecompressZipSyncByFileName(lpszZip, lpszDestDir, lpszDecFile, lpszReName);
	}

	DECOMPRESSPARAM deParam = {NULL,appData,lpszZip,lpszDestDir,false};
	UnzipProc(&deParam);

	return deParam.bResult;
}


////////////////////////////////CZipUnZip////////////////////////////////////////////
CZipUnZip::CZipUnZip(void)
{
    m_bResult = false;
}

CZipUnZip::~CZipUnZip(void)
{
}
void* UnzipThreadExcute(void* ptr)
{
    bool bResult = false;
	CZipUnZip* unzip = (CZipUnZip*)ptr;
	if (unzip) 
	{
        bResult=unzip->DecompressZipSync(unzip->m_pszZipFileName.c_str(), unzip->m_pszDestDirName.c_str());	
        unzip->UnzipStatus(bResult);
	}
	return NULL;
}
void CZipUnZip::UnZipFile( const char* pszZipFileName, const char* pszDestDirName)
{
    if ((pszDestDirName==NULL)||(pszDestDirName==NULL) ) 
    {
        return;
    }
    this->m_pszZipFileName = pszZipFileName;
    this->m_pszDestDirName = pszDestDirName;
    pthread_t pid;
    pthread_create(&pid, NULL, UnzipThreadExcute, this);	
}




