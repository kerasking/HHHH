/*
 *  QuickInteraction.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-17.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "QuickInteraction.h"
#include "NDUtility.h"
#include "NDUIImage.h"
#include "NDNpc.h"
#include "NDManualRole.h"
#include "NDPlayer.h"
#include "NDMapMgr.h"
#include "NDUISynLayer.h"
#include "VendorBuyUILayer.h"
#include "VendorUILayer.h"
#include "GameUITaskList.h"
#include "EmailSendScene.h"
#include "NDDirector.h"
#include "ChatInput.h"
#include "PlayerInfoScene.h"
#include "OtherPlayerInfoScene.h"
#include "NewMailSend.h"
#include "Chat.h"
#include "SystemAndCustomScene.h"
#include "NewVipStoreScene.h"
#include "BattleFieldData.h"
#include "BattleFieldScene.h"

using namespace NDEngine;

IMPLEMENT_CLASS(QuickInteraction, NDUIChildrenEventLayer)

QuickInteraction* QuickInteraction::s_instance = NULL;

void QuickInteraction::RefreshOptions()
{
	if (s_instance) {
		NDBaseRole * role = NDMapMgrObj.GetManualRole(NDPlayer::defaultHero().m_iFocusManuRoleID);
		
		if (!role)
		{
			role = NDPlayer::defaultHero().GetFocusNpc();
		}
		
		s_instance->Refresh(role);
	}
}

QuickInteraction::QuickInteraction()
{
	s_instance = this;
	m_btnSwitch = NULL;
	m_picEmptyBtn = NULL;
	m_picInviteTeam = NULL;
	m_picJoinTeam = NULL;
	m_picLeftTeam = NULL;
	m_picAddFriend = NULL;
	m_picReherse = NULL;
	m_picWatchBattle = NULL;
	m_picInviteSyn = NULL;
	m_picBaiShi = NULL;
	m_picShouTu = NULL;
	m_picShowVendor = NULL;
	m_picCloseTeam = NULL;
	m_picOpenTeam = NULL;
	m_picKickOutTeam = NULL;
	m_picDismissTeam = NULL;
	m_picAssignTeamLeader = NULL;
	
	m_picSysSet = NULL;
	m_picSysBackToMenu = NULL;
	m_picSysReset = NULL;
	
	m_secondBarShowIndex = 0;
	
	m_picTrade = m_picPk = NULL;
	
	m_dlgQueryVipShop = NULL;
	
	m_dlgQueryTreasureHunt = NULL;
	
	m_firstLayer = NULL;
}

QuickInteraction::~QuickInteraction()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
	if (m_secondBarLayer && m_secondBarLayer->GetParent() == NULL) {
		SAFE_DELETE(m_secondBarLayer);
	}
	
	SAFE_DELETE(m_picEmptyBtn);
	SAFE_DELETE(m_picInviteTeam);
	SAFE_DELETE(m_picJoinTeam);
	SAFE_DELETE(m_picLeftTeam);
	SAFE_DELETE(m_picAddFriend);
	SAFE_DELETE(m_picReherse);
	SAFE_DELETE(m_picWatchBattle);
	SAFE_DELETE(m_picInviteSyn);
	SAFE_DELETE(m_picBaiShi);
	SAFE_DELETE(m_picShouTu);
	SAFE_DELETE(m_picShowVendor);
	SAFE_DELETE(m_picCloseTeam);
	SAFE_DELETE(m_picOpenTeam);
	SAFE_DELETE(m_picKickOutTeam);
	SAFE_DELETE(m_picDismissTeam);
	SAFE_DELETE(m_picAssignTeamLeader);
	SAFE_DELETE(m_picTrade);
	SAFE_DELETE(m_picPk);
	SAFE_DELETE(m_picSysSet);
	SAFE_DELETE(m_picSysBackToMenu);
	SAFE_DELETE(m_picSysReset);
}

void QuickInteraction::Initialization()
{
	NDUIChildrenEventLayer::Initialization();
	
	this->SetDragOverEnabled(true);
	this->SwallowDragOverEvent(true);
	
	m_status = SS_SHOW;
	
	NDPicturePool* pool = NDPicturePool::DefaultPool();
	// 固定显示第一栏的功能和背景
	m_firstLayer = new NDUIChildrenEventLayer;
	
	NDUIChildrenEventLayer *firstLayer = m_firstLayer;
	
	firstLayer->Initialization();
	firstLayer->SetDragOverEnabled(true);
	//firstLayer->SetBackgroundColor(ccc4(0, 255, 0, 255));
	firstLayer->SetFrameRect(CGRectMake(0, 40, 347, 35));
	this->AddChild(firstLayer, 1);
	
	NDUIImage* imgFirstBg = new NDUIImage;
	imgFirstBg->Initialization();
	imgFirstBg->EnableEvent(false);
	imgFirstBg->SetPicture(pool->AddPicture(GetImgPathBattleUI("quick_bar_bg.png"), false), true);
	imgFirstBg->SetFrameRect(CGRectMake(0.0f, -9.0, 347.0f, 44.0f));
	firstLayer->AddChild(imgFirstBg);
	
	GLfloat x = 23;
	GLfloat y = 0.0f;
	m_btnPlayerBag = new NDUIButton;
	m_btnPlayerBag->Initialization();
	m_btnPlayerBag->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnPlayerBag->SetImage(pool->AddPicture(GetImgPathNew("bagicon.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnPlayerBag->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	m_btnPlayerBag->SetDelegate(this);
	//m_btnPlayerBag->SetTitle("摆摊", false, false);
	firstLayer->AddChild(m_btnPlayerBag);
	x += 43.0f;
	
	m_btnSystem = new NDUIButton;
	m_btnSystem->Initialization();
	m_btnSystem->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnSystem->SetImage(pool->AddPicture(GetImgPathNew("systemicon.png"), true), false, CGRectZero, true);
	m_btnSystem->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	m_btnSystem->SetDelegate(this);
	//m_btnTask->SetTitle("任务", false, false);
	firstLayer->AddChild(m_btnSystem);
	x += 43.0f;
	
	m_btnMail = new NDUIButton;
	m_btnMail->Initialization();
	m_btnMail->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnMail->SetImage(pool->AddPicture(GetImgPathBattleUI("mail.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnMail->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	m_btnMail->SetDelegate(this);
	//m_btnMail->SetTitle("邮件", false, false);
	m_btnMail->EnalbeGray(true);
	firstLayer->AddChild(m_btnMail);
	x += 43.0f;
	
	m_btnMainUiBack = new NDUIButton;
	m_btnMainUiBack->Initialization();
	m_btnMainUiBack->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnMainUiBack->SetImage(pool->AddPicture(GetImgPathNew("main_ui_back.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnMainUiBack->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	m_btnMainUiBack->SetDelegate(this);
	//m_btnTrade->SetTitle("交易", false, false);
	m_btnMainUiBack->EnalbeGray(false);
	firstLayer->AddChild(m_btnMainUiBack);
	x += 43.0f;
	
	m_btnMainUiReset = new NDUIButton;
	m_btnMainUiReset->Initialization();
	m_btnMainUiReset->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnMainUiReset->SetImage(pool->AddPicture(GetImgPathNew("battlefield.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnMainUiReset->SetDelegate(this);
	m_btnMainUiReset->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	//m_btnPK->SetTitle("PK", false, false);
	m_btnMainUiReset->EnalbeGray(false);
	firstLayer->AddChild(m_btnMainUiReset);
	x += 43.0f;
	
	m_btnViewInfo = new NDUIButton;
	m_btnViewInfo->Initialization();
	m_btnViewInfo->SetDelegate(this);
	m_btnViewInfo->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnViewInfo->SetImage(pool->AddPicture(GetImgPathBattleUI("treasure_hunt.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnViewInfo->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	//m_btnViewInfo->SetTitle("查看", false, false);
	//m_btnViewInfo->EnalbeGray(true);
	firstLayer->AddChild(m_btnViewInfo);
	x += 43.0f;
	
	m_btnPrivateTalk = new NDUIButton;
	m_btnPrivateTalk->Initialization();
	m_btnPrivateTalk->SetDelegate(this);
	m_btnPrivateTalk->SetBackgroundPicture(pool->AddPicture(GetImgPathBattleUI("itemchildback.png"), true), NULL, false, CGRectZero, true);
	m_btnPrivateTalk->SetImage(pool->AddPicture(GetImgPathBattleUI("private_talk.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnPrivateTalk->SetFrameRect(CGRectMake(x, y, 39.0f, 35.0f));
	//m_btnPrivateTalk->SetTitle("私聊", false, false);
	m_btnPrivateTalk->EnalbeGray(true);
	firstLayer->AddChild(m_btnPrivateTalk, 1);
	x += 43.0f;
	
	// 第二栏背景及切换按钮
	m_secondBarLayer = new NDUIChildrenEventLayer;
	m_secondBarLayer->Initialization();
	//m_secondBarLayer->SetBackgroundColor(ccc4(0, 0, 255, 255));
	m_secondBarLayer->SetFrameRect(CGRectMake(9, 0, 329, 35));
	m_secondBarLayer->SetDragOverEnabled(true);
	//this->AddChild(m_secondBarLayer);
	
	NDUIImage* imgSecondBg = new NDUIImage;
	imgSecondBg->Initialization();
	imgSecondBg->EnableEvent(false);
	imgSecondBg->SetPicture(pool->AddPicture(GetImgPathBattleUI("quick_bar_bg2.png"), false), true);
	imgSecondBg->SetFrameRect(CGRectMake(0, 0, 329, 75));
	m_secondBarLayer->AddChild(imgSecondBg);
	
	m_picEmptyBtn = pool->AddPicture(GetImgPathBattleUI("btn_icon.png"));
	m_picInviteTeam = pool->AddPicture(GetImgPathBattleUI("invite_team.png"));
	m_picJoinTeam = pool->AddPicture(GetImgPathBattleUI("join_team.png"));
	m_picLeftTeam = pool->AddPicture(GetImgPathBattleUI("left_team.png"));
	m_picAddFriend = pool->AddPicture(GetImgPathBattleUI("add_friend.png"));
	m_picReherse = pool->AddPicture(GetImgPathBattleUI("reherse.png"));
	m_picWatchBattle = pool->AddPicture(GetImgPathBattleUI("watch_battle.png"));
	m_picInviteSyn = pool->AddPicture(GetImgPathBattleUI("invite_syn.png"));
	m_picBaiShi = pool->AddPicture(GetImgPathBattleUI("baishi.png"));
	m_picShouTu = pool->AddPicture(GetImgPathBattleUI("shoutu.png"));
	m_picShowVendor = pool->AddPicture(GetImgPathBattleUI("show_vendor.png"));
	
	m_picAssignTeamLeader = pool->AddPicture(GetImgPathBattleUI("assign_team_leader.png"));
	m_picDismissTeam = pool->AddPicture(GetImgPathBattleUI("dismiss_team.png"));
	m_picCloseTeam = pool->AddPicture(GetImgPathBattleUI("close_team.png"));
	m_picOpenTeam = pool->AddPicture(GetImgPathBattleUI("open_team.png"));
	m_picKickOutTeam = pool->AddPicture(GetImgPathBattleUI("kickout_team.png"));
	
	m_picTrade = pool->AddPicture(GetImgPathBattleUI("trade.png"));
	m_picPk = pool->AddPicture(GetImgPathBattleUI("PK.png"));
	
	m_picSysSet = pool->AddPicture(GetImgPathNew("quickfunc_system.png"));
	m_picSysBackToMenu = pool->AddPicture(GetImgPathNew("main_ui_back.png"));
	m_picSysReset = pool->AddPicture(GetImgPathNew("main_ui_reset.png"));
	
	x = 12.5f;
	y = 0.0f;
	
	for (int i = 0; i < 6; i++) {
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetImage(m_picEmptyBtn);
		btn->SetFrameRect(CGRectMake(x + i * 43.0f, y, 40, 40));
		btn->SetDelegate(this);
		m_secondBarLayer->AddChild(btn);
		m_vSecondBarBtns.push_back(btn);
	}
	
	m_btnSwitch = new NDUIButton;
	m_btnSwitch->Initialization();
	m_btnSwitch->SetFrameRect(CGRectMake(x + 6 * 43 + 10, y + 8, 31, 31));
	m_btnSwitch->SetImage(NDPicturePool::DefaultPool()->AddPicture(GetImgPathBattleUI("refresh_new.png"), true), false, CGRectMake(0, 0, 0, 0), true);
	m_btnSwitch->SetFontColor(ccc4(255, 100, 0, 255));
	m_btnSwitch->SetTitle("2", false, false);
	m_btnSwitch->SetDelegate(this);
	//m_secondBarLayer->AddChild(m_btnSwitch);
}

void QuickInteraction::OnBattleBegin()
{
}

void QuickInteraction::OnButtonClick(NDUIButton* button)
{
	if (button->IsGray()) {
		return;
	}
	
	if (button == m_btnSwitch) {
		size_t count = m_vOpts.size();
		if (this->m_secondBarShowIndex < count) {
			m_btnSwitch->SetTitle("3");
			for (VEC_BTNS::iterator itBtn = m_vSecondBarBtns.begin(); itBtn != m_vSecondBarBtns.end(); itBtn++) {
				if (m_secondBarShowIndex < count) {
					this->SetBtnImgByOpt(*itBtn, m_vOpts.at(m_secondBarShowIndex));
					m_secondBarShowIndex++;
				} else {
					this->SetBtnImgByOpt(*itBtn, QI_BEGIN);
				}
			}
		} else {
			if (count > 6) {
				m_secondBarShowIndex = 0;
				m_btnSwitch->SetTitle("2");
				for (VEC_BTNS::iterator itBtn = m_vSecondBarBtns.begin(); itBtn != m_vSecondBarBtns.end(); itBtn++) {
					if (m_secondBarShowIndex < count) {
						this->SetBtnImgByOpt(*itBtn, m_vOpts.at(m_secondBarShowIndex));
						m_secondBarShowIndex++;
					} else {
						this->SetBtnImgByOpt(*itBtn, QI_BEGIN);
					}
				}
			}
		}
		
		return;
	}
	
	GameScene* gs = GameScene::GetCurGameScene();
	if (!gs) {
		return;
	}
	
	if (button == m_btnPlayerBag) {
		
		ResetSecondBar();
		
		// 打开背包
		NDScene* runningScene = NDDirector::DefaultDirector()->GetRunningScene();
		if (runningScene && !runningScene->IsKindOfClass(RUNTIME_CLASS(PlayerInfoScene))) {
			PlayerInfoScene* scene = PlayerInfoScene::Scene(); 
			NDDirector::DefaultDirector()->PushScene(scene);
			scene->SetTabFocusOnIndex(0, true);
		}
		/*
		bool fly = NDPlayer::defaultHero().IsInState(USERSTATE_FLY);
		if (fly) 
		{
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("BoothNotFly"));
			return;
		}
		
		if (NDMapMgrObj.canBooth()) {
			VendorUILayer::Show(gs);
			gs->SetUIShow(true);
		} else {
			showDialog(NDCommonCString("WenXinTip"), NDCommonCString("BoothNot"));
		}
		*/
		
		return;
	}
	
	if (button == m_btnSystem) {
		/*GameUITaskList *tasklist = new GameUITaskList;
		tasklist->Initialization();
		gs->AddChild(tasklist, UILAYER_Z, UILAYER_TASK_LIST_TAG);
		gs->SetUIShow(true);*/
	
		//NDDirector::DefaultDirector()->PushScene(SystemAndCustomScene::Scene());
		RefreshSystem();
		return;
	}
	
	if (button == m_btnMainUiBack) {
		ResetSecondBar();
		
		// 回主界面
		//NDPlayer& player = NDPlayer::defaultHero();
		m_dlgQueryTreasureHunt = new NDUIDialog;
		m_dlgQueryTreasureHunt->Initialization();
		m_dlgQueryTreasureHunt->SetDelegate(this);
		m_dlgQueryTreasureHunt->Show(NDCommonCString("tip"), 
				NDCommonCString("XunBaoTip"), NULL, NDCommonCString("StartXunBao"), NDCommonCString("BackToMenu"), NULL);
		
		return;
		//trade(role->m_id, 0);
	} else if (button == m_btnMainUiReset) {
		
		ResetSecondBar();
		
		{
			NDDirector::DefaultDirector()->PushScene(BattleFieldScene::Scene());
			CloseProgressBar;
			ShowProgressBar;
		}
		return;
		// 卡死复位
//		NDTransData bao(_MSG_RESET_POSITION);
//		SEND_DATA(bao);
//		
//		ShowProgressBar;
//		return;
		//sendPKAction(*role, BATTLE_ACT_PK);
	} 
	else if (button == m_btnViewInfo) 
	{
		ResetSecondBar();
		
		DealTreasureHunt();
		
		return; 
	}
	
	
	NDPlayer& player = NDPlayer::defaultHero();
	NDManualRole *role = NDMapMgrObj.GetManualRole(player.m_iFocusManuRoleID);
	
	if (!role) {
		if (button == m_btnPrivateTalk) 
		{
			ResetSecondBar();
			
			NDNpc* npc = player.GetFocusNpc();
			if (npc && npc->GetType() != 6) 
			{
				player.SendNpcInteractionMessage(npc->m_id);
				if (npc->IsDirectOnTalk()) 
				{
					//npc朝向修改	
					if (player.GetPosition().x > npc->GetPosition().x) 
						npc->DirectRight(true);
					else 
						npc->DirectRight(false);
				}
			}
			
			return;
		}
	}
	
	if (button == m_btnMail) {
		
		ResetSecondBar();
		
		if (role)
			NDDirector::DefaultDirector()->PushScene(NewMailSendScene::Scene(role->m_name.c_str()));
		//NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene(role->m_name));
	}else if (button == m_btnViewInfo) {
		ResetSecondBar();
		if (role)
			NDDirector::DefaultDirector()->PushScene(OtherPlayerInfoScene::Scene(role));
	} else if (button == m_btnPrivateTalk) {
		ResetSecondBar();
		
		if (role)
		{	
			PrivateChatInput::DefaultInput()->SetLinkMan(role->m_name.c_str());
			PrivateChatInput::DefaultInput()->Show();
		}
	} else {
		int tag = button->GetTag();
		switch (tag) {
			case QI_CLOSE_TEAM:
			case QI_OPEN_TEAM:
			{
				NDTransData bao(_MSG_TEAM);
				if (NDMapMgrObj.bolEnableAccept) 
				{
					bao << (unsigned short)MSG_TEAM_DISABLEACCEPT;
				}
				else 
				{
					bao << (unsigned short)MSG_TEAM_ENABLEACCEPT;
				}
				bao << player.m_id << int(0);
				SEND_DATA(bao);
			}
				break;
			case QI_DISMISS_TEAM:
			{
				NDTransData bao(_MSG_TEAM);
				bao << (unsigned short)MSG_TEAM_DISMISS << player.m_id << int(0);
				SEND_DATA(bao);
			}
				break;
			case QI_KICKOUT_TEAM:
			{
				if (role && !role->bClear) 
				{
					NDTransData bao(_MSG_TEAM);
					bao << (unsigned short)MSG_TEAM_KICK << player.m_id
					<< role->m_id;
					SEND_DATA(bao);
				}
			}
				break;
			case QI_ASSIGN_TEAM_LEADER:
			{
				if (role && !role->bClear) 
				{
					NDTransData bao(_MSG_TEAM);
					bao << (unsigned short)MSG_TEAM_CHGLEADER << player.m_id
					<< role->m_id;
					SEND_DATA(bao);
				}
			}
				break;
			case QI_INVITE_TEAM:
			{
				if (role)
				{
					NDTransData bao(_MSG_TEAM);
					bao << (unsigned short)MSG_TEAM_INVITE << player.m_id << role->m_id;
					SEND_DATA(bao);
					Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("TeamReqTip"));
				}
			}
				break;
			case QI_JOIN_TEAM:
			{
				if (role)
				{
					NDTransData bao(_MSG_TEAM);
					bao << (unsigned short)MSG_TEAM_JOIN << player.m_id << role->m_id;
					SEND_DATA(bao);
				}
			}
				break;
			case QI_LEFT_TEAM:
			{
				if (role)
				{
					NDTransData bao(_MSG_TEAM);
					bao << (unsigned short)MSG_TEAM_LEAVE << player.m_id << int(0);
					SEND_DATA(bao);
				}
			}
				break;
			case QI_ADD_FRIEND:
			{
				if (role)
					sendAddFriend(role->m_name);
			}
				break;
			case QI_REHERSE:
			{
				if (role)
					sendRehearseAction(role->m_id, REHEARSE_APPLY);
			}
				break;
			case QI_WATCH_BATTLE:
			{
				if (role)
				{
					ShowProgressBar;
					NDTransData bao(_MSG_BATTLEACT);
					bao << Byte(BATTLE_ACT_WATCH) << Byte(0) << Byte(1) << int(role->m_id);
					SEND_DATA(bao);
				}
			}
				break;
			case QI_INVITE_SYNDICATE:
			{
				if (role)
					sendInviteOther(role->m_name);
			}
				break;
			case QI_BAI_SHI:
			{
				if (role)
				{
					NDTransData bao(_MSG_TUTOR);
					bao << (unsigned char)1 << role->m_id;
					SEND_DATA(bao);
				}
			}
				break;
			case QI_SHOU_TU:
			{
				if (role)
				{
					NDTransData bao(_MSG_TUTOR);
					bao << (unsigned char)4 << role->m_id;
					SEND_DATA(bao);
				}
			}
				break;
			case QI_SHOW_VENDOR:
			{
				if (role)
				{
					NDUISynLayer::Show();
					VendorBuyUILayer::s_idVendor = role->m_id;
					
					NDTransData bao(_MSG_BOOTH);
					bao << Byte(BOOTH_QUEST) << role->m_id << int(0);
					SEND_DATA(bao);
				}
			}
				break;
			case QI_TRADE:
			{
				if (role)
					trade(role->m_id, 0);
			}
				break;
			case QI_PK:
			{
				if (role)
					sendPKAction(*role, BATTLE_ACT_PK);
			}
				break;
			case QI_SET:
			{
				ResetSecondBar();
				
				NDDirector::DefaultDirector()->PushScene(SystemAndCustomScene::Scene());
			}
				break;
			case QI_BACKTOMENU:
			{
				ResetSecondBar();
				
				m_dlgQueryTreasureHunt = new NDUIDialog;
				m_dlgQueryTreasureHunt->Initialization();
				m_dlgQueryTreasureHunt->SetDelegate(this);
				m_dlgQueryTreasureHunt->Show(
											 NDCommonCString("tip"), 
											 NDCommonCString("XunBaoTip"), 
											 NULL, 
											 NDCommonCString("StartXunBao"), 
											 NDCommonCString("BackToMenu"), 
											 NULL);
				
			}
				break;
			case QI_RESET:
			{
				ResetSecondBar();
				
				// 卡死复位
				NDTransData bao(_MSG_RESET_POSITION);
				SEND_DATA(bao);
				ShowProgressBar;
			}
				break;
			default:
				break;
		}
	}
}

