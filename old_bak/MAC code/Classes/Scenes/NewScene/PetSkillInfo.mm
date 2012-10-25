/*
 *  PetSkillInfo.mm
 *  DragonDrive
 *
 *  Created by wq on 11-8-28.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PetSkillInfo.h"
#include "NDUtility.h"
#include "NDMapMgr.h"
#include "BattleMgr.h"
#include "NDPath.h"
#include "ItemImage.h"
#include <sstream>
#include "ItemMgr.h"
#include "NDUISynLayer.h"

//////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PetSkillInfoLayer, NDUILayer)

PetSkillInfoLayer::PetSkillInfoLayer()
{
	m_imgSkill = NULL;
	m_lbSkillName = NULL;
	m_lbReqLv = NULL;
	m_skillInfo = NULL;
	m_btnKaiQi = NULL;
}

PetSkillInfoLayer::~PetSkillInfoLayer()
{
	if (m_btnKaiQi && m_btnKaiQi->GetParent() == NULL) {
		SAFE_DELETE(m_btnKaiQi);
	}
}
	
void PetSkillInfoLayer::Initialization()
{
	NDUILayer::Initialization();
	
	NDUIImage* imgSkillBg = new NDUIImage;
	imgSkillBg->Initialization();
	imgSkillBg->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_bagitem_sel.png")), true);
	imgSkillBg->SetFrameRect(CGRectMake(16, 16, 42, 42));
	this->AddChild(imgSkillBg);
	
	m_imgSkill = new NDUIImage;
	m_imgSkill->Initialization();
	m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
	this->AddChild(m_imgSkill);
	
	m_lbSkillName = new NDUILabel;
	m_lbSkillName->Initialization();
	m_lbSkillName->SetFontSize(16);
	m_lbSkillName->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbSkillName->SetFrameRect(CGRectMake(66, 14, 160, 20));
	this->AddChild(m_lbSkillName);
	
	m_lbReqLv = new NDUILabel;
	m_lbReqLv->Initialization();
	m_lbReqLv->SetFontSize(14);
	m_lbReqLv->SetFontColor(ccc4(187, 19, 19, 255));
	m_lbReqLv->SetFrameRect(CGRectMake(66, 41, 100, 20));
	this->AddChild(m_lbReqLv);
	
	NDUIImage* imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 68, 185, 2));
	this->AddChild(imgSlash);
	
	imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, 222, 185, 2));
	this->AddChild(imgSlash);
	
	m_skillInfo = new NDUILabelScrollLayer;
	m_skillInfo->Initialization();
	m_skillInfo->SetFrameRect(CGRectMake(6, 74, 180, 140));
	this->AddChild(m_skillInfo);
	
	m_btnKaiQi = new NDUIButton;
	m_btnKaiQi->Initialization();
	m_btnKaiQi->SetImage(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")), false, CGRectZero, true);
	m_btnKaiQi->SetFontColor(ccc4(247, 247, 247, 255));
	m_btnKaiQi->SetTitle(NDCommonCString("open"));
	m_btnKaiQi->SetDelegate(this);
	m_btnKaiQi->SetFrameRect(CGRectMake(26, 226, 48, 24));
}

void PetSkillInfoLayer::OnButtonClick(NDUIButton* button)
{
	/*
	if (button == m_btnKaiQi) {
		Item* item = ItemMgrObj.GetEquipItem(Item::eEP_Pet);
		if (item) 
		{
			ShowProgressBar;
			NDTransData bao(_MSG_PET_SKILL);
			bao << (unsigned char)4 << int(item->iID) << int(0);
			SEND_DATA(bao);
		}
	}
	*/
}
	
