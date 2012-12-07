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

#include "Reachability.h"
#include "pthread.h"

//´ýÊµÏÖ
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
		downer->m_fileLen = filelen;
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

DownloadPackage::DownloadPackage()
{	
	m_fileLen = 0;
 	m_http = new KHttp();
 	m_http->setNotifyCallback(DownloadCallback, this, 1);
}

DownloadPackage::~DownloadPackage()
{
 	delete m_http;
}

void DownloadPackage::FromUrl(const char* url)
{
	m_url = url;
}

void DownloadPackage::ToPath(const char* path)
{
	m_path = path;
}

void DownloadPackage::DownloadThreadExcute()
{
 	if (m_url.empty() || m_path.empty()) 
 	{
 		DidDownloadStatus(DownloadStatusFailed);
 		return;
 	}
	char tmpDir[100];
	memset(tmpDir,0,100);
 	Rstrchr(m_path.c_str(),'/',tmpDir); 
	string saveDir(tmpDir);
 	if (!KDirectory::isDirectoryExist(saveDir)) 
 	{
 		if (!KDirectory::createDir(saveDir))
 		{
 			DidDownloadStatus(DownloadStatusFailed);
 			return;
 		}
 	}	
 	
 	m_http->setTimeout(60 * 1000);
 	int donelen = m_http->getHttpFile(m_url.c_str(), m_path.c_str(), 0);
 	
 	if (m_http->getStatusCode() == 404) 
 	{
 		DidDownloadStatus(DownloadStatusResNotFound);
 	}	
 	else if ((donelen >= m_fileLen)&& (donelen>0)) 
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
	pthread_t pid;
	pthread_create(&pid, NULL, threadExcute, this);	
}

