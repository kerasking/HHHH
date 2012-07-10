//
//  LoginScene.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "LoginScene.h"
#import "CGPointExtension.h"
#import "GameSceneLoading.h"
#import "NDBeforeGameMgr.h"
#import "NDDirector.h"
#import "InitMenuScene.h"
#import "NDDataSource.h"
#import "NDString.h"
#import "NDDataTransThread.h"
#import "ServerListScene.h"
#include "FavoriteAccountList.h"
#include "NDBeforeGameMgr.h"
#include "NDUtility.h"
#include "define.h"
#include "NDUISynLayer.h"
#include "FindBackPasswordScene.h"
#include "PhoneBindScene.h"

IMPLEMENT_CLASS(LoginScene, NDScene)

LoginScene* LoginScene::Scene(bool changeServer/*=false*/)
{	
	LoginScene* scene = new LoginScene();	
	scene->Initialization(changeServer);	
	return scene;
}

LoginScene::LoginScene()
{
	m_menuLayer = NULL;
	m_frame = NULL;
	m_lbTitle = NULL;
	m_lbAccount = NULL;
	m_lbPwd = NULL;
	m_edtAccount = NULL;
	m_edtPwd = NULL;
	m_btnLogin = NULL;
	m_btnChangeAccount = NULL;
	m_btnChangeServer = NULL;
	//m_cbSavePassword = NULL;
	m_lbLastLoginServer = NULL;
	m_serverPort = 0;
	
	m_btnOk = NULL;
	m_btnCancel = NULL;
	
	
	m_btnBind = m_btnForgot = NULL;
	
	m_edtServer = NULL;
	
	m_hasClickChangeServer = false;
}

LoginScene::~LoginScene()
{	
}