void PetSkillInfoLayer::RefreshPetSkill(int idSkill)
{
	if (-1 == idSkill) {
		if (m_btnKaiQi->GetParent() == NULL) {
			this->AddChild(m_btnKaiQi);
		}
		m_imgSkill->SetPicture(NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("lockstate.png")), true);
		m_imgSkill->SetFrameRect(CGRectMake(17, 17, 40, 40));
		m_lbSkillName->SetText(NDCommonCString("notopen"));
		m_lbReqLv->SetText("");
		#pragma mark todo
		//int needNum=NDMapMgrObj.petInfo.m_data.int_PET_MAX_SKILL_NUM+1;
//		std::stringstream ss;
//		ss << NDCommonCString("OpenPetSkillTip") << "<cff0000" << needNum*needNum << "/e" << NDCommonCString("ge") << "“" << NDCommonCString("TianGongFu") << "”。";
//		m_skillInfo->SetText(ss.str().c_str());
	} else {
		if (m_btnKaiQi->GetParent()) {
			m_btnKaiQi->RemoveFromParent(false);
		}
		
		BattleSkill* pSkill = BattleMgrObj.GetBattleSkill(idSkill);
		if (pSkill) {
			m_imgSkill->SetPicture(GetSkillIconByIconIndex(pSkill->getIconIndex()), true);
			m_imgSkill->SetFrameRect(CGRectMake(20, 20, 34, 34));
			std::stringstream ss; 
			ss << pSkill->getName() << "(" << pSkill->getLevel() << NDCommonCString("Ji") << ")";
			m_lbSkillName->SetText(ss.str().c_str());
			ss.str("");
			ss << NDCommonCString("ReqLvl") << "：" << pSkill->getLvRequire() << NDCommonCString("Ji");
			m_lbReqLv->SetText(ss.str().c_str());
			m_skillInfo->SetText(pSkill->getSimpleDes(false).c_str());
		} else {
			m_imgSkill->SetPicture(NULL);
			m_lbSkillName->SetText("");
			m_lbReqLv->SetText("");
			m_skillInfo->SetText("");
		}
	}
	
	if (m_skillInfo && !this->IsVisibled()) {
		m_skillInfo->SetVisible(false);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
PetSkillIconLayer* PetSkillIconLayer::s_instance = NULL;

IMPLEMENT_CLASS(PetSkillIconLayer, NDUILayer)

void PetSkillIconLayer::OnUnLockSkill()
{
	if (s_instance) {
		s_instance->UnLockSkill();
	}
}

void PetSkillIconLayer::UnLockSkill()
{
	NDUIButton* btn = NULL;
	for (int i = 0; i < ROW_COUNT; i++) {
		for (int j = 0; j < COL_COUNT; j++) {
			btn = m_btnSkill[i][j];
			if (btn && -1 == btn->GetTag()) {
				btn->SetImage(NULL);
				btn->SetTag(0);
				NDUINode* focus = this->GetFocus();
				if (focus) {
					m_skillInfoLayer->RefreshPetSkill(focus->GetTag());
				}
				return;
			}
		}
	}
}

PetSkillIconLayer::PetSkillIconLayer()
{
	m_skillInfoLayer = NULL;
	s_instance = this;
	memset(m_btnSkill, 0L, sizeof(m_btnSkill));
}

PetSkillIconLayer::~PetSkillIconLayer()
{
	s_instance = NULL;
}

enum  {
	BG_SIZE = 42,
};

void PetSkillIconLayer::Initialization(PetSkillInfoLayer* skillInfoLayer)
{
	NDUILayer::Initialization();
	/*
	m_skillInfoLayer = skillInfoLayer;
	
	NDPicturePool& pool = *NDPicturePool::DefaultPool();
	
	NDUIImage* imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture((NDPath::GetImgPathNew("bag_bag_bg.png")), true);
	imgBg->SetFrameRect(CGRectMake(0, 0, 252, 274));
	this->AddChild(imgBg);
	
	GLfloat fStartX = 12;
	GLfloat fStartY = 12;
	
	NDPicture* picSkillButtonBg = pool.AddPicture((NDPath::GetImgPathNew("bag_bagitem.png"));
	NDPicture* picSkillButtonFocus = pool.AddPicture((NDPath::GetImgPathNew("bag_bagitem_sel.png"));
	
	bool bClearPicOnFree = true;
	
	NDPlayer& player = NDPlayer::defaultHero();
	HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
	if (!player.battlepet || player.battlepet->m_id != petData.int_PET_ID) 
	{
		return;
	}
	
	NDBattlePet& pet = *player.battlepet;
	
	SET_BATTLE_SKILL_LIST& actskill = pet.GetSkillList(SKILL_TYPE_ATTACK);
	SET_BATTLE_SKILL_LIST& passiveskill = pet.GetSkillList(SKILL_TYPE_PASSIVE);
	
	std::vector<int> vec_id;
	for (SET_BATTLE_SKILL_LIST::iterator itAct = actskill.begin(); itAct != actskill.end(); itAct++) 
	{
		vec_id.push_back(*itAct);
	}
	
	for (SET_BATTLE_SKILL_LIST::iterator itPas = passiveskill.begin(); itPas != passiveskill.end(); itPas++) 
	{
		vec_id.push_back(*itPas);
	}
	
	vector<int>::iterator it = vec_id.begin();
	
	BattleSkill* pSkill = NULL;
	
	int nSkillCount = 0;
	
	for (int i = 0 ; i < ROW_COUNT; i++) {
		fStartX = 12;
		for (int j = 0; j < COL_COUNT; j++) {
			NDUIButton* btn = new NDUIButton;
			btn->Initialization();
			if (bClearPicOnFree) {
				bClearPicOnFree = !bClearPicOnFree;
				btn->SetBackgroundPicture(picSkillButtonBg, NULL, false, CGRectZero, true);
				btn->SetFocusImage(picSkillButtonFocus, false, CGRectZero, true);
			} else {
				btn->SetBackgroundPicture(picSkillButtonBg);
				btn->SetFocusImage(picSkillButtonFocus);
			}
			btn->SetFrameRect(CGRectMake(fStartX, fStartY, BG_SIZE, BG_SIZE));
			btn->CloseFrame();
			btn->SetDelegate(this);
			
			if (it != vec_id.end()) {
				pSkill = BattleMgrObj.GetBattleSkill(*it);
				if (pSkill) {
					btn->SetTag(*it);
					btn->SetImage(GetSkillIconByIconIndex(pSkill->getIconIndex()), true, CGRectMake(4, 4, 34, 34), true);
				}
				it++;
				nSkillCount++;
			} else if (nSkillCount < petData.int_PET_MAX_SKILL_NUM) {
				nSkillCount++;
				btn->SetTag(0);
			} else {
				btn->SetTag(-1);
				btn->SetImage(pool.AddPicture((NDPath::GetImgPathNew("lockstate.png")), true, CGRectMake(1, 1, 40, 40), true);
			}

			m_btnSkill[i][j] = btn;
			this->AddChild(btn);
			fStartX += BG_SIZE + 4;
		}
		fStartY += BG_SIZE + 6;
	}
	
	this->SetFocus(m_btnSkill[0][0]);
	this->OnButtonClick(m_btnSkill[0][0]); */
}

void PetSkillIconLayer::OnButtonClick(NDUIButton* button)
{
	if (m_skillInfoLayer) {
		m_skillInfoLayer->RefreshPetSkill(button->GetTag());
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
IMPLEMENT_CLASS(PetSkillTab, NDUILayer)

PetSkillTab::PetSkillTab()
{
	m_petSkillIconLayer = NULL;
	m_petSkillInfoLayer = NULL;
}

PetSkillTab::~PetSkillTab()
{
	
}

void PetSkillTab::Initialization()
{
	NDUILayer::Initialization();
	
	m_petSkillInfoLayer = new PetSkillInfoLayer;
	m_petSkillInfoLayer->Initialization();
	m_petSkillInfoLayer->SetFrameRect(CGRectMake(0, 10, 202, 260));
	this->AddChild(m_petSkillInfoLayer);
	
	m_petSkillIconLayer = new PetSkillIconLayer;
	m_petSkillIconLayer->Initialization(m_petSkillInfoLayer);
	m_petSkillIconLayer->SetFrameRect(CGRectMake(214, 6, 230, 240));
	this->AddChild(m_petSkillIconLayer);
}
