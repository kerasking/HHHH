/*
 *  PlayerInfoScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-12.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PlayerInfoScene.h"
#include "NDDirector.h"
#include "CGPointExtension.h"
#include "NDUtility.h"
#include "GameUIAttrib.h"
#include "NewPlayerTask.h"
#include "FarmInfoScene.h"
#include "NDMsgDefine.h"
#include "NDUISynLayer.h"
#include "PlayerSkillInfo.h"

enum 
{
	ePlayerInfoBegin = 0,
	ePlayerInfoBag = ePlayerInfoBegin,
	ePlayerInfoAttr,
	ePlayerInfoSkill,
	ePlayerInfoPet,
	ePlayerInfoFarm,
	ePlayerInfoEnd,
};

static PlayerInfoScene* s_pScene = NULL;
IMPLEMENT_CLASS(PlayerInfoScene, NDCommonScene)

PlayerInfoScene* PlayerInfoScene::Scene()
{
	PlayerInfoScene *scene = new PlayerInfoScene;
	
	scene->Initialization();

	return scene;
}

CUIPet* PlayerInfoScene::QueryPetScene()
{
	if (s_pScene) {
		return s_pScene->m_pUiPet;
	}
	return NULL;
}

PlayerInfoScene::PlayerInfoScene()
{
	m_GameRoleNode = NULL;
	
	m_hasGetFarmInfo = false;
	
	//m_hasGetCanAcceptTask = false;
	m_skillTab = NULL;
	
	m_pUiPet = NULL;
	s_pScene = this;
}

PlayerInfoScene::~PlayerInfoScene()
{
	m_pUiPet = NULL;
	s_pScene = NULL;
}

void PlayerInfoScene::Initialization()
{
	NDCommonScene::Initialization();
	
	const char * tabtext[ePlayerInfoEnd] = 
	{
		NDCommonCString("bag"), NDCommonCString("property"), NDCommonCString("skill"), "宠物", NDCommonCString("ZhuanYuan")
	};
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	for (int i = ePlayerInfoBegin; i < ePlayerInfoEnd; i++) 
	{
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 70, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 70, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(tabtext[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}

	for (int i = ePlayerInfoBegin; i < ePlayerInfoEnd; i++) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == ePlayerInfoBag) 
		{
			InitBag(client);
		}
		else if (i == ePlayerInfoAttr)
		{
			InitAttr(client);
		}
		else if (i == ePlayerInfoPet)
		{
			InitPet(client);
		}
		else if (i == ePlayerInfoFarm)
		{
			InitFarm(client);
		} else if (i == ePlayerInfoSkill) {
			InitSkill(client);
		}
	}

	NDUILayer* commonLayer = this->CetGernalLayer(false, 1);
	
	m_GameRoleNode = new GameRoleNode;
	m_GameRoleNode->Initialization();
	//以下两行固定用法
	m_GameRoleNode->SetFrameRect(CGRectMake(0, 0, 480, 320));
	
	commonLayer->AddChild(m_GameRoleNode);
	
	DrawRole(true, ccp(97, 181));
	
	this->SetTabFocusOnIndex(ePlayerInfoBag, true);
}

void PlayerInfoScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
}

void PlayerInfoScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	NDCommonScene::OnTabLayerSelect(tab, lastIndex, curIndex);
	
	if (!m_hasGetFarmInfo && curIndex == (unsigned int)ePlayerInfoFarm) 
	{
		NDTransData bao(_MSG_ENTER_HAMLET);
		bao << (unsigned char)2 << int(0);
		SEND_DATA(bao);

		m_hasGetFarmInfo = true;
	}/*
	else if (!m_hasGetCanAcceptTask && curIndex == (unsigned int)ePlayerInfoTask) 
	{
		NDTransData bao(_MSG_QUERY_TASK_LIST_EX);
		bao << (unsigned char)0 << int(0);
		SEND_DATA(bao);
		ShowProgressBar;
		
		m_hasGetCanAcceptTask = true;
	}*/
	else if (curIndex == (uint)ePlayerInfoSkill) {
		m_skillTab->Update();
	}
}

void PlayerInfoScene::DrawRole(bool draw, CGPoint pos/*=CGPointZero*/)
{
	if (draw && m_tab && !(m_tab->GetFocusIndex() == ePlayerInfoBag ||m_tab->GetFocusIndex() == ePlayerInfoAttr)) 
	{
		return;
	}
	
	if (m_GameRoleNode)
	{
		m_GameRoleNode->EnableDraw(draw);
		
		if (draw)
			m_GameRoleNode->SetDisplayPos(pos);
	}
}

