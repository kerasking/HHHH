/*
 *  InitMenuScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "InitMenuScene.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "GameHelpScene.h"
#import "LoginScene.h"
#import "RegisterAccountScene.h"
#import "NDDataTransThread.h"
#import "define.h"
#import "NDBeforeGameMgr.h"
#include "ImageNumber.h"
#include "NDUIMemo.h"
#include "NDUIDialog.h"
#include "NDUISynLayer.h"
#include "WorldMapScene.h"
#include "NDUIDialog.h"
#include "GameSettingScene.h"
#include "NDUISynLayer.h"
#include "ImageNumber.h"
#include "cpLog.h"
#include "GameSceneLoading.h"
#include "Chat.h"
#include "ChatRecordManager.h"
#include <map>
#include "NDTextNode.h"
#include "UIImageCombiner.h"
#include "NDMapLayer.h"
#include "GameScene.h"
#include "NDPath.h"
#include "XMLReader.h"
#include "UpdateScene.h"
#include "NewHelpScene.h"
#include "SystemAndCustomScene.h"
//#include "NDCrashUpload.h"
#include "DownloadPackage.h"
#include <sstream>

#include "TestSceneZJH.h"
#include "ScriptInc.h"

using namespace NDEngine;

#define TIMER_CHECK_CRASH_TAG (100)

#define TAG_DLG_CRASH (101)

#define MAXLABEL_W (NDDirector::DefaultDirector()->GetWinSize().width)
#define MAXLABEL_H (NDDirector::DefaultDirector()->GetWinSize().height)

#define BGIMAGE [NSString stringWithFormat:@"%s", NDPath::GetImgPath("login_bk.png")]
#define ARROWIMAGELEFT [NSString stringWithFormat:@"%s", NDPath::GetImgPath("arrow_left.png")]
#define ARROWIMAGERIGHT [NSString stringWithFormat:@"%s", NDPath::GetImgPath("arrow_right.png")]

#define TAG_DLG_UPDATE 12

#define file_img_bg ("login_background.png")
#define file_img_btn_bg ("login_btn_bg.png")
#define file_img_copyright ("login_copyright.png")
#define file_img_left_hightlight ("login_left_hightlight.png")
#define file_img_left_normal ("login_left_normal.png")
#define file_img_menu_focus ("login_menu_focus.png")
#define file_img_menu_text ("login_menu_text.png")
#define file_img_ver ("login_ver.png")


static std::string strChooseText[InitMenuScene::ctEnd] =
{
	//"快速注册",			//ctQuickRegister = 0,
	NDCommonCString("FastGame"),			//ctQuickGame,		
	NDCommonCString("LoginGame"),			//ctLogin,			
	NDCommonCString("RegisterAccount"),			//ctRegister,			
	NDCommonCString("GameSetting"),			//ctGameSetting,		
	NDCommonCString("GameHelp"),			//ctGameHelp,			
	NDCommonCString("QuitGame"),			//ctQuit,				
						//ctEnd,
};

IMPLEMENT_CLASS(InitMenuScene, NDScene)

InitMenuScene* InitMenuScene::Scene(bool bShowNetError/*=false*/)
{
	InitMenuScene* scene = new InitMenuScene();	
	scene->Initialization(bShowNetError);
	return scene;
}

InitMenuScene::InitMenuScene()
{
	m_Layer			= NULL;
	/*
	m_lbFree		= NULL;
	m_lbVersion		= NULL;
	m_lbCopyRight	= NULL;
	*/
	m_btnLeft		= NULL;
	m_btnRight		= NULL;
	
	m_leftArrowImage = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew(file_img_left_normal));
	
	m_rightArrowImage = m_leftArrowImage->Copy();
	
	m_leftArrowHightlightImage = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew(file_img_left_hightlight));
	
	m_rightArrowHightlightImage = m_leftArrowHightlightImage->Copy();
	
	m_rightArrowImage->SetReverse(true);
	
	m_rightArrowHightlightImage->SetReverse(true);
	
	memset(m_focusImg, 0, sizeof(m_focusImg));
	memset(m_cpicMenuText, 0, sizeof(m_cpicMenuText));
	
	for (int ct = ctBegin ; ct < ctEnd; ct++) 
	{
		m_btnChoose[ct] = NULL;
	}
	
	InitBtnRelate();
	
	//static bool bLoad = false;
