//
//  GameSceneLoading.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "GameSceneLoading.h"
#import "NDDirector.h"
#import "CGPointExtension.h"
#import "NDUtility.h"
#include "NDUIImage.h"
#include "NDMessageCenter.h"
#include "NDMsgDefine.h"
#include "NDBeforeGameMgr.h"
#include "NDDataTransThread.h"
#include "InitMenuScene.h"
#include "NDPath.h"


#define TIMER_TAG_NET (1)

	
IMPLEMENT_CLASS(GameSceneLoading, NDScene)

GameSceneLoading* GameSceneLoading::Scene(bool connect/*=false*/, LoginType login/*=LoginTypeNone*/)
{
	GameSceneLoading* scene = new GameSceneLoading();
	scene->Initialization(connect, login);
	return scene;
}

GameSceneLoading::GameSceneLoading()
{
	m_lbTitle = NULL;
	m_tangRole = NULL;
	m_suiRole = NULL;
	
	interval = 0;
	
	x = -10.0f;
	
	m_timerNet = NULL;
	
	m_picBg = NULL;
	
	m_imageProcess = NULL;
}

GameSceneLoading::~GameSceneLoading()
{
	if (m_timerNet)
	{
		m_timerNet->KillTimer(this, TIMER_TAG_NET);
		delete m_timerNet;
	}
	//this->RemoveAllChildren(true);
	
	SAFE_DELETE(m_picBg);
	
	SAFE_DELETE_NODE(m_imageProcess);
}

void GameSceneLoading::Initialization(bool connect/*=false*/, LoginType login/*=LoginTypeNone*/)
{
	NDScene::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_layer = new NDUILayer();
	m_layer->Initialization();
	m_layer->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	this->AddChild(m_layer);
	
	//NSString * nsstr = [NSString stringWithFormat:@"%@%s", [[NSBundle mainBundle] resourcePath], "/loading.png"];//--Guosem 2012.8.14 真机上该文件因处与XX.app目录下被自动压缩，解码出错，故用资源目录下的替换
	NDPicturePool& pool		= *(NDPicturePool::DefaultPool());
	NDUIImage* imgBack	= new NDUIImage;
	imgBack->Initialization();
	imgBack->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
    NDPicture* pic = pool.AddPicture( NDPath::GetImgPath("Res00/Load/bg_load.png") );//([nsstr UTF8String]);//用资源目录下的替换
    if (pic) {
        //pic->Rotation(PictureRotation270);//--Guosem 2012.8.14 用资源目录下的图不旋转了
        imgBack->SetPicture(pic, true);
    }
	m_layer->AddChild(imgBack);
	
	//m_lbTitle = new NDUILabel();
//	m_lbTitle->Initialization();
//	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
//	m_lbTitle->SetFontSize(15);
//	m_lbTitle->SetFontColor(ccc4(0, 255, 0, 255));
//	if (!connect) 
//	{
//		m_lbTitle->SetText(NDCommonCString("ReadingGameInfo"));
//	}
//
//	m_lbTitle->SetFrameRect(CGRectMake(0, 228, winSize.width, 16));
//	m_layer->AddChild(m_lbTitle);
	
	/*
	NDUIImage* imgLogo = new NDUIImage;
	imgLogo->Initialization();
	NDPicture* picLogo = new NDPicture;
	picLogo->Initialization(GetImgPath("tradeMark.png"));
	imgLogo->SetPicture(picLogo, true);
	imgLogo->SetFrameRect(CGRectMake(190, 45, 100, 100));
	m_layer->AddChild(imgLogo);
	*/
	
	//m_suiRole = new NDManualRole;
//	m_suiRole->InitNonRoleData("", 1000000, 1);
//	//m_suiRole->SetEquipment(20020, 9);
//	//m_suiRole->UpdateState(USERSTATE_CAMP, true);
//	//m_suiRole->SetCamp(CAMP_TYPE_SUI);
//	m_suiRole->SetPosition(CGPointMake(480, 193));
//	m_suiRole->SetCurrentAnimation(MANUELROLE_WALK, YES);
//	m_suiRole->DirectRight(false);
//	//m_suiRole->updateFlagOfQiZhi();
//	m_layer->AddChild(m_suiRole);
	
	//m_tangRole = new NDManualRole;
//	m_tangRole->InitNonRoleData("", 1000000, 2);
//	//m_tangRole->SetEquipment(20020, 9);
//	//m_tangRole->UpdateState(USERSTATE_CAMP, true);
//	//m_tangRole->SetCamp(CAMP_TYPE_TANG);
//	m_tangRole->SetPosition(CGPointMake(0, 193));
//	m_tangRole->SetCurrentAnimation(MANUELROLE_WALK, YES);
//	m_tangRole->DirectRight(true);
//	//m_tangRole->updateFlagOfQiZhi();
//	m_layer->AddChild(m_tangRole);
//	m_timer.SetTimer(this, 0, 60.0f);
	
	if (connect)
	{
		m_timerNet = new NDTimer;
		m_timerNet->SetTimer(this, TIMER_TAG_NET, 0.5f);
	}
	
	//m_curLoginType = login;
//	
//	m_picBg = new NDPicture;
//	m_picBg->Initialization(GetImgPathNew("loading.png"));
//	
//	NDPicture*picProcess = new NDPicture;
//	picProcess->Initialization(GetImgPathNew("login_progress.png"));
//	m_imageProcess = new NDUIImage;
//	m_imageProcess->Initialization();
//	m_imageProcess->SetPicture(picProcess, true);
//	m_imageProcess->SetFrameRect(CGRectMake(127, 275, picProcess->GetSize().width, picProcess->GetSize().height));
}

