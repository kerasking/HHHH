//
//  SMLoginScene.h
//  SMYS
//
//  Created by user on 12-3-21.
//  Copyright 2012年 (网龙)DeNA. All rights reserved.
//

#ifndef SMYS_SMLoginScene_h
#define SMYS_SMLoginScene_h


#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUIlayer.h"
#include "NDTimer.h"
#include "NDUILoad.h"
#include "UIExp.h"
#include "BattleMgr.h"
#include "NDColorPool.h"
#include "NDDataPersist.h"
#include "NDLocalXmlString.h"
#include "ItemMgr.h"
#include "cpLog.h"
#include "NDUtility.h"
#include "FarmMgr.h"
//#include "BattleFieldMgr.h"
#include "SMUpdate.h"
#include "DownloadPackage.h"
#include "NDTransData.h"
#include "NDUIDialog.h"
#include "ZipUnZip.h"

#define ID_LOADING_PROCESS (90)
class CSMLoginScene
: public NDScene
, public DownloadPackageDelegate
, public ITimerCallback
//, public ISMUpdateEvent
//, public ITQZipEvent
, public NDUITargetDelegate
, public NDUIDialogDelegate
, public CZipUnZip
{
	DECLARE_CLASS(CSMLoginScene)
	
	CSMLoginScene();
	~CSMLoginScene();
	
	static CSMLoginScene* Scene( bool bShowEntry = false );//参数是否显示进入页面，
	
public:
	void Initialization(); override
	
public:// ISMUpdateEvent
	virtual void OnDownloadEvent(DWORD dwSizeFile,DWORD dwSideDownLoaded);
	virtual void OnUnCompress(int nFileNum,int nFileIndex,const char* pszFileName);
	virtual void CompleteUpdate(ISMUpdateEvent::ERROR_CODE emErrCode);
	virtual void OnError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg);
	virtual void UnzipPercent(int nFileNum,int nFileIndex);
    virtual void UnzipStatus(bool bResult);
    bool StartUpdate();
    //bool CheckClientVersion();//--Guosen 2012.8.7//在"NDBeforeGameMgr"里
    
protected:// ITQZipEvent
	virtual void OnUnCompressEvent(bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName);
	void OnTQZipError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg);

public://NDUIDialogDelegate
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
private:
    virtual void OnTimer(OBJID idTag);
	
public:// DownloadPackageDelegate//++Guosen 2012.8.7
	virtual void ReflashPercent( DownloadPackage* downer, int percent, int pos, int filelen ); override
	virtual void DidDownloadStatus( DownloadPackage* downer, DownloadStatus status ); override
	
public:
    //virtual int     OnProcess(int nPercent); //更新进度反馈//--Guosen 2012.8.7
    //virtual int     OnFail(const char* pszStrErr);//更新失败//--Guosen 2012.8.7
    //virtual int		OnComplete(void); //更新完成//--Guosen 2012.8.7
    
public://NDUITargetDelegate
	virtual bool OnTargetBtnEvent( NDUINode * uiNode, int targetEvent ); override
	
private:
    bool			m_bUpdOk;
    
public:// twt
    typedef deque<string> DEQSTR;
    DEQSTR deqUpdateUrl;
    vector<string> split(std::string& src, std::string delimit);
    std::string trim(std::string &s);
    std::string m_savePath, m_updateURL,m_doucumentPath,m_resPath,m_cachPath;
    void InitDownload( std::string & szUpdatePath );
    int  PackageCount ;
    bool ReadFile( const char* file, int begin, int end, char* buf );
    
public:
    //++Guosen
    void ShowRequestError();
	bool DeleteFileFromFile( std::string & szListFile );
		
	// 创建更新界面
	bool CreateUpdateUILayer();
	
	// 关闭更新界面
	void CloseUpdateUILayer();
	
	//响应"_MSG_CLIENT_VERSION"消息 
	void OnMsg_ClientVersion(NDTransData& data);
	
	void OnEvent_LoginOKNormal( int iAccountID );
	void OnEvent_LoginOKGuest( int iAccountID );
	void OnEvent_LoginOKGuest2Normal( int iAccountID );
	void OnEvent_LoginError( int iError );
	
	void StartDownload();
	void StartInstall();
	void StartEntry();
	void SetProgress( int nPercent );
	
	//创建确认对话框
	bool CreatConfirmDlg( const char * szTip );
	void CloseConfirmDlg();
	
	//
	void ShowCheckWIFIOff();
	//
	void ShowUpdateOff();
	
protected:
	void ShowWaitingAni();
	void CloseWaitingAni();
protected:
	NDUILayer *		m_pLayerOld; //旧的登陆界面
    NDUILayer *		m_pLayerUpdate;
    NDTimer *		m_pTimer;
	CUIExp *		m_pCtrlProgress;
	NDUILabel *		m_pLabelPromtp;
	int				m_iAccountID;
	int				m_iState;//
    NDUILayer *		m_pLayerCheckWIFI;
};
#endif
