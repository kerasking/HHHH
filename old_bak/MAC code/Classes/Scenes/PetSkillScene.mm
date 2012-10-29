/*
 *  PetSkillScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-31.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PetSkillScene.h"
#include "GameUIPaiHang.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "NDBattlePet.h"
#include "BattleMgr.h"
#include "BattleSkill.h"
#include "NDDirector.h"
#include "ItemMgr.h"
#include "NDUISynLayer.h"
#include "NDTransData.h"
#include "NDDataTransThread.h"
#include "Item.h"
#include "NDMapMgr.h"
#include <sstream>

void PetSkillSceneUpdate()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(PetSkillScene))) 
	{
		return;
	}
	
	((PetSkillScene*)scene)->UpdateGui();
}

///////////////////////////////////////////
class PetSkillLayer : public LabelLayer
{
	DECLARE_CLASS(PetSkillLayer)
public:
	PetSkillLayer() { ShowFrame(false); m_color = ccc4(0, 0, 0, 255); }
	~PetSkillLayer(){}
	
	void SetBoderColor(ccColor4B color)
	{
		m_color = color;
	}
		
	void draw() override
	{
		LabelLayer::draw();
		CGRect rect = this->GetScreenRect();
		DrawPolygon(rect, m_color, 1);
	}
private:
	ccColor4B m_color;
};

IMPLEMENT_CLASS(PetSkillLayer, LabelLayer)

////////////////////////////////////////////

#define title_height 28
#define bottom_height 42

enum  
{
	eTagNone = 500,
	eTagWeiKaiQi,
	eTagkaiQi,
};

IMPLEMENT_CLASS(PetSkillScene, NDScene)

PetSkillScene::PetSkillScene()
{
	m_menulayerBG = NULL;
	m_lbTitle = NULL;
	m_tlMain = NULL;
}

PetSkillScene::~PetSkillScene()
{
}

void PetSkillScene::Initialization()
{
	NDScene::Initialization();
	
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize dim = getStringSizeMutiLine("技能", 15);
	m_lbTitle = new NDUILabel;
	m_lbTitle->Initialization();
	m_lbTitle->SetFontSize(15);
	m_lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
	m_lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	m_lbTitle->SetText("技能");
	this->AddChild(m_lbTitle);
	
	m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetVisible(false);
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	
	UpdateGui();
}

void PetSkillScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
//	Item* item = ItemMgrObj.GetEquipItem(Item::eEP_Pet);
//	if (item) 
//	{
//		ShowProgressBar;
//		NDTransData bao(_MSG_PET_SKILL);
//		bao << (unsigned char)4 << int(item->iID) << int(0);
//		SEND_DATA(bao);
//	}
	
	dialog->Close();
}

void PetSkillScene::OnButtonClick(NDUIButton* button)
{
	if (m_menulayerBG && button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
	}
}


void PetSkillScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlMain && cell->IsKindOfClass(RUNTIME_CLASS(PetSkillLayer))) 
	{
		int iTag = cell->GetTag();
		if (iTag == eTagWeiKaiQi) 
		{
//			NDPlayer& player = NDPlayer::defaultHero();
//			HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
//			if (!player.battlepet || player.battlepet->m_id != petData.int_PET_ID) 
//			{
//				return;
//			}
//			
//			NDUIDialog *dlg = new NDUIDialog;
//			dlg->Initialization();
//			int needNum=petData.int_PET_MAX_SKILL_NUM+1;
//			std::stringstream ss;
//			ss << "开启宠物技能槽要消耗<cff0000" << needNum*needNum << "/e个“天工符”。\n请确认是否开启宠物技能格子。";
//			
//			dlg->Show("提示",ss.str().c_str(), "取消", "确定", NULL);
//			dlg->SetDelegate(this);
		}
		else if (iTag == eTagNone) 
		{
		}
		else if (iTag == eTagkaiQi) 
		{
		}
		else 
		{
			BattleMgr& bm = BattleMgrObj;
			BattleSkill* sk = bm.GetBattleSkill(iTag);
			if (sk) 
			{
				showDialog("查看", sk->getFullDes().c_str());
			}
		}
	}
}

void PetSkillScene::UpdateGui()
{
	//if (!m_tlMain) 
//	{
//		return;
//	}
//	
//	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
//	NDPlayer& player = NDPlayer::defaultHero();
//	HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
//	if (!player.battlepet || player.battlepet->m_id != petData.int_PET_ID) 
//	{
//		return;
//	}
//	
//	int w = winsize.width-10;
//	int h = 30;
//	
//	NDBattlePet& pet = *player.battlepet;
//	
//	SET_BATTLE_SKILL_LIST& actskill = pet.GetSkillList(SKILL_TYPE_ATTACK);
//	SET_BATTLE_SKILL_LIST& passiveskill = pet.GetSkillList(SKILL_TYPE_PASSIVE);
//	
//	NDDataSource *dataSource = new NDDataSource;
//	NDSection *section = new NDSection;
//	
//	std::vector<OBJID> vec_id;
//	for (SET_BATTLE_SKILL_LIST_IT it = actskill.begin(); it != actskill.end(); it++) 
//	{
//		vec_id.push_back(*it);
//	}
//	
//	for (SET_BATTLE_SKILL_LIST_IT it = passiveskill.begin(); it != passiveskill.end(); it++) 
//	{
//		vec_id.push_back(*it);
//	}
//	
//	int skillSize = vec_id.size();
//	
//	for(int i=0;i<10;i++)
//	{
//		PetSkillLayer *layer = new PetSkillLayer;
//		layer->Initialization();
//		layer->ShowFrame(false);
//		layer->SetFontSize(15);
//		layer->SetBoderColor(ccc4(0, 0, 0, 255));
//		layer->SetFrameRect(CGRectMake(0, 0, w, h));
//		
//		if(i<petData.int_PET_MAX_SKILL_NUM)
//		{
//			if(i<skillSize)
//			{	
//				layer->SetBackgroundColor(INTCOLORTOCCC4(0xffffff));
//				
//				int iSkillID = vec_id[i];
//
//				BattleMgr& bm = BattleMgrObj;
//				BattleSkill* sk = bm.GetBattleSkill(iSkillID);
//				if (!sk) 
//				{
//					layer->SetTag(eTagNone);
//					section->AddCell(layer);
//					continue;
//				}
//				
//				std::vector<std::string> vec_str;
//				std::stringstream ss, sslvl; 
//				ss << sk->getName();
//				sslvl << "(" << int(sk->getLevel()) << "级)";
//				vec_str.push_back(ss.str());
//				vec_str.push_back(sslvl.str());
//				layer->SetTexts(vec_str);
//				layer->SetTag(iSkillID);
//			}else{
//				
//				layer->SetBackgroundColor(INTCOLORTOCCC4(0x888888));
//				std::vector<std::string> vec_str;
//				vec_str.push_back("无");
//				layer->SetTexts(vec_str);
//				layer->SetFontColor(INTCOLORTOCCC4(0x00ee00));
//				layer->SetTag(eTagkaiQi);
//			}
//		}else{
//			layer->SetBackgroundColor(INTCOLORTOCCC4(0x444444));
//			std::vector<std::string> vec_str;
//			vec_str.push_back("未开启");
//			layer->SetTexts(vec_str);
//			layer->SetFontColor(INTCOLORTOCCC4(0xff0000));
//			layer->SetTag(eTagWeiKaiQi);
//		}
//		
//		section->AddCell(layer);
//	}
//		
//	dataSource->AddSection(section);
//	
//	int iY = title_height + 5;
//	
//	m_tlMain->SetFrameRect(CGRectMake(5, iY, w, winsize.height-title_height-bottom_height-10));
//	m_tlMain->SetVisible(true);
//	
//	if (m_tlMain->GetDataSource())
//	{
//		m_tlMain->SetDataSource(dataSource);
//		m_tlMain->ReflashData();
//	}
//	else
//	{
//		m_tlMain->SetDataSource(dataSource);
//	}
}




