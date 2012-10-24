/*
 *  PetSkillCompose.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "PetSkillCompose.h"
#include "NDPlayer.h"
#include "NDBattlePet.h"
#include "ItemMgr.h"
#include "NDItemType.h"
#include "BattleMgr.h"
#include "BattleSkill.h"
#include "NDUIItemButton.h"
#include "NDUIFrame.h"
#include "GameUIPetAttrib.h"
#include "NDUIBaseGraphics.h"
#include "NDDirector.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDBattlePet.h"
#include "NDUISynLayer.h"
#include "GamePlayerBagScene.h"
#include "define.h"
#include "EnumDef.h"
#include "CGPointExtension.h"
#include "NDMapMgr.h"
#include <sstream>

class SkillItemView : public NDUIItemButton
{
	DECLARE_CLASS(SkillItemView)
public:
	SkillItemView();
	~SkillItemView();
	
	void Initialization(); override
	void draw(); override
	
	void SetState(bool bClose=true);
	bool IsClose();
	void SetLock(bool bSet);
	bool isLock();
	void SetSkillID(int iSkillID);
	int GetSkillID();
private:
	bool m_bClose;
	bool m_bLock;
	NDUILayer* m_frontLayer;
	int m_iSkillID;
};

IMPLEMENT_CLASS(SkillItemView, NDUIItemButton)

SkillItemView::SkillItemView()
{
	m_bClose = true;
	m_bLock = false;
	m_frontLayer = NULL;
	m_iSkillID = -1;
}

SkillItemView::~SkillItemView()
{
	SAFE_DELETE(m_frontLayer);
}

void SkillItemView::Initialization()
{
	NDUIItemButton::Initialization();
	
	m_frontLayer = new NDUILayer;
	m_frontLayer->Initialization();
	m_frontLayer->SetTouchEnabled(false);
	m_frontLayer->SetBackgroundColor(ccc4(107, 158, 156, 255));
	m_frontLayer->SetVisible(false);
	
	this->SetFontColor(INTCOLORTOCCC4(0xffff00));
}

void SkillItemView::draw()
{
	NDUIItemButton::draw();
	
	if (!this->IsVisibled()) 
	{
		return;
	}
	
	CGRect rectItemImg = this->GetScreenRect();
	rectItemImg.origin.x += 2;
	rectItemImg.origin.y += 2;
	rectItemImg.size.width -= 4;
	rectItemImg.size.height -= 4;
	
	if (m_bClose && m_frontLayer && m_frontLayer->IsVisibled()) 
	{
		m_frontLayer->SetFrameRect(rectItemImg);
		m_frontLayer->draw();
	}
}

void SkillItemView::SetState(bool bClose/*=true*/)
{
	m_bClose = bClose;
	m_frontLayer->SetVisible(bClose);
}

bool SkillItemView::IsClose()
{
	return m_bClose;
}

void SkillItemView::SetLock(bool bSet)
{
	if (bSet) 
	{
		this->SetTitle(NDCommonCString("suo"));
	}
	else 
	{
		this->SetTitle("");
	}
	
	m_bLock = bSet;
}

bool SkillItemView::isLock()
{
	return m_bLock;
}

void SkillItemView::SetSkillID(int iSkillID)
{
	m_iSkillID = iSkillID;
}

int SkillItemView::GetSkillID()
{
	return m_iSkillID;
}

///////////////////////////////////////

#define title_height 28
#define bottom_height 42

#define SkillBookItemType 25010001

enum  
{
	eOP_Invalid = 9999,
	eOP_Query = 55,
	eOP_Compose,
	eOP_Close,
	eOP_ViewQuery,
	eOP_Lock,
	eOP_UnLock,
};

IMPLEMENT_CLASS(PetSkillCompose, NDScene)

PetSkillCompose* PetSkillCompose::s_instance = NULL;

PetSkillCompose::PetSkillCompose()
{
	m_menulayerBG = NULL;
	m_itemBag = NULL;
	m_lbSkillNum = NULL;
	m_lbSkillInfo = NULL;
	m_itemfocus = NULL;
	m_tlOperate = NULL;
	m_iFocusIndex = -1;
	
	memset(m_SkillItemView, 0, sizeof(m_SkillItemView));
	
	m_itemSkill.iItemType = SkillBookItemType;
	choiceAmount = 0;
	
	s_instance = this;
}

