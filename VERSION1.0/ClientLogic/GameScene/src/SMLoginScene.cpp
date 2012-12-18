//
//  SMLoginScene.cpp
//  SMYS
//
//  Created by user on 12-3-21.
//  Copyright 2012年 (网龙)DeNA. All rights reserved.
//

#include "SMLoginScene.h"
#include "NDDirector.h"
#include "ScriptGlobalEvent.h"
#include "ScriptInc.h"
//#include <iconv.h>
//#include "SimpleAudioEngine_objc.h"
#include "NDPath.h"
#include "SMUpdate.h"
#include "GameApp.h"
#include "NDUtility.h"
#include "sys/stat.h"
#include "SystemSetMgr.h"
#include "InstallSelf.h"
#include "NDBeforeGameMgr.h"
#include "NDTargetEvent.h"
#include "NDLocalXmlString.h"
#include "NDProfile.h"
#include "ScriptMgr.h"
#include <iostream>
#include <sstream>
#include "ScriptRegLua.h"
////////////////////////////////////////////////////////////

//--------------------//

#define UPDATE_ON		0	//0关闭下载，1开启下载
#define CACHE_MODE 		0	//发布模式//0关闭拷贝；1开启将资源拷贝至cache目录来访问

//--------------------//

#define TAG_INSTALL_SUCCESS			1
#define TAG_INSTALL_FAILED			2
#define TAG_TIMER_INIT				3
#define TAG_TIMER_GET_STATUS		4
#define	TAG_REQUEST_URL_ERROR		5
#define TAG_TIMER_DOWNLOAD_SUCCESS	6
#define TAG_TIMER_UPDATE			7	//
#define TAG_TIMER_CHECK_WIFI		8	// 检测WIFI
#define TAG_TIMER_UNZIP_SUCCESS     9
#define TAG_TIMER_CHECK_UPDATE      10  // 检测UPDATE
#define TAG_TIMER_CHECK_COPY        11  //
#define TAG_TIMER_FIRST_RUN         12  // 
#define TAG_TIMER_LOAD_RES_OK       13  // 装载文字和Lua完毕

//----------------------------------------------------------
//Update Layer 里
#define TAG_CTRL_PIC_BG					1	//背景图片控件tag
#define TAG_LABEL_PROMPT				4	//文字标签控件tag
#define TAG_CTRL_PROGRESS				2	//进度条控件tag
#define TAG_UPDATE_LAYER				(2000+167)	//层Tag

#define TAG_DLG_CONFIRM					100	//确认对话框tag

#define TAG_BTN_OK						101	//确定按钮
#define TAG_BTN_CANCEL					102	//取消按钮
#define TAG_LABEL_TIP					103	//文字标签
#define TAG_PIC_DLG_BG					12	//对话框背景

#define TAG_SPRITE_NODE					200	//

//----------------------------------------------------------
#define SZ_ERROR_01						"LOGIN_SZ_ERROR_01"			//"大版本更新,请重新下载最新游戏版本"
#define SZ_ERROR_02						"LOGIN_SZ_ERROR_02"			//"当前版本数据有误,请重新下载或者联系GM"
#define SZ_ERROR_03						"LOGIN_SZ_ERROR_03"			//"版本信息损坏，请重新下载或者联系GM"
#define SZ_ERROR_04						"LOGIN_SZ_ERROR_04"			//"抱歉,下载资源未找到,请联系GM"
#define SZ_ERROR_05						"LOGIN_SZ_ERROR_05"			//"下载失败,请检查网络链接或者重启设备尝试"
#define SZ_DOWNLOADING					"LOGIN_SZ_DOWNLOADING"		//"版本下载中……"
#define SZ_INSTALLING					"LOGIN_SZ_INSTALLING"		//"正在安装更新……"
#define SZ_WIFI_OFF						"LOGIN_SZ_WIFI_OFF"			//"必须下载更新包,但是未开启WIFI,是否继续？"
#define SZ_UPDATE_OFF					"LOGIN_SZ_UPDATE_OFF"		//"无法连接服务器,请检查网络"
#define SZ_FIRST_INSTALL                "LOGIN_SZ_FIRST_INSTALL"    //"首次运行,初始化配置中……"
#define SZ_CONNECT_SERVER               "LOGIN_SZ_CONNECT_SERVER"   //"连接服务器……"
#define SZ_SETUP						"LOGIN_SZ_SETUP"			//"配置中……"


