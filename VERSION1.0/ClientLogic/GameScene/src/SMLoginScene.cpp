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
//#include "SimpleAudioEngine_objc.h"
#include "NDPath.h"
#include "SMUpdate.h"
#include "GameApp.h"
//#include "NDUtility.h"
#include "NDUtil.h"
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
#include "ObjectTracker.h"
#include "CCPlatformConfig.h"
#include "NDUIProgressBar.h"
#include "TQPlatform.h"
#include "UsePointPls.h"
#include "StringConvert.h"
#include "NDJsonReader.h"
#include "../CocosDenshion/include/SimpleAudioEngine.h"

using namespace CocosDenshion;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include <android/log.h>
#include "android/jni/JniHelper.h"

#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGERROR(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#else
#define  LOG_TAG    "DaHuaLongJiang"
#define  LOGD(...)
#define  LOGERROR(...)
#endif
////////////////////////////////////////////////////////////

//--------------------//

#define UPDATE_TIP_TEXT_ANDROID 0x7f080039	///< 安卓解壓介面提示文字，對應安卓String.xml里的unzip_text 郭浩

#define UPDATE_ON		1	//0关闭下载，1开启下载
#define CACHE_MODE 		1  //发布模式//0关闭拷贝；1开启将资源拷贝至cache目录来访问
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
#define TAG_TIMER_CHECK_LOGIN_COPY  14
#define TAG_TIMER_LAZY_SEND_LOGIN_EVENT  15

//----------------------------------------------------------
//Update Layer 里
#define TAG_CTRL_PIC_BG					1	//背景图片控件tag
#define TAG_LABEL_PROMPT				4	//文字标签控件tag
#define TAG_CTRL_PROGRESS				2	//进度条控件tag
#define TAG_UPDATE_LAYER				(2000 + 167)	//层Tag

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
	CSMLoginScene* pkScene = new CSMLoginScene;
    pkScene->Initialization();
    pkScene->SetTag(SMLOGINSCENE_TAG);

	///< 給湯自勤哥展示用法……
// 	NDJsonReader kReader;
// 	kReader.readJsonFile("assets/conf.json");
// 
// 	string strID = kReader.readData("app_id");

	//LOGD("strID = %s",strID.c_str());
    
	if ( bShowEntry )
	{
		if (NDLocalXmlString::GetSingleton().LoadLoginString())
		{
			pkScene->setIsLoadLocalString(true);
		}
		SimpleAudioEngine::sharedEngine()->setMusicStream(true);
		SimpleAudioEngine::sharedEngine()->raiseMusicStream();
        
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
		CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();

		NDUILayer* pkLayer = new NDUILayer();

		pkLayer->Initialization();
		pkLayer->SetFrameRect(CCRectMake(0, 0, kWinSize.width, kWinSize.height));
		pkScene->AddChild(pkLayer);
		pkScene->m_pLayerOld = pkLayer;

		NDPicturePool& kPool = *(NDPicturePool::DefaultPool());
		NDUIImage* pkBackgroundImage = new NDUIImage;

		ccColor4B kColor = {100,100,100,255};

		pkScene->m_pkProgressTextLabel = new NDUILabel();
		pkScene->m_pkProgressTextLabel->Initialization();
		pkScene->m_pkProgressTextLabel->SetRenderTimes(1);
		pkScene->m_pkProgressTextLabel->SetTag(0);
		pkScene->m_pkProgressTextLabel->SetFontSize(15);
		pkScene->m_pkProgressTextLabel->SetFontColor(kColor);

		pkBackgroundImage->Initialization();

		NDUIImage* pkUILoadingImage = 0;
		NDPicture* pkLoadingPic = 0;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		NDPicture* pkPicture = kPool.AddPicture( NDPath::GetImg00Path("Res00/Load/Unzipping.png") );
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		NDPicture* pkPicture = kPool.AddPicture( NDPath::GetImg00Path("Res00/Load/Unzipping.png") );
#endif
		if (pkPicture)
		{
			pkBackgroundImage->SetPicture(pkPicture, true);
        }
        
        CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
        pkBackgroundImage->SetFrameRect( CCRectMake(0, 0, winSize.width, winSize.height ));
        
        pkLayer->AddChild(pkBackgroundImage);
#endif

		CCLog( "@@login01: open CSMLoginScene\r\n" );
		
		LOGD("TAG_TIMER_FIRST_RUN is register");
		pkScene->m_pTimer->SetTimer( pkScene, TAG_TIMER_FIRST_RUN,0.5f );
    }
	return pkScene;
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
, m_bIsLoadingLocalString(false)
, m_pkProgressTextLabel(0)
{
	INC_NDOBJ_RTCLS

	WriteCon( "%08X: CSMLoginScene::CSMLoginScene()\r\n", this);
}