PetSkillCompose::~PetSkillCompose()
{
	s_instance = NULL;
}

PetSkillCompose* PetSkillCompose::Scene()
{
	PetSkillCompose* scene = new PetSkillCompose();	
	scene->Initialization();
	return scene;
}

void PetSkillCompose::Initialization()
{
	//NDBattlePet *pet = NDPlayer::defaultHero().battlepet;
//	Item* petItem = ItemMgrObj.GetEquipItemByPos(Item::eEP_Pet);
//	HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
//	NDAsssert(pet != NULL && petItem != NULL && petData.int_PET_ID == pet->m_id);
	
	NDScene::Initialization();
	
	//m_menulayerBG = new NDUIMenuLayer;
//	m_menulayerBG->Initialization();
//	m_menulayerBG->ShowOkBtn();
//	this->AddChild(m_menulayerBG);
//	
//	if ( m_menulayerBG->GetOkBtn() ) 
//	{
//		m_menulayerBG->GetOkBtn()->SetDelegate(this);
//	}
//	
//	if ( m_menulayerBG->GetCancelBtn() ) 
//	{
//		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
//	}
//	
//	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
//	
//	CGSize dim = getStringSizeMutiLine(NDCommonCString("SkillCompose"), 15);
//	NDUILabel *lbTitle = new NDUILabel;
//	lbTitle->Initialization();
//	lbTitle->SetFontSize(15);
//	lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
//	lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
//	lbTitle->SetText(NDCommonCString("SkillCompose"));
//	m_menulayerBG->AddChild(lbTitle);
//	
//	NDUIFrame *frame = new NDUIFrame();
//	frame->Initialization();
//	frame->SetFrameRect(CGRectMake(10, title_height+8, 85, 80));
//	m_menulayerBG->AddChild(frame);
//	
//	GamePetNode *PetNode = new GamePetNode;
//	PetNode->Initialization(true);
//	//以下两行固定用法
//	PetNode->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
//	PetNode->SetDisplayPos(ccp(55,95));
//	m_menulayerBG->AddChild(PetNode);
//	
//	NDUILabel *name = new NDUILabel();
//	name->Initialization();
//	name->SetText(NDMapMgrObj.petInfo.str_PET_ATTR_NAME.c_str());
//	name->SetFontSize(13);
//	name->SetTextAlignment(LabelTextAlignmentLeft);
//	name->SetFontColor(INTCOLORTOCCC4(NDItemType::getItemColor(petItem->iItemType)));
//	name->SetFrameRect(CGRectMake(115, title_height+20, 480, 13));
//	m_menulayerBG->AddChild(name);
//	
//	std::stringstream ss;
//	ss << NDCommonCString("XingGe") << " : " << GameUIPetAttrib::getPetType(petData.int_PET_ATTR_TYPE);
//	NDUILabel *petType = new NDUILabel();
//	petType->Initialization();
//	petType->SetText(ss.str().c_str());
//	petType->SetFontSize(13);
//	petType->SetTextAlignment(LabelTextAlignmentLeft);
//	petType->SetFontColor(INTCOLORTOCCC4(0xff0000));
//	petType->SetFrameRect(CGRectMake(115, title_height+43, 480, 13));
//	m_menulayerBG->AddChild(petType);
//
//	m_lbSkillNum = new NDUILabel();
//	m_lbSkillNum->Initialization();
//	m_lbSkillNum->SetFontSize(13);
//	m_lbSkillNum->SetTextAlignment(LabelTextAlignmentLeft);
//	m_lbSkillNum->SetFontColor(ccc4(8, 32, 16, 255));
//	m_lbSkillNum->SetFrameRect(CGRectMake(115, title_height+66, 480, 13));
//	m_menulayerBG->AddChild(m_lbSkillNum);
//	
//	int iW = 200, iH = 157;
//	NDUILayer *layer = new NDUILayer;
//	layer->Initialization();
//	//layer->SetTouchEnabled(false);
//	layer->SetBackgroundColor(ccc4(255, 255, 255, 0));
//	layer->SetFrameRect(CGRectMake(2, 118, iW, iH));
//	m_menulayerBG->AddChild(layer);
//	
//	NDUILayer *bglayer = new NDUILayer;
//	bglayer->Initialization();
//	bglayer->SetTouchEnabled(false);
//	bglayer->SetBackgroundColor(ccc4(57, 44, 41, 255));
//	bglayer->SetFrameRect(CGRectMake(2, 2, iW-4, 20));
//	layer->AddChild(bglayer);
//	
//	m_lbSkillInfo = new NDUILabel();
//	m_lbSkillInfo->Initialization();
//	m_lbSkillInfo->SetText("");
//	m_lbSkillInfo->SetFontSize(13);
//	m_lbSkillInfo->SetTextAlignment(LabelTextAlignmentCenter);
//	m_lbSkillInfo->SetFontColor(ccc4(255, 247, 0, 255));
//	m_lbSkillInfo->SetFrameRect(CGRectMake(0, 0, iW-4, 20));
//	bglayer->AddChild(m_lbSkillInfo);
//	
//	float poly[4*2] = 
//	{
//		0,0,
//		iW-4, 0,
//		0, iH-4,
//		iW-4, iH-4
//	};
//	
//	float line[26] =
//	{
//		1,(4+2),  //point
//		6,(4+2),
//		6,1,
//		iW-6-1,1,
//		iW-6-1,4+2,
//		iW-1-1,4+2,
//		iW-1-1,iH-(4+2)-1,
//		iW-6-1,iH-(4+2)-1,
//		iW-6-1,iH-1-1,
//		6,iH-1-1,
//		6,iH-6-1,
//		1,iH-6-1,
//		1,6,
//	};
//	
//	for (int i=0; i<4; i++)
//	{
//		NDUIPolygon *polygon = new NDUIPolygon;
//		polygon->Initialization();
//		polygon->SetLineWidth(1);
//		polygon->SetColor(ccc3(46, 67, 50));
//		polygon->SetFrameRect(CGRectMake(poly[i*2], poly[i*2+1], 4, 4));
//		layer->AddChild(polygon);
//	}
//	
//	for (int i=0; i<12; i++)
//	{
//		NDUILine *uiline =  new NDUILine;
//		uiline->Initialization();
//		uiline->SetWidth(1);
//		uiline->SetColor(ccc3(46, 67, 50));
//		uiline->SetFromPoint(CGPointMake(line[i*2], line[i*2+1]));
//		uiline->SetToPoint(CGPointMake(line[i*2+2], line[i*2+1+2]));
//		uiline->SetFrameRect(CGRectMake(1, 1, 1, 1));
//		layer->AddChild(uiline);
//	}
//	
//	for (int i = 0; i < eRow*eCol; i++) 
//	{
//		m_SkillItemView[i] = new SkillItemView;
//		m_SkillItemView[i]->Initialization();
//		m_SkillItemView[i]->SetFrameRect(CGRectMake(5+i%eCol*(ITEM_CELL_W+6), 24+i/eCol*(ITEM_CELL_H+2), ITEM_CELL_W, ITEM_CELL_H));
//		m_SkillItemView[i]->SetDelegate(this);
//		layer->AddChild(m_SkillItemView[i]);
//	}
//	
//	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
//	m_itemBag = new GameItemBag;
//	m_itemBag->Initialization(itemlist);
//	m_itemBag->SetDelegate(this);
//	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
//	m_itemBag->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
//	m_menulayerBG->AddChild(m_itemBag);
//	
//	m_itemfocus = new ItemFocus;
//	m_itemfocus->Initialization();
//	m_itemfocus->SetFrameRect(CGRectZero);
//	m_menulayerBG->AddChild(m_itemfocus,1);
//	
//	NDUITopLayer *toplayer = new NDUITopLayer;
//	toplayer->Initialization();
//	toplayer->SetFrameRect(CGRectMake(0,0, winsize.width, winsize.height-48));
//	m_menulayerBG->AddChild(toplayer, 2);
//	
//	m_tlOperate = new NDUITableLayer;
//	m_tlOperate->Initialization();
//	m_tlOperate->VisibleSectionTitles(false);
//	m_tlOperate->SetDelegate(this);
//	m_tlOperate->SetVisible(false);
//	toplayer->AddChild(m_tlOperate);
//		
//	UpdateGui();
}

