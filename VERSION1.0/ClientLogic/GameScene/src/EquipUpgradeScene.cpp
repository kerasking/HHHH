/*
 *  EquipUpgradeScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "EquipUpgradeScene.h"
#include "NDDirector.h"
#include "ItemMgr.h"
#include "NDUIBaseGraphics.h"
//#include "CCPointExtension.h"
#include "NDUtility.h"
#include "NDPath.h"
#include "NDUISynLayer.h"
#include "NDSocket.h"
#include "NDDataTransThread.h"

#define title_height 28
#define bottom_height 42

IMPLEMENT_CLASS(EquipUpgradeScene, NDScene)

EquipUpgradeScene* EquipUpgradeScene::s_instance = NULL;

EquipUpgradeScene::EquipUpgradeScene()
{
	m_menulayerBG = NULL;
	m_btnEquip = NULL;
	m_itemBag = NULL;
	m_picTitle = NULL;
	m_lbName = NULL;
	m_dlgBag = NULL;
	m_dlgSend = NULL;
	m_iType = EQUIP_UPGRADE;
	
	m_itemfocus = NULL;
	
	m_bFoucusEquip = false;
	m_iCurOperateIndex = -1;
	
	m_lbName2 = NULL;
	m_btnEquip2 = NULL;
	 
	s_instance = this;
}

EquipUpgradeScene::~EquipUpgradeScene()
{
	SAFE_DELETE(m_picTitle);
	s_instance = NULL;
}

void EquipUpgradeScene::Initialization(int iType)
{
	NDAsssert(iType == EQUIP_UPGRADE || iType == EQUIP_ENHANCE || iType == EQUIP_UPLEVEL);
	
	m_iType = iType;
	
	NDScene::Initialization();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	m_menulayerBG->ShowOkBtn();
	AddChild(m_menulayerBG);
	
	if ( m_menulayerBG->GetOkBtn() ) 
	{
		m_menulayerBG->GetOkBtn()->SetDelegate(this);
	}
	
	if ( m_menulayerBG->GetCancelBtn() ) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	CCSize winsize = CCDirector::sharedDirector()->getWinSizeInPixels();
	
	if (m_iType == EQUIP_UPLEVEL) 
	{
		NDUILabel* lblTitle = new NDUILabel();
		lblTitle->Initialization();
		lblTitle->SetTextAlignment(LabelTextAlignmentCenter);
		lblTitle->SetFontSize(15);
		lblTitle->SetFontColor(ccc4(255, 245, 0, 255));
		lblTitle->SetTextAlignment(LabelTextAlignmentCenter);
		lblTitle->SetText(NDCommonCString("EquipUpLev"));
		lblTitle->SetFrameRect(CCRectMake(0, 0, winsize.width, m_menulayerBG->GetTitleHeight()));
		m_menulayerBG->AddChild(lblTitle);
	}
	else 
	{
		m_picTitle = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
		if (m_iType == EQUIP_UPGRADE) 
		{ 
			m_picTitle->Cut(CCRectMake(200, 81, 80, 21));
		}
		else if (m_iType == EQUIP_ENHANCE) 
		{
			m_picTitle->Cut(CCRectMake(160, 160, 80, 20));
		}
		
		CCSize sizeTitle = m_picTitle->GetSize();
		
		NDUIImage *imageTitle =  new NDUIImage;
		imageTitle->Initialization();
		imageTitle->SetPicture(m_picTitle);
		imageTitle->SetFrameRect(CCRectMake((winsize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
		m_menulayerBG->AddChild(imageTitle);
	}	
	
	m_btnEquip = new NDUIItemButton;
	m_btnEquip->Initialization();
	m_btnEquip->SetDelegate(this);
	m_btnEquip->SetFrameRect(CCRectMake(14, 50, ITEM_CELL_W, ITEM_CELL_H));
	m_menulayerBG->AddChild(m_btnEquip);
	m_btnEquip->ChangeItem(NULL);
	
	m_lbName = new NDUILabel;
	m_lbName->Initialization();
	m_lbName->SetFontSize(15);
	m_lbName->SetFontColor(ccc4(22, 30, 17, 255));
	m_lbName->SetText(NDCommonCString("FangRuEquip"));
	m_lbName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbName->SetFrameRect(CCRectMake(29+ITEM_CELL_W, 50+(ITEM_CELL_H-15)/2, winsize.width, 15));
	m_menulayerBG->AddChild(m_lbName);
	
	NDUILine *line = new NDUILine;
	line->Initialization();
	line->SetWidth(1);
	line->SetColor(ccc3(22, 30, 17));
	line->SetFromPoint(ccp(0,101));
	line->SetToPoint(ccp(206,101));
	m_menulayerBG->AddChild(line);
	
	if (m_iType == EQUIP_UPLEVEL) 
	{		
		m_btnEquip2 = new NDUIItemButton;
		m_btnEquip2->Initialization();
		m_btnEquip2->SetDelegate(this);
		m_btnEquip2->SetFrameRect(CCRectMake(14, 111, ITEM_CELL_W, ITEM_CELL_H));
		m_menulayerBG->AddChild(m_btnEquip2);
		m_btnEquip2->ChangeItem(NULL);
		
		m_lbName2 = new NDUILabel;
		m_lbName2->Initialization();
		m_lbName2->SetFontSize(15);
		m_lbName2->SetFontColor(ccc4(22, 30, 17, 255));
		m_lbName2->SetText(NDCommonCString("UpLevEquip"));
		m_lbName2->SetTextAlignment(LabelTextAlignmentLeft);
		m_lbName2->SetFrameRect(CCRectMake(29+ITEM_CELL_W, 111+(ITEM_CELL_H-15)/2, winsize.width, 15));
		m_menulayerBG->AddChild(m_lbName2);
		
		NDUILine *line2 = new NDUILine;
		line2->Initialization();
		line2->SetWidth(1);
		line2->SetColor(ccc3(22, 30, 17));
		line2->SetFromPoint(ccp(0,161));
		line2->SetToPoint(ccp(206,161));
		m_menulayerBG->AddChild(line2);
	}
	
	NDUICheckBox *check = new NDUICheckBox;
	check->Initialization();
	if (m_iType == EQUIP_UPGRADE) 
	{
		check->SetText(NDCommonCString("NeedOneTianKuiStone"));
	}
	else if (m_iType == EQUIP_ENHANCE)
	{
		check->SetText(NDCommonCString("NeedOneTianMoStone"));
	}
	else if (m_iType == EQUIP_UPLEVEL)
	{
		check->SetText(NDCommonCString("NeedOneTianRangStone"));
	}
	
	if (m_iType == EQUIP_UPLEVEL) 
	{
		check->SetFrameRect(CCRectMake(14, 181, winsize.width, 30));
	}
	else 
	{
		check->SetFrameRect(CCRectMake(14, 112, winsize.width, 30));
	}
	check->SetFontColor(ccc3(22, 30, 17));
	check->ChangeCBState();
	check->EnableEvent(false);
	m_menulayerBG->AddChild(check);
	
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	m_itemBag = new GameItemBag;
	m_itemBag->Initialization(itemlist);
	m_itemBag->SetDelegate(this);
	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itemBag->SetFrameRect(CCRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_menulayerBG->AddChild(m_itemBag);
	
	m_itemfocus = new ItemFocus;
	m_itemfocus->Initialization();
	m_itemfocus->SetFrameRect(CCRectZero);
	AddChild(m_itemfocus,1);
}

void EquipUpgradeScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnEquip) 
	{
		if (!m_bFoucusEquip) 
		{
			m_bFoucusEquip = true;
			if (m_itemfocus && m_btnEquip) 
			{
				m_itemfocus->SetFrameRect(m_btnEquip->GetFrameRect());
			}
			if (m_itemBag) 
			{
				m_itemBag->DeFocus();
			}
		}else 
		{
			Item *item = m_btnEquip->GetItem();
			if (item) 
			{
				std::vector<std::string> vec_str;
				vec_str.push_back(NDCommonCString("QuXia"));
				NDUIDialog *dlg = item->makeItemDialog(vec_str);
				dlg->SetDelegate(this);
			}
		}
	}
	else if (button == m_menulayerBG->GetOkBtn()) 
	{
		switch (m_iType) 
		{
			case EQUIP_UPGRADE: 
			{
				Item *temp = checkHasItem(Item::EUQIP_QUALITIY);// 天魁石
				if (temp != NULL) {
					m_dlgSend = new NDUIDialog;
					m_dlgSend->Initialization();
					m_dlgSend->SetDelegate(this);
					m_dlgSend->Show(NDCommonCString("WenXinTip"), NDCommonCString("UseTianKuiStoneTip"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
				} else {
					showDialog(NDCommonCString("OperateFail"), NDCommonCString("NeedTianKuiStoneTip"));
				}
				break;
			}
			case EQUIP_ENHANCE:
			{
				Item *item = m_btnEquip->GetItem();
				if (!item) 
				{
					break;
				}
				Item *temp = checkHasItem(Item::EUQIP_ENHANCE); // 玄魔石
				if (temp != NULL) {
					if (checkItemCanEnhance(item)) {
						m_dlgSend = new NDUIDialog;
						m_dlgSend->Initialization();
						m_dlgSend->SetDelegate(this);
						m_dlgSend->Show(NDCommonCString("WenXinTip"), NDCommonCString("UseTianMoStoneTip"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
					} else {
						showDialog(NDCommonCString("OperateFail"), NDCommonCString("CantQiangHua"));
					}
					
				} else {
					showDialog(NDCommonCString("OperateFail"), NDCommonCString("NeedTianMoStoneTip"));
				}
				break;
			}
			case EQUIP_UPLEVEL:
			{
				Item* item = m_btnEquip->GetItem();				
				if (item) 
				{
					Item* item2 = m_btnEquip2->GetItem();
					if (item2) 
					{
						Item* tls = checkHasItem(Item::EQUIP_TLS);
						if (tls != NULL) 
						{
							m_dlgSend = new NDUIDialog;
							m_dlgSend->Initialization();
							m_dlgSend->SetDelegate(this);
							m_dlgSend->Show(NDCommonCString("WenXinTip"), NDCommonCString("UseTianRangStoneTip"), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
						}
						else 
						{
							showDialog(NDCommonCString("OperateFail"), NDCommonCString("NeedTianRangStoneTip"));
						}
					}
					else 
					{
						ResetGui();
					}
				}
				else 
				{
					showDialog(NDCommonCString("tip"), NDCommonCString("FangRuEquipFirst"));
				}
				break;
			}
			default: 
				break;			
		}
	}
	else if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}

}

bool EquipUpgradeScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (m_bFoucusEquip) 
	{
		m_bFoucusEquip = false;
		m_itemfocus->SetFrameRect(CCRectZero);
	}
	
	if (itembag == m_itemBag && item && bFocused) 
	{
		m_iCurOperateIndex = iCellIndex;
		std::vector<std::string> vec_str;
		vec_str.push_back(NDCommonCString("FangRu"));
		m_dlgBag = item->makeItemDialog(vec_str);
		m_dlgBag->SetDelegate(this);
	}
	
	return false;
}

void EquipUpgradeScene::OnDialogClose(NDUIDialog* dialog)
{
	m_dlgBag = NULL;
	m_dlgSend = NULL;
}

void EquipUpgradeScene::PushEquip(Item* item)
{
	if (m_btnEquip) 
	{
		if (m_btnEquip->GetItem() && m_itemBag) 
			m_itemBag->AddItem(m_btnEquip->GetItem());
		
		m_btnEquip->ChangeItem(item);
	}
	
	if (item && m_lbName) 
	{
		m_lbName->SetText(item->getItemNameWithAdd().c_str());
	}
	
	if (item &&m_itemBag) 
	{
		m_itemBag->DelItem(item->m_nID);
	}	
}

void EquipUpgradeScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_dlgBag && m_iCurOperateIndex != -1 && m_itemBag) 
	{
		Item* item = m_itemBag->GetItem(m_iCurOperateIndex/MAX_CELL_PER_PAGE, m_iCurOperateIndex%MAX_CELL_PER_PAGE);
	
		if (m_iType == EQUIP_UPLEVEL) 
		{
			if (item->isEquip()) 
			{
				if (item->getIdUpLev() != 0) 
				{
					PushEquip(item);				
					NDItemType *itemtype = ItemMgrObj.QueryItemType(item->getIdUpLev());
					if (itemtype) 
					{
						Item* newItem = new Item(item->getIdUpLev());
						m_btnEquip2->ChangeItem(newItem);
						m_lbName2->SetText(newItem->getItemNameWithAdd().c_str());
					}
				}
				else 
				{
					showDialog(NDCommonCString("tip"), NDCommonCString("EquipCantUp"));
				}
			}
			else 
			{
				showDialog(NDCommonCString("OperateFail"), NDCommonCString("DoNotFangRuZhaWu"));
			}
		}
		else 
		{
			if (checkIsEquip(item)) 
			{
				PushEquip(item);
			}
			else 
			{
				showDialog(NDCommonCString("OperateFail"), NDCommonCString("ItemCantQiangHua"));
			}
		}		
	}
	else if (dialog == m_dlgSend && m_btnEquip)
	{
		Item* item = m_btnEquip->GetItem();
		Item* helpitem = NULL;
		if (m_iType == EQUIP_UPGRADE) 
		{
			helpitem = checkHasItem(Item::EUQIP_QUALITIY);
		}
		else if (m_iType == EQUIP_ENHANCE)
		{
			helpitem = checkHasItem(Item::EUQIP_ENHANCE);
		}
		else if (m_iType == EQUIP_UPLEVEL)
		{
			helpitem = checkHasItem(Item::EQUIP_TLS);
		}
		
		if (item && helpitem) 
		{
			switch (m_iType) {
				case EQUIP_UPGRADE: 
				{ //提升
					ShowProgressBar;
					NDTransData bao(_MSG_EQUIPIMPROVE);
					bao << (unsigned char)EQUIP_IM_QUALITY << int(item->m_nID) << int(helpitem->m_nID);
					SEND_DATA(bao);
					break;
				}
				case EQUIP_ENHANCE: 
				{ //强化
					ShowProgressBar;
					NDTransData bao(_MSG_EQUIPIMPROVE);
					bao << (unsigned char)EQUIP_IM_ENHANCE << int(item->m_nID) << int(helpitem->m_nID);
					SEND_DATA(bao);
					break;
				}
				case EQUIP_UPLEVEL:
				{
					ShowProgressBar;
					NDTransData bao(_MSG_EQUIPIMPROVE);
					bao << (unsigned char)EQUIP_IM_UPLEV << int(item->m_nID) << int(helpitem->m_nID);
					SEND_DATA(bao);
					break;
				}					
				default:
					break;

			}
		}
	}
	else 
	{
		Item *item = m_btnEquip->GetItem();
		if (m_itemBag && item) 
		{
			m_itemBag->AddItem(item);
		}
		if (m_btnEquip) 
		{
			m_btnEquip->ChangeItem(NULL);
		}
		if (m_lbName) 
		{
			m_lbName->SetText(NDCommonCString("FangRuEquip"));
		}
	}
	
	m_iCurOperateIndex = -1;
	dialog->Close();
	m_dlgBag = NULL;
	m_dlgSend = NULL;
}


void EquipUpgradeScene::ResetGui()
{
	if (m_itemBag) 
	{
		std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
		m_itemBag->UpdateItemBag(itemlist);
		m_itemBag->UpdateTitle();
	}
	
	if (m_btnEquip) 
	{
		m_btnEquip->ChangeItem(NULL);
	}
	
	if (m_btnEquip2) 
	{
		m_btnEquip2->ChangeItem(NULL);
	}
	
	if (m_lbName) 
	{
		m_lbName->SetText(NDCommonCString("FangRuEquip"));
	}
	
	if (m_lbName2) 
	{
		m_lbName2->SetText(NDCommonCString("UpLevEquip"));
	}
}

Item* EquipUpgradeScene::checkHasItem(int itemType) 
{
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	for_vec(itemlist, VEC_ITEM_IT)
	{
		Item* item = *it;
		if (item->m_nItemType == itemType) 
		{
			return item;
		}
	}
	
	return NULL;
}

bool EquipUpgradeScene::checkItemCanEnhance(Item* item) 
{
	if (!item) 
	{
		return false;
	}
	// 物理攻击,魔法攻击,物理防御,魔法防御,生命,法力六个项才可以强化
	if (item->getAtk() != 0 || item->getMag_atk() != 0 || item->getDef() != 0 || item->getMag_def() != 0 || item->getLife() != 0 || item->getMana() != 0) {
		return true;
	}
	return false;
}

bool EquipUpgradeScene::checkIsEquip(Item* item)
{
	if (!item) 
	{
		return false;
	}
	if (item->isCanEnhance() && (Item::isWeapon(item->m_nItemType) || Item::isDefEquip(item->m_nItemType) || Item::isAccessories(item->m_nItemType))) { // 装备类和防具
		return true;
	} else {		
		return false;
	}
	return true;
}

void EquipUpgradeScene::Refresh()
{
	if (s_instance) 
	{
		s_instance->ResetGui();
	}
}

bool IsDuanZhaoMaterial(int iItemType)
{
	return true;
}

bool IsDuanZhaoDaoJu(int iItemType)
{
	return true;
}

bool IsDuanZhaoEquip(int iItemType)
{
	return true;
}

std::string GetDuanZhaoEffect(int iItemType)
{
	return "";
}