//===========================================================================
CSMLoginScene::~CSMLoginScene()
{
	DEC_NDOBJ_RTCLS
   
	WriteCon( "%08X: CSMLoginScene::~CSMLoginScene()\r\n", this);

   	SAFE_DELETE( m_pTimer );
	//SAFE_DELETE(m_pkProgressTextLabel);

	NDDirector::DefaultDirector()->Recyle();
}

//===========================================================================
void CSMLoginScene::Initialization(void)
{
	NDScene::Initialization();
	//m_doucumentPath = NDPath::GetDocumentPath();
	m_strCachePath = NDPath::GetCashesPath();
	//m_strSavePath = m_strCachePath + "update.zip";
	//m_resPath = NDPath::GetResPath();
	PackageCount = 0;
	m_pTimer = new NDTimer();
}

void clearSplash()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
                                       "clearSplash",
                                       "()V"))
    {
        t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void notifyProcess(int nPercent)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    JniMethodInfo methodInfo;
    if (JniHelper::getStaticMethodInfo(methodInfo, "org/DeNA/DHLJ/DaHuaLongJiang", "drawText",
                                       "(I)V"))
    {
        methodInfo.env->CallStaticVoidMethod(methodInfo.classID, methodInfo.methodID, nPercent);
        
        methodInfo.env->DeleteLocalRef(methodInfo.classID);
    }
#endif
}

