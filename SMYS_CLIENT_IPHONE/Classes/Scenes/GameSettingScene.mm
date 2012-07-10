/*
 *  GameSettingScene.mm
 *  DragonDrive
 *
 *  Created by wq on 11-2-16.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameSettingScene.h"
#include "NDDirector.h"
#include "InitMenuScene.h"
#include <vector>
#include <string>
#include "GameScene.h"

using namespace std;
typedef vector<string> VEC_OPT_STRING;

IMPLEMENT_CLASS(GameSettingScene, NDScene)

GameSettingScene::GameSettingScene()
{
	m_menuLayer = NULL;
	//m_headPicOpt = NULL;
	//m_miniMapOpt = NULL;
	m_showObjLevel = NULL;
	m_worldChatOpt = NULL;
	m_synChatOpt = NULL;
	m_teamChatOpt = NULL;
	m_areaChatOpt = NULL;
	m_directKeyOpt = NULL;
	
	m_page1 = NULL;
	//m_page2 = NULL;
}

GameSettingScene::~GameSettingScene()
{
	
}

GameSettingScene* GameSettingScene::Scene()
{
	GameSettingScene* scene = new GameSettingScene();
	scene->Initialization();
	return scene;
}

void GameSettingScene::Initialization()
{
	NDScene::Initialization();
	
	this->m_menuLayer = new NDUIMenuLayer();
	m_menuLayer->Initialization();
	m_menuLayer->ShowOkBtn();
	
	m_menuLayer->SetDelegate(this);
	this->AddChild(m_menuLayer);
	
	if ( m_menuLayer->GetOkBtn() ) 
	{
		m_menuLayer->GetOkBtn()->SetDelegate(this);
	}
	
	if ( m_menuLayer->GetCancelBtn() ) 
	{
		m_menuLayer->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	NDUILabel* title = new NDUILabel();
	title->Initialization();
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetText(NDCommonCString("SysSetting"));
	title->SetFrameRect(CGRectMake(0, 5, winSize.width, 20));
	title->SetFontSize(20);
	title->SetFontColor(ccc4(255, 255, 0, 255));
	m_menuLayer->AddChild(title);
	
	m_page1 = new NDUILayer();
	m_page1->Initialization();
	m_page1->SetFrameRect(CGRectMake(0, m_menuLayer->GetTitleHeight(), winSize.width, m_menuLayer->GetTextHeight()));
	m_menuLayer->AddChild(m_page1);
	
	float y = 12.0f;
	NDUILabel* label = new NDUILabel();
	/*label->Initialization();
	label->SetText("头像显示");
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, 12, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText("缩略地图");
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	y += 35.0f;*/
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText(NDCommonCString("WorldChat"));
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	y += 35.0f;
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText(NDCommonCString("JunTuanChat"));
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	y += 35.0f;
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText(NDCommonCString("TeamChat"));
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	y += 35.0f;
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText(NDCommonCString("SectionChat"));
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	y += 35.0f;
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText(NDCommonCString("AppearPingZhi"));
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	y += 35.0f;
	
	VEC_OPT_STRING vOps;
	vOps.push_back(NDCommonCString("open"));
	vOps.push_back(NDCommonCString("close"));
	
	m_directKeyOpt = new NDUIOptionButton;
	m_directKeyOpt->Initialization();
	m_directKeyOpt->SetOptions(vOps);
	m_directKeyOpt->SetDelegate(this);
	m_directKeyOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_directKeyOpt->SetBgClr(ccc4(57, 44, 41, 255));
	
	/*
	 page 2 setting
	 */
	/*m_page2 = new NDUILayer();
	m_page2->Initialization();
	m_page2->SetFrameRect(CGRectMake(0, m_menuLayer->GetTitleHeight(), winSize.width, m_menuLayer->GetTextHeight()));
	m_menuLayer->AddChild(m_page2);
	m_page2->SetVisible(false);*/
	
	label = new NDUILabel();
	label->Initialization();
	label->SetText(NDCommonCString("DirectKey"));
	label->SetFontSize(14);
	label->SetTextAlignment(LabelTextAlignmentLeft);
	label->SetFrameRect(CGRectMake(85, y, 60, 14));
	label->SetFontColor(ccc4(24, 85, 82, 255));
	m_page1->AddChild(label);
	
	/*
	 -------------------------------------
	 */
	
	/*this->m_headPicOpt = new NDUIOptionButton;
	m_headPicOpt->Initialization();
	m_headPicOpt->SetOptions(vOps);
	m_headPicOpt->SetDelegate(this);
	m_headPicOpt->SetFrameRect(CGRectMake(198, 7, 220, 25));
	m_headPicOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_headPicOpt->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_headPicOpt);
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_HEAD)) {
		m_headPicOpt->SetOptIndex(1);
	}*/
	
	y = 7.0f;
	
	/*this->m_miniMapOpt = new NDUIOptionButton;
	m_miniMapOpt->Initialization();
	m_miniMapOpt->SetOptions(vOps);
	m_miniMapOpt->SetDelegate(this);
	m_miniMapOpt->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_miniMapOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_miniMapOpt->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_miniMapOpt);
	y += 35.0f;
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_MINI_MAP)) {
		m_miniMapOpt->SetOptIndex(1);
	}*/
	
	this->m_worldChatOpt = new NDUIOptionButton;
	m_worldChatOpt->Initialization();
	m_worldChatOpt->SetOptions(vOps);
	m_worldChatOpt->SetDelegate(this);
	m_worldChatOpt->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_worldChatOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_worldChatOpt->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_worldChatOpt);
	y += 35.0f;
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_WORLD_CHAT)) {
		m_worldChatOpt->SetOptIndex(1);
	}
	
	this->m_synChatOpt = new NDUIOptionButton;
	m_synChatOpt->Initialization();
	m_synChatOpt->SetOptions(vOps);
	m_synChatOpt->SetDelegate(this);
	m_synChatOpt->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_synChatOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_synChatOpt->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_synChatOpt);
	y += 35.0f;
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_SYN_CHAT)) {
		m_synChatOpt->SetOptIndex(1);
	}
	
	this->m_teamChatOpt = new NDUIOptionButton;
	m_teamChatOpt->Initialization();
	m_teamChatOpt->SetOptions(vOps);
	m_teamChatOpt->SetDelegate(this);
	m_teamChatOpt->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_teamChatOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_teamChatOpt->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_teamChatOpt);
	y += 35.0f;
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_TEAM_CHAT)) {
		m_teamChatOpt->SetOptIndex(1);
	}
	
	this->m_areaChatOpt = new NDUIOptionButton;
	m_areaChatOpt->Initialization();
	m_areaChatOpt->SetOptions(vOps);
	m_areaChatOpt->SetDelegate(this);
	m_areaChatOpt->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_areaChatOpt->SetFontColor(ccc4(247, 219, 115, 255));
	m_areaChatOpt->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_areaChatOpt);
	y += 35.0f;
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_AREA_CHAT)) {
		m_areaChatOpt->SetOptIndex(1);
	}
	
	this->m_showObjLevel = new NDUIOptionButton();
	m_showObjLevel->Initialization();
	
	vOps.clear();
	vOps.push_back(NDCommonCString("high")); // 0 - 同时显示名字和其他玩家
	vOps.push_back(NDCommonCString("mid")); // 1 - 不显示名字
	vOps.push_back(NDCommonCString("low")); // 2 - 不显示其他玩家
	m_showObjLevel->SetOptions(vOps);
	m_showObjLevel->SetDelegate(this);
	
	m_showObjLevel->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_showObjLevel->SetFontColor(ccc4(247, 219, 115, 255));
	m_showObjLevel->SetBgClr(ccc4(57, 44, 41, 255));
	m_page1->AddChild(m_showObjLevel);
	y += 35.0f;
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_NAME)) {
		if (NDDataPersist::IsGameSettingOn(GS_SHOW_OTHER_PLAYER)) {
			m_showObjLevel->SetOptIndex(1);
		} else {
			m_showObjLevel->SetOptIndex(2);
		}
	}
	
	m_directKeyOpt->SetFrameRect(CGRectMake(198, y, 220, 25));
	m_page1->AddChild(m_directKeyOpt);
	//m_page2->SetVisible(false);
	
	if (!NDDataPersist::IsGameSettingOn(GS_SHOW_DIRECT_KEY)) {
		m_directKeyOpt->SetOptIndex(1);
	}
	
	/*
	 page control
	 */	
	/*m_pageControl = new NDUILayer();
	m_pageControl->Initialization();
	m_pageControl->SetFrameRect(CGRectMake(150, 290, 180, 30));
	m_menuLayer->AddChild(m_pageControl);*/
	
	/*m_btnPrevPage = new NDUIButton();
	m_btnPrevPage->Initialization();
	m_btnPrevPage->SetTitle("上一页");
	m_btnPrevPage->CloseFrame();
	m_btnPrevPage->SetFrameRect(CGRectMake(0, 0, 60, 20));
	m_btnPrevPage->SetDelegate(this);
	m_pageControl->AddChild(m_btnPrevPage);	
	
	m_lbPage = new NDUILabel();
	m_lbPage->Initialization();
	m_lbPage->SetText("1 / 2");
	m_lbPage->SetFrameRect(CGRectMake(60, 0, 60, 20));
	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter);
	m_pageControl->AddChild(m_lbPage);
	
	m_curPage = 1;
	
	m_btnNextPage = new NDUIButton();
	m_btnNextPage->Initialization();
	m_btnNextPage->SetTitle("下一页");
	m_btnNextPage->CloseFrame();
	m_btnNextPage->SetFrameRect(CGRectMake(120, 0, 60, 20));
	m_btnNextPage->SetDelegate(this);
	m_pageControl->AddChild(m_btnNextPage);*/
	/*
	 --------------------------------------
	 */
}

