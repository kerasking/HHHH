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

	m_pkLabelText = NULL;
	m_pkLayerBack = NULL;
}

DramaTransitionScene::~DramaTransitionScene()
{
}

void DramaTransitionScene::Init()
{
	NDScene::Initialization();

	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();

	m_pkLayerBack = new NDUILayer;
	m_pkLayerBack->Initialization();
	m_pkLayerBack->SetBackgroundColor(ccc4(0, 0, 0, 255));
	m_pkLayerBack->SetFrameRect(
			CGRectMake(0, 0, winsize.width, winsize.height));
	AddChild(m_pkLayerBack);

	m_pkLabelText = new NDUILabel;
	m_pkLabelText->Initialization();
	m_pkLabelText->SetTextAlignment(LabelTextAlignmentCenter);
	m_pkLabelText->SetFrameRect(
			CGRectMake(winsize.width / 6, winsize.height / 6,
					winsize.width * 2 / 3, winsize.height * 2 / 3));
	m_pkLayerBack->AddChild(m_pkLabelText);
}

void DramaTransitionScene::SetText(std::string text, int nFontSize,
		int nFontColor)
{
	if (!m_pkLabelText)
	{
		return;
	}

	m_pkLabelText->SetText(text.c_str());
	m_pkLabelText->SetFontSize(nFontSize);
	m_pkLabelText->SetFontColor(INTCOLORTOCCC4(nFontColor));
}

void DramaTransitionScene::SetCloseTime(float fTime)
{
	m_kTimer.KillTimer(this, TIMER_TAG_CLOSE);
	m_kTimer.SetTimer(this, TIMER_TAG_CLOSE, fTime);
}

void DramaTransitionScene::OnTimer(OBJID tag)
{
	if (TIMER_TAG_CLOSE != tag)
	{
		return;
	}

	NDDirector::DefaultDirector()->PopScene();
}