//===========================================================================
void CSMLoginScene::OnTimer( OBJID idTag )
{
	/*
	static bool bFirst = true;

	if (bFirst)
	{
		LOGD("Entry First OnTimer");
		//idTag = TAG_TIMER_UPDATE;
		bFirst = false;
	}
   */
	if ( idTag == TAG_TIMER_UPDATE ) 
	{
		LOGD("TAG_TIMER_UPDATE process entry");
        /*
		if ( !rename( m_strSavePath.c_str(), m_strSavePath.c_str() ) )
		{
			if ( remove( m_strSavePath.c_str() ) )
			{ 
				m_pTimer->KillTimer(this, TAG_TIMER_UPDATE);
				return;
			}
		}
		*/
        //重新设置m_SavePath的值，保存本地的文件名与服务器上下载名保持一致
		char szUpdateURL[100] = {0};
		snprintf(szUpdateURL,sizeof(szUpdateURL),"%s",m_strUpdateURL.c_str());
		char* szTempFile = GetPathFileName(szUpdateURL,'/');
        if (szTempFile)
        {
			m_strSavePath = m_strCachePath + szTempFile;
        }
		else
			return;
		LOGD("m_strUpdateURL is %s,m_strSavePath is %s",m_strUpdateURL.c_str(),m_strSavePath.c_str());
        
		FromUrl(m_strUpdateURL.c_str());
		ToPath(m_strSavePath.c_str()); 
		Download();
		m_pTimer->KillTimer(this, TAG_TIMER_UPDATE);
	}
	else if ( idTag == TAG_TIMER_DOWNLOAD_SUCCESS )
	{
		m_pTimer->KillTimer(this, TAG_TIMER_DOWNLOAD_SUCCESS);

		LOGD("Entry TAG_TIMER_DOWNLOAD_SUCCESS process.");
		UnZipFile( m_strSavePath.c_str(), m_strCachePath.c_str());
	}
    else if ( idTag == TAG_TIMER_UNZIP_SUCCESS )
	{
		m_pTimer->KillTimer(this, TAG_TIMER_UNZIP_SUCCESS);
		if ( remove(m_strSavePath.c_str()) )
		{
		    NDLog("delete:%s failed",m_strSavePath.c_str());
		    //return;
		}
        std::string szListFile = NDPath::GetCashesPath() + SZ_DEL_FILE;
		DeleteFileFromFile( szListFile );
    
		if(kDeqUpdateUrl.size() > 0)
		{
		    kDeqUpdateUrl.pop_front();
			m_CurDownNum++;
		}

		PackageCount++;
		//查找下载队列
		if (kDeqUpdateUrl.size() > 0)
		{
		    //定义保存路径
		    m_strUpdateURL = *kDeqUpdateUrl.begin();
		    //m_savePath = [[NSString stringWithFormat:@"%s/update%d.zip", m_cachPath.c_str(), PackageCount] UTF8String];
			//重新设置m_SavePath的值，保存本地的文件名与服务器上下载名保持一致
			/*
			char szUpdateURL[100] = {0};
			snprintf(szUpdateURL,sizeof(szUpdateURL),"%s",m_strUpdateURL.c_str());
			char* szTempFile = GetPathFileName(szUpdateURL,'/');
			if (szTempFile)
			{
				m_strSavePath = m_strCachePath + szTempFile;
			}
			else
				return;
			*/
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
        int nCopyStatus = NDBeforeGameMgr::GetCopyStatus();
        switch (nCopyStatus) 
        {
            case -1:
				{
					m_pTimer->KillTimer( this, TAG_TIMER_CHECK_COPY );
					LOGERROR("Copy files error!");
					exit(0);
				}
                break;
            case 0:
                break;
            case 100:
				{
					if (!m_bIsLoadingLocalString)
					{
						NDLocalXmlString::GetSingleton().LoadLoginString();
						m_bIsLoadingLocalString = true;
					}

					CCImage::changeSystemFont(false);
					LOGD("Copy files succeeded!");
					CCDirector::sharedDirector()->setGLDefaultValues();
					m_pTimer->KillTimer( this, TAG_TIMER_CHECK_COPY );
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
					m_pkProgressTextLabel->SetVisible(false);
					NDBeforeGameMgrObj.doNDSdkLogin();
					ShowWaitingAni();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
                    notifyProcess(100);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
					usleep(200);
#endif
					OnProcessUpdate();
				}
                break;
            default:
				{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
					CCString* pstrString = NULL;
					notifyProcess (nCopyStatus);
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
					CCString* pstrString = CCString::stringWithFormat("解壓資源……已經解壓了%d%%",nCopyStatus);

					CCSize kTextSize = getStringSize(pstrString->getCString(), 20 * FONT_SCALE);
					CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();

					m_pkProgressTextLabel->SetFrameRect(CCRectMake(kWinSize.width / 2.0f - kTextSize.width / 3.0f,
						kWinSize.height - kTextSize.height * 1.1f, kTextSize.width, kTextSize.height));

					if(pstrString)
						m_pkProgressTextLabel->SetText(pstrString->getCString());
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
					CCAssert(0,""); ///< 未实现 郭浩
#endif

				}
                break;
        }
	}
	else if (TAG_TIMER_CHECK_LOGIN_COPY == idTag)
	{
	}
    else if ( TAG_TIMER_FIRST_RUN == idTag )
	{
		LOGD("Entry TAG_TIMER_FIRST_RUN == idTag");
		m_pTimer->KillTimer( this, TAG_TIMER_FIRST_RUN );
		
		//CreateUpdateUILayer();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
 		CCLog( "@@login02: to call OnEvent_LoginOKNormal()\r\n" );
		m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
		OnEvent_LoginOKNormal(m_iAccountID);
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        if(m_pLayerUpdate) {
            CCLog( "@@login02: m_pLayerUpdate=%p\r\n", m_pLayerUpdate );
            NDUIImage * pImage = (NDUIImage *)m_pLayerUpdate->GetChild( TAG_CTRL_PIC_BG);
            if ( pImage )
            {
                NDPicture * pPicture = new NDPicture;
                pPicture->Initialization( NDPath::GetUIImgPath( SZ_MOBAGE_BG_PNG_PATH ).c_str() );
                pImage->SetPicture( pPicture, true );
            }
        }
#endif

#if CACHE_MODE == 1
    	if ( NDBeforeGameMgrObj.CheckFirstTimeRuning() )
        {
			CCLog( "@@ first time running!!!\r\n");

			NDBeforeGameMgrObj.CopyRes();

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
        {
			CCImage::changeSystemFont(false);
            NDBeforeGameMgrObj.doNDSdkLogin();
			CloseWaitingAni();
			OnProcessUpdate();
		}
#else
		NDBeforeGameMgrObj.doNDSdkLogin();
		CloseWaitingAni();
		OnProcessUpdate();
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
	else if (TAG_TIMER_LAZY_SEND_LOGIN_EVENT == idTag)
	{
		CCLog( "@@ to call SMLoginScene::OnTimer, call ScriptGlobalEvent::OnEvent (GE_LOGIN_GAME); \r\n" );
		m_pTimer->KillTimer( this, TAG_TIMER_LAZY_SEND_LOGIN_EVENT );
		ScriptGlobalEvent::OnEvent (GE_LOGIN_GAME);
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
	LOGD("Entry StartUpdate");

	if ( kDeqUpdateUrl.empty() )
	{
		LOGERROR("kDeqUpdateUrl is empty");
		return false;
	}
	
	CCImage::changeSystemFont(true);

	//请求第一个包
	std::string strURL = *kDeqUpdateUrl.begin();
	m_strUpdateURL	= strURL;
	m_pTimer->SetTimer( this, TAG_TIMER_UPDATE, 0.5f );	
	m_CurDownNum = 1;
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
	if ( m_pLabelPromtp )
	{
		int iTotalDownNum = kDeqUpdateUrl.size() + m_CurDownNum - 1;
		//std::stringstream str;
		char dataSize[10] = {0};
		sprintf(dataSize,"%.2f",filelen/(1024*1024.0));
		std::string strDownloading = NDCommonCString2(SZ_DOWNLOADING);
		char buff[100] = {0};
		sprintf(buff,"(%sMB)%s(%d/%d)",dataSize, strDownloading.c_str(),m_CurDownNum,iTotalDownNum);
		//str << "("<<buff<< "MB)" << CCString::stringWithFormat(strDownloading.c_str(), m_CurDownNum, iTotalDownNum)->getCString();
		//m_pLabelPromtp->SetText( str.str().c_str() );
		m_pLabelPromtp->SetText(buff);
		m_pLabelPromtp->SetVisible( true );
	}
	SetProgress( percent );
}

//===========================================================================
void CSMLoginScene::DidDownloadStatus( DownloadStatus status )
{
	CCLog( "@@ CSMLoginScene::DidDownloadStatus(): %d\r\n", int(status));
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
	kDeqUpdateUrl.push_back(szUpdatePath);
}

//++Guosen2012.8.7
void CSMLoginScene::ShowRequestError()
{
	NDUIDialog* pkUIDialog = new NDUIDialog();
	pkUIDialog->Initialization();
	pkUIDialog->SetTag(TAG_REQUEST_URL_ERROR);
	pkUIDialog->SetDelegate(this);
	pkUIDialog->Show(NDCommonCString2("Common_error").c_str(),
		NDCommonCString2("LOGIN_SZ_REQUEST_DOWNLOAD_FAIL").c_str(),
		NULL, NDCommonCString2("Common_Ok").c_str(), NULL);
}

//===========================================================================
//通过传递进的文件路径，获得待删除的文件路径，删除待删除的文件，删除传递进的文件
bool CSMLoginScene::DeleteFileFromFile( std::string & szDelListFile )
{
	std::ifstream kTempFile;
	kTempFile.open( szDelListFile.c_str(), ios_base::in );
	if ( !kTempFile )
	{
		if ( kTempFile.is_open() )
		{
			kTempFile.close();
		}

		return false;
	}
	std::string lineStr;
	while ( getline( kTempFile, lineStr ) )
	{
		std::string DelFile = m_strCachePath + lineStr;
 		if ( remove( DelFile.c_str() ) )
		{
			NDLog( "删除文件失败：%s",DelFile.c_str() );
		}
	}
	kTempFile.close();
	remove( szDelListFile.c_str() );
	return true;
}

//===========================================================================
bool CSMLoginScene::CreateUpdateUILayer()
{
	LOGD("Entry CreateUpdateUILayer");

	if ( m_pLayerUpdate )
	{
		LOGERROR("m_pLayerUpdate is null");
		return false;
	}
	
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	NDUILayer*	pkLayer = new NDUILayer();

	if ( !pkLayer )
	{
		LOGERROR( "CSMLoginScene::CreateUpdateUILayer() pLayer is null" );
		return false;
	}

	pkLayer->Initialization();
	pkLayer->SetFrameRect( CCRectMake(0, 0, kWinSize.width, kWinSize.height) );
	pkLayer->SetTag( TAG_UPDATE_LAYER );
	AddChild(pkLayer);
	m_pLayerUpdate = pkLayer;
	
	NDUILoad kTempUILoad;
	
	//爲了識別 居中等效果 每次load都會clear一次，所以多次調用也沒關係
	NDLocalXmlString::GetSingleton().LoadLoginString();

	LOGD("Ready to load update.ini file");
	kTempUILoad.Load( "UpdateUI.ini", pkLayer, this, CCSizeMake(0, 0));
	
	m_pCtrlProgress	= (CUIExp*)pkLayer->GetChild( TAG_CTRL_PROGRESS );
	if ( !m_pCtrlProgress )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() m_pCtrlProgress is null" );
		return false;
	}

	m_pCtrlProgress->SetProcess(0);
	m_pCtrlProgress->SetTotal(100);
	m_pCtrlProgress->SetStyle(1);
	m_pCtrlProgress->SetVisible(false);
	m_pCtrlProgress->SetTextFontColor( ccc4(255,255,255,255) );
	
	m_pLabelPromtp	= (NDUILabel*)pkLayer->GetChild( TAG_LABEL_PROMPT );
	if ( !m_pLabelPromtp )
	{
		NDLog( "CSMLoginScene::CreateUpdateUILayer() m_pLabelPromtp is null" );
		return false;
	}

	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetVisible(false);
	}

	if (m_pLayerOld)
	{
		m_pLayerOld->SetVisible(false);
	}

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
void CSMLoginScene::OnMsg_ClientVersion(NDTransData& kData)
{
	CCLog( "@@ CSMLoginScene::OnMsg_ClientVersion()\r\n" );
	LOGD("Entry OnMsg_ClientVersion");

	bool bUpdate = false;
	
	int bLatest				= kData.ReadByte();
	int bForceUpdate		= kData.ReadByte();
	int nFromVersion		= kData.ReadInt();
	int nToVersion			= kData.ReadInt();
	std::string strUpdatePath  = kData.ReadUnicodeString();
	LOGD("Client Version:FromVersion is %d,ToVersion is %d",nFromVersion,nToVersion);

	//std::string strUpdatePath = "http://222.77.177.219/twt/android/6999_7000_in_dhljupdate.zip";//kData.ReadUnicodeString();
	
	if ( bForceUpdate )
	{
        CloseWaitingAni();
		LOGD("Redown the game client please!");
		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_01).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
		}
		return ;
	}
	else if ( ( nFromVersion ==  nToVersion ) &&  ( !bLatest ) )
	{
        CloseWaitingAni();
		LOGERROR("Current version error!!,Please call GM!");

		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_02).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
		}
		return ;
	}
	else if ( ( nFromVersion == 0 ) && ( nToVersion == 0 ) )
	{
        CloseWaitingAni();
		LOGERROR("Version info is broken,Please call GM!");

		if ( m_pLabelPromtp )
		{
			m_pLabelPromtp->SetText( NDCommonCString2(SZ_ERROR_03).c_str() );
			m_pLabelPromtp->SetFontColor( ccc4(0xFF,0x0,0x0,255) );
    		m_pLabelPromtp->SetVisible( true );
		}

		return ;
	}
	else if ( ( nFromVersion == nToVersion ) && (bLatest) )
	{
		LOGD("Current version is newest");

		StartEntry();
		return;
	}
	else
	{
		bUpdate = true;
	}

	LOGD("Res update URL:%s",strUpdatePath.c_str());
	kDeqUpdateUrl.push_back(strUpdatePath);

	if (bUpdate)
	{
		LOGD("Pass bUpdate,value is %s",bUpdate ? "true" : "false");

		if (bLatest)
		{
			CloseWaitingAni();
			if ( !NDBeforeGameMgrObj.isWifiNetWork() )//
			{
				ShowCheckWIFIOff();
				m_pTimer->SetTimer( this, TAG_TIMER_CHECK_WIFI, 1.0f );
			}
			else
			{
				StartUpdate();
			}
		}
	}

	LOGD("Leave OnMsg_ClientVersion");
	CCLog("@@ Leave OnMsg_ClientVersion");
}

