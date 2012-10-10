/*
 *  FindBackPasswordScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "FindBackPasswordScene.h"
#include "NDUILayer.h"
#include "NDUIImage.h"
#include "NDUILabel.h"
#include "CGPointExtension.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "NDUISynLayer.h"
#include "NDMsgDefine.h"
#include "InitMenuScene.h"
#include "NDBeforeGameMgr.h"
#include "LoginScene.h"

#define time_tag_verify (1)
#define time_tag_account (2)

IMPLEMENT_CLASS(FindBackPasswordScene, NDScene)

FindBackPasswordScene::FindBackPasswordScene()
{
	m_edtAccount = m_edtVerifyCode = NULL;
	
	m_sendVerify = NULL;
	
	m_btnOk = m_btnCancel = NULL;
}

FindBackPasswordScene::~FindBackPasswordScene()
{

}

FindBackPasswordScene* FindBackPasswordScene::Scene()
{
	FindBackPasswordScene* scene = new FindBackPasswordScene;
	scene->Initialization();
	
	return scene;
}

void FindBackPasswordScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
	NDUILayer* layer = new NDUILayer();
	layer->Initialization();
	layer->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	layer->SetBackgroundImage(GetImgPathNew("login_background.png"));
	layer->SetTouchEnabled(false);
	this->AddChild(layer);
	
	NDUILayer* layerControl = new NDUILayer();
	layerControl->Initialization();
	layerControl->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	layerControl->SetBackgroundImage(GetImgPathNew("createrole_bg.png"));
	this->AddChild(layerControl);
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	NDPicture *pic = pool.AddPicture(GetImgPathNew("login_text.png"));
	pic->Cut(CGRectMake(0, 7*24, 24*4, 24));
	NDUIImage *imgFindBackPW = new NDUIImage;
	imgFindBackPW->Initialization();
	imgFindBackPW->SetFrameRect(CGRectMake((winsize.width-pic->GetSize().width)/2, 16, pic->GetSize().width, pic->GetSize().height));
	imgFindBackPW->SetPicture(pic, true);
	layerControl->AddChild(imgFindBackPW);
	
	NDPicture *picZhang = pool.AddPicture(GetImgPathNew("login_text.png"));
	picZhang->Cut(CGRectMake(0, 4*24, 24, 24));
	NDPicture *picHao = pool.AddPicture(GetImgPathNew("login_text.png"));
	picHao->Cut(CGRectMake(24, 4*24, 24, 24));
	NDPicture *picYang = pool.AddPicture(GetImgPathNew("login_text.png"));
	picYang->Cut(CGRectMake(4*24, 8*24, 24, 24));
	NDPicture *picZheng = pool.AddPicture(GetImgPathNew("login_text.png"));
	picZheng->Cut(CGRectMake(4*24, 9*24, 24, 24));
	NDPicture *picMa = pool.AddPicture(GetImgPathNew("login_text.png"));
	picMa->Cut(CGRectMake(3*24, 4*24, 24, 24));
	
	int x = 35, y = 66, interval = 5;
	
	NDUIImage *image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x, y, 24, 24));
	image->SetPicture(picZhang, true);
	layerControl->AddChild(image);
	
	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x+(24+interval)*2, y, 24, 24));
	image->SetPicture(picHao, true);
	layerControl->AddChild(image);
	
	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x, y+40, 24, 24));
	image->SetPicture(picYang, true);
	layerControl->AddChild(image);

	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x+(24+interval), y+40, 24, 24));
	image->SetPicture(picZheng, true);
	layerControl->AddChild(image);

	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x+(24+interval)*2, y+40, 24, 24));
	image->SetPicture(picMa, true);
	layerControl->AddChild(image);
	
	m_edtAccount = new NDUICustomEdit();
	m_edtAccount->Initialization(ccp(125, y-2), 187);
	m_edtAccount->SetDelegate(this);
	//m_edtAccount->SetMinLength(6);
	//m_edtAccount->SetMaxLength(15);
	layerControl->AddChild(m_edtAccount);
	
	m_edtVerifyCode = new NDUICustomEdit();
	m_edtVerifyCode->Initialization(ccp(125, y+40-2), 187);
	m_edtVerifyCode->SetDelegate(this);
	//m_edtAccount->SetMinLength(6);
	//m_edtAccount->SetMaxLength(15);
	layerControl->AddChild(m_edtVerifyCode);
	
	NDPicture *picVerify = picpool.AddPicture(GetImgPathNew("get_sms_btn.png"));
	CGSize sizeVerify = picVerify->GetSize();
	m_sendVerify = new NDUIButton();
	m_sendVerify->Initialization();
	m_sendVerify->SetFrameRect(CGRectMake(125+187+4, y+40-2+(31-sizeVerify.height)/2, sizeVerify.width, sizeVerify.height));
	m_sendVerify->SetDelegate(this);
	m_sendVerify->SetImage(picVerify, false, CGRectZero, true);
	m_sendVerify->SetTouchDownImage(picpool.AddPicture(GetImgPathNew("get_sms_btn_fcs.png")), false, CGRectZero, true);
	layerControl->AddChild(m_sendVerify);
	
	NDUILabel *lbTip = new NDUILabel;
	lbTip->Initialization();
	lbTip->SetFontColor(ccc4(19, 81, 92, 255));
	lbTip->SetFontSize(14);
	lbTip->SetFrameRect(CGRectMake(48, 179, (winsize.width-48*2), winsize.height));
	lbTip->SetText(NDCommonCString("FindBackTip"));
	layerControl->AddChild(lbTip);
	
	m_btnOk = new NDUIOkCancleButton;
	m_btnOk->Initialization(CGRectMake(105, 251, 77, 26), true);
	m_btnOk->SetDelegate(this);
	layerControl->AddChild(m_btnOk);
	
	m_btnCancel = new NDUIOkCancleButton;
	m_btnCancel->Initialization(CGRectMake(308, 251, 77, 26),false);
	m_btnCancel->SetDelegate(this);
	layerControl->AddChild(m_btnCancel);
}
 
void FindBackPasswordScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_sendVerify) 
	{
		std::string account		= m_edtAccount->GetText();
		
		if (account.empty()) 
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("InputAccount"));
			return;
		}
		
		ShowProgressBar;
		
		m_time.SetTimer(this, time_tag_account, 0.1f);
		
		m_strAccount = account;
	}
	else if (button == m_btnOk)
	{
		std::string account		= m_edtAccount->GetText();
		std::string verifycode	= m_edtVerifyCode->GetText();
		
		if (account.empty()) 
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("AccountCantEmpty"));
			return;
		}
		
		if (verifycode.empty()) 
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("VerifyCodeCantEmpty"));
			return;
		}
		
		ShowProgressBar;
		
		m_time.SetTimer(this, time_tag_account, 0.1f);
		
		m_strAccount = account;
		
		m_strCode = verifycode;
	}
	else if (button == m_btnCancel)
	{
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
		//NDDirector::DefaultDirector()->PopScene(NULL, true);
	}
}

void FindBackPasswordScene::OnTimer(OBJID tag)
{
	m_time.KillTimer(this, tag);
	
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	int socket = mgr.SynConnect();
	if (socket == -1) 
	{
		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
		return;
	}
	
	if (tag == time_tag_account) 
	{
		NDTransData bao(MB_MSG_MOBILE_PWD);
		bao << (unsigned char)(1);
		bao.WriteUnicodeString(m_strAccount);
		mgr.SynSEND_DATA(bao);
	}
	else if (tag == time_tag_verify) 
	{
		NDTransData bao(MB_MSG_MOBILE_PWD);
		bao << (unsigned char)(2);
		bao.WriteUnicodeString(m_strAccount);
		bao.WriteUnicodeString(m_strCode);
		mgr.SynSEND_DATA(bao);
	}
	
	mgr.SynProcessData();
	
	mgr.SynConnectClose();
	
	CloseProgressBar;
}