#define SZ_UPDATE_URL					"192.168.19.169"//更新服务器的地址
#define SZ_DEL_FILE						"del.txt"//包含待删除文件路径的配置文件/CACHES目录下

#define SZ_MOBAGE_BG_PNG_PATH			"/res/image00/Res00/Load/mobage_bg.png"
#define SZ_UPDATE_BG_PNG_PATH			"/res/image00/Res00/Load/entry_bg.png"

////////////////////////////////////////////////////////////
//NSAutoreleasePool * globalPool = [[NSAutoreleasePool alloc] init];
IMPLEMENT_CLASS(CSMLoginScene, NDScene)

//===========================================================================
CSMLoginScene* CSMLoginScene::Scene( bool bShowEntry /*= false*/  )
{

	CSMLoginScene *scene = new CSMLoginScene;
    scene->Initialization();
    scene->SetTag(SMLOGINSCENE_TAG);
    
	if ( bShowEntry )
	{
		NDLocalXmlString::GetSingleton().LoadLoginString();//

		CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();

		NDUILayer * layer = new NDUILayer();
		layer->Initialization();
		layer->SetFrameRect(CCRectMake(0, 0, winSize.width, winSize.height));//不要硬编码！！
		scene->AddChild(layer);
		scene->m_pLayerOld = layer;
		
		NDPicturePool& pool		= *(NDPicturePool::DefaultPool());
		NDUIImage* imgBack	= new NDUIImage;
		imgBack->Initialization();
		imgBack->SetFrameRect(CCRectMake(0, 0, winSize.width, winSize.height));
#ifdef USE_MGSDK
    	NDPicture* pic = pool.AddPicture( NDPath::GetImgPath("Res00/Load/mobage_bg.png") );
#else
    	NDPicture* pic = pool.AddPicture( NDPath::GetImg00Path("Res00/Load/bg_load.png") );
#endif
    	if (pic) 
    	{
    	    imgBack->SetPicture(pic, true);
    	}
		layer->AddChild(imgBack);
		//layer->SetFrameRect( CCRectMake(winSize.width*0.0, winSize.height*0.0, winSize.width*0.7, winSize.height*0.225f));
		//layer->SetBackgroundColor( ccc4( 20,30,0,50) );

		scene->m_pTimer->SetTimer( scene, TAG_TIMER_FIRST_RUN,0.5f );
    }
	return scene;
}

//===========================================================================
CSMLoginScene::CSMLoginScene()
: m_bUpdOk(false)
, m_pLayerOld(NULL)
, m_pLayerUpdate(NULL)
, m_pTimer(NULL)
, m_pCtrlProgress(NULL)
, m_pLabelPromtp(NULL)
, m_iAccountID(0)
, m_iState(0)
, m_pLayerCheckWIFI(NULL)
{
}

//===========================================================================
CSMLoginScene::~CSMLoginScene()
{
    NDPicturePool::DefaultPool()->Recyle();
	if ( m_pTimer )
    {
    	delete m_pTimer;
    	m_pTimer = NULL;
    }
}

//===========================================================================
void CSMLoginScene::Initialization(void)
{
	NDScene::Initialization();
	//m_doucumentPath = NDPath::GetDocumentPath();
	m_cachPath = NDPath::GetCashesPath();
	m_savePath = m_cachPath + "supdate.zip";
	//m_resPath = NDPath::GetResPath();
	PackageCount = 0;
	m_pTimer = new NDTimer();
}