//===========================================================================

void CSMLoginScene::OnEvent_LoginOKNormal( int iAccountID )
{
	CCLog( "@@login03: OnEvent_LoginOKNormal()\r\n" );

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
	
#if (UPDATE_ON == 0 && CACHE_MODE == 0)
    CloseWaitingAni();
    StartEntry();
    clearSplash();
#endif
#if UPDATE_ON == 1
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
	LOGD("Entry StartDownload");
	
	//獲取要下載的總的數量
	int iTotalDownNum = kDeqUpdateUrl.size() + m_CurDownNum - 1;

	if ( m_pLabelPromtp )
	{
		m_pLabelPromtp->SetText( CCString::stringWithFormat(NDCommonCString2(SZ_DOWNLOADING).c_str(), m_CurDownNum, iTotalDownNum)->getCString());
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
	//在选服列表界面更新版本特殊处理
	if(NDBeforeGameMgrObj.GetLogUIUpdate())
	{
		ScriptMgrObj.excuteLuaFunc("LoguiLoginGame", "Login_ServerUI");
		return;
	}

	WriteCon( "@@ CSMLoginScene::StartEntry()\r\n" );
	CCLog( "@@login04: StartEntry()\r\n" );
#if 1
	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_SETUP).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}

//	ShowWaitingAni();

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

	ScriptMgrPtr->excuteLuaFunc( "LoadData", "GameSetting" ); 
	CloseUpdateUILayer();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	m_iAccountID = ScriptMgrPtr->excuteLuaFuncRetN( "GetAccountID", "Login_ServerUI" );
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	m_iAccountID = NDBeforeGameMgrObj.GetCurrentUser();
#endif
    
	CCLog( "@@login041: StartEntry(%u)\r\n" , m_iAccountID);
    if(m_iAccountID != 0) {
        NDBeforeGameMgrObj.SetLoginTry(false);
        ScriptMgrPtr->excuteLuaFunc( "ShowUI", "Entry", m_iAccountID );
    }
    else
        NDBeforeGameMgrObj.SetLoginTry(true);
	//    ScriptMgrObj.excuteLuaFunc("ProecssLocalNotification", "MsgLoginSuc");

