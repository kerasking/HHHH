//
//  DownLoadPackage.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-4-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "DownloadPackage.h"
#include "KData.h"
#include "KDirectory.h"
#include "KHttp.h"

#include "Reachability.h"
#include "pthread.h"

//¥˝ µœ÷
// bool isWifiNetWork()
// {
// 	Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
// 	if (r == nil || [r currentReachabilityStatus] != ReachableViaWiFi) 
// 		return false;
// 	else 
// 		return true;
// }
void Rstrchr(const char* src,char delimit,char* outFile)
{
	int i = strlen(src);
	if (!(*src))
	{
		return ;
	}
	strcpy(outFile,src);
	while (src[i-1])
	{
		if (strchr(src+(i-1),delimit))
		{
			outFile[i] = '\0';
			return;
		}
		else
		{
			i--;
		}
	}

    return;
}

void DownloadCallback(void *param, int percent, int pos, int filelen)
{
	DownloadPackage* downer = (DownloadPackage*)param;
	if (downer) 
	{
		downer->m_nFileLen = filelen;
		downer->ReflashPercent(percent, pos, filelen);
	}	
}

void* threadExcute(void* ptr)
{
	DownloadPackage* downer = (DownloadPackage*)ptr;

	if (downer) 
	{
		downer->DownloadThreadExcute();
	}

	return NULL;
}


//IMPLEMENT_CLASS(DownloadPackage, NDObject)

DownloadPackage::DownloadPackage():
m_pkHttp(0)
{	
	m_nFileLen = 0;
 	m_pkHttp = new KHttp;
 	m_pkHttp->setNotifyCallback(DownloadCallback, this, 1);
}

DownloadPackage::~DownloadPackage()
{
 	delete m_pkHttp;
}

void DownloadPackage::FromUrl(const char* url)
{
	m_strDownloadURL = url;
}

void DownloadPackage::ToPath(const char* path)
{
	m_strDownloadPath = path;
}

void DownloadPackage::DownloadThreadExcute()
{
 	if (m_strDownloadURL.empty() || m_strDownloadPath.empty()) 
 	{
 		DidDownloadStatus(DownloadStatusFailed);
 		return;
 	}
	char szTempDir[100] = {0};
 	Rstrchr(m_strDownloadPath.c_str(),'/',szTempDir); 
	string saveDir(szTempDir);

 	if (!KDirectory::isDirectoryExist(saveDir)) 
 	{
 		if (!KDirectory::createDir(saveDir))
 		{
 			DidDownloadStatus(DownloadStatusFailed);
 			return;
 		}
 	}	
 	
 	m_pkHttp->setTimeout(60 * 1000);
 	int nDoneLength = m_pkHttp->getHttpFile(m_strDownloadURL.c_str(),
		m_strDownloadPath.c_str(), 0);
 	
 	if (m_pkHttp->getStatusCode() == 404) 
 	{
 		DidDownloadStatus(DownloadStatusResNotFound);
 	}	
 	else if ((nDoneLength >= m_nFileLen) && (nDoneLength > 0)) 
 	{
 		DidDownloadStatus(DownloadStatusSuccess);
 	}
 	else 
 	{
 		DidDownloadStatus(DownloadStatusFailed);
 	}
 	
}

void DownloadPackage::Download()
{	
	pthread_t kPId = {0};
	pthread_create(&kPId, NULL, threadExcute, this);	
}