//===========================================================================
void CSMLoginScene::OnTimer( OBJID idTag )
{

	if ( idTag == TAG_TIMER_UPDATE ) 
	{
		if ( !rename( m_savePath.c_str(), m_savePath.c_str() ) )
		{
			if ( remove( m_savePath.c_str() ) )
			{ 
				m_pTimer->KillTimer(this, TAG_TIMER_UPDATE);
				return;
			}
		}     
		this->FromUrl(m_updateURL.c_str());
		this->ToPath(m_savePath.c_str()); 
		this->Download();
		m_pTimer->KillTimer(this, TAG_TIMER_UPDATE);
	}
	else if ( idTag == TAG_TIMER_DOWNLOAD_SUCCESS )
	{
		m_pTimer->KillTimer(this, TAG_TIMER_DOWNLOAD_SUCCESS);
        
		//下载成功后解压文件
		UnZipFile( m_savePath.c_str(), m_cachPath.c_str());
	}
    else if ( idTag == TAG_TIMER_UNZIP_SUCCESS )
	{
		m_pTimer->KillTimer(this, TAG_TIMER_UNZIP_SUCCESS);
		if ( remove(m_savePath.c_str()) )
		{
		    NDLog("delete:%s failed",m_savePath.c_str());//printf("删除压缩包:%s失败",m_savePath.c_str());
		    //return;
		}
        std::string szListFile = NDPath::GetCashesPath()+SZ_DEL_FILE;
		DeleteFileFromFile( szListFile );
    
		if(deqUpdateUrl.size()>0)
		{
		    deqUpdateUrl.pop_front();
		}
		PackageCount++;
		//查找下载队列
		if (deqUpdateUrl.size()>0)
		{
		    //定义保存路径
		    m_updateURL = *deqUpdateUrl.begin();
		    //m_savePath = [[NSString stringWithFormat:@"%s/update%d.zip", m_cachPath.c_str(), PackageCount] UTF8String];
		    m_pTimer->SetTimer( this, TAG_TIMER_UPDATE, 0.5f );
		    StartDownload();
		}
		else
		{
		    //跳转到启动界面
		    StartEntry();
		}
	}
	else if ( TAG_TIMER_CHECK_WIFI == idTag )
	{
		//如果检测没开启WIFI则不断检测//
    	if ( NDBeforeGameMgrObj.isWifiNetWork() )
    	{
			m_pTimer->KillTimer( this, TAG_TIMER_CHECK_WIFI );
			CloseConfirmDlg();
			StartUpdate();
    	}
	}
	else if ( TAG_TIMER_CHECK_UPDATE == idTag )
	{
        m_pTimer->KillTimer(this, TAG_TIMER_CHECK_UPDATE);
        ShowUpdateOff();
	}
	else if ( TAG_TIMER_CHECK_COPY == idTag )
	{
        int copyStatus = NDBeforeGameMgr::GetCopyStatus();
        switch (copyStatus) 
        {
            case -1:
                m_pTimer->KillTimer( this, TAG_TIMER_CHECK_COPY );
                //NSLog( @"Copy files error!" );
                exit(0);
                break;
            case 0:
                break;
            case 1:
                m_pTimer->KillTimer( this, TAG_TIMER_CHECK_COPY );
                NDBeforeGameMgrObj.doNDSdkLogin();
                ShowWaitingAni();
                break;
            default:
                break;
        }
	}
    else if ( TAG_TIMER_FIRST_RUN == idTag )
	{
		m_pTimer->KillTimer( this, TAG_TIMER_FIRST_RUN );
		CreateUpdateUILayer();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
		OnEvent_LoginOKNormal(m_iAccountID);
#else
#ifdef USE_MGSDK
		NDUIImage * pImage = (NDUIImage *)m_pLayerUpdate->GetChild( TAG_CTRL_PIC_BG);
		if ( pImage )
		{
			NDPicture * pPicture = new NDPicture;
			pPicture->Initialization( NDPath::GetUIImgPath( SZ_MOBAGE_BG_PNG_PATH ).c_str() );
			pImage->SetPicture( pPicture, true );
		}
#endif
#if CACHE_MODE == 1
    	if ( NDBeforeGameMgrObj.CheckFirstTimeRuning() )
        {
        	if ( m_pLabelPromtp )
            {
        		m_pLabelPromtp->SetText( NDCommonCString2(SZ_FIRST_INSTALL).c_str() );
        		m_pLabelPromtp->SetVisible( true );
                ShowWaitingAni();
#ifdef USE_MGSDK
        		m_pLabelPromtp->SetVisible( false );//Mobage的版本暂将文字绘在背景图上
#endif
            }
            m_pTimer->SetTimer( this, TAG_TIMER_CHECK_COPY, 0.5f );
        }
        else
#endif
        {
            NDBeforeGameMgrObj.doNDSdkLogin();
            ShowWaitingAni();
		}
#endif
    	//CreateUpdateUILayer();
		//NDBeforeGameMgrObj.CheckClientVersion(SZ_UPDATE_URL);
	}
	else if ( TAG_TIMER_LOAD_RES_OK == idTag )
	{
		m_pTimer->KillTimer( this, TAG_TIMER_LOAD_RES_OK );
		CloseWaitingAni();
		CloseUpdateUILayer();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		//if ( m_iAccountID == 0 )
		m_iAccountID = ScriptMgrObj.excuteLuaFuncRetN( "GetAccountID", "Login_ServerUI" );
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
#endif
		ScriptMgrObj.excuteLuaFunc( "ShowUI", "Entry", m_iAccountID );
		//    ScriptMgrObj.excuteLuaFunc("ProecssLocalNotification", "MsgLoginSuc");
	}
}