void QuickInteraction::Refresh(NDBaseRole* target)
{
	if (!target) {
		m_btnPrivateTalk->EnalbeGray(true);
		m_secondBarLayer->RemoveFromParent(false);
		return;
	}
	
	// npc 恢复默认
	if (target->IsKindOfClass(RUNTIME_CLASS(NDNpc))) {
		m_secondBarLayer->RemoveFromParent(false);
		//m_btnTrade->EnalbeGray(true);
		m_btnMail->EnalbeGray(true);
		//m_btnPK->EnalbeGray(true);
		//m_btnViewInfo->EnalbeGray(true);
		m_btnPrivateTalk->EnalbeGray(false);
	} else if (target->IsKindOfClass(RUNTIME_CLASS(NDManualRole))) {
		
		// 玩家互动选项
		NDPlayer& player = NDPlayer::defaultHero();
		NDManualRole* role = (NDManualRole*)target;
		
		m_vOpts.clear();
		
		//m_btnTrade->EnalbeGray(false);
		m_btnMail->EnalbeGray(false);
		//m_btnPK->EnalbeGray(role->IsInState(USERSTATE_PVE));
		//m_btnViewInfo->EnalbeGray(false);
		m_btnPrivateTalk->EnalbeGray(false);
		
		if (player.isTeamLeader()) 
		{
			if (NDMapMgrObj.bolEnableAccept)
			{
				m_vOpts.push_back(QI_CLOSE_TEAM);
			} 
			else 
			{
				m_vOpts.push_back(QI_OPEN_TEAM);
			}
			
			if (!role->isTeamMember())
			{
				m_vOpts.push_back(QI_INVITE_TEAM);
			} else {
				m_vOpts.push_back(QI_KICKOUT_TEAM);
				m_vOpts.push_back(QI_ASSIGN_TEAM_LEADER);
			}

			m_vOpts.push_back(QI_LEFT_TEAM);
			m_vOpts.push_back(QI_DISMISS_TEAM);
		}
		else if (player.isTeamMember())
		{
			m_vOpts.push_back(QI_LEFT_TEAM);
		}
		else
		{
			if (role->isTeamMember())
			{
				m_vOpts.push_back(QI_JOIN_TEAM);
			}
			else
			{
				m_vOpts.push_back(QI_INVITE_TEAM);
			}
		}
		
		m_vOpts.push_back(QI_TRADE);
		
		if (!role->IsInState(USERSTATE_PVE))
		{
			m_vOpts.push_back(QI_PK);
		}
		
		m_vOpts.push_back(QI_ADD_FRIEND);
		
		m_vOpts.push_back(QI_REHERSE);
		
		if (role->IsInState(USERSTATE_FIGHTING))
		{
			m_vOpts.push_back(QI_WATCH_BATTLE);
		}
		
		if (player.getSynRank() >= SYNRANK_MENZHU_SHENG && role->getSynRank() == SYNRANK_NONE) {
			m_vOpts.push_back(QI_INVITE_SYNDICATE);
		}
		
		if (player.level < 20 && role->level >= 20) 
		{
			m_vOpts.push_back(QI_BAI_SHI);
		} 
		else if (player.level >= 20 && role->level < 20)
		{
			m_vOpts.push_back(QI_SHOU_TU);
		}
		
		if(role->IsInState(USERSTATE_BOOTH))
		{
			m_vOpts.push_back(QI_SHOW_VENDOR);
		}
		
		m_secondBarShowIndex = 0;
		size_t count = m_vOpts.size();
		for (VEC_BTNS::iterator itBtn = m_vSecondBarBtns.begin(); itBtn != m_vSecondBarBtns.end(); itBtn++) {
			if (m_secondBarShowIndex < count) {
				this->SetBtnImgByOpt(*itBtn, m_vOpts.at(m_secondBarShowIndex));
				m_secondBarShowIndex++;
			} else {
				this->SetBtnImgByOpt(*itBtn, QI_BEGIN);
			}
		}
		
		if (count > 6) {
			if (m_btnSwitch->GetParent() == NULL) {
				m_secondBarLayer->AddChild(m_btnSwitch);
			}
		} else {
			m_btnSwitch->RemoveFromParent(false);
		}

		if (count > 0 && m_secondBarLayer->GetParent() == NULL) {
			this->AddChild(m_secondBarLayer);
		}
	}
}

