/*
 *  ActivityListScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-6-10.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *ActivityListScene
 */

#include "ActivityListScene.h"
#include "NDDirector.h"
#include "define.h"


//////////////////////////////////////////

IMPLEMENT_CLASS(ActivityListScene, NDScene)

std::string ActivityListScene::tab_titles[eMaxTab] = { 
	NDCommonCString("one"), 
	NDCommonCString("two"), 
	NDCommonCString("three"),
	NDCommonCString("four"), 
	NDCommonCString("five"), 
	NDCommonCString("six"), 
	NDCommonCString("seven")};
std::string ActivityListScene::s_data[eMaxTab];
unsigned int ActivityListScene::s_index = 0;

ActivityListScene::ActivityListScene()
{
	m_menulayerBG = NULL;
	memset(m_tabLayer, 0, sizeof(m_tabLayer));
	m_nodePolygon = NULL;
	m_iCurTabFocus = 0;
	m_lbTitle = NULL;
	m_memoContent = NULL;
}

ActivityListScene::~ActivityListScene()
{
	s_index = 0;
}

ActivityListScene* ActivityListScene::Scene()
{
	ActivityListScene* scene = new ActivityListScene;
	scene->Initialization();
	return scene;
}

void ActivityListScene::Initialization()
{
	NDScene::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->SetBackgroundColor(INTCOLORTOCCC4(0xc6cbb5));
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUIRecttangle* bkg = new NDUIRecttangle();
	bkg->Initialization();
	bkg->SetColor(ccc4(99, 117, 99, 255));
	bkg->SetFrameRect(CGRectMake(4, m_menulayerBG->GetTitleHeight() + 2, 472, m_menulayerBG->GetTextHeight() - 4));
	m_menulayerBG->AddChild(bkg);
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetText(NDCommonCString("active"));
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 245, 0, 255));
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 0, winsize.width, m_menulayerBG->GetTitleHeight()));
	m_menulayerBG->AddChild(m_lbTitle); 
	
	m_memoContent = new NDUIMemo;
	m_memoContent->Initialization();
	m_memoContent->SetFontSize(15);
	m_memoContent->SetTextAlignment(MemoTextAlignmentLeft);
	m_memoContent->SetFontColor(ccc4(0, 0, 0, 255));
	m_memoContent->SetFrameRect(CGRectMake(22, m_menulayerBG->GetTitleHeight()+33, winsize.width-16, winsize.height-m_menulayerBG->GetTitleHeight()-85));
	m_memoContent->SetBackgroundColor(ccc4(255, 255, 255, 0));
	m_menulayerBG->AddChild(m_memoContent); 
	
	int width = (winsize.width - 22) / eMaxTab;
	int x = 5;
	int y = m_menulayerBG->GetTitleHeight()+3;
	int iTabHeight = 30;
	
	m_nodePolygon = new NDUIPolygon;
	m_nodePolygon->Initialization();
	m_nodePolygon->SetFrameRect(CGRectMake(7, y+28, winsize.width-15,  winsize.height-y-80));
	m_nodePolygon->SetLineWidth(1);
	m_nodePolygon->SetColor(ccc3(19, 59, 64));
	//m_nodePolygon->SetVisible(true);
	m_menulayerBG->AddChild(m_nodePolygon);
	
	NDUIPolygon *polygon = new NDUIPolygon;
	polygon->Initialization();
	polygon->SetFrameRect(CGRectMake(8, y+29, winsize.width-17,  winsize.height-y-79));
	polygon->SetLineWidth(1);
	polygon->SetColor(ccc3(255, 225, 120));
	//polygon->SetVisible(true);
	m_menulayerBG->AddChild(polygon);
	
	for (int i = 0; i < eMaxTab; i++) 
	{
		m_tabLayer[i] = new StoreTabLayer;
		m_tabLayer[i]->Initialization();
		m_tabLayer[i]->SetText(tab_titles[i]);
		m_tabLayer[i]->SetFrameRect(CGRectMake(x, y, width, iTabHeight));
		m_tabLayer[i]->SetDelegate(this);
		m_menulayerBG->AddChild(m_tabLayer[i]);
		x += width+2;
	}
	
	m_tabLayer[m_iCurTabFocus]->SetTabFocus(true);
	
	UpdateGui();
}

void ActivityListScene::UpdateGui()
{
	if (m_memoContent && m_iCurTabFocus < eMaxTab) {
		m_memoContent->SetText(s_data[m_iCurTabFocus].c_str());
	}
}

void ActivityListScene::OnFocusTablayer(StoreTabLayer* tablayer)
{
	for (int i = 0; i < eMaxTab; i++) 
	{
		if (!m_tabLayer[i]) 
		{
			continue;
		}
		
		if (tablayer == m_tabLayer[i]) 
		{
			m_iCurTabFocus = i;
			m_tabLayer[i]->SetTabFocus(true);
		}
		else 
		{
			m_tabLayer[i]->SetTabFocus(false);
		}
	}
	
	UpdateGui();
}

void ActivityListScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}

void ActivityListScene::AddData(std::string str)
{
	if (s_index < eMaxTab) {
		s_data[s_index++] = str;
	}
}

void ActivityListScene::ClearData()
{
	for (int i = 0; i < eMaxTab; i++) {
		s_data[s_index] = "";
	}
}
