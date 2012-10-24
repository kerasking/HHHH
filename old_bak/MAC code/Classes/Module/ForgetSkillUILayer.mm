/*
 *  ForgetSkillUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "ForgetSkillUILayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "BattleMgr.h"
#include "SocialTextLayer.h"
#include "NDUISynLayer.h"
#include <sstream>

ForgetSkillUILayer* ForgetSkillUILayer::s_instance = NULL;

IMPLEMENT_CLASS(ForgetSkillUILayer, NDUIMenuLayer)

void ForgetSkillUILayer::Show()
{
	CloseProgressBar;
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
		GameScene* gameScene = (GameScene*)scene;
		ForgetSkillUILayer *layer = new ForgetSkillUILayer;
		layer->Initialization();
		gameScene->AddChild(layer, UILAYER_Z);
		gameScene->SetUIShow(true);
	}
}

ForgetSkillUILayer::ForgetSkillUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	m_tlMain = NULL;
	m_curSelEle = NULL;
}

ForgetSkillUILayer::~ForgetSkillUILayer()
{
	s_instance = NULL;
	this->releaseSkillElement();
}

void ForgetSkillUILayer::RefreshSkillList()
{
	if (s_instance) {
		s_instance->refreshMainList();
	}
}

void ForgetSkillUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
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
	dlg->Show(NULL, pSkill->getFullDes().c_str(), NDCommonCString("return"), NDCommonCString("forget"), NULL);
}

void ForgetSkillUILayer::OnButtonClick(NDUIButton* button)
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

void ForgetSkillUILayer::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("SkillForget"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 30, 476, 246));
	m_tlMain->VisibleSectionTitles(true);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 255));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
	
	this->refreshMainList();
}

void ForgetSkillUILayer::refreshMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	this->releaseSkillElement();
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	
	NDPlayer& role = NDPlayer::defaultHero();
	
	SET_BATTLE_SKILL_LIST& actSkill = role.GetSkillList(SKILL_TYPE_ATTACK);
	SET_BATTLE_SKILL_LIST& pasSkill = role.GetSkillList(SKILL_TYPE_PASSIVE);
	
	NDSection* secAct = NULL;
	NDSection* secPas = NULL;
	
	bool bChangeClr = false;
	BattleSkill* pSkill = NULL;
	BattleMgr& mgr = BattleMgrObj;
	
	if (actSkill.size() > 0) {
		secAct = new NDSection;
		secAct->SetTitle(NDCommonCString("PositiveSkill"));
		ds->AddSection(secAct);
		
		for (SET_BATTLE_SKILL_LIST_IT it = actSkill.begin(); it != actSkill.end(); it++) {
			pSkill = mgr.GetBattleSkill(*it);
			if (!pSkill) {
				continue;
			}
			
			SocialElement* se = new SocialElement;
			this->m_vSkillElement.push_back(se);
			se->m_id = pSkill->getId();
			stringstream ssName;
			ssName << pSkill->getName() << "(" << pSkill->getLevel() << NDCommonCString("Ji") <<")";
			se->m_text1 = ssName.str();
			
			stringstream ss;
			ss << (2 * pSkill->getMoney()) << NDCommonCString("money");
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
			secAct->AddCell(st);
		}
	}
	
	if (pasSkill.size() > 0) {
		secPas = new NDSection;
		secPas->SetTitle(NDCommonCString("NegativeSkill"));
		ds->AddSection(secPas);
		
		for (SET_BATTLE_SKILL_LIST_IT it = pasSkill.begin(); it != pasSkill.end(); it++) {
			pSkill = mgr.GetBattleSkill(*it);
			if (!pSkill) {
				continue;
			}
			
			SocialElement* se = new SocialElement;
			this->m_vSkillElement.push_back(se);
			se->m_id = pSkill->getId();
			stringstream ssName;
			ssName << pSkill->getName() << "(" << pSkill->getLevel() << NDCommonCString("Ji") << ")";
			se->m_text1 = ssName.str();
			
			stringstream ss;
			ss << (2 * pSkill->getMoney()) << NDCommonCString("money");
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
			secPas->AddCell(st);
		}
	}
	
	this->m_tlMain->ReflashData();
}

void ForgetSkillUILayer::releaseSkillElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vSkillElement.begin(); it != this->m_vSkillElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vSkillElement.clear();
}

void ForgetSkillUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	// 遗忘
	dialog->Close();
	
	NDTransData bao(_MSG_SKILL);
	bao << Byte(3) << this->m_curSelEle->m_id;
	SEND_DATA(bao);
}