void QuickInteraction::SetBtnImgByOpt(NDUIButton* btn, QUICK_INTERACTION qi)
{
	btn->SetTag(qi);
	btn->SetBackgroundPicture(m_picEmptyBtn);
	
	switch (qi) {
		case QI_CLOSE_TEAM:
			btn->SetImage(m_picCloseTeam);
			break;
		case QI_OPEN_TEAM:
			btn->SetImage(m_picOpenTeam);
			break;
		case QI_KICKOUT_TEAM:
			btn->SetImage(m_picKickOutTeam);
			break;
		case QI_ASSIGN_TEAM_LEADER:
			btn->SetImage(m_picAssignTeamLeader);
			break;
		case QI_DISMISS_TEAM:
			btn->SetImage(m_picDismissTeam);
			break;
		case QI_INVITE_TEAM:
			btn->SetImage(m_picInviteTeam);
			break;
		case QI_JOIN_TEAM:
			btn->SetImage(m_picJoinTeam);
			break;
		case QI_LEFT_TEAM:
			btn->SetImage(m_picLeftTeam);
			break;
		case QI_ADD_FRIEND:
			btn->SetImage(m_picAddFriend);
			break;
		case QI_REHERSE:
			btn->SetImage(m_picReherse);
			break;
		case QI_WATCH_BATTLE:
			btn->SetImage(m_picWatchBattle);
			break;
		case QI_INVITE_SYNDICATE:
			btn->SetImage(m_picInviteSyn);
			break;
		case QI_BAI_SHI:
			btn->SetImage(m_picBaiShi);
			break;
		case QI_SHOU_TU:
			btn->SetImage(m_picShouTu);
			break;
		case QI_SHOW_VENDOR:
			btn->SetImage(m_picShowVendor);
			break;
		case QI_PK:
			btn->SetImage(m_picPk);
			break;
		case QI_TRADE:
			btn->SetImage(m_picTrade);
			break;
		case QI_SET:
			btn->SetImage(m_picSysSet);
			break;
		case QI_BACKTOMENU:
			btn->SetImage(m_picSysBackToMenu);
			break;
		case QI_RESET:
			btn->SetImage(m_picSysReset);
			break;
		default:
			btn->SetImage(m_picEmptyBtn);
			btn->SetTag(QI_BEGIN);
			break;
	}
}

