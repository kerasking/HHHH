/*
 *  MasterUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "MasterUILayer.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include <sstream>

IMPLEMENT_CLASS(MasterUILayer, NDUIMenuLayer)

MasterUILayer* MasterUILayer::s_instance = NULL;

void MasterUILayer::refreshScroll(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			MasterUILayer *masterList = new MasterUILayer;
			masterList->Initialization();
			gameScene->AddChild(masterList, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList(data);
}

void MasterUILayer::releaseDaoshi()
{
	for (VEC_DAOSHI_ELEMENT_IT it = this->m_vDaoshi.begin(); it != this->m_vDaoshi.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vDaoshi.clear();
}

void MasterUILayer::refreshMainList(NDTransData& data)
{
	if (!this->m_tlMain)
	{
		return;
	}
	
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
	
	this->releaseDaoshi();
	
	int count = data.ReadByte();
	int curPage = data.ReadShort() + 1;
	int totalPage = data.ReadShort();
	
	m_btnPage->SetPages(curPage, totalPage);
	
	bool bChangeClr = false;
	for (int i = 0; i < count; i++) {
		SocialElement* pDaoshi = new SocialElement;
		this->m_vDaoshi.push_back(pDaoshi);
		SocialElement& daoshi = *pDaoshi;
		
		daoshi.m_id = data.ReadInt();			// id
		daoshi.m_state = ELEMENT_STATE(data.ReadByte());		// 在线状态
		daoshi.m_param = data.ReadByte();		// 等级
		daoshi.m_text1 = data.ReadUnicodeString();	// 名字
		
		stringstream ss;
		ss << daoshi.m_param;
		daoshi.m_text2 = ss.str();
		
		daoshi.m_text3 = daoshi.m_state == ES_ONLINE ? NDCommonCString("online") : NDCommonCString("offline");
		
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(10.0f, 0.0f, 450.0f, 27.0f), pDaoshi);
		
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

MasterUILayer::MasterUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	m_tlMain = NULL;
	m_curSelEle = NULL;
	m_optLayer = NULL;
	m_btnPage = NULL;
}

MasterUILayer::~MasterUILayer()
{
	s_instance = NULL;
	this->releaseDaoshi();
}

void MasterUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlMain == table) {
		this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
		// 显示操作选项
		NDUITableLayer* opt = new NDUITableLayer;
		opt->Initialization();
		opt->VisibleSectionTitles(false);
		opt->SetDelegate(this);
		
		CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 30) / 2, 94, 30));
		
		NDDataSource* ds = new NDDataSource;
		NDSection* sec = new NDSection;
		ds->AddSection(sec);
		opt->SetDataSource(ds);
		
		NDUIButton* btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle(NDCommonCString("BaiShi"));
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		switch (cellIndex) {
			case 0: // 拜师
			{
				NDTransData bao(_MSG_TUTOR);
				bao << Byte(18) << this->m_curSelEle->m_id;
				SEND_DATA(bao);
			}
				break;
			default:
				break;
		}
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void MasterUILayer::OnButtonClick(NDUIButton* button)
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

void MasterUILayer::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("MingShiTongXunLu"));
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
	title->SetText(NDCommonCString("name"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("level"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("state"));
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
	
	m_btnPage = new NDPageButton;
	m_btnPage->Initialization(CGRectMake(160.0f, 250.0f, 160.0f, 24.0f));
	m_btnPage->SetDelegate(this);
	this->AddChild(m_btnPage);
}

void MasterUILayer::OnPageChange(int nCurPage, int nTotalPage)
{
	NDUISynLayer::Show();
	NDTransData bao(_MSG_TUTOR);
	bao << Byte(17) << nCurPage - 1;
	SEND_DATA(bao);
}