void LoginScene::Initialization(bool changeServer/*=false*/)
{
	NDScene::Initialization();
	
	m_hasClickChangeServer = changeServer;
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	m_menuLayer = new NDUILayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	m_menuLayer->SetBackgroundImage(GetImgPathNew("login_background.png"));
	this->AddChild(m_menuLayer);
	
	NDUILayer *layerGame = new NDUILayer();
	layerGame->Initialization();
	layerGame->SetFrameRect(CGRectMake(0, 79, 480, 198));
	layerGame->SetBackgroundImage(GetImgPathNew("login_game_bg.png"));
	m_menuLayer->AddChild(layerGame);
	
	NDPicture *login = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
	login->Cut(CGRectMake(0, 24, 96, 24));
	
	NDUIImage *imageLogin = new NDUIImage;
	imageLogin->Initialization();
	imageLogin->SetPicture(login, true);
	imageLogin->SetFrameRect(CGRectMake(193, 94-79, 96, 24));
	layerGame->AddChild(imageLogin);
	
	NDPicture *account = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
	NDPicture *password = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
	
	account->Cut(CGRectMake(0, 96, 48, 24));
	password->Cut(CGRectMake(48, 96, 48, 24));
	
	NDUIImage *imageAccount = new NDUIImage;
	imageAccount->Initialization();
	imageAccount->SetPicture(account, true);
	imageAccount->SetFrameRect(CGRectMake(72, 131-79-2, 48, 24));
	layerGame->AddChild(imageAccount);
	
	NDUIImage *imagePassword = new NDUIImage;
	imagePassword->Initialization();
	imagePassword->SetPicture(password, true);
	imagePassword->SetFrameRect(CGRectMake(72, 174-79-2-6, 48, 24));
	layerGame->AddChild(imagePassword);
	
	m_edtAccount = new NDUICustomEdit();
	m_edtAccount->Initialization(ccp(77+48+10, 126-79), 137);
	m_edtAccount->SetDelegate(this);
	m_edtAccount->SetMinLength(6);
	m_edtAccount->SetMaxLength(15);
	m_edtAccount->SetText(m_loginData.GetData(kLoginData, kLastAccountName));
	layerGame->AddChild(m_edtAccount);
	
	m_edtPwd = new NDUICustomEdit();
	m_edtPwd->Initialization(ccp(77+48+10, 169-79-6), 171);
	m_edtPwd->SetDelegate(this);
	m_edtPwd->SetMinLength(7);
	m_edtPwd->SetMaxLength(12);
	m_edtPwd->SetPassword(true);
	m_edtPwd->SetText(m_loginData.GetData(kLoginData, kLastAccountPwd));
	layerGame->AddChild(m_edtPwd);
	
	NDPicture* picList = picpool.AddPicture(GetImgPathNew("list_btn.png"));
	CGSize sizeList = picList->GetSize();
	m_btnChangeAccount = new NDUIButton();
	m_btnChangeAccount->Initialization();
	m_btnChangeAccount->SetFrameRect(CGRectMake(77+48+10+137+3, 126-79, sizeList.width, sizeList.height));
	m_btnChangeAccount->SetImage(picList, false, CGRectZero, true);
	//m_btnChangeAccount->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("changeaccount_hightlight.png")), false, CGRectZero, true);
	m_btnChangeAccount->SetDelegate(this);
	
	layerGame->AddChild(m_btnChangeAccount);
	
	NDPicture *picBind = picpool.AddPicture(GetImgPathNew("bind_phone_btn.png"));
	CGSize sizeBind = picBind->GetSize();
	m_btnBind = new NDUIButton();
	m_btnBind->Initialization();
	m_btnBind->SetFrameRect(CGRectMake(77+48+10+137+3+sizeList.width+6, 126-79+(sizeList.height-sizeBind.height)/2, sizeBind.width, sizeBind.height));
	m_btnBind->SetDelegate(this);
	m_btnBind->SetImage(picBind, false, CGRectZero, true);
	m_btnBind->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("bind_phone_btn_fcs.png")), false, CGRectZero, true);
	layerGame->AddChild(m_btnBind);
	
	/*
	m_btnChangeServer = new NDUIButton();
	m_btnChangeServer->Initialization();
	m_btnChangeServer->SetFrameRect(CGRectMake(217+48+8, 174-79, 140, 25));
	m_btnChangeServer->SetDelegate(this);
	m_btnChangeServer->SetImage(picpool.AddPicture(GetImgPathNew("changeserver_normal.png")), false, CGRectZero, true);
	m_btnChangeServer->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("changeserver_hightlight.png")), false, CGRectZero, true);
	layerGame->AddChild(m_btnChangeServer);
	*/
	
	m_cbSavePassword	= new NDUICheckBox;
	m_cbSavePassword->Initialization(
						picpool.AddPicture(GetImgPathNew("check_sel.png")),
						picpool.AddPicture(GetImgPathNew("check_unsel.png")),
						true);
	m_cbSavePassword->SetFrameRect(CGRectMake(77+48+10+171+8, 169-79+5-6, 40, 30));
	m_cbSavePassword->SetDelegate(this);
	//m_cbSavePassword->SetText("保存密码");
	m_cbSavePassword->ChangeCBState();
	layerGame->AddChild(m_cbSavePassword);
	
	NDCombinePicture *combinePicSavePassword = new NDCombinePicture;
	for (int i = 0; i < 4; i++) 
	{
		NDPicture *pic = picpool.AddPicture(GetImgPathNew("create&login_text2.png"));
		pic->Cut(CGRectMake(180+1, 36+i*18, 15, 18));
		combinePicSavePassword->AddPicture(pic, CombintPictureAligmentRight);
	}
	
	NDUIImage *imageSavePassword = new NDUIImage;
	imageSavePassword->Initialization();
	imageSavePassword->SetCombinePicture(combinePicSavePassword, true);
	imageSavePassword->SetFrameRect(CGRectMake(77+48+10+171+10+15, 169-79+5+2-6, combinePicSavePassword->GetSize().width, combinePicSavePassword->GetSize().height));
	layerGame->AddChild(imageSavePassword);
	
	//NDPicture *server = picpool.AddPicture(GetImgPathNew("login_text.png"));
	//server->Cut(CGRectMake(0, 24*5, 24*3, 24));
	
	NDCombinePicture *combinePicServer = new NDCombinePicture;
	for (int i = 0; i < 3; i++) 
	{
		NDPicture *pic = picpool.AddPicture(GetImgPathNew("login_text.png"));
		pic->Cut(CGRectMake(2+i*24, 24*5, 19, 24));
		combinePicServer->AddPicture(pic, CombintPictureAligmentRight);
	}
	
	NDUIImage *imageServer = new NDUIImage;
	imageServer->Initialization();
	imageServer->SetCombinePicture(combinePicServer, true);
	imageServer->SetFrameRect(CGRectMake(72, 217-79-2-12, 19*3, 24));
	layerGame->AddChild(imageServer);
	
	m_edtServer = new NDUICustomEdit();
	m_edtServer->Initialization(ccp(77+48+10, 212-79-12), 137);
	m_edtServer->SetDelegate(this);
	//m_edtServer->SetMinLength(6);
	//m_edtServer->SetMaxLength(15);
	m_edtServer->ShowCaret(false);
	m_edtServer->SetText(NDBeforeGameMgrObj.GetServerDisplayName().c_str());
	layerGame->AddChild(m_edtServer);
	
	picList = picList->Copy();
	m_btnChangeServer = new NDUIButton();
	m_btnChangeServer->Initialization();
	m_btnChangeServer->SetFrameRect(CGRectMake(77+48+10+137+3, 212-79-12, sizeList.width, sizeList.height));
	m_btnChangeServer->SetImage(picList, false, CGRectZero, true);
	//m_btnChangeAccount->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("changeaccount_hightlight.png")), false, CGRectZero, true);
	m_btnChangeServer->SetDelegate(this);
	
	layerGame->AddChild(m_btnChangeServer);
	
	NDPicture *picForgot = picpool.AddPicture(GetImgPathNew("get_pass_btn.png"));
	CGSize sizeForgot = picForgot->GetSize();
	m_btnForgot = new NDUIButton();
	m_btnForgot->Initialization();
	m_btnForgot->SetFrameRect(CGRectMake(77+48+10+137+3+sizeList.width+6, 212-79-12+(sizeList.height-sizeForgot.height)/2, sizeForgot.width, sizeForgot.height));
	m_btnForgot->SetDelegate(this);
	m_btnForgot->SetImage(picForgot, false, CGRectZero, true);
	m_btnForgot->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("get_pass_btn_fcs.png")), false, CGRectZero, true);
	layerGame->AddChild(m_btnForgot);
	