void QuickInteraction::SetShrink(bool bShrink)
{
	if (bShrink) {
		if (m_status != SS_HIDE) {
			m_status = SS_SHRINKING;
		}
	} else {
		if (m_status != SS_SHOW) {
			m_status = SS_EXTENDING;
		}
	}
}

const float SHRINK_RATE = 20.0f;
const float HEIGHT = 320.0f;

void QuickInteraction::draw()
{
	switch (this->m_status) {
		case SS_HIDE:
			return;
			break;
		case SS_SHRINKING:
		{
			CGRect rect = this->GetFrameRect();
			rect.origin.y += SHRINK_RATE;
			
			// 收缩完成
			if (rect.origin.y >= HEIGHT) {
				rect.origin.y = HEIGHT;
				this->m_status = SS_HIDE;
			}
			this->SetFrameRect(rect);
		}
			break;
		case SS_EXTENDING:
		{
			CGRect rect = this->GetFrameRect();
			rect.origin.y -= SHRINK_RATE;
			
			// 展开完成
			if (rect.origin.y + rect.size.height <= HEIGHT) {
				rect.origin.y = HEIGHT - rect.size.height;
				this->m_status = SS_SHOW;
			}
			this->SetFrameRect(rect);
		}
			break;
		default:
			break;
	}
	
	NDUIChildrenEventLayer::draw();
}

