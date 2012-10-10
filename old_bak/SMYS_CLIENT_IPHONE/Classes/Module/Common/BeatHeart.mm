/*
 *  BeatHeart.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-20.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "BeatHeart.h"
#include "NDDataTransThread.h"
#include "NDNetMsg.h"
#include "GameScene.h"
#include "NDUtility.h"
#include "define.h"
#include "NDUISynLayer.h"
#include "GlobalDialog.h"

#define BeatHeartTimerTag (5555)

#define BeatHeartSendInterval (10.0f)

#define BeatHeartTipCount (3)

IMPLEMENT_CLASS(NDBeatHeart, NDObject)

NDBeatHeart::NDBeatHeart()
{
	NDNetMsgPoolObj.RegMsg(MB_LOGINSYSTEM_BEAT_HEART, this);
	
	m_bStart = false;
	
	m_timer = NULL;
	
	resetBeatData();
}

NDBeatHeart::~NDBeatHeart()
{
	if (m_bStart) reverseState();
	
	resetBeatData();
}

// 登录成功启动心跳
void NDBeatHeart::Start()
{
	if (!m_bStart) reverseState();
}

// 退出游戏结束心跳
void NDBeatHeart::Stop()
{
	if (m_bStart) reverseState();
	
	resetBeatData();
}

// 有服务端消息到达
void NDBeatHeart::HadServerMsgArrive()
{
	if (!m_bStart) return;
	
	resetBeatData();
}

void NDBeatHeart::OnTimer(OBJID tag)
{
	if (!m_bStart) 
	{
		if (m_timer)
		{
			m_timer->KillTimer(this, BeatHeartTimerTag);
			
			delete m_timer;
			
			m_timer = NULL;
		}
		
		resetBeatData();
		
		return;
	}
	
	if (m_uiSendBeatCount == BeatHeartTipCount) 
	{
		m_uiSendBeatCount = 0;
		
		m_uiHadTipCount++;
		
		AddTipCount();
	}
	
	//SEND BEAT HEART
	NDTransData bao(MB_LOGINSYSTEM_BEAT_HEART);
	SEND_DATA(bao);
	
	m_uiSendBeatCount++;
}

bool NDBeatHeart::process(MSGID msgID, NDTransData* data, int len)
{
	if (msgID == MB_LOGINSYSTEM_BEAT_HEART && m_bStart) 
	{
		HadServerMsgArrive();
	}
	
	return true;
}

void NDBeatHeart::reverseState()
{
	m_bStart = !m_bStart;
	
	if (m_bStart && !m_timer) 
	{
		m_timer = new NDTimer;
		
		m_timer->SetTimer(this, BeatHeartTimerTag, BeatHeartSendInterval);
	}
	
	if (!m_bStart && m_timer) 
	{
		m_timer->KillTimer(this, BeatHeartTimerTag);
		
		delete m_timer;
		
		m_timer = NULL;
	}
	
	resetBeatData();
}

void NDBeatHeart::resetBeatData()
{
	m_uiSendBeatCount = 0;
	
	m_uiHadTipCount = 0;
}

void NDBeatHeart::AddTipCount()
{
	if (m_uiHadTipCount == 1) 
	{
		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("NetExceptFirst"));
	}
	else if (m_uiHadTipCount == 2)
	{
		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("NetExceptSecond"));
	}
	else if (m_uiHadTipCount == 3)
	{
		CloseProgressBar;
		
		GameQuitDialog::DefaultShow(NDCommonCString("NetErr"), NDCommonCString("NetExceptErr"));
		/*
		GameQuitDialog *dlg = new GameQuitDialog;
		dlg->Initialization();
		dlg->Show("通讯出错", "非常抱歉，与服务器断开链接，请回到标题重新登录。", "回到标题", NULL);	
		*/
		if (NDDataTransThread::DefaultThread()->GetThreadStatus() == ThreadStatusRunning) 
		{
			NDDataTransThread::DefaultThread()->Stop();
		}
	}
}