/*
 *  SyndicateInviteList.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateInviteList.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "SyndicateCommon.h"
#include <sstream>

IMPLEMENT_CLASS(SyndicateInviteList, NDUIMenuLayer)

SyndicateInviteList* SyndicateInviteList::s_instance = NULL;

void SyndicateInviteList::refreshScroll(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			SyndicateInviteList *list = new SyndicateInviteList;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList(data);
}

void SyndicateInviteList::processSynInvite(NDTransData& data)
{
	CloseProgressBar;
	int btAnswer = data.ReadByte();
	
	switch (btAnswer) {
		case INVITE_ACCEPT_OK: {// 接受邀请,成功加入帮派,删除所有邀请记录
			if (s_instance && s_instance->m_curSelEle) {
				NDPlayer& role = NDPlayer::defaultHero();
				role.synName = s_instance->m_curSelEle->m_text1;
				role.setSynRank(SYNRANK_MEMBER);
				s_instance->clearMainList();
			}
			break;
		}
		case INVITE_REFUSE_OK: {// 拒绝邀请成功,删除该邀请记录
			if (s_instance) {
				s_instance->releaseCurSelEle();
			}
			break;
		}
	}
}

void SyndicateInviteList::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vSyn.begin(); it != this->m_vSyn.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vSyn.clear();
}

void SyndicateInviteList::releaseCurSelEle()
{
	if (m_curSelEle) {
		NDDataSource* ds = m_tlMain->GetDataSource();
		NDSection* sec = ds->Section(0);
		for (uint i = 0; sec->Count(); i++) {
			SocialTextLayer* cell = (SocialTextLayer*)sec->Cell(i);
			if (cell->GetSocialElement() == m_curSelEle) {
				sec->RemoveCell(cell);
				break;
			}
		}
		
		for (VEC_SOCIAL_ELEMENT_IT it = this->m_vSyn.begin(); it != this->m_vSyn.end(); it++) {
			if (m_curSelEle == *it) {
				SAFE_DELETE(*it);
				m_vSyn.erase(it);
				break;
			}
		}
		m_curSelEle = NULL;
		m_tlMain->ReflashData();
		
		if (m_lbTitle) {
			std::stringstream ss; ss << NDCommonCString("JunTuanInviteHang") << "[" << sec->Count() << "]";
			m_lbTitle->SetText(ss.str().c_str());
		}
	}
}

void SyndicateInviteList::clearMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	m_tlMain->GetDataSource()->Clear();
	m_tlMain->ReflashData();
	this->releaseElement();
	
	if (m_lbTitle) {
		std::stringstream ss; ss << NDCommonCString("JunTuanInviteHang") << "[0]";
		m_lbTitle->SetText(ss.str().c_str());
	}
}

void SyndicateInviteList::refreshMainList(NDTransData& data)
{
	this->clearMainList();
	
	NDSection* sec = new NDSection;
	m_tlMain->GetDataSource()->AddSection(sec);
	
	int btCount = data.ReadByte();
	
	bool bChangeClr = false;
	for (int i = 0; i < btCount; i++) {
		int idSyn = data.ReadInt();
		string strSynName = data.ReadUnicodeString();
		
		SocialElement* se = new SocialElement;
		this->m_vSyn.push_back(se);
		se->m_id = idSyn;
		se->m_text1 = strSynName;
		
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(10.0f, 0.0f, 450.0f, 27.0f), se);
		
		if (bChangeClr) {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		sec->AddCell(st);
	}
	
	this->m_tlMain->ReflashData();
	
	if (m_lbTitle) {
		std::stringstream ss; ss << NDCommonCString("JunTuanInviteHang") << "[" << sec->Count() << "]";
		m_lbTitle->SetText(ss.str().c_str());
	}
}

SyndicateInviteList::SyndicateInviteList()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	this->m_lbTitle = NULL;
}

SyndicateInviteList::~SyndicateInviteList()
{
	s_instance = NULL;
	this->releaseElement();
}

void SyndicateInviteList::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
				this->RemoveFromParent(true);
			}
		}
	}
}

void SyndicateInviteList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlMain == table) {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		int nHeight = 0;
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(NDCommonCString("AgreeJoin"));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(NDCommonCString("RejectJoin"));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(NDCommonCString("ViewJunTuiInfo"));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		opt->SetFrameRect(CGRectMake((winSize.width - 110) / 2, (winSize.height - 30) / 2, 110, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		switch (cellIndex) {
			case 0:
			{
				sendInviteResult(INVITE_ACCEPT, this->m_curSelEle->m_id);
			}
				break;
			case 1:
			{
				sendInviteResult(INVITE_REFUSE, this->m_curSelEle->m_id);
			}
				break;
			case 2:
			{
				sendQueryTaxisDetail(this->m_curSelEle->m_id);
			}
				break;
			default:
				break;
		}
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void SyndicateInviteList::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	std::stringstream ssTitle; ssTitle << NDCommonCString("JunTuanInviteHang") << "[0]";
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetText(ssTitle.str().c_str());
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetTextAlignment(LabelTextAlignmentCenter);
	m_lbTitle->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	m_lbTitle->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(m_lbTitle);
	
	NDUILayer* columnTitle = new NDUILayer;
	columnTitle->Initialization();
	columnTitle->SetBackgroundColor(ccc4(115, 117, 115, 255));
	columnTitle->SetFrameRect(CGRectMake(7, 32, 466, 17));
	this->AddChild(columnTitle);
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("InviteYourJunTuan"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 50, 476, 200));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
}