void QuickInteraction::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_dlgQueryVipShop)
	{
		dialog->Close();
		
		map_vip_item& items = ItemMgrObj.GetVipStore();
		if (items.empty()) 
		{
			NDTransData bao(_MSG_SHOP_CENTER);
			bao << (unsigned char)0;
			SEND_DATA(bao);
			ShowProgressBar;
			
			return;
		} 
		
		// 商场购买
		NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene());
	}
	else if (dialog == m_dlgQueryTreasureHunt)
	{
		dialog->Close();
		
		if (buttonIndex == 0)
		{ // 开始寻宝
			DealTreasureHunt();
		}
		else if (buttonIndex == 1)
		{ // 回主界面
			quitGame();
		}
	}
}

void QuickInteraction::OnDialogClose(NDUIDialog* dialog)
{
	if (dialog == m_dlgQueryVipShop)
	{
		m_dlgQueryVipShop = NULL;
	}
	else if (dialog == m_dlgQueryTreasureHunt)
	{
		m_dlgQueryTreasureHunt = NULL;
	}
}

void QuickInteraction::DealTreasureHunt()
{
	if (!NDMapMgrObj.canTreasureHunt()) 
	{
		// 地图不可寻宝
		showDialog(NDCommonCString("tip"), NDCommonCString("MapCantXunBao"));
		return;
	}
	
	if (NDPlayer::defaultHero().activityValue <= 0)
	{
		m_dlgQueryVipShop = new NDUIDialog;
		m_dlgQueryVipShop->Initialization();
		m_dlgQueryVipShop->SetDelegate(this);
		m_dlgQueryVipShop->Show(NDCommonCString("tip"), NDCommonCString("XunBaoHuoLiZero"),
								NULL, NDCommonCString("MallBuy"), NULL);
		return;
	}
	
	NDTransData bao(_MSG_QUERY_TREASURE_HUNT_PROB);
	ShowProgressBar;
	SEND_DATA(bao);
}

