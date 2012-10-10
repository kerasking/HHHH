/*
 *  GameUIBattleSkill.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUIBattleSkill.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "GameUIPlayerList.h"
#include "NDPlayer.h"
#include "SocialElement.h"
#include "BattleMgr.h"
#include "SocialTextLayer.h"
#include "GameScene.h"
#include <sstream>

#define title_height 28
#define bottom_height 42

IMPLEMENT_CLASS(GameUIBattleSkill, NDUIMenuLayer)

GameUIBattleSkill::GameUIBattleSkill()
{
	m_lbTitle = NULL;
	m_tlOperate = NULL;
}

GameUIBattleSkill::~GameUIBattleSkill()
{
	for (std::vector<SocialElement*>::iterator it = m_vecSocial.begin(); it != m_vecSocial.end(); it++) 
	{
		delete *it;
	}
	m_vecSocial.clear();
}

void GameUIBattleSkill::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	CGSize dim = getStringSizeMutiLine("技能", 15);
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
	m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	m_lbTitle->SetText("技能");
	this->AddChild(m_lbTitle);
	
	//NDUITopLayerEx *topLayerEx = new NDUITopLayerEx;
//	topLayerEx->Initialization();
//	topLayerEx->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
//	this->AddChild(topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->SetDelegate(this);
	m_tlOperate->VisibleScrollBar(false);
	m_tlOperate->SetFrameRect(CGRectMake(8, title_height+8, winsize.width-16, winsize.height-bottom_height-title_height-16));
	this->AddChild(m_tlOperate);
	
	NDDataSource *dataSource = new NDDataSource;
	NDPlayer& player = NDPlayer::defaultHero();
	
	for (int i = 0; i < 2; i++) 
	{
		std::string title = i == 0 ? "主动技能" : "被动技能";
		SKILL_TYPE skilltype = i == 0 ? SKILL_TYPE_ATTACK : SKILL_TYPE_PASSIVE;
		
		SET_BATTLE_SKILL_LIST& actlist = player.GetSkillList(skilltype);
		SET_BATTLE_SKILL_LIST_IT it = actlist.begin();
		
		if (actlist.empty()) continue;
		
		NDSection *section = new NDSection;
		section->Clear();
		section->SetTitle(title.c_str());
		
		bool bChangeClr = false;
	
		for (; it != actlist.end(); it++)
		{
			int idSkill = *it;
			BattleMgr& bm = BattleMgrObj;
			BattleSkill* skill = bm.GetBattleSkill(idSkill);
			if (!skill) 
			{
				continue;
			}
			
			SocialTextLayer* st = new SocialTextLayer;
			SocialElement * se = new SocialElement;
			std::stringstream ss1, ss2; 
			
			ss1 << skill->getName() << "(" << skill->getLevel() << "级)";
			
			if (skill->getSpRequire() == 0) 
			{
				ss2 << "满级";
			} 
			else 
			{
				ss2 << skill->getCurSp() << "/" << skill->getSpRequire();
			}
			
			se->m_text1 = ss1.str();
			se->m_text2 = ss2.str();
			
			m_vecSocial.push_back(se);
			
			st->Initialization(CGRectMake(5.0f, 0.0f, 460.0f, 27.0f),
							   CGRectMake(5.0f, 0.0f, 430.0f, 27.0f), se);
			if (bChangeClr) {
				st->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
			} else {
				st->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
			}
			
			bChangeClr = !bChangeClr;
			st->SetTag(idSkill);
			section->AddCell(st);
		}
		
		dataSource->AddSection(section);
	}
		
	if (dataSource->Count() == 0) 
	{
		delete dataSource;
	}
	else 
	{
		m_tlOperate->SetDataSource(dataSource);
	}
}

void GameUIBattleSkill::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate && cell->IsKindOfClass(RUNTIME_CLASS(SocialTextLayer))) 
	{
		int idSkill = cell->GetTag();
		
		BattleMgr& bm = BattleMgrObj;
		BattleSkill* skill = bm.GetBattleSkill(idSkill);
		if (skill) 
		{
			showDialog("查看", skill->getSimpleDes(true).c_str());
		}
	}
}

void GameUIBattleSkill::OnButtonClick(NDUIButton* button)
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
