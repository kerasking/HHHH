/*
 *  RegisterAccountScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import "RegisterAccountScene.h"
#import "CGPointExtension.h"
#import "NDBeforeGameMgr.h"
#import "NDDirector.h"
#import "InitMenuScene.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"

/*
IMPLEMENT_CLASS(RegisterAccountScene, NDScene)

RegisterAccountScene* RegisterAccountScene::Scene()
{	
	RegisterAccountScene* scene = new RegisterAccountScene();	
	scene->Initialization();	
	return scene;
}

RegisterAccountScene::RegisterAccountScene()
{
	m_menuLayer = NULL;
	m_frame = NULL;
	m_lbTitle = NULL;
	m_lbAccount = NULL;
	m_lbPwd = NULL;
	m_edtAccount = NULL;
	m_edtPwd = NULL;
	m_inputView = NULL;
	m_btnRegister = NULL;
	m_lbTip1 = NULL;
	m_lbTip2 = NULL;
	m_input = NULL;
}

RegisterAccountScene::~RegisterAccountScene()
{	
}

void RegisterAccountScene::Initialization()
{
	NDScene::Initialization();
	
	m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	m_menuLayer->SetDelegate(this);
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	m_frame = new NDUIFrame();
	m_frame->Initialization();
	m_frame->SetFrameRect(CGRectMake(100, 43, 280, 80));
	m_menuLayer->AddChild(m_frame);
	
	m_lbTitle = new NDUILabel();
	m_lbTitle->Initialization();
	m_lbTitle->SetText("注册");
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFontSize(20);
	m_lbTitle->SetFontColor(ccc4(255, 231, 0,255));
	m_lbTitle->SetFrameRect(CGRectMake(0, 5, 480, 20));
	//m_lbTitle->Initialization("注册", 20, LabelDisplayHorizontal, LabelTextAlignmentCenter);
	//m_lbTitle->SetPosition(ccp(0, 5));
	//m_lbTitle->SetFontColor(ccc3(255, 231, 0));
	m_menuLayer->AddChild(m_lbTitle);
	
	m_lbAccount = new NDUILabel();
	m_lbAccount->Initialization();
	m_lbAccount->SetText("账号");
	m_lbAccount->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbAccount->SetFontSize(20);
	m_lbAccount->SetFontColor(ccc4(24, 85, 82,255));
	m_lbAccount->SetFrameRect(CGRectMake(150, 50, 480, 20));
	//m_lbAccount->Initialization("账号", 20, LabelDisplayHorizontal, LabelTextAlignmentLeft);
	//m_lbAccount->SetPosition(ccp(160, 50));
	//m_lbAccount->SetFontColor(ccc3(24, 85, 82));
	m_menuLayer->AddChild(m_lbAccount);
	
	m_lbPwd = new NDUILabel();
	m_lbPwd->Initialization();
	m_lbPwd->SetText("密码");
	m_lbPwd->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbPwd->SetFontSize(20);
	m_lbPwd->SetFontColor(ccc4(24, 85, 82,255));
	m_lbPwd->SetFrameRect(CGRectMake(150, 90, 480, 20));
	//m_lbPwd->Initialization("密码", 20, LabelDisplayHorizontal, LabelTextAlignmentLeft);
	//m_lbPwd->SetPosition(ccp(160, 90));
	//m_lbPwd->SetFontColor(ccc3(24, 85, 82));
	m_menuLayer->AddChild(m_lbPwd);
	
	m_edtAccount = new NDUIEdit();
	m_edtAccount->Initialization();
	m_edtAccount->SetFrameRect(CGRectMake(100, 10, 130, 24));
	m_edtAccount->SetDelegate(this);
	m_edtAccount->SetMaxLength(15);
	m_edtAccount->SetMinLength(6);
	m_frame->AddChild(m_edtAccount);
	
	m_edtPwd = new NDUIEdit();
	m_edtPwd->Initialization();
	m_edtPwd->SetFrameRect(CGRectMake(100, 46, 130, 24));
	m_edtPwd->SetDelegate(this);
	m_edtPwd->SetMaxLength(10);
	m_edtPwd->SetPassword(true);
	m_edtPwd->SetMaxLength(12);
	m_edtPwd->SetMinLength(7);
	m_frame->AddChild(m_edtPwd);
	
	m_btnRegister = new NDUIButton();
	//m_btnRegister->Initialization(ButtonDisplayHorizontal);
	m_btnRegister->Initialization();
	m_btnRegister->SetFrameRect(CGRectMake(15, 133, 450, 32));
	m_btnRegister->SetTitle("提交注册");
	m_btnRegister->SetDelegate(this);
	m_menuLayer->AddChild(m_btnRegister);
	
	m_lbTip1 = new NDUILabel();
	m_lbTip1->Initialization();
	m_lbTip1->SetText("用户名密码仅支持英文或数字");
	m_lbTip1->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTip1->SetFontSize(15);
	m_lbTip1->SetFontColor(ccc4(12, 29, 10,255));
	m_lbTip1->SetFrameRect(CGRectMake(149, 196, 480, 20));
	//m_lbTip1->Initialization("用户名密码仅支持英文或数字", 15, LabelDisplayHorizontal, LabelTextAlignmentLeft);
	//m_lbTip1->SetPosition(ccp(149, 196));
	//m_lbTip1->SetFontColor(ccc3(12, 29, 10));
	m_menuLayer->AddChild(m_lbTip1);
	
	m_lbTip2 = new NDUILabel();
	m_lbTip2->Initialization();
	m_lbTip2->SetText("用户名6-15位,密码7-12位");
	m_lbTip2->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbTip2->SetFontSize(15);
	m_lbTip2->SetFontColor(ccc4(12, 29, 10,255));
	m_lbTip2->SetFrameRect(CGRectMake(159, 226, 480, 15));
	//m_lbTip2->Initialization("用户名6-10位,密码7-12位", 15, LabelDisplayHorizontal, LabelTextAlignmentLeft);
	//m_lbTip2->SetPosition(ccp(159, 226));
	//m_lbTip2->SetFontColor(ccc3(12, 29, 10));
	m_menuLayer->AddChild(m_lbTip2);
}

void RegisterAccountScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnRegister) 
	{
		std::string strUserName = m_edtAccount->GetText();
		std::string strPassWord = m_edtPwd->GetText();
		
		if (strUserName.empty() || strUserName.size() < 6 || strUserName.size() > 15)
		{
			showDialog(NDCommonCString("tip"), "用户名不合法");
			return;
		}
		
		if (strPassWord.empty() || strPassWord.size() < 7 || strPassWord.size() > 12)
		{
			showDialog(NDCommonCString("tip"), "密码不合法");
			return;
		}
		
		ShowProgressBar;
		
		NDBeforeGameMgrObj.RegisterAccout(strUserName, strPassWord);
	}
	else if ( m_menuLayer && (button == m_menuLayer->GetCancelBtn()) )
	{
		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(), true);
	}
}

bool RegisterAccountScene::OnEditClick(NDUIEdit* edit)
{
	m_input = new NDUICustomView();
	m_input->Initialization();
	
	std::vector<int> tags;
	tags.push_back(0);
	tags.push_back(1);
	
	std::vector<std::string> titles;
	titles.push_back("请输入账号(只能由数字或字母组成，6-15位)");
	titles.push_back("请输入密码(只能由数字或字母组成，7-12位)");
	
	m_input->SetEdit(2, tags, titles);
	m_input->SetDelegate(this);
	
	m_input->SetEditMaxLength(15, 0);
	m_input->SetEditMinLength(6, 0);
	
	m_input->SetEditMaxLength(12, 1);
	m_input->SetEditMinLength(7, 1);
	
	m_input->SetEditText(m_edtAccount->GetText().c_str(), 0);
	m_input->SetEditText(m_edtPwd->GetText().c_str(), 1);
	
	m_input->SetOkCancleButtonPosY(125);
	
	m_input->Show();
	return false;
}

bool RegisterAccountScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	m_edtAccount->SetText(m_input->GetEditText(0).c_str());
	m_edtPwd->SetText(m_input->GetEditText(1).c_str());
	return true;
}
*/