bool QuickInteraction::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	return true;
}

bool QuickInteraction::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	if (button->GetImage() == m_picEmptyBtn) return true;
	
	ShowMask(false);
	
	return true;
}

bool QuickInteraction::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	if (desButton->GetImage() == m_picEmptyBtn) return true;
	
	ShowMask(false);
	
	OnButtonClick(desButton);
	
	return true;
}

bool QuickInteraction::OnButtonDragOver(NDUIButton* overButton, bool inRange)
{
	if (overButton->GetImage() == m_picEmptyBtn) return true;
	
	ShowMask(inRange, overButton->GetImage());
	
	return true;
}

bool QuickInteraction::OnButtonLongClick(NDUIButton* button)
{
	ShowMask(false);
	
	OnButtonClick(button);
	
	return true;
}

bool QuickInteraction::OnButtonLongTouch(NDUIButton* button)
{
	// 显示蒙板
	
	if (button->GetImage() == m_picEmptyBtn) return true;
	
	ShowMask(true, button->GetImage());
	
	return true;
}

void QuickInteraction::OnButtonDown(NDUIButton* button)
{
	if (button->GetImage() == m_picEmptyBtn) return;
	
	ShowMask(true, button->GetImage());
}

void QuickInteraction::OnButtonUp(NDUIButton* button)
{
	if (button->GetImage() == m_picEmptyBtn) return;
	
	ShowMask(false);
}