void PetSkillCompose::OnButtonClick(NDUIButton* button)
{
	if (m_menulayerBG->GetCancelBtn() == button) 
	{
		if (m_tlOperate->IsVisibled())
		{
			m_tlOperate->SetVisible(false);
			return;
		}
		NDDirector::DefaultDirector()->PopScene();
		return;
	}
	
	for (int i = 0; i < eRow*eCol; i++) 
	{
		if (!m_SkillItemView[i] || m_SkillItemView[i] != button) 
		{
			continue;
		}
		
		if (m_iFocusIndex != i) 
		{
			m_iFocusIndex = i;
			UpdateFoucus();
			return;
		}
		
		if (m_SkillItemView[i]->GetItem() == NULL)
		{
			return;
		}
		
		std::vector<std::string> vec_str; std::vector<int> vec_id;
		
		if (m_SkillItemView[i]->isLock()) 
		{
			vec_str.push_back(NDCommonCString("CancelSuoDing")); vec_id.push_back(eOP_UnLock);
		}
		else 
		{
			vec_str.push_back(NDCommonCString("SuoDing")); vec_id.push_back(eOP_Lock);
		}

		vec_str.push_back(NDCommonCString("ChaKang")); vec_id.push_back(eOP_ViewQuery);
		
		InitTLContent(m_tlOperate, vec_str, vec_id);
		break;
	}
}