#else //多线程不会有什么好处，反而是崩溃和不稳定，
	  //实际上网络线程和控制台线程都是多余的！单线程足够了！
	if (m_pLabelPromtp)
	{
		m_pLabelPromtp->SetText( NDCommonCString2(SZ_SETUP).c_str() );
		m_pLabelPromtp->SetVisible( true );
	}
//	ShowWaitingAni();
	NDLocalXmlString::GetSingleton();
	ScriptMgrObj;
	pthread_t pid = {0};
	pthread_create(&pid, NULL, CSMLoginScene::LoadTextAndLua, (void*)this);	
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    clearSplash();
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
	int	iTag = uiNode->GetTag();
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
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	NDUILayer* pkLayer = new NDUILayer();

	if (!pkLayer)
	{
		return false;
	}

	pkLayer->Initialization();
	pkLayer->SetFrameRect( CCRectMake(0, 0, kWinSize.width, kWinSize.height) );
	pkLayer->SetTag( TAG_DLG_CONFIRM );
	AddChild(pkLayer);	
	
	NDUILoad kTempUILoad2;
	kTempUILoad2.Load( "ShowYesOrNoDlg.ini", pkLayer, this, CCSizeMake(0, 0) );
	
	NDUILabel * pLabelTip	= (NDUILabel*)pkLayer->GetChild( TAG_LABEL_TIP );
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
    int nPercent = 100 * (nFileIndex + 1) / nFileNum;
    SetProgress( nPercent );
}

