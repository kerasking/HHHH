/*
 *  DramaTransitionScene.cpp
 *  SMYS
 *
 *  Created by jhzheng on 12-4-20.
 *  Copyright 2012 (ÍøÁú)DeNA. All rights reserved.
 *
 */

#include "DramaTransitionScene.h"
#include "NDDirector.h"

#define TIMER_TAG_CLOSE (1)

IMPLEMENT_CLASS(DramaTransitionScene, NDScene)

DramaTransitionScene::DramaTransitionScene()
{
	INIT_AUTOLINK(DramaTransitionScene);
	
	m_lbText		= NULL;
	m_layerBack		= NULL;
}

DramaTransitionScene::~DramaTransitionScene()
{
}

void DramaTransitionScene::Init()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_layerBack = new NDUILayer;
	m_layerBack->Initialization();
	m_layerBack->SetBackgroundColor(ccc4(0, 0, 0, 255));
	m_layerBack->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	this->AddChild(m_layerBack);
	
	m_lbText	= new NDUILabel;
	m_lbText->Initialization();
	m_lbText->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbText->SetFrameRect(CGRectMake(winsize.width / 6, winsize.height / 6, winsize.width * 2 / 3, winsize.height * 2 / 3));
	m_layerBack->AddChild(m_lbText);
}

void DramaTransitionScene::SetText(std::string text, int nFontSize, int nFontColor)
{
	if (!m_lbText)
	{
		return;
	}
	
	m_lbText->SetText(text.c_str());
	m_lbText->SetFontSize(nFontSize);
	m_lbText->SetFontColor(INTCOLORTOCCC4(nFontColor));
}

void DramaTransitionScene::SetCloseTime(float fTime)
{
	m_timer.KillTimer(this, TIMER_TAG_CLOSE);
	m_timer.SetTimer(this, TIMER_TAG_CLOSE, fTime);
}

void DramaTransitionScene::OnTimer(OBJID tag)
{
	if (TIMER_TAG_CLOSE != tag)
	{
		return;
	}
	
	NDDirector::DefaultDirector()->PopScene();
}