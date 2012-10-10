/*
 *  SyndicateApprove.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateApprove.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "SyndicateCommon.h"
#include "NDMapMgr.h"
#include "EmailSendScene.h"
#include <sstream>

IMPLEMENT_CLASS(SyndicateApprove, NDUIMenuLayer)

SyndicateApprove* SyndicateApprove::s_instance = NULL;

void SyndicateApprove::refreshScroll(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			SyndicateApprove *list = new SyndicateApprove;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList(data);
}

void SyndicateApprove::delCurSelEle()
{
	CloseProgressBar;
	if (s_instance) {
		s_instance->releaseCurSelEle();
	}
}

void SyndicateApprove::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void SyndicateApprove::releaseCurSelEle()
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
		
		for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
			if (m_curSelEle == *it) {
				SAFE_DELETE(*it);
				m_vElement.erase(it);
				break;
			}
		}
		m_curSelEle = NULL;
		m_tlMain->ReflashData();
		
		UpdtaeTitle(sec->Count());
	}
}

void SyndicateApprove::refreshMainList(NDTransData& data)
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
	
	
	int approveCount = data.ReadShort();
	int btCurPage = data.ReadByte(); // 当前页数
	int btCurPageApproveCount = data.ReadByte(); // 当前需审批人数
	
	int t_totalPage = 1;
	if (approveCount % ONE_PAGE_COUNT == 0) {
		t_totalPage = approveCount / ONE_PAGE_COUNT;
	} else {
		t_totalPage = approveCount / ONE_PAGE_COUNT + 1;
	}
	t_totalPage = max(1, t_totalPage);
	
	this->m_btnPage->SetPages(btCurPage + 1, t_totalPage);
	
	bool bChangeClr = false;
	for (int i = 0; i < btCurPageApproveCount; i++) {
		int idRole = data.ReadInt();
		string strName = data.ReadUnicodeString();
		
		SocialElement* se = new SocialElement;
		this->m_vElement.push_back(se);
		se->m_id = idRole;
		se->m_text1 = strName;
		
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
	
	UpdtaeTitle(sec->Count());
}

SyndicateApprove::SyndicateApprove()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	this->m_btnPage = NULL;
	this->m_lbTitle = NULL;
}

SyndicateApprove::~SyndicateApprove()
{
	s_instance = NULL;
	this->releaseElement();
}

void SyndicateApprove::OnButtonClick(NDUIButton* button)
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

void SyndicateApprove::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
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
		btn->SetTitle("通过审批");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle("拒绝通过");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle("添加好友");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle("发送邮件");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nHeight) / 2, 94, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		switch (cellIndex) {
			case 0:
			{
				sendApproveAccept(this->m_curSelEle->m_id, this->m_curSelEle->m_text1);
			}
				break;
			case 1:
			{
				sendApproveRefuse(this->m_curSelEle->m_id);
			}
				break;
			case 2: // 添加好友
			{
				//sendQueryTaxisDetail(this->m_curSelEle->m_id);
				sendAddFriend(this->m_curSelEle->m_text1);
			}
				break;
			case 3: // 发送邮件
			{
				//sendQueryTaxisDetail(this->m_curSelEle->m_id);
				NDDirector::DefaultDirector()->PushScene(EmailSendScene::Scene(this->m_curSelEle->m_text1));
			}
				break;
			default:
				break;
		}
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void SyndicateApprove::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetText("待审批玩家");
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
	
	NDUILabel *title = new NDUILabel;
	title->Initialization();
	title->SetText("申请加入的玩家姓名");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
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
	
	m_btnPage = new NDPageButton;
	m_btnPage->Initialization(CGRectMake(160.0f, 250.0f, 160.0f, 24.0f));
	m_btnPage->SetDelegate(this);
	this->AddChild(m_btnPage);
}

void SyndicateApprove::OnPageChange(int nCurPage, int nTotalPage)
{
	sendQueryApprove(nCurPage - 1);
}

void SyndicateApprove::UpdtaeTitle(int iCurPageCount)
{
	if (!m_lbTitle || !m_btnPage) {
		return;
	}
	
	int curCount = (m_btnPage->GetCurPage()-1 < 0 ? 0 : m_btnPage->GetCurPage()-1)  * ONE_PAGE_COUNT;
	std::stringstream temp;
	if (iCurPageCount > 0) {
		temp << "待审批人数[" << (curCount + 1) << " ~ " << (curCount + iCurPageCount) << "]";
	} else {
		temp << "待审批人数[" << curCount << " ~ " << (curCount + iCurPageCount) << "]";
	}
	
	m_lbTitle->SetText(temp.str().c_str());
}
