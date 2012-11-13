/*
 *  NDUISynLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-1-11.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "NDUISynLayer.h"
#include "NDScene.h"
#include "NDDirector.h"
#include "NDConstant.h"
#include "CCPointExtension.h"
#include "UISpriteNode.h"
#include "NDPath.h"
#include "NDAnimationGroup.h"
#include "GameScene.h"
#include "NDPlayer.h"

using namespace NDEngine;

NDUISynLayer* NDUISynLayer_instances = NULL;

IMPLEMENT_CLASS(NDUISynLayer, NDUILayer)

NDUISynLayer::NDUISynLayer()
{
	NDAsssert(NDUISynLayer_instances == NULL);
	/*
	m_texLine = [[CCTexture2D alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:GetImgPath("syn_track.png")]]];
	m_texBlock = [[CCTexture2D alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithUTF8String:GetImgPath("syn_btn.png")]]];	
	*/
	// 此设置只是使本层不接收消息,但是触摸消息会往下传,因此注释
	//this->SetTouchEnabled(false);
	
	//m_ShaLou = NULL;
}

NDUISynLayer::~NDUISynLayer()
{
	// 关闭的时候，恢复初始状态
	NDUISynLayer_instances = NULL;
//	[m_texLine release];
//	[m_texBlock release];
}

void NDUISynLayer::Show(SYN_TAG tag)
{
	// 玩家停止寻路
	NDScene* parentScene = NDDirector::DefaultDirector()->GetRunningScene();
	if (parentScene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
	{
		NDPlayer::defaultHero().stopMoving();
	}
	
	// 当前已经显示, 更新tag
	if (NDUISynLayer_instances)
	{
		NDUISynLayer_instances->m_tag = tag;
	}
	else
	{
		NDScene* parentScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (parentScene) {
			NDUISynLayer_instances = new NDUISynLayer();
			NDUISynLayer_instances->Initialization();
			NDUISynLayer_instances->m_tag = tag;
			NDUISynLayer_instances->SetTimeOut(15);
			
            //** chh 2012-0-17 **//
            //parentScene->AddChild(NDUISynLayer_instances, ScriptMgrObj.excuteLuaFuncRetN("GetProcessBarUIZOrder", ""),10000);
            parentScene->AddChild(NDUISynLayer_instances,9000);
		}
	}

}

bool NDUISynLayer::IsShown()
{
	return NDUISynLayer_instances != NULL;
}

void NDUISynLayer::Initialization()
{
	NDUILayer::Initialization();
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	this->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	
	CUISpriteNode *node = new CUISpriteNode;
	node->Initialization();
	node->ChangeSprite(NDPath::GetAniPath("busy.spr").c_str());//"loading.spr"//“程序忙碌”动画
	node->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	this->AddChild(node);
	/*
	this->m_ptLine = CGPointMake((winSize.width - 135) / 2, (winSize.height - 9) / 2);
	this->m_ptBlock = this->m_ptLine;
	this->m_cyclePosX = this->m_ptLine.x + 113.0f;
	
	m_lbText = new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetFontSize(13);
	m_lbText->SetFontColor(ccc4(255, 255, 255, 255));
	m_lbText->SetFrameRect(CGRectMake((winSize.width - 135) / 2 + 10, (winSize.height - 9) / 2-20, winSize.width, 13));
	m_lbText->SetText("");
	this->AddChild(m_lbText);	
	*/
	
//	m_ShaLou = new NDLightEffect;
//	m_ShaLou->Initialization(GetAniPath("sandglass1.spr"));
//	//m_ShaLou->SetPosition(ccp((51-32)/2, (320-220)/2+220+(320-(320-220)/2-220-32)/2));
//	m_ShaLou->SetPosition(ccp(51-32-5+5+9, 320-16-17));
//	m_ShaLou->SetLightId(0);

	
}

void NDUISynLayer::SetTimeOut(float seconds)
{
	m_timer.SetTimer(this, 1, seconds);
}

void NDUISynLayer::OnTimer(OBJID tag)
{
	// 超时关闭
	if (tag == 1)
	{
		/*
		NDUIDialog* dlgOverTime = new NDUIDialog;
		dlgOverTime->Initialization();
		dlgOverTime->Show(NDCommonCString("ConnectFail"), NDCommonCString("ConnectFailTip"), NULL, NULL);
		*/
		ScriptMgrObj.excuteLuaFunc<bool>("ShowYesDlg", "CommonDlgNew", NDCommonCString("ConnectFailTip"));
		Close(CLOSE);
		
//		NDDataTransThread::DefaultThread()->GetSocket()->Close();
//		NDDataTransThread::DefaultThread()->Stop();
//		NDDataTransThread::DefaultThread()->Start(NDDataTransThread::DefaultThread()->GetSocket()->GetIpAddress().c_str(), 
//												  NDDataTransThread::DefaultThread()->GetSocket()->GetPort());
		
	}
}

void NDUISynLayer::Close(SYN_TAG tag)
{
	// 正在显示
	if (NDUISynLayer_instances)
	{
		if (tag == NDUISynLayer_instances->m_tag || tag == CLOSE)
		{
			NDUISynLayer_instances->RemoveFromParent(true);
		}
	}
}

void NDUISynLayer::ShowWithTitle(std::string title)
{
	/*
	Show();
	if (NDUISynLayer_instances)
	{
		NDUISynLayer_instances->SetTitle(title);
	}
	*/
}

void NDUISynLayer::SetTitle(std::string title)
{
		/*
	if (m_lbText)
	{
		m_lbText->SetText(title.c_str());
	}
	*/
}

void NDUISynLayer::draw()
{
	if (!isDrawEnabled()) return;
	NDUILayer::draw();
	if (this->IsVisibled()) 
	{
		/*
		glDisableClientState(GL_COLOR_ARRAY);
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		[this->m_texLine drawAtPoint:this->m_ptLine];
		glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		[this->m_texBlock drawAtPoint:this->m_ptBlock];
		glEnableClientState(GL_COLOR_ARRAY);
		
		this->m_ptBlock.x += 2.0f;
		if (this->m_ptBlock.x > this->m_cyclePosX)
		{
			this->m_ptBlock.x = this->m_ptLine.x;
		}
		*/
		
		/*
		if (m_ShaLou)
			m_ShaLou->Run(this->GetContentSize());
		*/
	}
}