//	if ( !bLoad ) 
//	{
//		NDBeforeGameMgrObj.Load();
//	}
//	
//	bLoad = true;
	
	m_dlgTip = NULL;
	
	iTipType = 0;
	
	//NDDataTransThread::DefaultThread()->Stop();
}

InitMenuScene::~InitMenuScene()
{	
	delete m_leftArrowImage;
	delete m_rightArrowImage;
	delete m_leftArrowHightlightImage;
	delete m_rightArrowHightlightImage;
	
	for (int ct = ctBegin; ct < ctEnd; ct++) 
	{
		delete m_focusImg[ct];
		
		delete m_cpicMenuText[ct][0];
		delete m_cpicMenuText[ct][1];
	}
}

void InitMenuScene::Initialization(bool bShowNetError/*=false*/)
{	
	GLfloat w=NDDirector::DefaultDirector()->GetWinSize().width;
	GLfloat h=NDDirector::DefaultDirector()->GetWinSize().height;
	NDScene::Initialization();
	m_Layer = new NDUILayer();
	m_Layer->Initialization();
	m_Layer->SetFrameRect(CGRectMake(0, 0, w, h));
	m_Layer->SetDelegate(this);
	m_Layer->SetBackgroundImage(NDPath::GetImgPathNew(file_img_bg));
	this->AddChild(m_Layer);
	
	NDPicturePool& picPool = *(NDPicturePool::DefaultPool());
	
	NDPicture *picBtnImg = picPool.AddPicture(NDPath::GetImgPathNew(file_img_btn_bg));
	
	NDUIImage *btnImg = new NDUIImage;
	btnImg->Initialization();
	btnImg->EnableEvent(false);
	btnImg->SetPicture(picBtnImg, true);
	btnImg->SetFrameRect(CGRectMake(0, 140, picBtnImg->GetSize().width, picBtnImg->GetSize().height));
	m_Layer->AddChild(btnImg);
	
	/*
	m_lbFree = new NDUILabel();
	m_lbFree->Initialization();
	m_lbFree->SetText("永久免费");
	m_lbFree->SetFontSize(13);
	m_lbFree->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbFree->SetFrameRect(CGRectMake(5, 7, 13, MAXLABEL_H));
	m_lbFree->SetFontColor(ccc4(162, 229, 220,255));	
	m_Layer->AddChild(m_lbFree);
	
	m_lbVersion = new NDUILabel();
	m_lbVersion->Initialization();
	m_lbVersion->SetText(GetSoftVersion().insert(0, "V").c_str());
	m_lbVersion->SetFontSize(13);
	m_lbVersion->SetFontColor(ccc4(162, 229, 220,255));	
	m_lbVersion->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbVersion->SetFrameRect(CGRectMake(25, 10, MAXLABEL_W, 13));
	m_Layer->AddChild(m_lbVersion);
	
	m_lbCopyRight = new NDUILabel();
	m_lbCopyRight->Initialization();
	m_lbCopyRight->SetText("@2011 91游戏");
	m_lbCopyRight->SetFontSize(15);
	m_lbCopyRight->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbCopyRight->SetFontColor(ccc4(253,252,247,255));
	m_lbCopyRight->SetFrameRect(CGRectMake(0, 300, MAXLABEL_W, 15));
	m_Layer->AddChild(m_lbCopyRight);
	*/
	m_focusImg[ctBegin] = picPool.AddPicture(NDPath::GetImgPathNew(file_img_menu_focus));
	
	for (int ct = int(ctBegin)+1 ; ct < ctEnd; ct++) 
	{
		m_focusImg[ct] = m_focusImg[ctBegin]->Copy();
	}
	
	CGSize sizeBtn = m_focusImg[ctBegin]->GetSize();
	
	for (int ct = ctBegin ; ct < ctEnd; ct++) 
	{
		m_cpicMenuText[ct][0] = GetMenuTextCombinePic(ChooseType(ct), false);
		
		m_cpicMenuText[ct][1] = GetMenuTextCombinePic(ChooseType(ct), true);
		
		m_btnChoose[ct] = new NDUIButton;
		m_btnChoose[ct]->Initialization();
		m_btnChoose[ct]->CloseFrame();
		m_btnChoose[ct]->SetFontSize(16);
		m_btnChoose[ct]->SetFocusImage(m_focusImg[ct]);
		//m_btnChoose[ct]->SetTitle(strChooseText[ct].c_str(),false);
		m_btnChoose[ct]->SetFontColor(ccc4(162, 229, 220,255));//ccc4(16,56,66,255));
		m_btnChoose[ct]->SetDelegate(this);
		m_btnChoose[ct]->SetFrameRect(CGRectMake((w-picBtnImg->GetSize().width)/2, 140, sizeBtn.width, sizeBtn.height));
		SetMenuBtnIndexImg(ChooseType(ct), false);
		m_Layer->AddChild(m_btnChoose[ct]);
	}
	
	m_btnFocus = m_btnChoose[0];
	
	UpdateChooseBtn( true );
	
	SetMenuBtnIndexImg(ctBegin, true);
	
	CGSize sizeDir = m_leftArrowImage->GetSize();
	
	m_btnLeft = new NDUIButton;
	m_btnLeft->Initialization();
	m_btnLeft->SetFrameRect(CGRectMake((92-sizeDir.width)/2, 140+(picBtnImg->GetSize().height-sizeDir.height)/2, sizeDir.width, sizeDir.height));
	m_btnLeft->SetImage(m_leftArrowImage);
	m_btnLeft->SetTouchDownImage(m_leftArrowHightlightImage);
	m_btnLeft->SetDelegate(this);
	m_Layer->AddChild(m_btnLeft);
	
	m_btnRight = new NDUIButton;
	m_btnRight->Initialization();
	m_btnRight->SetFrameRect(CGRectMake(480-(92-sizeDir.width)/2-sizeDir.width, 140+(picBtnImg->GetSize().height-sizeDir.height)/2, sizeDir.width, sizeDir.height));
	m_btnRight->SetImage(m_rightArrowImage);
	m_btnRight->SetTouchDownImage(m_rightArrowHightlightImage);
	m_btnRight->SetDelegate(this);
	m_Layer->AddChild(m_btnRight);
	
	NDUIImage *freeFee = new NDUIImage;
	freeFee->Initialization();
	NDPicture *freePic = picPool.AddPicture(NDPath::GetImgPathNew(file_img_copyright));
	freePic->Cut(CGRectMake(7*18, 0, 36*4, 36));
	freeFee->SetPicture(freePic, true);
	freeFee->SetFrameRect(CGRectMake(480-84, 320-24-18, freePic->GetSize().width, freePic->GetSize().height));
	freeFee->EnableEvent(false);
	m_Layer->AddChild(freeFee);
	
	NDUIImage *ver = new NDUIImage;
	ver->Initialization();
	NDCombinePicture *combinepicVer = GetVerTextCombinePic(GetSoftVersion());
	ver->SetCombinePicture(combinepicVer, true);
	ver->SetFrameRect(CGRectMake(480-84+(72-combinepicVer->GetSize().width)/2, 320-24-18+5+18, combinepicVer->GetSize().width, combinepicVer->GetSize().height));
	ver->EnableEvent(false);
	m_Layer->AddChild(ver);
	
	NDUIImage *copyright = new NDUIImage;
	copyright->Initialization();
	NDPicture *copyrightPic = picPool.AddPicture(NDPath::GetImgPathNew(file_img_copyright));
	copyrightPic->Cut(CGRectMake(0, 0, 7*18, 18));
	copyright->SetPicture(copyrightPic, true);
	copyright->SetFrameRect(CGRectMake((480-copyrightPic->GetSize().width)/2, 320-12-copyrightPic->GetSize().height, copyrightPic->GetSize().width, copyrightPic->GetSize().height));
	copyright->EnableEvent(false);
	m_Layer->AddChild(copyright);
	
	m_Layer->SetFocus((NDUINode*)m_btnChoose[m_iCurrIndex]);
	
	NDDataTransThread::DefaultThread()->Stop();
	
	//m_Layer->SetTouchEnabled(true);
	if (bShowNetError) {
		m_timer.SetTimer(this, 0, 1.5f);
	} else {
#ifndef DEBUG
        /*
		NDCrashUpload *upload = [NDCrashUpload Shared];
		if (upload && ![upload HadDealBefore]) 
		{
//			NSUInteger sizeUpload = [upload GetCrashReportSize] ;
//			if ( NSUInteger(0) != sizeUpload)
//			{
				m_timer.SetTimer(this, TIMER_CHECK_CRASH_TAG, 0.5f);
//			}
		}
         */
#endif
	}

	
	// test
	//m_timer.SetTimer(this, 1, 2);
	
}