void QuickInteraction::ShowMask(bool show, NDPicture* pic/*=NULL*/)
{
	
#define QUICK_INTERACTION_MASK_IMAGE_TAG (100)
	
	if (!show)
	{
		if (m_layerMask)
		{
			NDUIMaskLayer* layerMask = m_layerMask.Pointer();
			SAFE_DELETE_NODE(layerMask);
		}
		
		return;
	}
	
	if (show && !pic) return;
	
	if (!m_layerMask)
	{
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		
		if (!scene->IsKindOfClass(RUNTIME_CLASS(GameScene)))
			return;
		
		CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
		
		CGSize picsize = pic->GetSize();
		
		CGRect rectMask = CGRectMake(0, 0, winsize.width, winsize.height);
		
		NDUIMaskLayer* layerMask = new NDUIMaskLayer;
		layerMask->Initialization();
		layerMask->SetFrameRect(rectMask);
		scene->AddChild(layerMask, MAP_MASKLAYER_Z);
		
		m_layerMask = layerMask->QueryLink();
		
		NDUIImage *image = new NDUIImage;
		image->Initialization();
		image->SetFrameRect(CGRectMake((rectMask.size.width-picsize.width)/2, 
									   (rectMask.size.height-picsize.height)/2, 
									   picsize.width, picsize.height));
		image->SetTag(QUICK_INTERACTION_MASK_IMAGE_TAG);
		layerMask->AddChild(image);
	}
	
	if (!m_layerMask) return;
	
	NDUIImage *image = (NDUIImage *)m_layerMask->GetChild(QUICK_INTERACTION_MASK_IMAGE_TAG);
	
	if (image)
		image->SetPicture(pic);
}