void CSMLoginScene::UnzipStatus(bool bResult)
{
	if (!bResult) 
    {
        NDLog("UnZipFile:%s failed",m_strSavePath.c_str());
        //return;
    }
	m_pTimer->SetTimer( this, TAG_TIMER_UNZIP_SUCCESS, 0.5f );	
}

//===========================================================================
//显示等待的转圈圈动画
void CSMLoginScene::ShowWaitingAni()
{
	CUISpriteNode* pkCheckNode = (CUISpriteNode *)GetChild(TAG_SPRITE_NODE);

	if ( pkCheckNode )
	{
		return;
	}
	CCSize kWinSize = CCDirector::sharedDirector()->getWinSizeInPixels();	
	CUISpriteNode* pkUIScriptNode = new CUISpriteNode;
	pkUIScriptNode->Initialization();
	pkUIScriptNode->ChangeSprite(NDPath::GetAniPath("busy.spr").c_str());
	pkUIScriptNode->SetTag( TAG_SPRITE_NODE );
	pkUIScriptNode->SetFrameRect(CCRectMake(0, 0, kWinSize.width, kWinSize.height));
	AddChild(pkUIScriptNode);
}
void CSMLoginScene::CloseWaitingAni()
{
	RemoveChild( TAG_SPRITE_NODE, true );
}