void PlayerInfoScene::InitBag(NDUIClientLayer* client)
{
	CGSize clientSize = client->GetFrameRect().size;
	
	NewPlayerBagLayer *bag = new NewPlayerBagLayer;
	bag->Initialization();
	bag->SetFrameRect(CGRectMake(0, 0, clientSize.width, clientSize.height));
	
	client->AddChild(bag);
}

void PlayerInfoScene::InitAttr(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab *tab = new NDFuncTab;
	tab->Initialization(2, CGPointMake(200, 5));
	
	for(int j =0; j<2; j++)
	{
		TabNode* tabnode = tab->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = (j == 0 ? 18*4 : 18*5);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	GameUIAttrib *attr = new GameUIAttrib;
	attr->Initialization();
	attr->SetFrameRect(CGRectMake(0, 0, 200, sizeClient.height));
	client->AddChild(attr);
	
	attr->AddPropAlloc(tab->GetClientLayer(0));
	attr->AddProp(tab->GetClientLayer(1));

	client->AddChild(tab);
}

void PlayerInfoScene::InitPet(NDUIClientLayer* client)
{
	CGSize clientSize = client->GetFrameRect().size;
	
	m_pUiPet = new CUIPet;
	if (!m_pUiPet) {
		return;
	}
	NDPlayer& player = NDPlayer::defaultHero();
	if (!m_pUiPet->Init(player.m_id, 0)) {
		SAFE_DELETE(m_pUiPet);
		return;
	}
	m_pUiPet->SetFrameRect(CGRectMake(0, 0, clientSize.width, clientSize.height));
	
	client->AddChild(m_pUiPet);
}


void PlayerInfoScene::InitSkill(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab *tab = new NDFuncTab;
	tab->Initialization(4, CGPointMake(200, 5));
	
	for(int j =0; j<4; j++)
	{
		TabNode* tabnode = tab->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = 0;
		
		if (j == 1) {
			startX = 18 * 1;
		} else if (j == 2) {
			startX = 18 * 2;
		} else if (j == 3) {
			startX = 18 * 3;
		}
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	m_skillTab = new PlayerSkillInfo;
	m_skillTab->Initialization();
	m_skillTab->SetFrameRect(CGRectMake(0, 0, 200, sizeClient.height));
	client->AddChild(m_skillTab);
	tab->SetDelegate(m_skillTab);
	m_skillTab->AddActSkill(tab->GetClientLayer(0));
	m_skillTab->AddPasSkill(tab->GetClientLayer(1));
	m_skillTab->AddLifeSkill(tab->GetClientLayer(2));
	m_skillTab->AddPlayerState(tab->GetClientLayer(3));
	
	client->AddChild(tab);
}
/*
void PlayerInfoScene::InitTask(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab *tab = new NDFuncTab;
	tab->Initialization(2, CGPointMake(200, 5));
	
	for(int j =0; j<2; j++)
	{
		TabNode* tabnode = tab->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = (j == 0 ? 18*6 : 18*7);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	NewPlayerTask *task = new NewPlayerTask;
	task->Initialization();
	task->SetFrameRect(CGRectMake(0, 0, 200, sizeClient.height));
	client->AddChild(task);
	tab->SetDelegate(task);
	task->AddKeJie(tab->GetClientLayer(0));
	task->AddYiJie(tab->GetClientLayer(1));
	
	client->AddChild(tab);
}
*/
void PlayerInfoScene::InitFarm(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	NDFuncTab *tab = new NDFuncTab;
	tab->Initialization(1, CGPointMake(200, 5), CGSizeMake(25, 100), 100);
	
	TabNode* tabnode = tab->GetTabNode(0);
	
	//NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
	NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
	
	int startX = 10*18;
	
	//pic->Cut(CGRectMake(startX, 36, 18, 36));
	picFocus->Cut(CGRectMake(startX, 0, 18, 72));
	
	tabnode->SetTextPicture(NULL, picFocus);

	
	FarmInfoLayer *farm = new FarmInfoLayer;
	farm->Initialization();
	farm->SetFrameRect(CGRectMake(0, 0, 200, sizeClient.height));
	client->AddChild(farm);
	
	farm->InitTrends(tab->GetClientLayer(0));

	client->AddChild(tab);
	
	m_hasGetFarmInfo = false;
}

