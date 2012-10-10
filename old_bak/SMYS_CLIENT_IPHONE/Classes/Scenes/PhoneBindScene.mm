/*
 *  PhoneBindScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PhoneBindScene.h"
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
#include "NDBeforeGameMgr.h"
#include "InitMenuScene.h"
#include "LoginScene.h"

IMPLEMENT_CLASS(PhoneBindScene, NDScene)

PhoneBindScene::PhoneBindScene()
{
	m_edtAccount = m_edtPhoneNum = m_edtPassword = NULL;
	
	m_btnCommit = m_btnRet = NULL;
}

PhoneBindScene::~PhoneBindScene()
{
	
}

PhoneBindScene* PhoneBindScene::Scene()
{
	PhoneBindScene* scene = new PhoneBindScene;
	scene->Initialization();
	
	return scene;
}

void PhoneBindScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	//NDPicturePool& picpool = *(NDPicturePool::DefaultPool());
	
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
	pic->Cut(CGRectMake(0, 8*24, 24*4, 24));
	NDUIImage *imgBind = new NDUIImage;
	imgBind->Initialization();
	imgBind->SetFrameRect(CGRectMake((winsize.width-pic->GetSize().width)/2, 16, pic->GetSize().width, pic->GetSize().height));
	imgBind->SetPicture(pic, true);
	layerControl->AddChild(imgBind);
	
	NDPicture *picShou = pool.AddPicture(GetImgPathNew("login_text.png"));
	picShou->Cut(CGRectMake(3*24, 5*24, 24, 24));
	NDPicture *picJi = pool.AddPicture(GetImgPathNew("login_text.png"));
	picJi->Cut(CGRectMake(4*24, 5*24, 24, 24));
	NDPicture *picZhang = pool.AddPicture(GetImgPathNew("login_text.png"));
	picZhang->Cut(CGRectMake(0, 4*24, 24, 24));
	NDPicture *picHao = pool.AddPicture(GetImgPathNew("login_text.png"));
	picHao->Cut(CGRectMake(24, 4*24, 24, 24));
	NDPicture *picMi = pool.AddPicture(GetImgPathNew("login_text.png"));
	picMi->Cut(CGRectMake(2*24, 4*24, 24, 24));
	NDPicture *picMa = pool.AddPicture(GetImgPathNew("login_text.png"));
	picMa->Cut(CGRectMake(3*24, 4*24, 24, 24));
	NDPicture*picHaoCopy = picHao->Copy();
	NDPicture*picMaCopy = picMa->Copy();
	
	int x = 79, y = 69;
	
	NDPicture* picPhoneNum[4] = { picShou, picJi, picHaoCopy, picMaCopy, };
	for (int i = 0; i < 4; i++) 
	{
		NDUIImage *image = new NDUIImage;
		image->Initialization();
		image->SetFrameRect(CGRectMake(x+24*i-4*i, y, 24, 24));
		image->SetPicture(picPhoneNum[i], true);
		layerControl->AddChild(image);
	}
	
	NDUIImage *image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x, y+24+20, 24, 24));
	image->SetPicture(picZhang, true);
	layerControl->AddChild(image);
	
	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x+60, y+44, 24, 24));
	image->SetPicture(picHao, true);
	layerControl->AddChild(image);
	
	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x, y+88, 24, 24));
	image->SetPicture(picMi, true);
	layerControl->AddChild(image);
	
	image = new NDUIImage;
	image->Initialization();
	image->SetFrameRect(CGRectMake(x+60, y+88, 24, 24));
	image->SetPicture(picMa, true);
	layerControl->AddChild(image);
	
	m_edtPhoneNum = new NDUICustomEdit();
	m_edtPhoneNum->Initialization(ccp(168, y-2), 226);
	m_edtPhoneNum->SetDelegate(this);
	//m_edtAccount->SetMinLength(6);
	//m_edtAccount->SetMaxLength(15);
	layerControl->AddChild(m_edtPhoneNum);
	
	m_edtAccount = new NDUICustomEdit();
	m_edtAccount->Initialization(ccp(168, y+44-2), 226);
	m_edtAccount->SetDelegate(this);
	//m_edtAccount->SetMinLength(6);
	//m_edtAccount->SetMaxLength(15);
	layerControl->AddChild(m_edtAccount);
	
	m_edtPassword = new NDUICustomEdit();
	m_edtPassword->Initialization(ccp(168, y+88-2), 226);
	m_edtPassword->SetDelegate(this);
	m_edtPassword->SetPassword(true);
	//m_edtAccount->SetMinLength(6);
	//m_edtAccount->SetMaxLength(15);
	layerControl->AddChild(m_edtPassword);

	NDPicture *picCommit = pool.AddPicture(GetImgPathNew("login_text.png"));
	picCommit->Cut(CGRectMake(0, 6*24, 24*2, 24));
	m_btnCommit = new NDUIImageButton;
	m_btnCommit->Initialization(CGRectMake(105, 251, 77, 26), picCommit);
	m_btnCommit->SetDelegate(this);
	layerControl->AddChild(m_btnCommit);
	
	NDPicture *picRet = pool.AddPicture(GetImgPathNew("login_text.png"));
	picRet->Cut(CGRectMake(24*2, 6*24, 24*2, 24));
	m_btnRet = new NDUIImageButton;
	m_btnRet->Initialization(CGRectMake(308, 251, 77, 26),picRet);
	m_btnRet->SetDelegate(this);
	layerControl->AddChild(m_btnRet);
}

void PhoneBindScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnCommit) 
	{
		std::string phonenum	= m_edtPhoneNum->GetText();
		std::string account		= m_edtAccount->GetText();
		std::string password	= m_edtPassword->GetText();
		
		if (phonenum.empty() || account.empty() || password.empty())
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("InputWholeInfo"));
			return;
		}
			
		if (phonenum.size() != 11) 
		{
			showDialog(NDCommonCString("tip"), NDCommonCString("PhoneNumErr"));
			return;
		}
		
		ShowProgressBar;
		
		m_time.SetTimer(this, 1, 0.1f);
		
		m_strAccount = account;
		
		m_strPassword = password;
		
		m_strPhoneNum = phonenum;
	}
	else if (button == m_btnRet)
	{
		NDDirector::DefaultDirector()->ReplaceScene(LoginScene::Scene(), true);
		//NDDirector::DefaultDirector()->PopScene(NULL, true);
	}
}


void PhoneBindScene::OnTimer(OBJID tag)
{
	m_time.KillTimer(this, tag);
	
	NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
	int socket = mgr.SynConnect();
	if (socket == -1) 
	{
		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
		return;
	}
	
	NDTransData bao(MB_MSG_MOBILE_PWD);		
	bao << (unsigned char)(0);
	bao.WriteUnicodeString(m_strAccount);
	bao.WriteUnicodeString(m_strPassword);
	bao.WriteUnicodeString(m_strPhoneNum);
	mgr.SynSEND_DATA(bao);
	
	mgr.SynProcessData();
	
	mgr.SynConnectClose();
	
	CloseProgressBar;
}