#pragma mark 新的注册帐号

IMPLEMENT_CLASS(NewRegisterAccountScene, NDScene)

NewRegisterAccountScene* NewRegisterAccountScene::Scene()
{	
	NewRegisterAccountScene* scene = new NewRegisterAccountScene();	
	scene->Initialization();	
	return scene;
}

NewRegisterAccountScene::NewRegisterAccountScene()
{
	m_menuLayer = NULL;

	m_edtAccount = NULL;
	m_edtPwd = NULL;
	
	m_btnOk = NULL;
	m_btnCancel = NULL;
	
	m_input = NULL;
}

NewRegisterAccountScene::~NewRegisterAccountScene()
{	
}

void NewRegisterAccountScene::Initialization()
{
	NDScene::Initialization();
	
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
	login->Cut(CGRectMake(0, 24*9, 96, 24));
	
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
	imageAccount->SetFrameRect(CGRectMake(72+40, 131-79-2, 48, 24));
	layerGame->AddChild(imageAccount);
	
	NDUIImage *imagePassword = new NDUIImage;
	imagePassword->Initialization();
	imagePassword->SetPicture(password, true);
	imagePassword->SetFrameRect(CGRectMake(72+40, 174-79-2-6, 48, 24));
	layerGame->AddChild(imagePassword);
	
	m_edtAccount = new NDUICustomEdit();
	m_edtAccount->Initialization(ccp(77+48+10+40, 126-79), 171);
	m_edtAccount->SetDelegate(this);
	m_edtAccount->SetMinLength(6);
	m_edtAccount->SetMaxLength(15);
	//m_edtAccount->SetText(m_loginData.GetData(kLoginData, kLastAccountName));
	layerGame->AddChild(m_edtAccount);
	
	m_edtPwd = new NDUICustomEdit();
	m_edtPwd->Initialization(ccp(77+48+10+40, 169-79-6), 171);
	m_edtPwd->SetDelegate(this);
	m_edtPwd->SetMinLength(7);
	m_edtPwd->SetMaxLength(12);
	m_edtPwd->SetPassword(true);
	//m_edtPwd->SetText(m_loginData.GetData(kLoginData, kLastAccountPwd));
	layerGame->AddChild(m_edtPwd);
	
	NDUILabel *lb = new NDUILabel;
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentLeft);
	lb->SetFontSize(12);
	lb->SetFrameRect(CGRectMake(72+4, 169-79-6+31+4, winSize.width, winSize.height));
	lb->SetText(NDCommonCString("AccountPWNeedRange6To15"));
	lb->SetFontColor(ccc4(107, 14, 14, 255));
	layerGame->AddChild(lb);
	
	lb = new NDUILabel;
	lb->Initialization();
	lb->SetTextAlignment(LabelTextAlignmentLeft);
	lb->SetFontSize(12);
	lb->SetFrameRect(CGRectMake(72+40, 169-79-6+31+4+20, winSize.width, winSize.height));
	lb->SetText(NDCommonCString("Use91Login"));
	lb->SetFontColor(ccc4(107, 14, 14, 255));
	layerGame->AddChild(lb);
	

	NDPicture *picCommit = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
	picCommit->Cut(CGRectMake(0, 6*24, 24*2, 24));
	m_btnOk = new NDUIImageButton;
	m_btnOk->Initialization(CGRectMake(101, 232-79+4, 77, 26), picCommit);
	m_btnOk->SetDelegate(this);
	layerGame->AddChild(m_btnOk);
	
	picCommit = picpool.AddPicture(GetImgPathNew("create&login_text.png"));
	picCommit->Cut(CGRectMake(24*2, 6*24, 24*2, 24));
	m_btnCancel = new NDUIImageButton;
	m_btnCancel->Initialization(CGRectMake(308, 232-79+4, 77, 26),picCommit);
	m_btnCancel->SetDelegate(this);
	layerGame->AddChild(m_btnCancel);
}

void NewRegisterAccountScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnOk) 
	{
		std::string strUserName = m_edtAccount->GetText();
		std::string strPassWord = m_edtPwd->GetText();
		
		if (strUserName.empty() || strUserName.size() < 6 || strUserName.size() > 15)
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("UseNameInvalid"));
			return;
		}
		
		if (strPassWord.empty() || strPassWord.size() < 7 || strPassWord.size() > 12)
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("PWInvalid"));
			return;
		}
		
		ShowProgressBar;
		
		NDBeforeGameMgrObj.RegisterAccout(strUserName, strPassWord);
	}
	else if ( m_menuLayer && (button == m_btnCancel) )
	{
		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(), true);
	}
}

bool NewRegisterAccountScene::OnEditClick(NDUIEdit* edit)
{
	m_input = new NDUICustomView();
	m_input->Initialization();
	
	std::vector<int> tags;
	tags.push_back(0);
	tags.push_back(1);
	
	std::vector<std::string> titles;
	titles.push_back(NDCommonCString("AccountNeedRange6To15"));
	titles.push_back(NDCommonCString("PWNeedRange7To12"));
	
	m_input->SetEdit(2, tags, titles);
	m_input->SetDelegate(this);
	
	m_input->SetEditMaxLength(15, 0);
	m_input->SetEditMinLength(6, 0);
	
	m_input->SetEditMaxLength(12, 1);
	m_input->SetEditMinLength(7, 1);
	
	m_input->SetEditText(m_edtAccount->GetText().c_str(), 0);
	m_input->SetEditText(m_edtPwd->GetText().c_str(), 1);
	
	m_input->SetOkCancleButtonPosY(125);
	
	m_input->SetEditPassword(true, 1);
	
	m_input->Show();
	this->AddChild(m_input);
	return false;
}

bool NewRegisterAccountScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	m_edtAccount->SetText(m_input->GetEditText(0).c_str());
	m_edtPwd->SetText(m_input->GetEditText(1).c_str());
	return true;
}

