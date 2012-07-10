#pragma once

/*
封装的更新模块
Copyright(c) 1999-2012, TQ Digital Entertainment, All Rights Reserved
*/

#ifndef __NUPDATEFACTORY__HEAD__FILE__
#define __NUPDATEFACTORY__HEAD__FILE__
#include "NetFactory.h"
#include "TQzip.h"
#include "BaseType.h"
#include "IAsynTaskManager.h"

//本接口为更新的下载回调
class IUpdateEvent
{
public:
	enum ERROR_CODE{
		ERRCODE_NONE=0,//正常或成功
		ERRCODE_CONECTION_FAILED,//连接失败
		ERRCODE_CONECTION_SERVERERR,//服务器内部错误
		ERRCODE_FILE_SAVEFAIL,//文件保存失败
		ERRCODE_VERSION_LATEST,//已经是最新的版本
		ERRCODE_VERSION_NOPACKAT,//没有可更新的版本
		ERRCODE_UNCOMPRESS_FAILED//解压失败
	};
public:
	//函数：下载过程的回调
	//参数：dwSizeFile 总文件大小
	//参数：dwSideDownLoaded 已经下载的文件大小
	virtual void OnDownloadEvent(DWORD dwSizeFile,DWORD dwSideDownLoaded){};


	//函数：资源解压 注：只能解压框架自定义的资源包，资源包详看CTQZip
	//参数：nFileNum 资源包中的文件数
	//参数：nFileIndex 解压至第nFileIndex个文件
	//参数：pszFileName 正在解压的文件名
	virtual void OnUnCompress(int nFileNum,int nFileIndex,const char* pszFileName){};

	//函数：更新或下载操作结束时的回调
	virtual void CompleteUpdate(ERROR_CODE emErrCode){ };

	//函数：更新失败的回调
	//参数：emErrCode 错误编码
	//参数：pszErrMsg 错误提示
	virtual void OnError(ERROR_CODE emErrCode,const char* pszErrMsg){};
	~IUpdateEvent(){};
};
class HttpClientSocket;
class CUpdateFactory:public INetEvnet,public ITQZipEvent
{
public:
	enum UPDATE_MODE
	{
		UM_ASP,
		UM_STATIC,
	};
public:
	//函数：更新单实例引用
	static CUpdateFactory& sharedInstance();

	//函数：初始化更新配置 必须调用且只调一次
	//参数：pszServerUrl 传入更新服务器地址（HTTP URL）
	//参数：pszAppName 传入APP资源名称
	//参数：pszOutSourcePath 传入的是资源更新的路径
	//参数：pUpdateEvent  更新或下载的回调
	//返回值： true 表示成功初始化，false表示初始化失败
	bool Init(const char*pszServerUrl,const char* pszAppName,const char *pszOutSourcePath,IUpdateEvent *pUpdateEvent);

	//函数：更新模式
	//参数：emUpdateMode 更新的模式
	void SetUpdateMode(UPDATE_MODE emUpdateMode);

	//函数：判定是否有新版本
	//返回值： true 表示有版本要更新，false表示已经是最新版本
	bool CheckVersion();

	//函数：更新数据
	//返回值： true 表示更新成功完成，false表示更新失败
	bool Update(bool bInUIThread = true);

	//函数：下载数据包 注：bool Update()走的是正常更新流程 而本函数则下载数据包
	//参数：pszServerUrl  服务器下载地址
	//参数：pszSourcePath 下载的资源目录
	//参数：bUnCompress 是否要解压 只支持框架提供的压缩格式
	//参数：pDownloadEvent 
	//返回值： true 表示下载成功完成，false表示下载失败
	bool Download(const char*pszServerUrl,const char*pszSourcePath,bool bUnCompress,IUpdateEvent *pDownloadEvent,bool bInUIThread = true);
protected:
	//INetEvent接口方法
	virtual void OnData(Socket* pSocket, const char *buf, size_t n);
	virtual void OnConnect(Socket* pSocket);
	virtual void OnConnectFailed(Socket* pSocket);
	virtual void OnDisconnect(Socket* pSocket);
	virtual void OnDataComplete(Socket* pSocket);
	virtual const char*GetErrorMsg(IUpdateEvent::ERROR_CODE ecErro);
protected:
	//ITQZipEvent接口方法
	virtual void OnUnCompressEvent(bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName);
	void OnTQZipError(ERROR_CODE emErrCode,const char* pszErrMsg);
protected:
	void GetNewsversion(bool bInUIThread = true);
	void GetApplicationXml(bool bInUIThread = true);
	void GetPacketXml(bool bInUIThread = true);
protected:
	virtual void CheckDownloadBegine(const char*pszFilePath);
private:
	CUpdateFactory(void);
	~CUpdateFactory(void);
private:
	std::string m_strServerUrl;
	std::string m_strAppName;
	std::string m_strOutSorucePath;

	std::string m_strUpdatePacketUrl;//要下载文件的URL
	std::string m_strUpdatePacketName;//要下载文件的文件名
	DWORD m_dwUpdatePackeSize;//要下载文件的总大小（字节）
	std::string m_strPacketxmlUrl;//更新包的配置XML地址

	IUpdateEvent *m_pUpdateEvent;//更新用的回调
	DWORD m_nCurVersion;//当前本地版本
	DWORD m_dwSizeDownloaded;//已经下载的文件大小（字节）
	DWORD m_dwDownloadBegin;//断点下载前的文件大小（字节）
	bool m_bNeedUpdate;//是否需要更新
	bool m_bUnCompress;//是否需要解压

	HttpClientSocket* m_pSocket;
	bool m_bDataComplete;//文件是否下载结束（）

	DWORD m_nStatus;//当前的操作状态

	IUpdateEvent::ERROR_CODE m_ecErro;
	std::ofstream m_file;

	UPDATE_MODE m_emUpdateMode;
	CRITICAL_SECTION_ID	m_idCS;

};

#endif