//	NDPicture* picSavePassword = picpool.AddPicture(GetImgPathNew(""))
//	NDUIImage *imgSavePassword = new NDUIImage;
//	imgSavePassword->Initialization();
//	imgSavePassword->SetPicture(NDPicture *pic, true);
//	imgSavePassword->SetFrameRect(CGRectMake(150, 212, , <#CGFloat height#>))
	
	/*
	m_lbLastLoginServer = new NDUILabel();
	NSString* serverName = [NSString stringWithUTF8String:NDBeforeGameMgrObj.GetServerDisplayName().c_str()];
	NSString* lastServer = [NSString stringWithFormat:@"上次登录:%@", serverName];
	m_lbLastLoginServer->Initialization();
	m_lbLastLoginServer->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbLastLoginServer->SetText([lastServer UTF8String]);
	m_lbLastLoginServer->SetFrameRect(CGRectMake(176, 210-79, winSize.width, 20));
	m_lbLastLoginServer->SetFontSize(15);
	m_lbLastLoginServer->SetFontColor(ccc4(24, 60, 57, 255));
	layerGame->AddChild(m_lbLastLoginServer);
	*/
	
	m_btnOk = new NDUIOkCancleButton;
	m_btnOk->Initialization(CGRectMake(101, 232-79+4, 77, 26), true);
	m_btnOk->SetDelegate(this);
	layerGame->AddChild(m_btnOk);
	
	m_btnCancel = new NDUIOkCancleButton;
	m_btnCancel->Initialization(CGRectMake(308, 232-79+4, 77, 26),false);
	m_btnCancel->SetDelegate(this);
	layerGame->AddChild(m_btnCancel);
	
