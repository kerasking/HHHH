/*
 *  SyndicateUpgrade.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateUpgrade.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDDirector.h"
#include "NDConstant.h"

IMPLEMENT_CLASS(SyndicateUpgrade, NDUIMenuLayer)

SyndicateUpgrade* SyndicateUpgrade::s_instance = NULL;

void SyndicateUpgrade::refresh(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			SyndicateUpgrade *layer = new SyndicateUpgrade;
			layer->Initialization();
			gameScene->AddChild(layer, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshContent(data);
}

SyndicateUpgrade::SyndicateUpgrade()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_lbTitle = NULL;
	this->m_memoContent1 = NULL;
	this->m_memoContent2 = NULL;
}

SyndicateUpgrade::~SyndicateUpgrade()
{
	s_instance = NULL;
}

void SyndicateUpgrade::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			((GameScene*)(this->GetParent()))->SetUIShow(false);
			this->RemoveFromParent(true);
		}
	} else if (button == this->GetOkBtn()) {
		sendUpGradeSyn();
	}
}

void SyndicateUpgrade::Initialization()
{
	NDUIMenuLayer::Initialization();
	this->ShowOkBtn();
	
	if ( this->GetOkBtn() ) 
	{
		this->GetOkBtn()->SetDelegate(this);
	}
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* label = new NDUILabel;
	label->Initialization();
	label->SetFontColor(ccc4(0, 0, 0, 255));
	label->SetText("升级条件");
	label->SetFrameRect(CGRectMake(0, 80, 480, 15));
	label->SetTextAlignment(LabelTextAlignmentCenter);
	this->AddChild(label);
}

void SyndicateUpgrade::refreshContent(NDTransData& data)
{
	string title = data.ReadUnicodeString();
	string content1 = data.ReadUnicodeString();
	string content2 = data.ReadUnicodeString();
	
	if (m_lbTitle == NULL) {
		m_lbTitle = new NDUILabel;
		m_lbTitle->Initialization();
		m_lbTitle->SetFontSize(15);
		m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
		m_lbTitle->SetFrameRect(CGRectMake(0, 5, 480, 15));
		m_lbTitle->SetFontColor(ccc4(255, 240, 0,255));
		this->AddChild(m_lbTitle);
	}
	
	m_lbTitle->SetText(title.c_str());
	
	if (m_memoContent1 == NULL) {
		m_memoContent1 = new NDUIMemo;
		m_memoContent1->Initialization();
		m_memoContent1->SetFontColor(ccc4(0, 0, 0, 255));
		m_memoContent1->SetBackgroundColor(ccc4(107, 158, 156, 255));
		m_memoContent1->SetFrameRect(CGRectMake(20.0f, 35.0f, 440.0f, 40.0f));
		this->AddChild(m_memoContent1);
	}
	
	m_memoContent1->SetText(content1.c_str());
	
	if (m_memoContent2 == NULL) {
		m_memoContent2 = new NDUIMemo;
		m_memoContent2->Initialization();
		m_memoContent2->SetFontColor(ccc4(0, 0, 0, 255));
		m_memoContent2->SetBackgroundColor(ccc4(107, 158, 156, 255));
		m_memoContent2->SetFrameRect(CGRectMake(20.0f, 100.0f, 440.0f, 170.0f));
		this->AddChild(m_memoContent2);
	}
	
	m_memoContent2->SetText(content2.c_str());
}