//===========================================================================
//显示检测WIFI失败对话框
void CSMLoginScene::ShowCheckWIFIOff()
{
// 	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
// 	
// 	NDUILayer *	pLayer	= new NDUILayer();
// 	if ( !pLayer )
// 		return;
// 	pLayer->Initialization();
// 	pLayer->SetFrameRect( CCRectMake(0, 0, winSize.width, winSize.height) );
// 	AddChild(pLayer);
// 	m_pLayerCheckWIFI = pLayer;
// 	NDUILoad tmpUILoad;
// 	tmpUILoad.Load( "CheckWIFIDlg.ini", pLayer, this, CCSizeMake(0, 0) );
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
void* CSMLoginScene::LoadTextAndLua( void * pPointer )
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

void CSMLoginScene::OnProcessUpdate()
{
#if UPDATE_ON == 1
	NDJsonReader kReader;
	string strUpdateURL = kReader.getGameConfig("world_server_ip").c_str();
	unsigned int uiServerPort = atoi(kReader.getGameConfig("server_port").c_str());

	LOGD("%s%s:%d",CONVERT_GBK_TO_UTF8("此時更新的IP地址為："),strUpdateURL.c_str(),uiServerPort);
	CreateUpdateUILayer();
    
    clearSplash();

	if ( !strUpdateURL.length() )
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

	if ( !NDBeforeGameMgrObj.CheckClientVersion( strUpdateURL.c_str(),uiServerPort) )
	{
		LOGERROR("CheckClientVersion failed");
		CloseWaitingAni();
		StartEntry();
		return;
	}
#else
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	//StartEntry();
#endif
#endif
}

std::string CSMLoginScene::getTextFromStringXML_JNI( int nTextID )
{
	std::string ret;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, "org/DeNA/DHLJ/DaHuaLongJiang",
		"getTextFromStringXML",
		"(I)Ljava/lang/String;"))
	{
		jstring retFromJava = (jstring) t.env->CallStaticObjectMethod(t.classID,
			t.methodID, nTextID);
		const char* str = t.env->GetStringUTFChars(retFromJava, 0);
		ret = str;

		t.env->ReleaseStringUTFChars(retFromJava, str);
		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(retFromJava);
	}
	else
	{
		LOGERROR("Cant' find java function:getTextFromStringXML");
	}
#endif
	return ret;
}


char*  CSMLoginScene::GetPathFileName(char* src, char delitmit)   
{ 
	int i = strlen(src); 
	if(!(*src))     
		return NULL; 
	while(src[i-1])  
		if(strchr(src + (i - 1), delitmit))
			return   (src + i); 
		else   
		{
			i--; 
		}
		//如果都没有找到，则返回整个字符串
		if (i == 0)
		{
			return src;
		}
		return  NULL; 
} 

void CSMLoginScene::lazySendLoginEvent()
{
	if (m_pTimer)
	{
		m_pTimer->SetTimer( this, TAG_TIMER_LAZY_SEND_LOGIN_EVENT,0.1f );
	}
}