void InitMenuScene::OnTimer(OBJID tag)
{
	if (tag == 0)
	{
		m_timer.KillTimer(this, 0);

		showDialog(NDCommonCString("tip"), NDCommonCString("ConnectErr"));
	}
	
	// test
	if (tag == 1)
	{
		//OnClickChooseBtn(ctQuickGame);
	}
	
	if (tag == TIMER_CHECK_CRASH_TAG)
	{
		m_timer.KillTimer(this, tag);
		
#ifndef DEBUG
        /*
		NDCrashUpload *upload = [NDCrashUpload Shared];
		if (upload && ![upload HadDealBefore] /*&& isWifiNetWork()) */
		/*{
			NSUInteger sizeUpload = [upload GetCrashReportSize] ;
			if ( NSUInteger(0) != sizeUpload)
			{
				std::stringstream ss;
				ss << NDCommonCString("CrashReportTip");
				if (sizeUpload/1024 > 0)
				{
					ss << sizeUpload / 1024 << "KByte";
				}
				else
				{
					ss << sizeUpload << "Byte";
				}
				ss   << NDCommonCString("CrashReportTip2");
				   
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetTag(TAG_DLG_CRASH);
				dlg->SetDelegate(this);
				dlg->Show(NDCommonCString("tip"), ss.str().c_str(), NULL, NULL);
			}
		}
        */
#endif
	}
}