//==========================================================
//--Guosen 2012.8.7
//int     
//CSMLoginScene::OnProcess(int nPercent)
//{
//    CUIExp* pProcess = (CUIExp*)m_layer->GetChild(ID_LOADING_PROCESS);
//	if (!pProcess) {
//        return 0;
//    }
//    pProcess->SetProcess(nPercent);
//    return 0;
//}
//==========================================================
//--Guosen 2012.8.7
//int     
//CSMLoginScene::OnFail(const char* pszStrErr)
//{
//    return 0;
//}
//==========================================================
//--Guosen 2012.8.7
//int		
//CSMLoginScene::OnComplete(void)
//{
//    m_bUpdOk = true;
//    return 0; 
//}
//===========================================================================
// 开启更新
bool CSMLoginScene::StartUpdate()
{
	if ( deqUpdateUrl.empty() )
	{
		return false;
	}
	//请求第一个包
	std::string url = *deqUpdateUrl.begin();
	m_updateURL	= url;
	m_pTimer->SetTimer( this, TAG_TIMER_UPDATE, 0.5f );	
	StartDownload();
	return true;
}


//===========================================================================
//函数：解包过程的回调
//参数：bOpContinue 是否终止解包操作
//参数：nFileNum 要解包的总文件数
//参数：nFileIndex 要解包的当前文件索引
//参数：pszFileName 文件名，绝对路径
void CSMLoginScene::OnUnCompressEvent( bool &bOpContinue,int nFileNum,int nFileIndex,const char* pszFileName )
{
	int percent = (nFileIndex + 1) *100/ nFileNum;
	SetProgress( percent );
}

//===========================================================================
//函数：操作错误的回调
//参数：emErrCode 错误编码
//参数：pszErrMsg 错误提示
void CSMLoginScene::OnTQZipError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg)
{
	NDLog("OnTQZipError %s", pszErrMsg);
}

///////////////////////////////////////////////
//bool 
//CSMLoginScene::CheckClientVersion()
//{
//    int nCurVer = 0;
//	NSString *strIniPath = [NSString stringWithFormat:@"%s", NDPath::GetResPath("version.ini")];
//	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:strIniPath];
//	if (!stream)
//	{
//		return false;
//	}
//	//nCurVer = [stream readInt];
//    NDDataTransThread::DefaultThread()->Stop();
//    NDDataTransThread::ResetDefaultThread();
//    NDDataTransThread::DefaultThread()->Start("192.168.64.30", 9500);
//	if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
//	{
//		return false;
//	}
//	NDTransData data(_MSG_CLIENT_VERSION);
//	
//	int version = 1;
//	data << version;
//	NDDataTransThread::DefaultThread()->GetSocket()->Send(&data);
//
//}
//===========================================================================
/*void 
CSMLoginScene::OnDrawUI()
{
    (NDDirector::DefaultDirector())->ForceDraw();
}
*/
//===========================================================================
void 
CSMLoginScene::OnDownloadEvent(DWORD dwSizeFile,DWORD dwSideDownLoaded)
{
    float nProcess = (float)dwSideDownLoaded/(float)dwSizeFile;
    //ScriptMgrObj.excuteLuaFunc("OnDownloadEvent", "Login_Upd",int(nProcess*60));
}
//===========================================================================
void 
CSMLoginScene::OnUnCompress(int nFileNum,int nFileIndex,const char* pszFileName)
{
    //ScriptMgrObj.excuteLuaFunc("OnUnCompress", "Login_Upd");
}
//===========================================================================
void 
CSMLoginScene::CompleteUpdate(ISMUpdateEvent::ERROR_CODE emErrCode)
{
    //ScriptMgrObj.excuteLuaFunc("CompleteUpdate", "Login_Upd");
}
//===========================================================================
void 
CSMLoginScene::OnError(ISMUpdateEvent::ERROR_CODE emErrCode,const char* pszErrMsg)
{
	if(emErrCode == ISMUpdateEvent::ERRCODE_VERSION_LATEST){
        return;
    }
    //ScriptMgrObj.excuteLuaFunc("OnUpdError", "Login_Upd",pszErrMsg);
}

