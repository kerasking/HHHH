/*
 *  OpenHoleScene.mm
 *  DragonDrive
 *OpenHoleScene
 *  Created by jhzheng on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "OpenHoleScene.h"OpenHoleScene
#include "NDDirector.h"
#include "ItemMgr.h"
#include "NDUIBaseGraphics.h"
#include "CGPointExtension.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"
#include "Chat.h"
#include <sstream>

#define title_height 28
#define bottom_height 42

IMPLEMENT_CLASS(OpenHoleScene, NDScene)

OpenHoleScene* OpenHoleScene::s_instance = NULL;

OpenHoleScene::OpenHoleScene()
{
	m_menulayerBG = NULL;
	m_btnEquip = NULL;
	m_itemBag = NULL;
	m_lbTip = NULL;
	
	s_instance = this;
}

OpenHoleScene::~OpenHoleScene()
{
	s_instance = NULL;
}

void OpenHoleScene::Initialization()
{
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->ShowOkBtn();
	this->AddChild(m_menulayerBG);
	
	if ( m_menulayerBG->GetOkBtn() ) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	if ( m_menulayerBG->GetCancelBtn() ) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	CGSize dim = getStringSizeMutiLine(NDCommonCString("EquipHole"), 15);
	NDUILabel *lbTitle = new NDUILabel;
	lbTitle->Initialization();
	lbTitle->SetFontSize(15);
	lbTitle->SetFontColor(ccc4(255, 247, 0, 255));
	lbTitle->SetFrameRect(CGRectMake((winsize.width-dim.width)/2, (title_height-dim.height)/2, dim.width, dim.height));
	lbTitle->SetText(NDCommonCString("EquipHole"));
	m_menulayerBG->AddChild(lbTitle);
	
	m_btnEquip = new NDUIItemButton;
	m_btnEquip->Initialization();
	m_btnEquip->SetDelegate(this);
	m_btnEquip->SetFrameRect(CGRectMake(14, 50, ITEM_CELL_W, ITEM_CELL_H));
	m_menulayerBG->AddChild(m_btnEquip);
	m_btnEquip->EnableEvent(false);
	m_btnEquip->ChangeItem(NULL);
	
	m_lbTip = new NDUILabel;
	m_lbTip->Initialization();
	m_lbTip->SetFontSize(15);
	m_lbTip->SetFontColor(ccc4(22, 30, 17, 255));
	m_lbTip->SetText(NDCommonCString("ItemCantHole"));
	m_lbTip->SetTextAlignment(LabelTextAlignmentLeft);
	m_menulayerBG->AddChild(m_lbTip);
	
	NDUILine *line = new NDUILine;
	line->Initialization();
	line->SetWidth(1);
	line->SetColor(ccc3(22, 30, 17));
	line->SetFromPoint(ccp(0,101));
	line->SetToPoint(ccp(206,101));
	m_menulayerBG->AddChild(line);
	
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	m_itemBag = new GameItemBag;
	m_itemBag->Initialization(itemlist);
	m_itemBag->SetDelegate(this);
	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itemBag->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_menulayerBG->AddChild(m_itemBag);
	
	ResetGui();
}

void OpenHoleScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetOkBtn()) 
	{
		Item *item = NULL;
		if (m_itemBag) 
		{
			item = m_itemBag->GetFocusItem();
		}
		
		OnSelect(item);
	}
	else if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	
}

bool OpenHoleScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (itembag == m_itemBag) 
	{
		if (!bFocused) 
		{
			UpdateEquipInfo(item);
		}
		else 
		{
			OnSelect(item);
		}
	}
	
	return false;
}

void OpenHoleScene::OnClickPage(GameItemBag* itembag, int iPage)
{
	UpdateEquipInfo(itembag->GetFocusItem());
}

void OpenHoleScene::OnDialogClose(NDUIDialog* dialog)
{
}

void OpenHoleScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	Item *item = NULL;
	if (m_itemBag) 
	{
		item = m_itemBag->GetFocusItem();
	}
	
	if (item) 
	{
		NDTransData bao(_MSG_EQUIPIMPROVE);
		bao << (unsigned char)4 << int(item->iID) << int(0);
		SEND_DATA(bao);
	}
	
	dialog->Close();
}

void OpenHoleScene::OnSelect(Item* item)
{
	if (item == NULL || !item->canOpenHole()) {
		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("ItemCantHole"));
		//if (GameScreen.getInstance() != null) {
		//					GameScreen.getInstance().initNewChat(new ChatRecord(5,"系统","该物品不能开洞！"));
		//				}
		return;
	}
	if (item->getCurHoleNum() == item->getMaxHoleNum()) {
		Chat::DefaultChat()->AddMessage(ChatTypeSystem, NDCommonCString("EquipHoleMax"));
		//if (GameScreen.getInstance() != null) {
		//					GameScreen.getInstance().initNewChat(new ChatRecord(5,"系统",NDCommonCString("EquipHoleMax")));
		//				}
		return;
	}
	
	int iMaterialCount = GetMaterialCount();
	if (iMaterialCount == 0) {
		showDialog(NDCommonCString("NotHaveYueGuang"));
		return;
	}
	if (iMaterialCount < (item->getCurHoleNum() + 1)) {
		showDialog(NDCommonCString("YueGuangBaoZhuiNotEnoughAmount"));
		return;
	}
	std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("OpenHole"));
	NDUIDialog *dlg = item->makeItemDialog(vec_str);
	dlg->SetDelegate(this);
}

void OpenHoleScene::UpdateEquipInfo(Item* item)
{
	if (m_btnEquip) 
	{
		m_btnEquip->ChangeItem(item);
	}
	
	std::stringstream tip;
	if (item != NULL && item->canOpenHole()) {
		if (item->getCurHoleNum() == item->getMaxHoleNum()) {
			tip << NDCommonCString("HoleUpToMax");
		}else {
			tip << NDCommonCString("need") << (item->getCurHoleNum() + 1) << NDCommonCString("GeYueGuanBaoZhui");
		}
	} else {
		tip << (NDCommonCString("ItemCantHole"));
	}
	
	if (m_lbTip) 
	{
		m_lbTip->SetText(tip.str().c_str());
		CGSize dim = getStringSizeMutiLine(tip.str().c_str(), 15);
		m_lbTip->SetFrameRect(CGRectMake((203-dim.width)/2, 112, dim.width, dim.height));
	}
}


void OpenHoleScene::ResetGui()
{
	if (m_itemBag) 
	{
		std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
		m_itemBag->UpdateItemBag(itemlist);
		m_itemBag->UpdateTitle();
	}
	Item *item = NULL;
	if (m_itemBag) 
	{
		item = m_itemBag->GetFocusItem();
	}
	UpdateEquipInfo(item);
}

int OpenHoleScene::GetMaterialCount()
{
	int nCount = 0;
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	for_vec(itemlist, VEC_ITEM_IT)
	{
		Item* item = *it;
		if (item->iItemType == Item::OPENHOLE) {
			nCount += item->iAmount;
		}
	}
	
	return nCount;
}

void OpenHoleScene::Refresh()
{
	if (s_instance) 
	{
		s_instance->ResetGui();
	}
}
