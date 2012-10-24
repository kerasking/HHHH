/*
 *  SyndicateInfoLayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-1.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateInfoLayer.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDDirector.h"
#include "NDConstant.h"

IMPLEMENT_CLASS(SyndicateInfoLayer, NDUIMenuLayer)

SyndicateInfoLayer* SyndicateInfoLayer::s_instance = NULL;

void SyndicateInfoLayer::refresh(const string& title, const string& content)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene) {
			SyndicateInfoLayer *layer = new SyndicateInfoLayer;
			layer->Initialization();
			scene->AddChild(layer, UILAYER_Z);
		} else {
			return;
		}
	}
	
	s_instance->refreshContent(title, content);
}

SyndicateInfoLayer::SyndicateInfoLayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_lbTitle = NULL;
	this->m_memoContent = NULL;
}

SyndicateInfoLayer::~SyndicateInfoLayer()
{
	s_instance = NULL;
}

void SyndicateInfoLayer::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->GetParent()) 
		{
			this->RemoveFromParent(true);
		}
	}
}

void SyndicateInfoLayer::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
}

void SyndicateInfoLayer::refreshContent(const string& title, const string& content)
{
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
	
	if (m_memoContent == NULL) {
		m_memoContent = new NDUIMemo;
		m_memoContent->Initialization();
		m_memoContent->SetFontColor(ccc4(0, 0, 0, 255));
		m_memoContent->SetBackgroundColor(ccc4(107, 158, 156, 255));
		m_memoContent->SetFrameRect(CGRectMake(20.0f, 35.0f, 440.0f, 230.0f));
		this->AddChild(m_memoContent);
	}
	
	m_memoContent->SetText(content.c_str());
}