//===========================================================================
void CSMLoginScene::ReflashPercent(int percent, int pos, int filelen )
{
    /*
	if (m_label) 
	{
		//NSString *str = [NSString stringWithFormat:@"已下载：%d\%", percent];
		//m_label->SetText([str UTF8String]);
		char buff[100] = {0x00};
		sprintf(buff, "已下载：%d\%%", percent);
		m_label->SetText(buff);
		
		m_progressBar->SetCurrentStep(percent);
	}
    */ 
	SetProgress( percent );
}

//===========================================================================
void CSMLoginScene::DidDownloadStatus( DownloadStatus status )
{
	if (status == DownloadStatusResNotFound) 
	{
		//m_label->SetText( "抱歉，下载资源未找到，请联系GM" );
		if (m_pLabelPromtp)
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_04).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
			//m_pLabelPromtp->SetFontSize( 20 );
			//CCRect tRect = m_pLabelPromtp->GetFrameRect();
			//m_pLabelPromtp->SetFrameRect( CCRectMake( tRect.origin.x, tRect.origin.y, tRect.size.width*3, tRect.size.height*2));
			//m_pLabelPromtp->SetVisible( true );
		}
	}
	else if (status == DownloadStatusFailed)
	{
		if (m_pLabelPromtp)
		{
			//m_label->SetText( "下载失败，请检查网络链接或者重启设备尝试" );
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_05).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
			//m_pLabelPromtp->SetFontSize( 20 );
			//CCRect tRect = m_pLabelPromtp->GetFrameRect();
			//m_pLabelPromtp->SetFrameRect( CCRectMake( tRect.origin.x/2, tRect.origin.y, tRect.size.width*3, tRect.size.height*2));
			//m_pLabelPromtp->SetVisible( true );
		}
	}
	else 
	{
		//m_label->SetText("下载完成，正在进行安装升级，请稍候......");		
		m_pTimer->SetTimer( this, TAG_TIMER_DOWNLOAD_SUCCESS, 0.5f );
		StartInstall();
	}
}

//===========================================================================
//wt
// 初始化更新队列
void CSMLoginScene::InitDownload( std::string & szUpdatePath )
{
	deqUpdateUrl.push_back(szUpdatePath);
}

//++Guosen2012.8.7
void CSMLoginScene::ShowRequestError()
{
	NDUIDialog* dlg = new NDUIDialog();
	dlg->Initialization();
	dlg->SetTag(TAG_REQUEST_URL_ERROR);
	dlg->SetDelegate(this);
	dlg->Show(NDCommonCString2("Common_error"), NDCommonCString2("LOGIN_SZ_REQUEST_DOWNLOAD_FAIL"), NULL, NDCommonCString2("Common_Ok"), NULL);
}

//===========================================================================
//通过传递进的文件路径，获得待删除的文件路径，删除待删除的文件，删除传递进的文件
bool CSMLoginScene::DeleteFileFromFile( std::string & szDelListFile )
{
	std::ifstream	tmpFile;
	tmpFile.open( szDelListFile.c_str(), ios_base::in );
	if ( !tmpFile )
	{
		if ( tmpFile.is_open() )
			tmpFile.close();
		return false;
	}
	std::string  lineStr;
	while ( getline( tmpFile, lineStr ) )
	{
		std::string DelFile = m_cachPath + lineStr;
 		if ( remove( DelFile.c_str() ) )
		{
			NDLog( "删除文件失败：%s",DelFile.c_str() );
		}
	}
	tmpFile.close();
	remove( szDelListFile.c_str() );
	return true;
}