bool PetSkillCompose::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (m_iFocusIndex != -1)
	{
		m_iFocusIndex = -1;
		UpdateFoucus();
	}
	
	if (itembag == m_itemBag && item && bFocused) 
	{
		std::vector<std::string> vec_str; std::vector<int> vec_id;
		vec_str.push_back(NDCommonCString("HeCheng")); vec_id.push_back(eOP_Compose);
		vec_str.push_back(NDCommonCString("ChaKang")); vec_id.push_back(eOP_Query);
		vec_str.push_back(NDCommonCString("close")); vec_id.push_back(eOP_Close);
		
		InitTLContent(m_tlOperate, vec_str, vec_id);
	}
	
	return false;
}

void PetSkillCompose::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate && cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton))) 
	{
		m_tlOperate->SetVisible(false);
		
		int iOperate = cell->GetTag();
		switch (iOperate) 
		{
			case eOP_Query:
			{
				Item *item = m_itemBag == NULL ? NULL : (m_itemBag->GetFocusItem() == NULL ? NULL : m_itemBag->GetFocusItem());
				if (item) 
				{
					NDTransData bao(_MSG_QUERY_DESC);
					bao << int(item->iID);
					SEND_DATA(bao);
					ShowProgressBar;
				}
			}
				break;
			case eOP_Compose:
			{
				std::stringstream LearnSkillTip;
				LearnSkillTip << NDCommonCString("PetLearnNewSkillTip") << "\n" << NDCommonCString("PetLearnNewSkillTip2");
				NDUIDialog *dlg = new NDUIDialog;
				dlg->Initialization();
				dlg->SetDelegate(this);
				dlg->Show(NDCommonCString("WenXinTip"), LearnSkillTip.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			}
				break;
			case eOP_Close:
			{
			}
				break;
			case eOP_ViewQuery:
			{
				if (m_iFocusIndex < 0 || m_iFocusIndex >= eRow*eCol) 
				{
					return;
				}
				
				//NDBattlePet *pet = NDPlayer::defaultHero().battlepet;
//				HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
//				if (pet && pet->m_id == petData.int_PET_ID
//						&& m_iFocusIndex < petData.int_PET_MAX_SKILL_NUM 
//						&& m_SkillItemView[m_iFocusIndex]
//						&& m_SkillItemView[m_iFocusIndex]->GetSkillID() != -1) 
//				{
//					BattleMgr& bm = BattleMgrObj;
//					BattleSkill* sk = bm.GetBattleSkill(m_SkillItemView[m_iFocusIndex]->GetSkillID());
//					if (sk) 
//					{
//						showDialog(sk->getName().c_str(), sk->getFullDes().c_str());
//					}
//				}
			}
				break;
			case eOP_Lock:
			{
				if (!m_SkillItemView[m_iFocusIndex] || m_SkillItemView[m_iFocusIndex]->GetSkillID() == -1) 
				{
					return;
				}
				/*　加锁不受限制　comment by jhzheng
				if(choiceAmount+1 > MAXCHOICE)
				{
					std::stringstream ss; 
					ss << "技能锁定失败，每次合成最多可锁定" << int(MAXCHOICE) << "个技能，请先取消一个要保护的技能";
					showDialog(NDCommonCString("WenXinTip"), ss.str().c_str());
				}
				else*/ if(getItemAmontByName(NDCommonCString("SuoLingFu"))<(choiceAmount+1)*(choiceAmount+1))
				{
					std::stringstream ss;
					ss << NDCommonCString("SuoLingFu") << NDCommonCString("BuZhu") << "。" << NDCommonCString("SuoDing") << "<cff0000" << (choiceAmount+1)
					<< "/e" << NDCommonCString("ge") << NDCommonCString("skill") << NDCommonCString("need") << "<cff0000" << ((choiceAmount+1)*(choiceAmount+1)) << "/e" << NDCommonCString("ge") << NDCommonCString("SuoLingFu");
					showDialog(NDCommonCString("WenXinTip"), ss.str().c_str());
				}
				else
				{
					m_SkillItemView[m_iFocusIndex]->SetLock(true);
					choiceAmount++;
				}
			}
				break;
			case eOP_UnLock:
			{
				if (!m_SkillItemView[m_iFocusIndex] || m_SkillItemView[m_iFocusIndex]->GetSkillID() == -1) 
				{
					return;
				}
				
				m_SkillItemView[m_iFocusIndex]->SetLock(false);
				choiceAmount--;
			}
				break;
			default:
				break;
		}
	}
}

