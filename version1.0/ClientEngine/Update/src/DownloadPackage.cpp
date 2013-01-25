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

#include "pthread.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>
#include <sys/stat.h>

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif

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
	DownloadPackage* pkDownloader = (DownloadPackage*)ptr;

	if (pkDownloader) 
	{
		pkDownloader->DownloadThreadExcute();
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
		LOGERROR("DownloadStatusFailed!!");
 		DidDownloadStatus(DownloadStatusResNotFound);
 		return;
 	}

	LOGD("Download path is %s,Download URL is %s",
		m_strDownloadPath.c_str(),m_strDownloadURL.c_str());

	char szTempDir[100] = {0};
 	Rstrchr(m_strDownloadPath.c_str(),'/',szTempDir); 
	string strSaveDir(szTempDir);

 	if (!KDirectory::isDirectoryExist(strSaveDir)) 
 	{
 		if (!KDirectory::createDir(strSaveDir))
 		{
			LOGERROR("Create dir failed",strSaveDir.c_str());
 			DidDownloadStatus(DownloadStatusFailed);
 			return;
 		}
 	}		
 	m_pkHttp->setTimeout(60 * 1000);
	//获取已经下载文件的大小,如果已经存在，则进行续传
	m_nFileLen = 0;
    int startpos = GetFileSize(m_strDownloadPath.c_str());
	LOGD("Download startpos is %d",startpos);
 	int nDoneLength = m_pkHttp->getHttpFile(m_strDownloadURL.c_str(),
		m_strDownloadPath.c_str(), startpos);
   if (startpos >0 && m_pkHttp->getStatusCode() == 416)
   {
	   LOGD("already Download succeeded ,to unzip file!");
	   DidDownloadStatus(DownloadStatusSuccess);
	   return ;
   }
	//网络连接失败,进行重新连接尝试
	int nReconnectCount = RECONNECTCOUNT;
	if (nDoneLength == -1 || ((nDoneLength < m_nFileLen) && (nDoneLength > 0)))
	{
		while (nReconnectCount)
		{
			nReconnectCount--;
			sleep(10000);
			m_nFileLen = 0;
			startpos = GetFileSize(m_strDownloadPath.c_str());
			nDoneLength = m_pkHttp->getHttpFile(m_strDownloadURL.c_str(),
				m_strDownloadPath.c_str(), startpos);
			if ((nDoneLength >= m_nFileLen) && (m_nFileLen > 0))
			{
				break;
			}
		}
	}
	LOGD("Download length is %d,File length is %d",nDoneLength,m_nFileLen);
 	if (m_pkHttp->getStatusCode() == 404) 
 	{
		LOGERROR("Download DownloadStatusResNotFound!");
 		DidDownloadStatus(DownloadStatusResNotFound);
 	}	
 	else if ((nDoneLength >= m_nFileLen) && (nDoneLength > 0)) 
 	{
		LOGD("Download succeeded!");
 		DidDownloadStatus(DownloadStatusSuccess);
 	}
 	else 
 	{
		LOGERROR("DownloadStatusFailed,Status code is %d",m_pkHttp->getStatusCode());
 		DidDownloadStatus(DownloadStatusFailed);
 	}
 	
}

void DownloadPackage::Download()
{
	LOGD("Entry Download");
	pthread_t kPId = {0};
	pthread_create(&kPId, NULL, threadExcute, this);	
}

int DownloadPackage::GetFileSize(const char* filepath)
{
	//int size = 0;
  //  #ifdef WIN32
	FILE* file = fopen(filepath, "rb");
	if(file)
	{
		fseek(file, 0L, SEEK_END);
		return ftell(file); 
	}
	return 0;
#if 0

 #ifdef WIN32
if (file)
	{
		size = filelength(fileno(file));
		fclose(file);
		return size;
	}
	#else
		struct stat info;  
		stat(filepath, &info);  
		size = info.st_size;  
		return size;
	#endif
#endif

}