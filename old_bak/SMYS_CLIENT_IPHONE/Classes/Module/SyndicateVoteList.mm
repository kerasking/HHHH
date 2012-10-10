/*
 *  SyndicateVoteList.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateVoteList.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "SyndicateCommon.h"
#include "NDUtility.h"

enum {
	TAG_VOTE_VIEW,
	TAG_VOTE_CANCEL,
	TAG_VOTE_YES,
	TAG_VOTE_NO,
};

IMPLEMENT_CLASS(SyndicateVoteList, NDUIMenuLayer)

SyndicateVoteList* SyndicateVoteList::s_instance = NULL;

void SyndicateVoteList::refreshScroll(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			SyndicateVoteList *list = new SyndicateVoteList;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList(data);
}

void SyndicateVoteList::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void SyndicateVoteList::refreshMainList(NDTransData& data)
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	this->releaseElement();
	
	int count = data.ReadByte();
	bool bChangeClr = false;
	for (int i = 0; i < count; i++) {
		int idVode = data.ReadInt();//投票id
		int idSponsor = data.ReadInt();//发起人id
		string t_detail = data.ReadUnicodeString();//投票原因
		int nEndTime = data.ReadInt();//到期时间
		
		SocialElement* se = new SocialElement;
		this->m_vElement.push_back(se);
		se->m_id = idVode;
		se->m_param = idSponsor;
		se->m_text1 = t_detail;
		se->m_text2 = getStringTime(nEndTime);
		
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
}

SyndicateVoteList::SyndicateVoteList()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
}

SyndicateVoteList::~SyndicateVoteList()
{
	s_instance = NULL;
	this->releaseElement();
}

void SyndicateVoteList::OnButtonClick(NDUIButton* button)
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

void SyndicateVoteList::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
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
		btn->SetTitle("查看");
		btn->SetTag(TAG_VOTE_VIEW);
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		if (m_curSelEle->m_param == NDPlayer::defaultHero().m_id) {
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle("取消投票项");
			btn->SetTag(TAG_VOTE_CANCEL);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			nHeight += 30;
		} else {
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle("赞成票");
			btn->SetTag(TAG_VOTE_YES);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			nHeight += 30;
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle("反对票");
			btn->SetTag(TAG_VOTE_NO);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			nHeight += 30;
		}
		
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 30) / 2, 94, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		int tag = cell->GetTag();
		switch (tag) {
			case TAG_VOTE_VIEW:
			{
				sendSynVoteComm(ACT_QUERY_VOTE_INFO, this->m_curSelEle->m_id);
			}
				break;
			case TAG_VOTE_NO:
			{
				sendSynVoteComm(ACT_VOTE_NO, this->m_curSelEle->m_id);
			}
				break;
			case TAG_VOTE_YES:
			{
				sendSynVoteComm(ACT_VOTE_YES, this->m_curSelEle->m_id);
				break;
			}
			case TAG_VOTE_CANCEL:
			{
				sendSynVoteComm(ACT_CANCEL_VOTE, this->m_curSelEle->m_id);
				break;
			}
			default:
				break;
		}
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
		
		if (tag == TAG_VOTE_NO || tag == TAG_VOTE_YES) {
			this->OnButtonClick(this->GetCancelBtn());
		}
	}
}

void SyndicateVoteList::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText("投票箱");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	NDUILayer* columnTitle = new NDUILayer;
	columnTitle->Initialization();
	columnTitle->SetBackgroundColor(ccc4(115, 117, 115, 255));
	columnTitle->SetFrameRect(CGRectMake(7, 32, 466, 17));
	this->AddChild(columnTitle);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText("原因");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText("结束时间");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentRight);
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