//	m_btnOk = new NDUIButton;
//	m_btnOk->Initialization();
//	m_btnOk->SetDelegate(this);
//	m_btnOk->SetBackgroundPicture(picpool.AddPicture(GetImgPathNew("btn_ok&cancel_normal.png"), 77), true);
//	m_btnOk->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("btn_ok&cancel_hightlight.png"), 77), false, CGRectZero, true);
//	NDPicture *picTextOk = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
//	picTextOk->Cut(CGRectMake(48, 72, 48, 24));
//	m_btnOk->SetImage(picTextOk, true, CGRectMake((77-picTextOk->GetSize().width)/2, (26-picTextOk->GetSize().height)/2, picTextOk->GetSize().width, picTextOk->GetSize().height), true);
//	m_btnOk->SetFrameRect(CGRectMake(101, 232-79, 77, 26));
//	layerGame->AddChild(m_btnOk);
//	
//	m_btnCancel = new NDUIButton;
//	m_btnCancel->Initialization();
//	m_btnCancel->SetDelegate(this);
//	m_btnCancel->SetBackgroundPicture(picpool.AddPicture(GetImgPathNew("btn_ok&cancel_normal.png"), 77), true);
//	m_btnCancel->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("btn_ok&cancel_hightlight.png"), 77), false, CGRectZero, true);
//	NDPicture *picTextCancel = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
//	picTextCancel->Cut(CGRectMake(48, 48, 48, 24));
//	m_btnCancel->SetImage(picTextCancel, true, CGRectMake((77-picTextCancel->GetSize().width)/2, (26-picTextCancel->GetSize().height)/2, picTextCancel->GetSize().width, picTextCancel->GetSize().height), true);
//	m_btnCancel->SetFrameRect(CGRectMake(308, 232-79, 77, 26));
//	layerGame->AddChild(m_btnCancel);
/*	
//	if ( m_menuLayer->GetCancelBtn() ) 
//	{
//		m_menuLayer->GetCancelBtn()->SetDelegate(this);
//	}
	
	m_frame = new NDUIFrame();
	m_frame->Initialization();
	m_frame->SetFrameRect(CGRectMake(100, 33, 280, 80));
	m_menuLayer->AddChild(m_frame);

	m_lbTitle = new NDUILabel();
	m_lbTitle->Initialization();
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetText("登录游戏");
	m_lbTitle->SetFrameRect(CGRectMake(0, 5, winSize.width, 20));
	m_lbTitle->SetFontSize(20);
	m_lbTitle->SetFontColor(ccc4(255, 231, 0, 255));
	m_menuLayer->AddChild(m_lbTitle);
	
	m_lbAccount = new NDUILabel();
	m_lbAccount->Initialization();
	m_lbAccount->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbAccount->SetText("账号");
	m_lbAccount->SetFrameRect(CGRectMake(160, 40, 100, 20));
	m_lbAccount->SetFontSize(20);
	m_lbAccount->SetFontColor(ccc4(24, 85, 82, 255));
	m_menuLayer->AddChild(m_lbAccount);
	
	m_lbPwd = new NDUILabel();
	m_lbPwd->Initialization();
	m_lbPwd->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbPwd->SetText("密码");
	m_lbPwd->SetFrameRect(CGRectMake(160, 80, 100, 20));
	m_lbPwd->SetFontSize(20);
	m_lbPwd->SetFontColor(ccc4(24, 85, 82, 255));
	m_menuLayer->AddChild(m_lbPwd);
	
	m_errorNote = new NDUILabel();
	m_errorNote->Initialization();
	m_errorNote->SetFontColor(ccc4(24, 85, 82, 255));
	m_errorNote->SetTextAlignment(LabelTextAlignmentCenter);
	m_errorNote->SetFontSize(20);
	m_errorNote->SetFrameRect(CGRectMake(0, 290, winSize.width, 20));
	m_menuLayer->AddChild(m_errorNote); 
	
	
	//m_edtAccount->SetMinLength(6);
	//m_edtAccount->SetMaxLength(10);
	m_frame->AddChild(m_edtAccount);
	
	
	
	m_btnLogin = new NDUIButton();
	m_btnLogin->Initialization();
	m_btnLogin->SetFrameRect(CGRectMake(15, 165, 450, 32));
	m_btnLogin->SetFontColor(ccc4(8, 32, 16, 255));
	m_btnLogin->SetBackgroundColor(ccc4(108, 158, 155, 255));
	m_btnLogin->SetTitle("登录");
	m_btnLogin->SetDelegate(this);
	m_menuLayer->AddChild(m_btnLogin);
	*/
	
	/*
	m_serverIP = m_loginData.GetLoginData(kLastServerIP);
	string strPort = m_loginData.GetLoginData(kLastServerPort);
	if (!strPort.empty())
	{
		m_serverPort = atoi(strPort.c_str());
	}
	 */
}

void LoginScene::SetServerInfo(const char* serverIP, const char* serverName, int serverPort)
{
	if (serverIP)
	{
		this->m_serverIP = serverIP;
	}
	
	if (serverName)
	{
		this->m_serverName = serverName;
		/*
		if (m_lbLastLoginServer)
		{
			NSString* name = [NSString stringWithUTF8String:serverName];
			NSString* lastServer = [NSString stringWithFormat:@"上次登录:%@", name];
			m_lbLastLoginServer->SetText([lastServer UTF8String]);
		}
		*/
		if (m_edtServer)
		{
			m_edtServer->SetText(serverName);
		}
	}
	
	this->m_serverPort = serverPort;
}

