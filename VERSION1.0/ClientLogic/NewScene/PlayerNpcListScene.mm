/*
 *  PlayerNpcListScene.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PlayerNpcListScene.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "PlayerNpcListLayers.h"
#include "NDMapMgr.h"
#include "QuickInteraction.h"

enum 
{
	eListBegin = 0,
	ePlayerNpcList = eListBegin,
	eListEnd,
};

IMPLEMENT_CLASS(PlayerNpcListScene, NDCommonScene)

PlayerNpcListScene* PlayerNpcListScene::Scene()
{
	PlayerNpcListScene *scene = new PlayerNpcListScene;
	
	scene->Initialization();
	
	return scene;
}

PlayerNpcListScene::PlayerNpcListScene()
{
	m_tabNodeSize.width = 150;
	m_npcList = NULL;
	m_tabFunc = NULL;
	m_layerNpcControl = NULL;
	m_layerPlayerControl = NULL;
	m_playerList = NULL;
}

PlayerNpcListScene::~PlayerNpcListScene()
{
	QuickInteraction::RefreshOptions();
	
	if (m_layerNpcControl) {
		m_layerNpcControl->RemoveFromParent(false);
		SAFE_DELETE(m_layerNpcControl);
	}
	
	if (m_layerPlayerControl) {
		m_layerPlayerControl->RemoveFromParent(false);
		SAFE_DELETE(m_layerPlayerControl);
	}
}

void PlayerNpcListScene::Initialization()
{
	NDCommonScene::Initialization();
	
	const char * tabtext[eListEnd] = 
	{
		NDCommonCString("PlayerOrNpcList"),
	};
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	for (int i = eListBegin; i < eListEnd; i++) 
	{
		TabNode* tabnode = this->AddTabNode();
		
		tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 150, 31), 
						  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 150, 34),
						  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
		
		tabnode->SetText(tabtext[i]);
		
		tabnode->SetTextColor(ccc4(245, 226, 169, 255));
		
		tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
		
		tabnode->SetTextFontSize(18);
	}
	
	for (int i = eListBegin; i < eListEnd; i++) 
	{
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		NDUIClientLayer* client = this->GetClientLayer(i);
		
		if (i == ePlayerNpcList) 
		{
			this->InitPlayerNpcList(client);
		}
	}
	
	this->SetTabFocusOnIndex(ePlayerNpcList, true);
}

void PlayerNpcListScene::InitPlayerNpcList(NDUIClientLayer* client)
{
	if (!client) return;
	
	CGSize sizeClient = client->GetFrameRect().size;
	m_tabFunc = new NDFuncTab;
	m_tabFunc->Initialization(2, CGPointMake(0, 5), CGSizeMake(25, 63), 0, 0, true);
	m_tabFunc->SetDelegate(this);
	
	for(int j =0; j<2; j++)
	{
		TabNode* tabnode = m_tabFunc->GetTabNode(j);
		
		NDPicture *pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		NDPicture *picFocus = NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("newui_text.png"));
		
		int startX = (j == 0 ? 18*8 : 18*9);
		
		pic->Cut(CGRectMake(startX, 36, 18, 36));
		picFocus->Cut(CGRectMake(startX, 0, 18, 36));
		
		tabnode->SetTextPicture(pic, picFocus);
	}
	
	client->AddChild(m_tabFunc);
	
	this->InitPlayerList();
}

void PlayerNpcListScene::OnTabLayerClick(TabLayer* tab, uint curIndex)
{
	if (tab->IsKindOfClass(RUNTIME_CLASS(VerticalTabLayer))) {
		if (curIndex == 1) {
			if (m_npcList) {
				m_npcList->OnClickTab();
				if (m_layerNpcControl && !m_layerNpcControl->GetParent()) {
					this->AddChild(m_layerNpcControl);
				}
			}
		}
	}
}

void PlayerNpcListScene::OnTabLayerSelect(TabLayer* tab, unsigned int lastIndex, unsigned int curIndex)
{
	if (tab->IsKindOfClass(RUNTIME_CLASS(VerticalTabLayer))) {
		if (lastIndex == 0 && curIndex == 1) {
			if (m_playerList) {
				m_playerList->RemoveFromParent(false);
				SAFE_DELETE(m_playerList);
			}
			
			if (m_layerPlayerControl) {
				m_layerPlayerControl->RemoveFromParent(false);
				SAFE_DELETE(m_layerPlayerControl);
			}
			
			if (m_npcList) {
				m_npcList->RemoveFromParent(true);
				m_npcList = NULL;
			}
			
			if (m_layerNpcControl) {
				m_layerNpcControl->RemoveFromParent(false);
				SAFE_DELETE(m_layerNpcControl);
			}
			
			if (m_tabFunc) {
				m_npcList = new NpcListLayer;
				m_npcList->Initialization(this);
				m_npcList->SetFrameRect(CGRectMake(15, 15, 425, 230));
				//m_npcList->SetBackgroundColor(ccc4(255, 0, 0, 255));
				m_tabFunc->GetClientLayer(1)->AddChild(m_npcList);
				
				m_layerNpcControl = new NDUILayer;
				m_layerNpcControl->Initialization();
				//m_layerNpcControl->SetBackgroundColor(ccc4(0, 0, 255, 255));
				m_layerNpcControl->SetFrameRect(CGRectMake(0, 284, 480, 36));
				this->AddChild(m_layerNpcControl);
				
				NDPicturePool* pool = NDPicturePool::DefaultPool();
				
				NDUIButton* btnTask = new NDUIButton;
				btnTask->Initialization();
				btnTask->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("btn_bg0.png")), NULL, false, CGRectZero, true);
				btnTask->SetFontColor(ccc4(255, 255, 255, 255));
				btnTask->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("task.png"), false), false, CGRectZero, true);
				//btnTask->SetTitle("任务");
				btnTask->SetFrameRect(CGRectMake(0, 0, 39, 35));
				btnTask->SetDelegate(this);
				btnTask->SetTag(eNpcTask);
				m_layerNpcControl->AddChild(btnTask);
				
				NDUIButton* btnDaoHang = new NDUIButton;
				btnDaoHang->Initialization();
				btnDaoHang->SetFontColor(ccc4(255, 255, 255, 255));
				btnDaoHang->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("btn_bg0.png")), NULL, false, CGRectZero, true);
				btnDaoHang->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("dao_hang.png"), false), false, CGRectZero, true);
				//btnDaoHang->SetTitle("导航");
				btnDaoHang->SetFrameRect(CGRectMake(440, 0, 39, 35));
				btnDaoHang->SetDelegate(this);
				btnDaoHang->SetTag(eNpcDaoHang);
				m_layerNpcControl->AddChild(btnDaoHang);
			}
		} else if (lastIndex == 1 && curIndex == 0) {
			if (m_npcList) {
				m_npcList->OnClickTab();
				m_npcList->RemoveFromParent(true);
				m_npcList = NULL;
			}
			
			if (m_layerNpcControl) {
				m_layerNpcControl->RemoveFromParent(false);
				SAFE_DELETE(m_layerNpcControl);
			}
			
			if (m_tabFunc) {
				this->InitPlayerList();
			}
		}
	}
}

void PlayerNpcListScene::InitPlayerList()
{
	if (!m_playerList) {
		m_playerList = new PlayerListLayer;
		m_playerList->Initialization(this);
		m_tabFunc->GetClientLayer(0)->AddChild(m_playerList);
	}
}

void PlayerNpcListScene::RefreshPlayerControl(int idPlayer)
{
	if (!m_layerPlayerControl) {
		m_layerPlayerControl = new NDUILayer;
		m_layerPlayerControl->Initialization();
		//m_layerPlayerControl->SetBackgroundColor(ccc4(255, 0, 255, 255));
		m_layerPlayerControl->SetFrameRect(CGRectMake(0, 284, 480, 36));
	}
	
	if (m_layerPlayerControl->GetParent() == NULL) {
		this->AddChild(m_layerPlayerControl);
	}
	
	m_layerPlayerControl->RemoveAllChildren(true);
	
#define fastinit(tag) \
do \
{ \
btn = new NDUIButton; \
btn->Initialization(); \
btn->SetBackgroundPicture(pic); \
btn->SetFrameRect(CGRectMake(bAddToLeft ? fLeftX : fRightX, 0, 39, 35)); \
btn->SetTag(tag); \
btn->SetDelegate(this); \
m_layerPlayerControl->AddChild(btn); \
if (bAddToLeft) { \
fLeftX += 42; \
} else { \
fRightX -= 42; \
} \
bAddToLeft = !bAddToLeft; \
} while (0)
	
	NDManualRole *role = NDMapMgrObj.GetManualRole(idPlayer);
	
	if (role) {
		NDPlayer& player = NDPlayer::defaultHero();
		
		NDUIButton* btn = NULL;
		bool bAddToLeft = true;
		GLfloat fLeftX = 0;
		GLfloat fRightX = 445;
		
		NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("btn_bg0.png"));
		
		NDPicturePool& pool = *NDPicturePool::DefaultPool();
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetBackgroundPicture(pic, NULL, false, CGRectZero, true);
		btn->SetImage(pool.AddPicture(GetImgPathBattleUI("trade.png")), false, CGRectZero, true);
		btn->SetFrameRect(CGRectMake(fLeftX, 0, 39, 35));
		btn->SetTag(ePlayerTrade);
		btn->SetDelegate(this);
		m_layerPlayerControl->AddChild(btn);
		//btn->SetTitle("交易");
		bAddToLeft = false;
		fLeftX += 42;
		
		if (!player.isTeamMember())
		{
			if (role->isTeamMember())
			{
				fastinit(ePlayerJoinTeam);
				btn->SetImage(pool.AddPicture(GetImgPathBattleUI("join_team.png")), false, CGRectZero, true);
				//btn->SetTitle("进队");
			}
			else
			{
				fastinit(ePlayerInviteTeam);
				btn->SetImage(pool.AddPicture(GetImgPathBattleUI("invite_team.png")), false, CGRectZero, true);
				//btn->SetTitle("组队");
			}
		}
		else if (player.isTeamLeader()) 
		{
			if (!role->isTeamMember())
			{
				fastinit(ePlayerInviteTeam);
				btn->SetImage(pool.AddPicture(GetImgPathBattleUI("invite_team.png")), false, CGRectZero, true);
				//btn->SetTitle("组队");
			}
		}
		
		fastinit(ePlayerAddFriend);
		btn->SetImage(pool.AddPicture(GetImgPathBattleUI("add_friend.png")), false, CGRectZero, true);
		//btn->SetTitle("好友");
		fastinit(ePlayerPrivateTalk);
		btn->SetImage(pool.AddPicture(GetImgPathBattleUI("private_talk.png")), false, CGRectZero, true);
		//btn->SetTitle("私聊");
		
		if (!role->IsInState(USERSTATE_PVE))
		{
			fastinit(ePlayerPK);
			btn->SetImage(pool.AddPicture(GetImgPathBattleUI("PK.png")), false, CGRectZero, true);
			//btn->SetTitle("PK");
		}
		
		fastinit(ePlayerReherse);
		btn->SetImage(pool.AddPicture(GetImgPathBattleUI("reherse.png")), false, CGRectZero, true);
		//btn->SetTitle("比武");
		
		if (role->IsInState(USERSTATE_FIGHTING))
		{
			fastinit(ePlayerWatchBattle);
			btn->SetImage(pool.AddPicture(GetImgPathBattleUI("watch_battle.png")), false, CGRectZero, true);
			//btn->SetTitle("观战");
		}
		
		if (player.level < 20 && role->level >= 20) 
		{
			fastinit(ePlayerBaiShi);
			btn->SetImage(pool.AddPicture(GetImgPathBattleUI("baishi.png")), false, CGRectZero, true);
			//btn->SetTitle("拜师");
		} 
		else if (player.level >= 20 && role->level < 20)
		{
			fastinit(ePlayerShouTu);
			btn->SetImage(pool.AddPicture(GetImgPathBattleUI("shoutu.png")), false, CGRectZero, true);
			//btn->SetTitle("收徒");
		}
		
		fastinit(ePlayerMail);
		btn->SetImage(pool.AddPicture(GetImgPathBattleUI("mail.png")), false, CGRectZero, true);
		//btn->SetTitle("邮件");
		
		if (player.getSynRank() >= SYNRANK_MENZHU_SHENG) {
			fastinit(ePlayerInviteSyn);
			btn->SetImage(pool.AddPicture(GetImgPathBattleUI("invite_syn.png")), false, CGRectZero, true);
			//btn->SetTitle("军团");
		}
		
	} else {
		if (m_layerPlayerControl->GetParent()) {
			m_layerPlayerControl->RemoveFromParent(false);
		}
	}
#undef fastinit
}

void PlayerNpcListScene::RemoveNpcControlLayer()
{
	if (m_layerNpcControl) {
		m_layerNpcControl->RemoveFromParent(false);
	}
}

void PlayerNpcListScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button))
	{
		return;
	}
	
	int tag = button->GetTag();
	switch (tag) {
		case eNpcTask:
		{
			if (m_npcList) {
				m_npcList->OnClickTask();
			}
		}
			break;
		case eNpcDaoHang:
		{
			if (m_npcList) {
				m_npcList->OnClickDaoHang();
			}
		}
			break;
		default:
			if (m_playerList) {
				m_playerList->OnClickControl(tag);
			}
			break;
	}
}