void PetSkillCompose::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	//NDBattlePet *pet = NDPlayer::defaultHero().battlepet;
//	HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
//	if (!pet || pet->m_id != petData.int_PET_ID) 
//	{
//		dialog->Close();
//		return;
//	}
//	
//	if( choiceAmount == petData.int_PET_MAX_SKILL_NUM)
//	{
//		showDialog(NDCommonCString("tip"), NDCommonCString("HeChengFail"));
//	}
//	else
//	{
//		Item* petItem = ItemMgrObj.GetEquipItemByPos(Item::eEP_Pet);
//		Item* bagItem = NULL;
//		if (m_itemBag) 
//		{
//			bagItem = m_itemBag->GetFocusItem();
//		}
//		if (!petItem || !bagItem) 
//		{
//			dialog->Close();
//			return;
//		}
//		NDTransData bao(_MSG_PET_SKILL);
//		bao << (unsigned char)5 << int(petItem->iID) << int(bagItem->iID) << (unsigned char)choiceAmount;
//		if (choiceAmount > 0) 
//		{
//			for (int i = 0; i < eRow*eCol; i++) 
//			{
//				if (m_SkillItemView[i] 
//					&& m_SkillItemView[i]->GetSkillID() != -1 
//					&& m_SkillItemView[i]->isLock()) 
//				{
//					BattleSkill* sk = BattleMgrObj.GetBattleSkill(m_SkillItemView[i]->GetSkillID());
//					if (sk) 
//					{
//						bao << int(sk->getId());
//					}
//				}
//			}
//		}
//		
//		SEND_DATA(bao);
//	}
//	
//	dialog->Close();
}