void LoginScene::SaveLoginData()
{
	std::string strUserName = m_edtAccount->GetText();
	std::string strPassWord = m_edtPwd->GetText();
	
	if (strUserName.empty() || strPassWord.empty()) 
	{
		return;
	}
	
	m_loginData.SetData(kLoginData, kLastAccountName, strUserName.c_str());
	if (m_cbSavePassword->GetCBState())
	{		
		m_loginData.SetData(kLoginData, kLastAccountPwd, strPassWord.c_str());
		m_loginData.AddAcount(strUserName.c_str(), strPassWord.c_str());
	}
	else
	{
		m_loginData.SetData(kLoginData, kLastAccountPwd, "");
		m_loginData.AddAcount(strUserName.c_str(), NULL);
	}
	
	m_loginData.SetData(kLoginData, kLastServerIP, NDBeforeGameMgrObj.GetServerIP().c_str());
	
	m_loginData.SetData(kLoginData, kLastServerName, NDBeforeGameMgrObj.GetServerDisplayName().c_str());	
	m_loginData.SetData(kLoginData, kLastServerSendName, NDBeforeGameMgrObj.GetServerName().c_str());	
	NSString* strPort = [NSString stringWithFormat:@"%d", NDBeforeGameMgrObj.GetServerPort()];
	m_loginData.SetData(kLoginData, kLastServerPort, [strPort UTF8String]);
	
	m_loginData.SaveLoginData();
	m_loginData.SaveAccountList();
}

void LoginScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnOk) 
	{
		if(NDBeforeGameMgrObj.GetServerIP().empty())
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("SelServer"));
			//m_errorNote->SetText("请先选择服务器");
			return;
		}
		// 网络初始化
		/*
		NDDataTransThread::DefaultThread()->Start(NDBeforeGameMgrObj.GetServerIP().c_str(), NDBeforeGameMgrObj.GetServerPort());
		if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning) 
		{
			//m_errorNote->SetText("网络连接失败，请检查网络配置");
			NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
			//showDialog(NDCommonCString("tip"), "网络连接失败，请检查网络配置");
			return;
		}
		*/
		
		std::string strUserName = m_edtAccount->GetText();
		std::string strPassWord = m_edtPwd->GetText();
		
		if ( strUserName.empty() || strPassWord.empty() ) 
		{
			//m_errorNote->SetText("密码不能为空");
			showDialog(NDCommonCString("tip"), NDCommonCString("PWCantEmpty"));
			return;
		}
		
		this->SaveLoginData();
		
		NDBeforeGameMgrObj.SetUserName(strUserName);
		NDBeforeGameMgrObj.SetPassWord(strPassWord);
		
		//NDBeforeGameMgrObj.CheckVersionAndLogin();
		LoginType logintype = LoginTypeFirst;
		if (m_hasClickChangeServer) 
		{
			logintype = LoginTypeSecond;
		}
		NDDirector::DefaultDirector()->ReplaceScene(GameSceneLoading::Scene(true, logintype));
	}
	else if ( m_menuLayer && (button == m_btnCancel) )
	{
		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(), true);
	}
	else if ( button == m_btnChangeServer )
	{
		NDDirector::DefaultDirector()->ReplaceScene(ServerListScene::Scene(), true);
	}
	else if (button == this->m_btnChangeAccount)
	{
		NDDirector::DefaultDirector()->ReplaceScene(NewFavoriteAccountList::Scene(), true);
	}
	else if (button == this->m_btnForgot)
	{
		NDDirector::DefaultDirector()->ReplaceScene(FindBackPasswordScene::Scene(), true);
	}	
	else if (button == this->m_btnBind)
	{
		NDDirector::DefaultDirector()->ReplaceScene(PhoneBindScene::Scene(), true);
	}
}

void LoginScene::SetUserNameText(const char* username)
{
	if (!username) {
		return;
	}
	
	m_edtAccount->SetText(username);
	this->SaveLoginData();
}

void LoginScene::SetPasswordText(const char* password)
{
	if (!password) {
		return;
	}
	
	m_edtPwd->SetText(password);
	this->SaveLoginData();
}

void LoginScene::OnEditInputFinish(NDUIEdit* edit)
{
	this->SaveLoginData();

#if ND_DEBUG_STATE == 1
	if (edit == m_edtAccount)
	{
		std::string str = m_edtAccount->GetText();
		if (str == "changeserver-i")
		{
			NDDataPersist loginData;
			loginData.SetData(kLoginData, kLinkType, "i_dd");
			loginData.SaveLoginData();
		}
		else if (str == "changeserver-o")
		{
			NDDataPersist loginData;
			loginData.SetData(kLoginData, kLinkType, "o");
			loginData.SaveLoginData();
		}
	}
#endif
}

bool LoginScene::OnEditClick(NDUIEdit* edit)
{
	if (edit == m_edtServer) 
	{
		NDDirector::DefaultDirector()->ReplaceScene(ServerListScene::Scene(), true);
		return false;
	}
		
	return true;
}

//void LoginScene::OnCBClick(NDUICheckBox* checkbox)
//{
//	if (checkbox->GetCBState()) 
//	{
//		//NDLog(@"当前处于选中状态");
//	}
//	else 
//	{
//		//NDLog(@"当前不处于选中状态");
//	}
//	
//}














