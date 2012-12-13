//
//  GameSceneLoading.mm
//  DragonDrive
//
//  Created by xiezhenghai on 11-1-5.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#include "GameSceneLoading.h"
#include "NDDirector.h"
#include "CCPointExtension.h"
#include "NDUtility.h"
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
	
	CCSize winSize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	m_layer = new NDUILayer();
	m_layer->Initialization();
	m_layer->SetFrameRect(CCRectMake(0, 0, winSize.width, winSize.height));
	this->AddChild(m_layer);
	

	NDUIImage* imgBack	= new NDUIImage;
	imgBack->Initialization();
	imgBack->SetFrameRect(CCRectMake(0, 0, winSize.width, winSize.height));
    NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture( NDPath::GetImg00Path("Res00/Load/bg_load.png") );
    if (pic) 
	{
        //pic->Rotation(PictureRotation270);//--Guosem 2012.8.14 用资源目录下的图不旋转了
        imgBack->SetPicture(pic, true);
    }
	m_layer->AddChild(imgBack);

	if (connect)
	{
		m_timerNet = new NDTimer;
		m_timerNet->SetTimer(this, TIMER_TAG_NET, 0.5f);
	}
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
		NDBaseNetMsgPoolObj.AddBackToMenuPacket();
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
	//DrawRecttangle(CCSizeMake(176, 210, 134, 10), ccc4(125, 125, 125, 255));
	//DrawRecttangle(CCSizeMake(176, 210, interval, 10), ccc4(0, 255, 0, 255));
	
	if (m_imageProcess)
	{
		float percent = interval / (float)134;
		
		CCRect rect = m_imageProcess->GetFrameRect();
		rect.size.width =  232 * percent;
		
		m_imageProcess->SetFrameRect(rect);
		
		m_imageProcess->draw();
	}
	
	if (m_picBg)
	{
		m_picBg->DrawInRect(CCRectMake(0, 0, 480, 320));
	}
	
	
	m_suiRole->SetPosition(CCPointMake(x, 193.0f));
	m_suiRole->RunAnimation(true);
	
	m_tangRole->SetPosition(CCPointMake(480.0f - x, 193.0f));
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
			//NDDirector::DefaultDirector()->ReplaceScene(InitMenuScene::Scene(true), true);
		return false;
	}
	
	NDBeforeGameMgrObj.Login();
	
	return true;
}

void GameSceneLoading::DealNet()
{
	switch (m_curLoginType) 
	{
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
				Login(true);
			}
		}
		break;

	default:
		break;
	}
}

void GameSceneLoading::CheckVersionSucess()
{
	if (m_lbTitle)
		m_lbTitle->SetText(NDCommonCString("ConnectingServer").c_str());
	
	DealNet();
}