//===========================================================================
bool CSMLoginScene::CreateUpdateUILayer()
{
	if ( m_pLayerUpdate )
		return false;
	
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	NDUILayer *	pLayer	= new NDUILayer();
	if ( !pLayer )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() pLayer is null" );
		return false;
	}
	pLayer->Initialization();
	pLayer->SetFrameRect( CCRectMake(0, 0, winSize.width, winSize.height) );
	pLayer->SetTag( TAG_UPDATE_LAYER );
	AddChild(pLayer);
	m_pLayerUpdate		= pLayer;
	
	NDUILoad tmpUILoad;
	tmpUILoad.Load( "UpdateUI.ini", pLayer, this, CCSizeMake(0, 0) );
	
	m_pCtrlProgress	= (CUIExp*)pLayer->GetChild( TAG_CTRL_PROGRESS );
	if ( !m_pCtrlProgress )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() m_pCtrlProgress is null" );
		return false;
	}
	m_pCtrlProgress->SetProcess(0);
	m_pCtrlProgress->SetTotal(100);
	m_pCtrlProgress->SetStyle(2);
	m_pCtrlProgress->SetVisible(false);
	
	m_pLabelPromtp	= (NDUILabel*)pLayer->GetChild( TAG_LABEL_PROMPT );
	if ( !m_pLabelPromtp )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() m_pLabelPromtp is null" );
		return false;
	}
	if (m_pLabelPromtp) m_pLabelPromtp->SetVisible(false);
	if (m_pLayerOld) m_pLayerOld->SetVisible(false);
	return true;
}

//===========================================================================
void CSMLoginScene::CloseUpdateUILayer()
{
	if ( m_pLayerUpdate )
	{
		m_pLayerUpdate->RemoveFromParent(true);
		m_pLayerUpdate	= NULL;
		m_pCtrlProgress	= NULL;
		m_pLabelPromtp	= NULL;
	}
}

//===========================================================================
void CSMLoginScene::OnMsg_ClientVersion(NDTransData& data)
{
	bool bUpdate = false;
	
	int bLatest				= data.ReadByte();
	int bForceUpdate		= data.ReadByte();
	int FromVersion			= data.ReadInt();
	int ToVersion			= data.ReadInt();
	std::string UpdatePath	= data.ReadUnicodeString();
	
	if ( bForceUpdate )
	{
        CloseWaitingAni();
		//printf("请用户重新下载最新游戏版本");
		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_01).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
    		//m_pLabelPromtp->SetFontSize( 20 );
		}
		return ;
	}
	else if ( ( FromVersion ==  ToVersion ) &&  ( !bLatest ) )
	{
        CloseWaitingAni();
		//printf("当前版本数据有误,请重新下载或者联系GM");
		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_02).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
    		//m_pLabelPromtp->SetFontSize( 20 );
		}
		return ;
	}
	else if ( ( FromVersion == 0 ) && ( ToVersion == 0 ) )
	{
        CloseWaitingAni();
		//printf("版本信息损坏，请重新下载或者联系GM");
		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_03).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
    		//m_pLabelPromtp->SetFontSize( 20 );
		}
		return ;
	}
	else if ( ( FromVersion == ToVersion ) && (bLatest) )
	{
		//printf("当前版本是最新游戏版本");
		StartEntry();
		return;
	}
	else
		bUpdate = true;
	    
	NDLog("URL:%s",UpdatePath.c_str());
	deqUpdateUrl.push_back(UpdatePath);
	if (bUpdate)
	{
		if (bLatest) 
		{
			CloseWaitingAni();
			//if ( !NDBeforeGameMgrObj.isWifiNetWork() )//关闭掉坑爹的WIFI监测
			//{
			//	ShowCheckWIFIOff();
			//	m_pTimer->SetTimer( this, TAG_TIMER_CHECK_WIFI, 1.0f );
			//}
			//else
			{
				StartUpdate();
			}
		}
	}
}

//===========================================================================

void CSMLoginScene::OnEvent_LoginOKNormal( int iAccountID )
{
	m_iAccountID = iAccountID;
#ifdef USE_MGSDK
    if(m_pLayerUpdate)
    {
        NDUIImage * pImage = (NDUIImage *)m_pLayerUpdate->GetChild( TAG_CTRL_PIC_BG);
        if ( pImage )
        {
            NDPicture * pPicture = new NDPicture;
            std::string str = SZ_UPDATE_BG_PNG_PATH;
            pPicture->Initialization( NDPath::GetUIImgPath( str.c_str() ).c_str() );
            pImage->SetPicture( pPicture, true );
        }
    }
#endif
	
#if UPDATE_ON == 0
		CloseWaitingAni();
		StartEntry();
#endif
#if UPDATE_ON == 1
	const char*	pszUpdateURL	= SZ_UPDATE_URL;//ScriptMgrObj.excuteLuaFuncRetS( "GetUpdateURL", "Update" );//此时Lua脚本未加载……
	if ( !pszUpdateURL )
	{
		CloseWaitingAni();
		StartEntry();
		return;
	}
		
	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_CONNECT_SERVER).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
	if ( !NDBeforeGameMgrObj.CheckClientVersion( pszUpdateURL ) )
	{
		CloseWaitingAni();
		StartEntry();
	}