bool InitMenuScene::IsLatestVersion(std::string& fileUrl, std::string& latestVersion)
{
	bool res = true;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:GetUpdateUrl().c_str()]]];
	NSURLResponse *response = nil;
	NSError *err = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err]; 
	if (!err)
	{
		cpLog(LOG_DEBUG, "not err");
		XMLReader *reader = [[XMLReader alloc] initWithData:(char*)[data bytes] length:[data length]];
		int retStatus = [reader getIntWithPath:@"/result/resultState/code" andIndexs:NULL size:0];
		if (retStatus == 0) 
		{
			cpLog(LOG_DEBUG, "xml return success");
			fileUrl = [[reader getStringWithPath:[NSString stringWithUTF8String:"/result/data/filelist/file"] andIndexs:NULL size:0] UTF8String];
			
			NSString* latestVer = [reader getStringWithPath:[NSString stringWithUTF8String:"/result/data/version"] andIndexs:NULL size:0];
			NSString* localVersion = [NSString stringWithUTF8String:GetSoftVersion().c_str()];
			if ([latestVer isEqualToString:localVersion]) 
				res = true;
			else 
				res = false;
			
			latestVersion = [latestVer UTF8String];
			
		}
		[reader release];		
	}
	return res;
}

void InitMenuScene::OnButtonClick(NDUIButton* button)
{	
	if ( button == m_btnLeft) 
	{
		m_iFirstIndex = m_iCurrIndex == 0 ? ( m_iFirstIndex == 0 ? ctEnd - 1 : m_iFirstIndex - 1 ) : m_iFirstIndex;
		if ( m_iCurrIndex == 0 ) 
		{
			UpdateChooseBtn(true);
		}
		else 
		{
			m_iCurrIndex  = m_iCurrIndex - 1;			
			UpdateChooseBtn(false);
		}
	}
	else if ( button == m_btnRight)
	{	
		m_iFirstIndex = m_iCurrIndex == ctEnd - 1 ? ( m_iFirstIndex  == ctEnd - 1 ? 0 : m_iFirstIndex + 1 ) : m_iFirstIndex;
		if ( m_iCurrIndex == ctEnd -1 ) {
			UpdateChooseBtn( true );
		}
		else 
		{
			m_iCurrIndex  = m_iCurrIndex + 1;
			UpdateChooseBtn(false);
		}
	}
	else 
	{		
		ChooseType ctIndex = ctEnd;
		for (int ct = ctBegin ; ct < ctEnd; ct++) 
		{
			if ( m_btnChoose[ct] && m_btnChoose[ct] == button ) 
			{
				ctIndex = ChooseType(ct);
				break;
			}
		}
		
		if ( ctIndex == ctEnd ) return;
		
		int iIndex;
		
		if ( ctIndex >= m_iFirstIndex ) 
		{
			iIndex = ctIndex - m_iFirstIndex;
		}
		else 
		{
			iIndex = ctIndex + ctEnd - m_iFirstIndex;
		}
		
		bool bReturn = m_iCurrIndex != iIndex;
		
		m_iCurrIndex = iIndex;
		
		UpdateChooseBtn(false);
		
		if (bReturn) return;
		
		OnClickChooseBtn(ctIndex);
	}
}

void InitMenuScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog->GetTag() == TAG_DLG_UPDATE) 
	{
		if (buttonIndex == 0) 
		{
			char buff[100] = {0x00};
			sprintf(buff, "最新版本：%s", m_latestVersion.c_str());
			
			UpdateScene* scene = new UpdateScene();
			scene->Initialization(m_fileUrl.c_str(), buff);
			NDDirector::DefaultDirector()->PushScene(scene);
		}
		else 
		{
			exit(0);
		}
	}
	else 
	{
		if (m_dlgTip) 
		{
			m_dlgTip->Close();
			m_dlgTip = NULL;
		}
		
		//快速游戏
		NewRegisterAccountScene *scene = NewRegisterAccountScene::Scene();
		scene->SetAccountText(NDBeforeGameMgrObj.GetUserName().c_str());
		scene->SetPasswordText(NDBeforeGameMgrObj.GetPassWord().c_str());
		NDDirector::DefaultDirector()->ReplaceScene(scene, true);
	}
}

void InitMenuScene::OnDialogClose(NDUIDialog* dialog)
{
    /*
	if (dialog->GetTag() == TAG_DLG_CRASH)
	{
		NDCrashUpload *upload = [NDCrashUpload Shared];
		if (upload) 
		{
			[upload UploadCrashReport];
		}
		
		return;
	}
     */
	
	if (iTipType == 1) 
	{ // 快速注册
		NewRegisterAccountScene *scene = NewRegisterAccountScene::Scene();
		scene->SetAccountText(NDBeforeGameMgrObj.GetUserName().c_str());
		NDDirector::DefaultDirector()->ReplaceScene(scene);
		return ;
	}
	NDUISynLayer::Close(SYN_FAST_REGISTER);
}

