/*
 *  SyndicateStorage.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "SyndicateStorage.h"
#include "NDUISynLayer.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDDirector.h"
#include "SocialTextLayer.h"
#include "SyndicateCommon.h"
#include "NDUtility.h"
#include <sstream>
#include "NDUICustomView.h"

const Byte t_formID[6] = {
	DONATE_MONEY,
	DONATE_WOOD,
	DONATE_STONE,
	DONATE_PAINT,
	DONATE_COAL,
	DONATE_EMONEY,
};

const char* t_str[6] = {"银两","木材","石材","油漆","乌金","元宝"};

IMPLEMENT_CLASS(SyndicateStorage, NDUIMenuLayer)

SyndicateStorage* SyndicateStorage::s_instance = NULL;

void SyndicateStorage::refreshScroll(NDTransData& data)
{
	CloseProgressBar;
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			SyndicateStorage *list = new SyndicateStorage;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	s_instance->refreshMainList(data);
}

void SyndicateStorage::releaseElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void SyndicateStorage::refreshMainList(NDTransData& data)
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
	
	long long t_contriTotal = data.ReadLong();//总贡献值
	{
		stringstream ss;
		ss << t_contriTotal;
		m_lbTotalContri->SetText(ss.str().c_str());
	}
	
	bool bChangeClr = false;
	for(int i = 0; i < 6; i++){
		stringstream ss;
		if(i == 0 || i == 5){
			long long lVal = data.ReadLong();
			ss << lVal;
		}else {
			int nVal = data.ReadInt();
			ss << nVal;
		}
		
		SocialElement* se = new SocialElement;
		this->m_vElement.push_back(se);
		se->m_id = i;
		se->m_param = t_formID[i];
		se->m_text1 = t_str[i];
		se->m_text2 = ss.str();
		
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

SyndicateStorage::SyndicateStorage()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	this->m_lbTotalContri = NULL;
}

SyndicateStorage::~SyndicateStorage()
{
	s_instance = NULL;
	this->releaseElement();
}

void SyndicateStorage::OnButtonClick(NDUIButton* button)
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

bool SyndicateStorage::isInputOk(NDUICustomView* view)
{
	string inputData = view->GetEditText(0);
	if (inputData.empty()) {
		view->ShowAlert("请输入");
		return false;
	}
	NDPlayer& role = NDPlayer::defaultHero();
	int num = atoi(inputData.c_str());
	switch (m_curSelEle->m_param) {
		case DONATE_MONEY: {
			if (num < 100 || num % 100 > 0) {
				view->ShowAlert("请输入100的倍数！");
				return false;
			}
			if (num <= role.money) {
				return true;
			}else {
				view->ShowAlert("您所剩银两不足！");
				return false;
			}
			break;
		}
		case DONATE_EMONEY: {
			if (num >0 && num <= role.eMoney) {
				return true;
			}else {
				view->ShowAlert("您所剩元宝不足！");
				return false;
			}
			break;
		}
		default:
			break;
	}
	return true;
}

bool SyndicateStorage::OnCustomViewConfirm(NDUICustomView* customView)
{
	VerifyViewNum(*customView);
	
	if (!this->isInputOk(customView)) {
		return false;
	}
	
	sendContributeSyn(this->m_curSelEle->m_param, atoi(customView->GetEditText(0).c_str()));
	return true;
}

void SyndicateStorage::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
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
		btn->SetTitle("捐献");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		btn = new NDUIButton;
		btn->Initialization();
		btn->SetTitle("离开");
		btn->SetFocusColor(ccc4(253, 253, 253, 255));
		sec->AddCell(btn);
		nHeight += 30;
		
		opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 30) / 2, 94, nHeight));
		sec->SetFocusOnCell(0);
		
		this->m_optLayer = new NDOptLayer;
		this->m_optLayer->Initialization(opt);
		this->AddChild(m_optLayer);
	} else if (this->m_optLayer && this->m_optLayer->GetOpt() == table) {
		switch (cellIndex) {
			case 0: // 捐献
			{
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetDelegate(this);
				std::vector<int> vec_id; vec_id.push_back(1);
				string strTitle = "请输入您要捐献的";
				strTitle += t_str[m_curSelEle->m_id];
				strTitle += "数:";
				std::vector<std::string> vec_str; vec_str.push_back(strTitle);
				view->SetEdit(1, vec_id, vec_str);
				view->Show();
				this->AddChild(view);
			}
				break;
			default:
				break;
		}
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
}

void SyndicateStorage::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText("军团仓库");
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
	title->SetText("总贡献");
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	m_lbTotalContri = new NDUILabel;
	m_lbTotalContri->Initialization();
	m_lbTotalContri->SetText("0");
	m_lbTotalContri->SetFontSize(15);
	m_lbTotalContri->SetTextAlignment(LabelTextAlignmentRight);
	m_lbTotalContri->SetFrameRect(CGRectMake(12, 32, 456, 17));
	m_lbTotalContri->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(m_lbTotalContri);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 50, 476, 200));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
}