void PetSkillCompose::UpdateGui()
{
	//NDPlayer& player = NDPlayer::defaultHero();
//	HeroPetInfo::PetData& petData = NDMapMgrObj.petInfo.m_data;
//	if (!player.battlepet || player.battlepet->m_id != petData.int_PET_ID) 
//	{
//		return;
//	}
//	
//	NDBattlePet& pet = *player.battlepet;
//	
//	std::stringstream ss; 
//	ss << NDCommonCString("skill") << " : " << "(" << int(pet.SkillSize()) << "/" << int(petData.int_PET_MAX_SKILL_NUM) << ")";
//	m_lbSkillNum->SetText(ss.str().c_str());
//	
//	SET_BATTLE_SKILL_LIST& actskill = pet.GetSkillList(SKILL_TYPE_ATTACK);
//	SET_BATTLE_SKILL_LIST& passiveskill = pet.GetSkillList(SKILL_TYPE_PASSIVE);
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
//	for (int i = 0; i < eRow*eCol; i++) 
//	{
//		if (!m_SkillItemView[i]) 
//		{
//			continue;
//		}
//		if (i < skillSize) 
//		{
//			m_SkillItemView[i]->ChangeItem(&m_itemSkill);
//			m_SkillItemView[i]->SetState(false);
//			m_SkillItemView[i]->SetSkillID(vec_id[i]);
//		} 
//		else if (i >= petData.int_PET_MAX_SKILL_NUM) 
//		{
//			m_SkillItemView[i]->ChangeItem(NULL);
//			m_SkillItemView[i]->SetState(true);
//			m_SkillItemView[i]->SetSkillID(-1);
//		}
//		else 
//		{
//			m_SkillItemView[i]->ChangeItem(NULL);
//			m_SkillItemView[i]->SetState(false);
//			m_SkillItemView[i]->SetSkillID(-1);
//		}
//	}
//	
//	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
//	m_itemBag->UpdateItemBag(itemlist);
//	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
//	m_itemBag->UpdateTitle();
}

void PetSkillCompose::UpdateFoucus()
{
	if (m_iFocusIndex == -1 || m_iFocusIndex < 0 || m_iFocusIndex >= eRow*eCol) 
	{
		m_lbSkillInfo->SetText("");
		m_itemfocus->SetFrameRect(CGRectZero);
	}
	else 
	{
		if (m_SkillItemView[m_iFocusIndex]) 
		{
			m_itemfocus->SetFrameRect(m_SkillItemView[m_iFocusIndex]->GetScreenRect());
		}
		
		if (m_itemBag) 
		{
			m_itemBag->DeFocus();
		}
		
		std::stringstream ss;
		if (m_SkillItemView[m_iFocusIndex]->GetSkillID() == -1) 
		{
			if (m_SkillItemView[m_iFocusIndex]->IsClose())
			{
				ss << NDCommonCString("notopen");
			}
			else 
			{
				ss << NDCommonCString("wu");
			}

		}
		else 
		{
			BattleSkill* sk = BattleMgrObj.GetBattleSkill(m_SkillItemView[m_iFocusIndex]->GetSkillID());
			if (sk) 
				ss << sk->getName() << "(" << sk->getLevel() << NDCommonCString("Ji") << ")";
		}
		m_lbSkillInfo->SetText(ss.str().c_str());
	}
}

void PetSkillCompose::InitTLContent(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text,tag) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetTag(tag); \
button->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
button->SetTitle(text); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0);
	
	if (!tl || vec_str.empty() || vec_str.size() != vec_id.size())
	{
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	std::vector<std::string>::iterator it = vec_str.begin();
	for (int iIDIndex = 0; it != vec_str.end(); it++, iIDIndex++)
	{
		fastinit(((*it).c_str()), vec_id[iIDIndex])
	}
	
	section->SetFocusOnCell(0);
	
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
#undef fastinit
}

int PetSkillCompose::getItemAmontByName(std::string name)
{
	int amount=0;
	VEC_ITEM& items = ItemMgrObj.GetPlayerBagItems();
	for_vec(items, VEC_ITEM_IT)
	{
		Item *item = *it;
		if (item->getItemName() == name) 
		{
			amount += item->iAmount;
		}
	}
	
	return amount;
}

void PetSkillCompose::refresh()
{
	if (s_instance) 
	{
		s_instance->UpdateGui();
	}
}