void InitMenuScene::FastGameOrRegisterTip(int iType)
{
//	if (m_dlgTip) 
//	{
//		m_dlgTip->Close();
//		m_dlgTip = NULL;
//	}
	CloseProgressBar;
	m_dlgTip = new NDUIDialog;
	m_dlgTip->Initialization();
	m_dlgTip->SetDelegate(this);
	if (iType == 1) 
	{ //快速注册
		std::string str = "";
		str += NDCommonCString("UserName");
		str += NDBeforeGameMgrObj.GetUserName();
		m_dlgTip->Show(NDCommonCString("GetUserNameSucc"), str.c_str(), NDCommonCString("Ok"), NULL);
	}
	else
	{ //快速游戏
		std::string str = "";
		str += NDCommonCString("AccountName");
		str += NDBeforeGameMgrObj.GetUserName();
		str += "\n";
		str += NDCommonCString("UserPW");
		str += NDBeforeGameMgrObj.GetPassWord();
		m_dlgTip->Show(NDCommonCString("SysTip"), str.c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"),NULL);
	}
	iTipType = iType;
}

void InitMenuScene::UpdateChooseBtn(bool bUpdate)
{
	if (bUpdate && m_focusImg[ctBegin]) 
	{
		
		CGSize picSize = m_focusImg[ctBegin]->GetSize();
		for (int ct = ctBegin ; ct < ctEnd; ct++) 
		{
			ChooseType ctIndex = ChooseType( (m_iFirstIndex + ct) % ctEnd ) ;
			
			m_btnChoose[ctIndex]->SetFrameRect(CGRectMake(92+(13+picSize.width)*ct, 140, picSize.width, picSize.height));			
			
			//if ( ct == ctEnd - 1 ) 
//			{
//				m_btnChoose[ctIndex]->SetVisible(false);
//			}
//			else 
//			{
				m_btnChoose[ctIndex]->SetVisible(true);
			//}
		}
	}

	if ( m_Layer /*&& m_Layer->GetFocus() != m_btnChoose[(m_iCurrIndex+m_iFirstIndex)%ctEnd]*/ ) 
	{
		SetMenuBtnImg(m_btnFocus, false);
		m_btnFocus = m_btnChoose[(m_iCurrIndex+m_iFirstIndex)%ctEnd];
		m_Layer->SetFocus( (NDUINode*)m_btnFocus );	
		SetMenuBtnImg(m_btnFocus, true);
		
		/*
		for (int i = 0; i < ctEnd; i++) 
		{
			m_btnChoose[i]->SetFontColor(ccc4(16,56,66,255));
		}
		m_btnFocus->SetFontColor(ccc4(255,253,0,255));
		*/
	}	
}

void InitMenuScene::InitBtnRelate()
{
	m_iFirstIndex = ctBegin;
	m_iCurrIndex  = m_iFirstIndex;
}

void InitMenuScene::OnClickChooseBtn(ChooseType ctIndex)
{		
//	if (m_btnFocus != m_btnChoose[ctIndex]) 
//	{
//		SetMenuBtnImg(m_btnFocus, false);
//		//m_btnFocus->SetFontColor(ccc4(16,56,66,255));
//		m_btnFocus = m_btnChoose[ctIndex];
//		SetMenuBtnImg(m_btnFocus, true);
//		return;
//	}
	//if ( ctIndex == ctQuickRegister ) 
//	{
//		ShowProgressBar;
//		NDBeforeGameMgrObj.FastGameOrRegister(1);
//	}
//	else 
	if ( ctIndex == ctQuickGame )
	{
		//ScriptMgrObj.excuteLuaFunc("LoadUI", "TaskUI");
		NDDirector::DefaultDirector()->PushScene(TestSceneZJH::Scene());
		return;
		// 获取最近使用的记录
		if (NDBeforeGameMgrObj.CanFastLogin()) 
		{
			//NDDataTransThread::DefaultThread()->Start(NDBeforeGameMgrObj.GetServerIP().c_str(), NDBeforeGameMgrObj.GetServerPort());
//			if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
//			{
//				showDialog(NDCommonCString("tip"), "网络连接失败，请检查网络配置");
//				return;
//			}
//			NDBeforeGameMgrObj.CheckVersionAndLogin();
			
			NDDirector::DefaultDirector()->ReplaceScene(GameSceneLoading::Scene(true, LoginTypeFirst));
		}
		else 
		{
			ShowProgressBar;
			NDBeforeGameMgrObj.FastGameOrRegister(2);
		}

	}
	else if ( ctIndex == ctLogin )
	{
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
	}
	else if ( ctIndex == ctRegister )
	{
		NDDirector::DefaultDirector()->ReplaceScene(NewRegisterAccountScene::Scene(), true);
	}
	else if ( ctIndex == ctGameSetting )
	{
		NDDirector::DefaultDirector()->PushScene(SystemAndCustomScene::Scene(true), true);
	}
	else if ( ctIndex == ctGameHelp )
	{
		ScriptMgrObj.excuteLuaFunc("LoadUI", "PlayerUIAttr");
		return;
		NDDirector::DefaultDirector()->PushScene(NewHelpScene::Scene(true), true);
	}
	else if ( ctIndex == ctQuit )
	{
		exit(0);
	}
}

NDCombinePicture* InitMenuScene::GetMenuTextCombinePic(ChooseType ctIndex, bool focus)
{
	if (ctIndex < ctBegin || ctIndex >= ctEnd ) 
	{
		return NULL;
	}
	
	int len = strChooseText[ctIndex].size();
	
	std::string first = strChooseText[ctIndex].substr(0, len/2);
	
	std::string second = strChooseText[ctIndex].substr(len/2, len);
	
	NDCombinePicture *combinePic = new NDCombinePicture;
	
	combinePic->AddPicture(GetMenuTextPic(first, focus, true, first == NDCommonCString("game")), CombintPictureAligmentDown); 
	
	combinePic->AddPicture(GetMenuTextPic(second, focus, false), CombintPictureAligmentDown);
	
	return combinePic;
}

NDPicture* InitMenuScene::GetMenuTextPic(std::string text, bool focus, bool first, bool bParticular/*=false*/)
{
	NDPicture *res = NULL;
	
	bool bGet = false;
	
	CGRect cut = CGRectZero;
	
	int perWidth = 24, perHeight = 48;
	
	int var = 24;
	
	cut.size = CGSizeMake(perWidth, perHeight);
	
	/*if (bParticular) 
	{
		bGet = true;
	}
	else 
	*/if (text == NDCommonCString("fast")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth, 0);
		else		cut.origin = ccp(var+0, 0);
	}
	else if (text == NDCommonCString("game")) 
	{
		bGet = true;
		
		if (focus)	
			if (first)
					cut.origin = ccp(0, 0);
			else
					cut.origin = ccp(var+perWidth, perHeight);
		else		cut.origin = ccp(var+0, perHeight);
	}
	else if (text == NDCommonCString("login")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth*3, 0);
		else		cut.origin = ccp(var+perWidth*2, 0);
	}
	else if (text == NDCommonCString("set")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth*3, perHeight);
		else		cut.origin = ccp(var+perWidth*2, perHeight);
	}
	else if (text == NDCommonCString("register")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth*5, 0);
		else		cut.origin = ccp(var+perWidth*4, 0);
	}
	else if (text == NDCommonCString("account")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth*5, perHeight);
		else		cut.origin = ccp(var+perWidth*4, perHeight);
	}
	else if (text == NDCommonCString("quit")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth*7, 0);
		else		cut.origin = ccp(var+perWidth*6, 0);
	}
	else if (text == NDCommonCString("help")) 
	{
		bGet = true;
		
		if (focus)	cut.origin = ccp(var+perWidth*7, perHeight);
		else		cut.origin = ccp(var+perWidth*6, perHeight);
	}
	
	if (!bGet) return res;
	
	res = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew(file_img_menu_text));
	
	res->Cut(cut);
	
	return res;
}