void QuickInteraction::RefreshSystem()
{
	m_btnPrivateTalk->EnalbeGray(true);
	m_btnMail->EnalbeGray(true);
	
	m_vOpts.clear();
	
	m_vOpts.push_back(QI_SET);
	m_vOpts.push_back(QI_BACKTOMENU);
	m_vOpts.push_back(QI_RESET);
	
	m_secondBarShowIndex = 0;
	size_t count = m_vOpts.size();
	for (VEC_BTNS::iterator itBtn = m_vSecondBarBtns.begin(); itBtn != m_vSecondBarBtns.end(); itBtn++) {
		if (m_secondBarShowIndex < count) {
			this->SetBtnImgByOpt(*itBtn, m_vOpts.at(m_secondBarShowIndex));
			m_secondBarShowIndex++;
		} else {
			this->SetBtnImgByOpt(*itBtn, QI_BEGIN);
		}
	}
	
	if (count > 6) {
		if (m_btnSwitch->GetParent() == NULL) {
			m_secondBarLayer->AddChild(m_btnSwitch);
		}
	} else {
		m_btnSwitch->RemoveFromParent(false);
	}
	
	if (count > 0 && m_secondBarLayer->GetParent() == NULL) {
		this->AddChild(m_secondBarLayer);
	}
}

void QuickInteraction::ResetSecondBar()
{
	m_vOpts.clear();
	
	for (VEC_BTNS::iterator itBtn = m_vSecondBarBtns.begin(); itBtn != m_vSecondBarBtns.end(); itBtn++) {
		this->SetBtnImgByOpt(*itBtn, QI_BEGIN);
	}
	
	m_btnSwitch->RemoveFromParent(false);
	m_secondBarLayer->RemoveFromParent(false);
	
	RefreshOptions();
}
