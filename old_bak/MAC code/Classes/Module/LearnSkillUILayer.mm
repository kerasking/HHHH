/*
 *  LearnSkillUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-26.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "LearnSkillUILayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "BattleMgr.h"
#include "SocialTextLayer.h"
#include "NDUISynLayer.h"
#include <sstream>

LearnSkillUILayer* LearnSkillUILayer::s_instance = NULL;

IMPLEMENT_CLASS(LearnSkillUILayer, NDUIMenuLayer)

void LearnSkillUILayer::Show(VEC_BATTLE_SKILL& vSkills)
{
	CloseProgressBar;
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
		GameScene* gameScene = (GameScene*)scene;
		LearnSkillUILayer *layer = new LearnSkillUILayer;
		layer->Initialization(vSkills);
		gameScene->AddChild(layer, UILAYER_Z);
		gameScene->SetUIShow(true);
	}
}

LearnSkillUILayer::LearnSkillUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	m_tlMain = NULL;
	m_curSelEle = NULL;
	m_pVecSkills = NULL;
}

LearnSkillUILayer::~LearnSkillUILayer()
{
	s_instance = NULL;
	this->releaseSkillElement();
}

void LearnSkillUILayer::RefreshSkillList()
{
	if (s_instance) {
		s_instance->refreshMainList();
	}
}

void LearnSkillUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
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
	std::stringstream ss;
	ss << NDCommonCString("up") << "/" << NDCommonCString("learn");
	dlg->Show(NULL, pSkill->getFullDes().c_str(), NDCommonCString("return"), ss.str().c_str(), NULL);
}

void LearnSkillUILayer::OnButtonClick(NDUIButton* button)
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

void LearnSkillUILayer::Initialization(VEC_BATTLE_SKILL& vSkills)
{
	NDUIMenuLayer::Initialization();
	
	this->m_pVecSkills = &vSkills;
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCommonCString("skill"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(2, 30, 476, 210));
	m_tlMain->VisibleSectionTitles(true);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	m_tlMain->SetDataSource(new NDDataSource);
	
	this->refreshMainList();
}

void LearnSkillUILayer::refreshMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	this->releaseSkillElement();
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	
	bool bChangeClr = false;
	bool bSetTitle = false;
	
	VEC_BATTLE_SKILL& vSkills = *m_pVecSkills;
	BattleSkill* pSkill = NULL;
	BattleMgr& mgr = BattleMgrObj;
	NDPlayer& role = NDPlayer::defaultHero();
	for (VEC_BATTLE_SKILL_IT it = vSkills.begin(); it != vSkills.end(); it++) {
		pSkill = mgr.GetBattleSkill(*it);
		if (!pSkill) {
			continue;
		}
		
		if (!bSetTitle) {
			if(pSkill->getType() == SKILL_TYPE_ATTACK) {
				sec->SetTitle(NDCommonCString("PositiveSkill"));
			} else {
				sec->SetTitle(NDCommonCString("NegativeSkill"));
			}
			bSetTitle = true;
		}
		
		SocialElement* se = new SocialElement;
		m_vSkillElement.push_back(se);
		se->m_id = pSkill->getId();
		se->m_text1 = pSkill->getName();
		
		stringstream ss;
		ss << pSkill->getLevel() << NDCommonCString("Ji") << "(";
		
		if (role.IsBattleSkillLearned(*it)) {
			ss << NDCommonCString("hadlearn") << ")";
		} else {
			ss << NDCommonCString("nolearn") << ")";
		}
		
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
	
	sec->SetFocusOnCell(0);
	
	this->m_tlMain->ReflashData();
}

void LearnSkillUILayer::releaseSkillElement()
{
	for (VEC_SOCIAL_ELEMENT_IT it = this->m_vSkillElement.begin(); it != this->m_vSkillElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vSkillElement.clear();
}

void LearnSkillUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	// 升级/学习
	dialog->Close();
	
	if (this->m_curSelEle == NULL)
	{
		return;
	}
	
	NDTransData bao(_MSG_SKILL);
	bao << Byte(1) << this->m_curSelEle->m_id;
	SEND_DATA(bao);
}