void GameSettingScene::OnButtonClick(NDUIButton* button)
{
	/*if (button == m_btnPrevPage) 
	{
		if (m_curPage > 1) 
		{
			m_curPage--;
			m_page1->SetVisible(true);
			m_page2->SetVisible(false);
			
			char buf[100] = {0x00};
			sprintf(buf, "%d / 2", m_curPage);
			m_lbPage->SetText(buf);
		}	
		
	}
	else if ( button == m_btnNextPage)
	{
		if (m_curPage < 2) 
		{
			m_curPage++;
			m_page2->SetVisible(true);
			m_page1->SetVisible(false);
			
			char buf[100] = {0x00};
			sprintf(buf, "%d / 2", m_curPage);
			m_lbPage->SetText(buf);
		}
	}
	else */
	{
		if ( m_menuLayer && (button == m_menuLayer->GetOkBtn()) )
		{
			this->m_gameSettingData.SaveGameSetting();
		}	
		
		NDDirector::DefaultDirector()->PopScene(NULL, true);
		
		// 缩略地图
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			GameScene* gameScene = (GameScene*)scene;
			//gameScene->ShowMiniMap(NDDataPersist::IsGameSettingOn(GS_SHOW_MINI_MAP));
			//gameScene->ShowPlayerHead(NDDataPersist::IsGameSettingOn(GS_SHOW_HEAD));
			gameScene->ShowMiniMap(true);
			gameScene->ShowPlayerHead(true);
			//gameScene->ShowDirectKey(NDDataPersist::IsGameSettingOn(GS_SHOW_DIRECT_KEY));
		}
	}	
}