NDCombinePicture* InitMenuScene::GetVerTextCombinePic(std::string strver)
{
	NDCombinePicture *combinePic = new NDCombinePicture;
	
	std::string::const_iterator begin = strver.begin();
	std::string::const_iterator end = strver.end();
	
	while (begin != end) 
		combinePic->AddPicture(GetVerTextPic(*begin++), CombintPictureAligmentRight);

	return combinePic;
}

NDPicture* InitMenuScene::GetVerTextPic(char cChar)
{
	NDPicture *res = NULL;
	
	bool bGet = false;
	
	CGRect cut = CGRectZero;
	
	int perWidth = 9;
	
	cut.size = CGSizeMake(perWidth, perWidth);
	
	if (cChar == 'v' || cChar == 'V')
	{
		bGet = true;
	}
	else if (cChar == '.')
	{
		bGet = true;
		
		cut.origin = ccp(perWidth*11, 0);
	}
	else if (isdigit(cChar)) 
	{
		bGet = true;
		cut.origin = ccp((cChar-48) * perWidth + perWidth, 0);
	}
	
	if (!bGet) return res;
	
	res = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew(file_img_ver));
	
	res->Cut(cut);
	
	return res;
}

void InitMenuScene::SetMenuBtnIndexImg(ChooseType ctIndex, bool focus)
{
	if (ctIndex < ctBegin 
		|| ctIndex >= ctEnd
		|| !m_cpicMenuText
		|| !m_cpicMenuText[ctIndex]
		|| !m_cpicMenuText[ctIndex][focus ? 1 : 0]
		|| !m_btnChoose
		|| !m_btnChoose[ctIndex]) 
	{
		return;
	}
	
	NDCombinePicture *pic = m_cpicMenuText[ctIndex][focus ? 1 : 0];
	
	CGSize size = m_btnChoose[ctIndex]->GetFrameRect().size,
		   sizepic = pic->GetSize();
		   
	m_btnChoose[ctIndex]->SetCombineImage(pic, true, CGRectMake((size.width-sizepic.width)/2, (size.height-sizepic.height)/2, sizepic.width, sizepic.height));
	
	m_btnChoose[ctIndex]->SetTouchDownCombineImage(pic, true, CGRectMake((size.width-sizepic.width)/2, (size.height-sizepic.height)/2, sizepic.width, sizepic.height));
}

void InitMenuScene::SetMenuBtnImg(NDUIButton *btn, bool focus)
{
	for (int ct = ctBegin; ct < ctEnd; ct++) 
	{
		if (btn == m_btnChoose[ct]) 
		{
			SetMenuBtnIndexImg(ChooseType(ct), focus);
			break;
		}
	}
}



