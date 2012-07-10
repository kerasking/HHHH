/*
 *  RemoveStoneScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "RemoveStoneScene.h"RemoveStoneScene
#include "NDDirector.h"
#include "ItemMgr.h"
#include "NDUIBaseGraphics.h"
#include "CGPointExtension.h"
#include "NDUtility.h"
#include "NDUISynLayer.h"

#define title_height 28
#define bottom_height 42

IMPLEMENT_CLASS(RemoveStoneScene, NDScene)

RemoveStoneScene* RemoveStoneScene::s_instance = NULL;

RemoveStoneScene::RemoveStoneScene()
{
	m_menulayerBG = NULL;
	m_btnEquip = NULL;
	m_itemBag = NULL;
	m_picTitle = NULL;
	m_lbName = NULL;
	m_check = NULL;
	memset(m_btnStoneItem, 0, sizeof(m_btnStoneItem));
	m_dlgBag = NULL;
	m_dlgSend = NULL;
	
	m_itemfocus = NULL;
	
	m_iFocusIndex = focus_bag;
	m_iCurOperateIndex = -1;
	
	m_iStoneFocusIndex = -1;
	memset(m_StoneDigout, 0, sizeof(m_StoneDigout));
	
	s_instance = this;
}

RemoveStoneScene::~RemoveStoneScene()
{
	SAFE_DELETE(m_picTitle);
	s_instance = NULL;
}

void RemoveStoneScene::Initialization()
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
	
	m_picTitle = NDPicturePool::DefaultPool()->AddPicture(GetImgPath("titles.png"));
	m_picTitle->Cut(CGRectMake(199, 141, 81, 20));
	
	CGSize sizeTitle = m_picTitle->GetSize();
	
	NDUIImage *imageTitle =  new NDUIImage;
	imageTitle->Initialization();
	imageTitle->SetPicture(m_picTitle);
	imageTitle->SetFrameRect(CGRectMake((winsize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
	m_menulayerBG->AddChild(imageTitle);
	
	m_btnEquip = new NDUIItemButton;
	m_btnEquip->Initialization();
	m_btnEquip->SetDelegate(this);
	m_btnEquip->SetFrameRect(CGRectMake(14, 50, ITEM_CELL_W, ITEM_CELL_H));
	m_menulayerBG->AddChild(m_btnEquip);
	m_btnEquip->ChangeItem(NULL);
	
	m_lbName = new NDUILabel;
	m_lbName->Initialization();
	m_lbName->SetFontSize(15);
	m_lbName->SetFontColor(ccc4(22, 30, 17, 255));
	m_lbName->SetText(NDCommonCString("equip"));
	m_lbName->SetTextAlignment(LabelTextAlignmentLeft);
	m_lbName->SetFrameRect(CGRectMake(29+ITEM_CELL_W, 50+(ITEM_CELL_H-15)/2, winsize.width, 15));
	m_menulayerBG->AddChild(m_lbName);
	
	NDUILine *line = new NDUILine;
	line->Initialization();
	line->SetWidth(1);
	line->SetColor(ccc3(22, 30, 17));
	line->SetFromPoint(ccp(0,101));
	line->SetToPoint(ccp(206,101));
	m_menulayerBG->AddChild(line);
	
	m_check = new NDUICheckBox;
	m_check->Initialization();
	m_check->SetText(NDCommonCString("BaoLiuBaoShi"));
	m_check->SetFrameRect(CGRectMake(57, 125, winsize.width, 30));
	m_check->SetFontColor(ccc3(22, 30, 17));
	m_check->SetDelegate(this);
	m_menulayerBG->AddChild(m_check);
	
	int iStartX = 0, iStartY = 164, inter_w = 12, inter_h = 20;
	iStartX = (203-(ITEM_CELL_W)*3-inter_w*2)/2;
	for (int i = 0; i < eStoneNum; i++) 
	{
		int iX = 0, iY = 0;
		iX = iStartX + (ITEM_CELL_W+inter_w)*(i%3);
		iY = iStartY + (ITEM_CELL_H+inter_h)*(i/3);
		m_btnStoneItem[i] = new NDUIItemButton;
		NDUIItemButton *&btn = m_btnStoneItem[i];
		btn->Initialization();
		btn->SetDelegate(this);
		btn->SetFrameRect(CGRectMake(iX, iY, ITEM_CELL_W, ITEM_CELL_H));
		m_menulayerBG->AddChild(btn);
		btn->ChangeItem(NULL);
	}
	
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	m_itemBag = new GameItemBag;
	m_itemBag->Initialization(itemlist);
	m_itemBag->SetDelegate(this);
	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itemBag->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_menulayerBG->AddChild(m_itemBag);
	
	m_itemfocus = new ItemFocus;
	m_itemfocus->Initialization();
	m_itemfocus->SetFrameRect(CGRectZero);
	this->AddChild(m_itemfocus,1);
}

void RemoveStoneScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_btnEquip) 
	{
		if (m_iFocusIndex != foucus_equip) 
		{
			m_iFocusIndex = foucus_equip;
			if (m_itemfocus && m_btnEquip) 
			{
				m_itemfocus->SetFrameRect(m_btnEquip->GetFrameRect());
			}
			if (m_itemBag) 
			{
				m_itemBag->DeFocus();
			}
			m_iStoneFocusIndex = -1;
		}else 
		{
			Item *item = m_btnEquip->GetItem();
			if (item && m_itemBag) 
			{
				m_itemBag->AddItem(item);
				m_itemBag->UpdateTitle();
			}
			UpdateEquipInfo(item);
		}
	}
	else if (button == m_menulayerBG->GetOkBtn()) 
	{
		Item *item = NULL;
		if (m_btnEquip) 
		{
			item = m_btnEquip->GetItem();
		}
		if (item == NULL) {
			return;
		}
		bool bolHas = false;
		for (int i = 0; i < eStoneNum; i++) {
			if (m_StoneDigout[i]) {
				bolHas = true;
				break;
			}
		}
		if (!bolHas) {
			return;
		}
		
		NDTransData bao(_MSG_DIGOUT);
		bao << int(item->iID);
		if (m_check->GetCBState()) {
			bao << (unsigned char)(1);
		} else {
			bao << (unsigned char)(0);
		}
		int num = 0;
		std::vector<Item*> itemlist;
		for (int i = 0; i < eStoneNum; i++) {
			if (m_StoneDigout[i] && m_btnStoneItem[i] && m_btnStoneItem[i]->GetItem()) {
				num++;
				itemlist.push_back(m_btnStoneItem[i]->GetItem());
			}
		}
		
		if (num <= 0) 
		{
			return;
		}
		
		bao << (unsigned char)num;
		int iSize = itemlist.size();
		
		for (int i = 0; i < iSize; i++) {
			Item* item = itemlist[i];
			bao << int(item->iItemType);
		}
		
		SEND_DATA(bao);
	}
	else if (button == m_menulayerBG->GetCancelBtn()) 
	{
		NDDirector::DefaultDirector()->PopScene();
	}
	else 
	{
		for (int i = 0; i < eStoneNum; i++) 
		{
			if (button == m_btnStoneItem[i]) 
			{
				m_iFocusIndex = focus_other;
				if (m_itemfocus && m_btnStoneItem[i]) 
				{
					m_itemfocus->SetFrameRect(m_btnStoneItem[i]->GetFrameRect());
				}
				if (m_itemBag) 
				{
					m_itemBag->DeFocus();
				}
				if (m_iStoneFocusIndex == i && m_btnStoneItem[i]->GetItem() != NULL) 
				{
					m_StoneDigout[i] = !m_StoneDigout[i];
					m_btnStoneItem[i]->setBackDack(m_StoneDigout[i]);
				}
				m_iStoneFocusIndex = i;
				break;
			}
		}
	}
	
}

bool RemoveStoneScene::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (m_iFocusIndex != focus_bag) 
	{
		m_iFocusIndex = focus_bag;
		m_itemfocus->SetFrameRect(CGRectZero);
	}
	
	if (itembag == m_itemBag && item && bFocused) 
	{
		m_iCurOperateIndex = iCellIndex;
		std::vector<std::string> vec_str;
		vec_str.push_back(NDCommonCString("FangRu"));
		m_dlgBag = item->makeItemDialog(vec_str);
		m_dlgBag->SetDelegate(this);
	}
	
	m_iStoneFocusIndex = -1;
	
	return false;
}

void RemoveStoneScene::OnDialogClose(NDUIDialog* dialog)
{
	m_dlgBag = NULL;
	m_dlgSend = NULL;
}

void RemoveStoneScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_dlgBag && m_iCurOperateIndex != -1 && m_itemBag) 
	{
		Item* item = m_itemBag->GetItem(m_iCurOperateIndex/MAX_CELL_PER_PAGE, m_iCurOperateIndex%MAX_CELL_PER_PAGE);
		
		if (item->getStonesCount() < 1) {
			showDialog(NDCommonCString("error"), NDCommonCString("NotFindXiangQiangBaoShi"));
		} else {
			UpdateEquipInfo(item);
		}
	}

	m_iCurOperateIndex = -1;
	dialog->Close();
	m_dlgBag = NULL;
	m_dlgSend = NULL;
}

void RemoveStoneScene::OnCBClick( NDUICheckBox* cb )
{
	if(cb == m_check)
	{
		m_iFocusIndex = -1;
		if (m_itemfocus) 
		{
			m_itemfocus->SetFrameRect(CGRectZero);
		}
		if (m_itemBag) 
		{
			m_itemBag->DeFocus();
		}
	}
}

void RemoveStoneScene::ResetGui()
{
	if (m_itemBag) 
	{
		std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
		m_itemBag->UpdateItemBag(itemlist);
		m_itemBag->UpdateTitle();
	}
	
	UpdateEquipInfo(NULL);
}

void RemoveStoneScene::UpdateEquipInfo(Item* item)
{
	m_btnEquip->ChangeItem(item);
	m_lbName->SetText( item == NULL ? NDCommonCString("equip") : item->getItemNameWithAdd().c_str());
	
	std::vector<Item*> stoneItemList;
	if (item)
	{
		stoneItemList = item->vecStone;
	}
	
	int iSize = stoneItemList.size();

	for (int i = 0; i < eStoneNum; i++)
	{
		Item *stone = NULL;
		if (i < iSize) 
		{
			stone = stoneItemList[i];
		}
		
		if (m_btnStoneItem[i]) 
		{
			m_btnStoneItem[i]->ChangeItem(stone);
		}
	}
	
	memset(m_StoneDigout, 0, sizeof(m_StoneDigout));
}

void RemoveStoneScene::Refresh()
{
	if (s_instance) 
	{
		s_instance->ResetGui();
	}
}