#endif
}

//---------------------------------------------------------------------------
void CSMLoginScene::OnEvent_LoginOKGuest( int iAccountID )
{
	OnEvent_LoginOKNormal( iAccountID );
}

//---------------------------------------------------------------------------
void CSMLoginScene::OnEvent_LoginOKGuest2Normal( int iAccountID )
{
	OnEvent_LoginOKNormal( iAccountID );
}

//---------------------------------------------------------------------------
void CSMLoginScene::OnEvent_LoginError( int iError )
{
    std::stringstream  tmpSS;
    tmpSS << "Error:" << iError;
	if ( m_pLabelPromtp )
    {
		m_pLabelPromtp->SetVisible( true );
		m_pLabelPromtp->SetText( tmpSS.str().c_str() );
		m_pLabelPromtp->SetVisible( true );
    }
}

//===========================================================================
void CSMLoginScene::StartDownload()
{
	if ( m_pLabelPromtp )
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_DOWNLOADING).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
	if ( m_pCtrlProgress )
	{
		m_pCtrlProgress->SetVisible( true );
	}
}

//---------------------------------------------------------------------------
void CSMLoginScene::StartInstall()
{
	if ( m_pLabelPromtp )
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_INSTALLING).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
	if ( m_pCtrlProgress )
	{
		m_pCtrlProgress->SetVisible( true );
	}
}
//---------------------------------------------------------------------------
void CSMLoginScene::SetProgress( int nPercent )
{
	NDLog("CSMLoginScene::SetProgress() nPercent:%d",nPercent);
	if ( m_pCtrlProgress )
	{
		m_pCtrlProgress->SetProcess( nPercent );
	}
}

//===========================================================================
void CSMLoginScene::StartEntry()
{
	WriteCon( "@@ CSMLoginScene::StartEntry()\r\n" );
	CCLOG( "@@ CSMLoginScene::StartEntry()\r\n" );

#if 1 //取完代码android又崩溃了，先还原代码.
	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_SETUP).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
	ShowWaitingAni();

	{
		WriteCon( "@@ NDLocalXmlString::LoadData()...\r\n" );
		TIME_SLICE("NDLocalXmlString::LoadData()");
		NDLocalXmlString::GetSingleton().LoadData();
	}

	{
		WriteCon( "@@ ScriptMgrObj.Load()...\r\n" );
		TIME_SLICE("ScriptMgrObj.Load()");
		ScriptMgrObj.Load(); //加载LUA脚本
	}

	ScriptMgrObj.excuteLuaFunc( "LoadData", "GameSetting" ); 
	CloseUpdateUILayer();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	//if ( m_iAccountID == 0 )
	m_iAccountID = ScriptMgrObj.excuteLuaFuncRetN( "GetAccountID", "Login_ServerUI" );
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
#endif

	ScriptMgrObj.excuteLuaFunc( "ShowUI", "Entry", m_iAccountID );
	//    ScriptMgrObj.excuteLuaFunc("ProecssLocalNotification", "MsgLoginSuc");

#else //多线程不会有什么好处，反而是崩溃和不稳定，
	  //实际上网络线程和控制台线程都是多余的！单线程足够了！
	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_SETUP).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
	ShowWaitingAni();
	NDLocalXmlString::GetSingleton();
	ScriptMgrObj;
	pthread_t pid;
	pthread_create(&pid, NULL, CSMLoginScene::LoadTextAndLua, (void*)this);	
#endif

	CCLOG( "@@ CSMLoginScene::StartEntry() -- done.\r\n" );
}

//===========================================================================
void CSMLoginScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog->GetTag() == TAG_DLG_CONFIRM)
	{
    	NDBeforeGameMgrObj.doNDSdkLogin();
	}
}