void GameSettingScene::OnOptionChange(NDUIOptionButton* option)
{
	/*if (option == this->m_headPicOpt) {
		bool bOn = this->m_headPicOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_HEAD, bOn);
	} else if (option == this->m_miniMapOpt) {
		bool bOn = this->m_miniMapOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_MINI_MAP, bOn);
	} else */if (option == this->m_worldChatOpt) {
		bool bOn = this->m_worldChatOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_WORLD_CHAT, bOn);
	} else if (option == this->m_synChatOpt) {
		bool bOn = this->m_synChatOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_SYN_CHAT, bOn);
	} else if (option == this->m_teamChatOpt) {
		bool bOn = this->m_teamChatOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_TEAM_CHAT, bOn);
	} else if (option == this->m_areaChatOpt) {
		bool bOn = this->m_areaChatOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_AREA_CHAT, bOn);
	}else if (option == this->m_directKeyOpt) {
		bool bOn = this->m_directKeyOpt->GetOptionIndex() == 0;
		this->m_gameSettingData.SetGameSetting(GS_SHOW_DIRECT_KEY, bOn);
	}	else if (option == this->m_showObjLevel) {
		switch (this->m_showObjLevel->GetOptionIndex()) {
			case 0: // 高
				this->m_gameSettingData.SetGameSetting(GS_SHOW_NAME, true);
				this->m_gameSettingData.SetGameSetting(GS_SHOW_OTHER_PLAYER, true);
				break;
			case 1: // 中
				this->m_gameSettingData.SetGameSetting(GS_SHOW_NAME, false);
				this->m_gameSettingData.SetGameSetting(GS_SHOW_OTHER_PLAYER, true);
				break;
			case 2: // 低
				this->m_gameSettingData.SetGameSetting(GS_SHOW_NAME, false);
				this->m_gameSettingData.SetGameSetting(GS_SHOW_OTHER_PLAYER, false);
				break;
			default:
				break;
		}
	}
}
