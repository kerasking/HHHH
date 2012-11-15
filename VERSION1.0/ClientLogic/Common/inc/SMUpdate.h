#pragma once

/*
 Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
 */

#ifndef __SMUPDATE__HEAD__FILE__
#define __SMUPDATE__HEAD__FILE__
//#include <NetFactory.h>
//#include <TQzip.h>
#include "BaseType.h"
//#include <IAsynTaskManager.h>
//#include "NDTimer.h"

class ISMUpdateEvent
{
public:
	enum ERROR_CODE{
		ERRCODE_NONE=0,
		ERRCODE_CONECTION_FAILED,
		ERRCODE_CONECTION_SERVERERR,
		ERRCODE_FILE_SAVEFAIL,
		ERRCODE_VERSION_LATEST,
		ERRCODE_VERSION_NOPACKAT,
		ERRCODE_UNCOMPRESS_FAILED
	};
public:
	virtual void OnDownloadEvent(DWORD dwSizeFile,DWORD dwSideDownLoaded){};
    
	virtual void OnUnCompress(int nFileNum,int nFileIndex,const char* pszFileName){};
    
	virtual void CompleteUpdate(ERROR_CODE emErrCode){ };
    
	virtual void OnError(ERROR_CODE emErrCode,const char* pszErrMsg){};
	~ISMUpdateEvent(){};
};

enum UPDATE_PROCESS
{
    UPDATE_PROCESS_NONE=0,
    UPDATE_PROCESS_GET_CHECK_APPXML,
    UPDATE_PROCESS_GET_CHECK_VERTXT,
    UPDATE_PROCESS_GETPACK_XML,
    UPDATE_PROCESS_UPDATE_DOWNLOAD,
    UPDATE_PROCESS_DOWNLOAD,
};

class HttpClientSocket;
class CSMUpdate //:public INetEvnet,public ITQZipEvent//,public ITimerCallback
{
public:
	enum UPDATE_MODE
	{
		UM_ASP,
		UM_STATIC,
	};
public:
	static CSMUpdate& sharedInstance();
	bool Init(const char*pszServerUrl,const char* pszAppName,const char *pszOutSourcePath,ISMUpdateEvent *pUpdateEvent);
    
	void SetUpdateMode(UPDATE_MODE emUpdateMode);
    
	bool CheckVersion();
    
    int  GetVersion(const char* pszResPath);
	bool Update();
	bool Download(const char*pszServerUrl,const char*pszSourcePath,bool bUnCompress,ISMUpdateEvent *pDownloadEvent,bool bInUIThread = true);
    
    void SetUpdatePackName(const char* pszPackName);
protected:
	#if 0
virtual void OnData(Socket* pSocket, const char *buf, size_t n);
	virtual void OnConnect(Socket* pSocket);
	virtual void OnConnectFailed(Socket* pSocket);
	virtual void OnDisconnect(Socket* pSocket);
	virtual void OnDataComplete(Socket* pSocket);
#endif
	virtual const char*GetErrorMsg(ISMUpdateEvent::ERROR_CODE ecErro);
protected:
	virtual void OnUnCompressEvent(bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName);
	//void OnTQZipError(ERROR_CODE emErrCode,const char* pszErrMsg);
protected:
	void GetNewsversion(bool bInUIThread = true);
	void GetApplicationXml(bool bInUIThread = true);
	void GetPacketXml(bool bInUIThread = true);
    bool StartDownload();
protected:
	virtual void CheckDownloadBegine(const char*pszFilePath);
    
public:
    void Process(void);
    
private:
    void SetUpdateProcess(UPDATE_PROCESS eProcess);
    
private:
	CSMUpdate(void);
	~CSMUpdate(void);
    
private:
    UPDATE_PROCESS m_eProcess;
	std::string m_strServerUrl;
	std::string m_strAppName;
	std::string m_strOutSorucePath;
    
	std::string m_strUpdatePacketUrl;
	std::string m_strUpdatePacketName;
	DWORD m_dwUpdatePackeSize;
	std::string m_strPacketxmlUrl;
    
	ISMUpdateEvent *m_pUpdateEvent;
	DWORD m_nCurVersion;
	DWORD m_dwSizeDownloaded;
	DWORD m_dwDownloadBegin;
	bool m_bNeedUpdate;
	bool m_bUnCompress;
    
	HttpClientSocket* m_pSocket;
	bool m_bDataComplete;
    
	DWORD m_nStatus;
    
	ISMUpdateEvent::ERROR_CODE m_ecErro;
	std::ofstream m_file;
    
	UPDATE_MODE m_emUpdateMode;
	//CRITICAL_SECTION_ID	m_idCS;
};

#endif