//===========================================================================
bool CSMLoginScene::OnTargetBtnEvent( NDUINode * uiNode, int targetEvent )
{
	int	iTag	= uiNode->GetTag();
	if ( TE_TOUCH_BTN_CLICK == targetEvent )
	{
		if ( TAG_BTN_OK == iTag ) 
		{
			CloseConfirmDlg();
			StartUpdate();
		}
		else if ( TAG_BTN_CANCEL == iTag ) 
		{
			exit(0);
		}
	}
	return true;
}



//===========================================================================
bool CSMLoginScene::CreatConfirmDlg( const char * szTip )
{
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	NDUILayer *	pLayer	= new NDUILayer();
	if ( !pLayer )
		return false;
	pLayer->Initialization();
	pLayer->SetFrameRect( CCRectMake(0, 0, winSize.width, winSize.height) );
	pLayer->SetTag( TAG_DLG_CONFIRM );
	AddChild(pLayer);	
	
	NDUILoad tmpUILoad2;
	tmpUILoad2.Load( "ShowYesOrNoDlg.ini", pLayer, this, CCSizeMake(0, 0) );
	
	NDUILabel * pLabelTip	= (NDUILabel*)pLayer->GetChild( TAG_LABEL_TIP );
	if ( pLabelTip && szTip )
	{
		pLabelTip->SetText( szTip );
	}
	return true;
}
void CSMLoginScene::CloseConfirmDlg()
{
	RemoveChild( TAG_DLG_CONFIRM, true );
}

//===========================================================================
void CSMLoginScene::UnzipPercent(int nFileNum,int nFileIndex)
{    
    int nPercent = 100*(nFileIndex+1)/nFileNum;
    SetProgress( nPercent );
}

void CSMLoginScene::UnzipStatus(bool bResult)
{
	if (!bResult) 
    {
        NDLog("UnZipFile:%s failed",m_savePath.c_str());
        //return;
    }
	m_pTimer->SetTimer( this, TAG_TIMER_UNZIP_SUCCESS, 0.5f );	
}

//===========================================================================
//显示等待的转圈圈动画
void CSMLoginScene::ShowWaitingAni()
{
	CUISpriteNode * pNode = (CUISpriteNode *)GetChild(TAG_SPRITE_NODE);
	if ( pNode )
	{
		return;
	}
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();	
	CUISpriteNode *node = new CUISpriteNode;
	node->Initialization();
	node->ChangeSprite(NDPath::GetAniPath("busy.spr").c_str());
	node->SetTag( TAG_SPRITE_NODE );
	node->SetFrameRect(CCRectMake(0, 0, winSize.width, winSize.height));
	AddChild(node);
}
void CSMLoginScene::CloseWaitingAni()
{
	RemoveChild( TAG_SPRITE_NODE, true );
}

//===========================================================================
//显示检测WIFI失败对话框
void CSMLoginScene::ShowCheckWIFIOff()
{
	//CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	//
	//NDUILayer *	pLayer	= new NDUILayer();
	//if ( !pLayer )
	//	return;
	//pLayer->Initialization();
	//pLayer->SetFrameRect( CCRectMake(0, 0, winSize.width, winSize.height) );
	//AddChild(pLayer);
	//m_pLayerCheckWIFI = pLayer;
	//NDUILoad tmpUILoad;
	//tmpUILoad.Load( "CheckWIFIDlg.ini", pLayer, this, CCSizeMake(0, 0) );
	CreatConfirmDlg( NDCommonCString2(SZ_WIFI_OFF).c_str() );
	m_iState = 1;
}

//显示更新联接失败对话框
void CSMLoginScene::ShowUpdateOff()
{
	CreatConfirmDlg( NDCommonCString2(SZ_UPDATE_OFF).c_str() );
	m_iState = 2;
}

//装载文本和Lua//多线程
void * CSMLoginScene::LoadTextAndLua( void * pPointer )
{
	if ( pPointer )
	{
		CSMLoginScene * pScene = (CSMLoginScene*)pPointer;
		NDLocalXmlString::GetSingleton().LoadData();
		//ScriptMgrObj.Load();//
		ScriptMgrObj.excuteLuaFunc( "LoadData", "GameSetting" ); 
		pScene->m_pTimer->SetTimer( pScene, TAG_TIMER_LOAD_RES_OK,0.05f );
	}
	return pPointer;
}