void GameSceneLoading::OnTimer(OBJID tag)
{
	if	(tag == TIMER_TAG_NET)
	{
		m_timerNet->KillTimer(this, TIMER_TAG_NET);
		delete m_timerNet;
		m_timerNet = NULL;
		// 检测版本不在这里处理了
		/*
		NDBeforeGameMgrObj.CheckVersion();
		m_lbTitle->SetText("检测版本更新...");
		*/
		CheckVersionSucess();
	}
	else if (tag == 0)
	{
		m_timer.KillTimer(this, 0);
		/*
		NDTransData *data = new NDTransData(_MSG_GAME_QUIT); //quit game message
		NDMessageCenter::DefaultMessageCenter()->AddMessage(data);*/
		NDNetMsgMgr::GetSingleton().AddBackToMenuPacket();
	}
}

void GameSceneLoading::UpdateTitle(const string& strTitle)
{
	m_lbTitle->SetText(strTitle.c_str());
}

void GameSceneLoading::draw()
{
	NDScene::draw();
	
	return;
	
	if (interval > 134) 
		interval = 0;
	else 
		interval += 5;
	//DrawRecttangle(CGRectMake(176, 210, 134, 10), ccc4(125, 125, 125, 255));
	//DrawRecttangle(CGRectMake(176, 210, interval, 10), ccc4(0, 255, 0, 255));
	
	if (m_imageProcess)
	{
		float percent = interval / (float)134;
		
		CGRect rect = m_imageProcess->GetFrameRect();
		rect.size.width =  232 * percent;
		
		m_imageProcess->SetFrameRect(rect);
		
		m_imageProcess->draw();
	}
	
	if (m_picBg)
	{
		m_picBg->DrawInRect(CGRectMake(0, 0, 480, 320));
	}
	
	
	m_suiRole->SetPosition(CGPointMake(x, 193.0f));
	m_suiRole->RunAnimation(true);
	
	m_tangRole->SetPosition(CGPointMake(480.0f - x, 193.0f));
	m_tangRole->RunAnimation(true);
	
	x += 5.0f;
	
	if (x > 490.0f) {
		x = 0.0f;
	}	
}

bool GameSceneLoading::Login(bool failBackToMenu)
{
	NDDataTransThread::DefaultThread()->Start(NDBeforeGameMgrObj.GetServerIP().c_str(), NDBeforeGameMgrObj.GetServerPort());
	if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
	{
		if (failBackToMenu)
			NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
		return false;
	}
	
	NDBeforeGameMgrObj.Login();
	
	return true;
}

void GameSceneLoading::DealNet()
{
	switch (m_curLoginType) {
		case LoginTypeNone:
		case LoginTypeSecond:
			Login(true);
			break;
		case LoginTypeFirst:
		{
			NDBeforeGameMgr& mgr = NDBeforeGameMgrObj;
			if (!mgr.IsCMNet()) 
			{
				mgr.SwitchToCMNet();
			}
			
			if (!Login(false))
			{
				//mgr.DownLoadServerList(true);
				
				Login(true);
			}
		}
			break;

		default:
			break;
	}
	//NDBeforeGameMgrObj.SwitchToCMNet();
	
	//NDDataTransThread::DefaultThread()->Start(NDBeforeGameMgrObj.GetServerIP().c_str(), NDBeforeGameMgrObj.GetServerPort());
//	if (NDDataTransThread::DefaultThread()->GetThreadStatus() != ThreadStatusRunning)	
//	{
//		NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
//		return;
//	}
//	
//	NDBeforeGameMgrObj.CheckVersionAndLogin();
}

void GameSceneLoading::CheckVersionSucess()
{
	if (m_lbTitle)
		m_lbTitle->SetText(NDCommonCString("ConnectingServer"));
	
	DealNet();
}
