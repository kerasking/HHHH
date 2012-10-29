/*
 *  SynInfoUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SynInfoUILayer.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "NDUISynLayer.h"
#include "GlobalDialog.h"
#include "NDPath.h"
#include "NDDirector.h"

SynInfoUILayer* SynInfoUILayer::GetCurInstance()
{
	return s_instance;
}

SynInfoUILayer* SynInfoUILayer::s_instance = NULL;

IMPLEMENT_CLASS(SynInfoUILayer, NDUILayer)

SynInfoUILayer::SynInfoUILayer()
{
	s_instance = this;
	m_lbInfoTitle = NULL;
	m_btnResign = m_btnChgSynBoard = m_btnQuitSyn = NULL;
	m_synNote = m_synInfo = NULL;
	m_dlgSyndicateResign = m_dlgSyndicateQuit = 0;
}

SynInfoUILayer::~SynInfoUILayer()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
}

void SynInfoUILayer::processSynInfo(NDTransData& data)
{
	CloseProgressBar;
	
	string t_wndTitle = data.ReadUnicodeString();
	string t_wndDetail = data.ReadUnicodeString();
	
	if (m_lbInfoTitle) {
		m_lbInfoTitle->SetText(t_wndTitle.c_str());
	}
	
	if (m_synInfo) {
		m_synInfo->SetText(t_wndDetail.c_str());
	}
}

void SynInfoUILayer::processSynBraodcast(NDTransData& data)
{
	string strNote = data.ReadUnicodeString();
	if (m_synNote) {
		m_synNote->SetText(strNote.c_str());
	}
}

void SynInfoUILayer::Initialization()
{
	NDUILayer::Initialization();
	
	this->SetFrameRect(CGRectMake(0, 0, 450, 286));
	//this->SetBackgroundColor(ccc4(255, 0, 0, 255));
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	NDUIImage* imgLeft = new NDUIImage;
	imgLeft->Initialization();
	imgLeft->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_left_bg.png")), true);
	imgLeft->SetFrameRect(CGRectMake(0, 9, 203, 262));
	this->AddChild(imgLeft);
	
	NDUIImage* imgRight = new NDUIImage;
	imgRight->Initialization();
	imgRight->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_bag_bg.png")), true);
	imgRight->SetFrameRect(CGRectMake(203, 3, 252, 274));
	this->AddChild(imgRight);
	
	NDUIImage* infoTitle = new NDUIImage;
	infoTitle->Initialization();
	infoTitle->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("farmrheadtitle.png")), true);
	infoTitle->SetFrameRect(CGRectMake(6, 21, 8, 8));
	this->AddChild(infoTitle);
	
	m_lbInfoTitle = new NDUILabel;
	m_lbInfoTitle->Initialization();
	m_lbInfoTitle->SetFontColor(ccc4(187, 19, 19, 255));
	//m_lbInfoTitle->SetText("军团信息");
	m_lbInfoTitle->SetFrameRect(CGRectMake(16, 17, 80, 30));
	this->AddChild(m_lbInfoTitle);
	
	NDUIImage* imgInfoBg = new NDUIImage;
	imgInfoBg->Initialization();
	imgInfoBg->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("attr_role_bg.png")), true);
	imgInfoBg->SetFrameRect(CGRectMake(0, 40, 196, 185));
	this->AddChild(imgInfoBg);
	
	m_synInfo = new NDUIMemo;
	m_synInfo->Initialization();
	m_synInfo->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_synInfo->SetFrameRect(CGRectMake(6, 50, 186, 170));
	m_synInfo->SetFontColor(ccc4(187, 19, 19, 255));
	this->AddChild(m_synInfo);
	
	m_synNote = new NDUIMemo;
	m_synNote->Initialization();
	m_synNote->SetBackgroundColor(ccc4(0, 0, 0, 0));
	m_synNote->SetFrameRect(CGRectMake(230, 50, 200, 171));
	m_synNote->SetFontColor(ccc4(187, 19, 19, 255));
	this->AddChild(m_synNote);
	
	NDUIImage* imgCamp = new NDUIImage;
	imgCamp->Initialization();
	imgCamp->SetFrameRect(CGRectMake(0, 150, 79, 72));
	this->AddChild(imgCamp);
	
	NDPlayer& player = NDPlayer::defaultHero();
	CAMP_TYPE camp = player.GetCamp();
	switch (camp) {
		case CAMP_TYPE_TU:
			imgCamp->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("tu.png")), true);
			break;
		case CAMP_TYPE_TANG:
			imgCamp->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("tang.png")), true);
			break;
		case CAMP_TYPE_SUI:
			imgCamp->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("sui.png")), true);
			break;
		default:
			break;
	}
	
	NDUIImage* imgSynBroadcast = new NDUIImage;
	imgSynBroadcast->Initialization();
	imgSynBroadcast->SetPicture(pool.AddPicture(NDPath::GetImgPathNew("syn_broadcast.png")), true);
	imgSynBroadcast->SetFrameRect(CGRectMake(263, 15, 134, 24));
	this->AddChild(imgSynBroadcast);
	
	m_btnQuitSyn = new NDUIButton;
	m_btnQuitSyn->Initialization();
	m_btnQuitSyn->SetDelegate(this);
	m_btnQuitSyn->SetFrameRect(CGRectMake(6, 226, 52, 43));
	m_btnQuitSyn->SetImage(pool.AddPicture(NDPath::GetImgPathNew("btn_quit_syn.png")), false, CGRectZero, true);
	this->AddChild(m_btnQuitSyn);
	
	if (player.getSynRank() > SYNRANK_MEMBER) {
		m_btnResign = new NDUIButton;
		m_btnResign->Initialization();
		m_btnResign->SetDelegate(this);
		m_btnResign->SetFrameRect(CGRectMake(136, 226, 35, 42));
		m_btnResign->SetImage(pool.AddPicture(NDPath::GetImgPathNew("resign.png")), false, CGRectZero, true);
		this->AddChild(m_btnResign);
		m_btnResign->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, true, CGRectMake(0, 3, 35, 35), true);
	}
	
	if (player.getSynRank() >= SYNRANK_VICE_LEADER) {
		m_btnChgSynBoard = new NDUIButton;
		m_btnChgSynBoard->Initialization();
		m_btnChgSynBoard->SetDelegate(this);
		m_btnChgSynBoard->SetFrameRect(CGRectMake(386, 226, 52, 43));
		m_btnChgSynBoard->SetImage(pool.AddPicture(NDPath::GetImgPathNew("btn_modify_note.png")), false, CGRectZero, true);
		this->AddChild(m_btnChgSynBoard);
	}
	
	// 发送消息请求
	sendQueryPanelInfo();
	sendQueryAnnounce();
}

void SynInfoUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	OBJID tagDlg = dialog->GetTag();
	if (tagDlg == m_dlgSyndicateResign) {
		dialog->Close();
		m_dlgSyndicateResign = 0;
		sendQuerySynNormalInfo(ACT_RESIGN);
		m_btnResign->RemoveFromParent(true);
		m_btnResign = NULL;
	} else if (tagDlg == m_dlgSyndicateQuit) {
		dialog->Close();
		m_dlgSyndicateQuit = 0;
		sendQuerySynNormalInfo(QUIT_SYN);
		NDDirector::DefaultDirector()->PopScene(true);
	}
}

void SynInfoUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnResign) {
		this->m_dlgSyndicateResign = GlobalDialogObj.Show(this, NDCommonCString("WenXinTip"), NDCString("ConfirmResign"), 0, NDCString("Resign"), NULL);
	} else if (button == m_btnChgSynBoard) {
		NDUICustomView *view = new NDUICustomView;
		view->Initialization();
		view->SetDelegate(this);
		std::vector<int> vec_id; vec_id.push_back(1);
		std::vector<std::string> vec_str; vec_str.push_back(NDCString("InputBrocast"));
		view->SetEdit(1, vec_id, vec_str);
		view->Show();
		this->AddChild(view);
	} else if (button == m_btnQuitSyn) {
		this->m_dlgSyndicateQuit = GlobalDialogObj.Show(this, NDCommonCString("WenXinTip"), NDCString("ConfirmLeave"), 0, NDCommonCString("Ok"), NULL);
	}
}

bool SynInfoUILayer::OnCustomViewConfirm(NDUICustomView* customView)
{
	string synNote = customView->GetEditText(0);
	if (synNote.size() > 0) {
		m_synNote->SetText(synNote.c_str());
		sendModifyNote(synNote);
	}
	return true;
}


