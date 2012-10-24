/*
 *  DianhuaUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "DianhuaUILayer.h"
#include "NDUISynLayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "SocialTextLayer.h"
#include "BattleMgr.h"
#include <sstream>

DianhuaUILayer* DianhuaUILayer::s_instance = NULL;

IMPLEMENT_CLASS(DianhuaUILayer, NDUIMenuLayer)

DianhuaUILayer::DianhuaUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	m_tlMain = NULL;
	m_curSelEle = NULL;
}

DianhuaUILayer::~DianhuaUILayer()
{
	s_instance = NULL;
	this->releaseSkillElement();
}

void DianhuaUILayer::RefreshList(int type, int idNextLevelSkill, int lqz)
{
	if (!s_instance) {
		CloseProgressBar;
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			DianhuaUILayer *layer = new DianhuaUILayer;
			layer->Initialization(type);
			gameScene->AddChild(layer, UILAYER_Z);
			gameScene->SetUIShow(true);
		}
	}
	s_instance->AddSkillToList(idNextLevelSkill, lqz);
}

void DianhuaUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	this->m_curSelEle = ((SocialTextLayer*)cell)->GetSocialElement();
	// 显示操作选项
	BattleSkill* pSkill = BattleMgrObj.GetBattleSkill(this->m_curSelEle->m_id);
	if (!pSkill) {
		return;
	}
	
	NDUIDialog* dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->SetDelegate(this);
	dlg->Show(NULL, pSkill->getFullDes().c_str(), NDCommonCString("return"), NDCommonCString("DianHua"), NULL);
}

void DianhuaUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
		{
			((GameScene*)(this->GetParent()))->SetUIShow(false);
			this->RemoveFromParent(true);
		}
	}
}

void DianhuaUILayer::Initialization(int type)
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	if (type == 3) {
		title->SetText(NDCommonCString("CanWuSkill"));
	} else {
		title->SetText(NDCommonCString("XinFaDianFa"));
	}
	
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
	title->SetText(NDCommonCString("skill"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentLeft);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("LingQiConsume"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentRight);
	title->SetFrameRect(CGRectMake(12, 32, 456, 17));
	title->SetFontColor(ccc4(0, 0, 0,255));
	this->AddChild(title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(4, 50, 466, 226));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	
	NDDataSource *ds = new NDDataSource;
	m_tlMain->SetDataSource(ds);
	
	ds->AddSection(new NDSection);
}

void DianhuaUILayer::AddSkillToList(int idNextLevelSkill, int lqz)
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	NDSection* sec = ds->Section(0);
	
	BattleMgr& mgr = BattleMgrObj;
	BattleSkill* pSkill = mgr.GetBattleSkill(idNextLevelSkill - 1);
	if (pSkill) {
		SocialElement* se = new SocialElement;
		this->m_vSkillElement.push_back(se);
		se->m_id = idNextLevelSkill - 1;
		stringstream ssName;
		ssName << pSkill->getName() << "(" << (idNextLevelSkill % 100) << NDCommonCString("Ji") << ")";
		se->m_text1 = ssName.str();
		
		stringstream ss;
		ss << lqz;
		se->m_text2 = ss.str();
		
		SocialTextLayer* st = new SocialTextLayer;
		st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
				   CGRectMake(8.0f, 0.0f, 452.0f, 27.0f), se);
		
		sec->AddCell(st);
	}
	
	this->m_tlMain->ReflashData();
}

void DianhuaUILayer::releaseSkillElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vSkillElement.begin(); it != this->m_vSkillElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vSkillElement.clear();
}

void DianhuaUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	// 点化
	dialog->Close();
	
	NDTransData bao(_MSG_SKILL);
	bao << Byte(4) << this->m_curSelEle->m_id + 1;
	SEND_DATA(bao);
}
