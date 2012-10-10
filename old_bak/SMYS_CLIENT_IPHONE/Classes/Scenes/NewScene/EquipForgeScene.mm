/*
 *  EquipForgeScene.mm
 *  DragonDrive
 *
 *  Created by wq on 11-9-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "EquipForgeScene.h"
#include "NDUtility.h"
#include "ItemMgr.h"
#include <sstream>
#include "ItemImage.h"
#include "GlobalDialog.h"
#include "EquipUpgradeScene.h"
#include "NDUISynLayer.h"

IMPLEMENT_CLASS(EquipForgeScene, NDCommonScene)

EquipForgeScene* EquipForgeScene::s_instance = NULL;

void EquipForgeScene::processEquipImprove()
{
	m_bag->UpdateMoney();
	// 锻造装备信息更新
	if (m_forgeItem) {
		this->RefreshEnancedInfo(m_forgeItem);
	}
	// 辅助物品数量更新
	if (m_fuzhuItem) {
		NDUIItemButton* btn = m_bag->GetItemBtnByItem(m_fuzhuItem);
		if (btn) {
			btn->ChangeItem(m_fuzhuItem, true);
		}
	}
}

void EquipForgeScene::processDelItem(int idItem)
{
	m_bag->DelItem(idItem);
	if (m_forgeItem && m_forgeItem->iID == idItem) {
		m_forgeItem = NULL;
		m_lbEquipForge->SetText(NDCommonCString("equip"));
		m_equipForge->ChangeItem(NULL);
		m_lbEquipDes->SetText("");
		m_lbConsumeItem->SetText("");
		m_lbConsumeMoney->SetText("");
	} else if (m_fuzhuItem && m_fuzhuItem->iID == idItem) {
		m_fuzhuItem = NULL;
		m_lbConsumeFuzhu->SetText("");
		m_itemFuzhu->ChangeItem(NULL);
	}
}

EquipForgeScene::EquipForgeScene()
{
	s_instance = this;
	m_bag = NULL;
	m_lbEquipForge = NULL;
	m_lbEquipDes = NULL;
	m_lbConsumeItem = NULL;
	m_lbConsumeMoney = NULL;
	m_lbConsumeFuzhu = NULL;
	m_btnConfirm = NULL;
	m_equipForge = NULL;
	m_itemFuzhu = NULL;
	m_imageMouse = NULL;
	m_forgeItem = NULL;
	m_fuzhuItem = NULL;
}

EquipForgeScene::~EquipForgeScene()
{
	if (s_instance == this) {
		s_instance = NULL;
	}
}

void EquipForgeScene::Initialization()
{
	NDCommonScene::Initialization();
	
	NDPicturePool& pool = *(NDPicturePool::DefaultPool());
	
	TabNode* tabnode = this->AddTabNode();
	
	tabnode->SetImage(pool.AddPicture(GetImgPathNew("newui_tab_unsel.png"), 70, 31), 
					  pool.AddPicture(GetImgPathNew("newui_tab_sel.png"), 70, 34),
					  pool.AddPicture(GetImgPathNew("newui_tab_selarrow.png")));
	
	tabnode->SetText(NDCommonCString("DuanZhao"));
	
	tabnode->SetTextColor(ccc4(245, 226, 169, 255));
	
	tabnode->SetFocusColor(ccc4(173, 70, 25, 255));
	
	tabnode->SetTextFontSize(18);
	
	this->SetTabFocusOnIndex(0, true);
	
	NDUIClientLayer* client = this->GetClientLayer(0);
	
	float fStartY = 10;
	NDUIImage* imgBg = new NDUIImage;
	imgBg->Initialization();
	imgBg->SetPicture(pool.AddPicture(GetImgPathNew("bag_left_bg.png")), true);
	imgBg->SetFrameRect(CGRectMake(0, fStartY, 203, 262));
	client->AddChild(imgBg);
	
	fStartY += 6;
	m_lbEquipForge = new NDUILabel;
	m_lbEquipForge->Initialization();
	m_lbEquipForge->SetText(NDCommonCString("equip"));
	m_lbEquipForge->SetFontSize(16);
	m_lbEquipForge->SetFontColor(ccc4(140, 40, 40, 255));
	m_lbEquipForge->SetFrameRect(CGRectMake(16, fStartY, 100, 18));
	client->AddChild(m_lbEquipForge);
	fStartY += 26;
	
	m_equipForge = new NDUIItemButton;
	m_equipForge->Initialization();
	m_equipForge->SetDelegate(this);
	m_equipForge->SetFrameRect(CGRectMake(16, fStartY, 42, 42));
	m_equipForge->ShowItemCount(false);
	client->AddChild(m_equipForge);
	
	m_lbEquipDes = new NDUILabelScrollLayer;
	m_lbEquipDes->Initialization();
	m_lbEquipDes->SetFrameRect(CGRectMake(68, fStartY, 126, 60));
	//m_lbEquipDes->SetText("", 0, 0, 60, ccc4(8, 8, 8, 255));
	client->AddChild(m_lbEquipDes);
	fStartY += 62;
	
	NDUIImage* imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, fStartY, 185, 2));
	client->AddChild(imgSlash);
	fStartY += 8;
	
	NDUILabel* lbFuzhu = new NDUILabel;
	lbFuzhu->Initialization();
	lbFuzhu->SetText(NDCommonCString("FuZhu"));
	lbFuzhu->SetFontSize(16);
	lbFuzhu->SetFontColor(ccc4(140, 40, 40, 255));
	lbFuzhu->SetFrameRect(CGRectMake(16, fStartY, 100, 18));
	client->AddChild(lbFuzhu);
	fStartY += 26;
	
	m_itemFuzhu = new NDUIItemButton;
	m_itemFuzhu->Initialization();
	m_itemFuzhu->SetDelegate(this);
	m_itemFuzhu->SetFrameRect(CGRectMake(16, fStartY, 42, 42));
	m_itemFuzhu->ShowItemCount(false);
	client->AddChild(m_itemFuzhu);
	
	NDUILabel* lbConsume = new NDUILabel;
	lbConsume->Initialization();
	lbConsume->SetText(NDCommonCString("NeedConsume"));
	lbConsume->SetFontSize(14);
	lbConsume->SetFontColor(ccc4(8, 8, 8, 255));
	lbConsume->SetFrameRect(CGRectMake(68, fStartY, 80, 16));
	client->AddChild(lbConsume);
	fStartY += 16;
	
	m_lbConsumeItem = new NDUILabel;
	m_lbConsumeItem->Initialization();
	m_lbConsumeItem->SetFontSize(14);
	m_lbConsumeItem->SetFontColor(ccc4(8, 8, 8, 255));
	m_lbConsumeItem->SetFrameRect(CGRectMake(68, fStartY, 80, 16));
	client->AddChild(m_lbConsumeItem);
	fStartY += 16;
	
	m_lbConsumeMoney = new NDUILabel;
	m_lbConsumeMoney->Initialization();
	m_lbConsumeMoney->SetFontSize(14);
	m_lbConsumeMoney->SetFontColor(ccc4(8, 8, 8, 255));
	m_lbConsumeMoney->SetFrameRect(CGRectMake(68, fStartY, 80, 16));
	client->AddChild(m_lbConsumeMoney);
	fStartY += 16;
	
	m_lbConsumeFuzhu = new NDUILabel;
	m_lbConsumeFuzhu->Initialization();
	m_lbConsumeFuzhu->SetFontSize(14);
	m_lbConsumeFuzhu->SetFontColor(ccc4(8, 8, 8, 255));
	m_lbConsumeFuzhu->SetFrameRect(CGRectMake(68, fStartY, 80, 16));
	client->AddChild(m_lbConsumeFuzhu);
	fStartY += 18;
	
	imgSlash = new NDUIImage;
	imgSlash->Initialization();
	imgSlash->SetPicture(NDPicturePool::DefaultPool()->AddPicture(GetImgPathNew("bag_left_fengge.png")), true);
	imgSlash->SetFrameRect(CGRectMake(6, fStartY, 185, 2));
	client->AddChild(imgSlash);
	fStartY += 18;
	
	m_btnConfirm = new NDUIButton;
	m_btnConfirm->Initialization();
	m_btnConfirm->SetFontColor(ccc4(255, 255, 255, 255));
	m_btnConfirm->SetFontSize(12);
	m_btnConfirm->CloseFrame();
	m_btnConfirm->SetTitle(NDCommonCString("commit"));
	m_btnConfirm->SetBackgroundPicture(pool.AddPicture(GetImgPathNew("bag_btn_normal.png")),
							  pool.AddPicture(GetImgPathNew("bag_btn_click.png")),
							  false, CGRectZero, true);
	m_btnConfirm->SetDelegate(this);
	m_btnConfirm->SetFrameRect(CGRectMake(16, fStartY, 48, 24));
	client->AddChild(m_btnConfirm);
	
	VEC_ITEM vItems;
	ItemMgrObj.GetEnhanceItem(vItems);
	m_bag = new NewGameItemBag;
	m_bag->Initialization(vItems, true, false);
	m_bag->SetFrameRect(CGRectMake(203, 6, NEW_ITEM_BAG_W, NEW_ITEM_BAG_H));
	m_bag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_bag->SetDelegate(this);
	client->AddChild(m_bag);
	
	m_imageMouse = new NDUIImage;
	m_imageMouse->Initialization();
	m_imageMouse->EnableEvent(false);
	this->AddChild(m_imageMouse, 1);
}

void EquipForgeScene::OnButtonClick(NDUIButton* button)
{
	if (OnBaseButtonClick(button)) return;
	
	if (m_btnConfirm == button) {
		if (!m_forgeItem) {
			return;
		}
		
		NDItemType* itemType = ItemMgrObj.QueryItemType(m_forgeItem->iItemType);
		if (!itemType) {
			return;
		}
		
		EnhancedObj* enhancedObj = ItemMgrObj.QueryEnhancedType(itemType->m_data.m_enhancedId + m_forgeItem->iAddition + 1);
		
		if (enhancedObj) {
			NDItemType* reqItem = ItemMgrObj.QueryItemType(enhancedObj->req_item);
			if (reqItem) {
				stringstream sb;
				sb << NDCommonCString("DuanZhaoConsume") << "：\n";
				sb << reqItem->m_name << "x<cff0000" << enhancedObj->req_num << "/e \n";
				sb << NDCommonCString("money") << "x<cff0000" << enhancedObj->req_money << "/e \n";
				sb << NDCommonCString("StartDuanZhao") << "\n(<cff0000" << NDCommonCString("DuanZhaoFailNotAppear") << "/e)";
				
				GlobalDialogObj.Show(this, NDCommonCString("WenXinTip"), sb.str().c_str(), 0, NDCommonCString("Ok"), NULL);
			}
		} else {
			GlobalDialogObj.Show(NULL, NDCommonCString("WenXinTip"), NDCommonCString("EquipCantDuanZhao"), 0, NULL);
		}
	}
}

void sendEquipEnhance(int idEquip, int idStuff) {
	ShowProgressBar;
	NDTransData bao(_MSG_EQUIPIMPROVE);
	bao << Byte(EQUIP_IM_ENHANCE) << idEquip << idStuff;
	SEND_DATA(bao);
}

void EquipForgeScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	dialog->Close();
	if (m_forgeItem) {
		sendEquipEnhance(m_forgeItem->iID, m_fuzhuItem ? m_fuzhuItem->iID : 0);
	}
}

bool EquipForgeScene::OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch)
{
	if (desButton == uiSrcNode) {
		return true;
	}
	
	if (uiSrcNode && uiSrcNode->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton))) {
		NDUIItemButton* equip = (NDUIItemButton*)uiSrcNode;
		Item* item = equip->GetItem();
		if (item) {
			if (item->isCanEnhance()) {
				if (desButton == m_equipForge) {
					m_equipForge->ChangeItem(item, false);
					if (m_forgeItem) {
						NDUIItemButton* itemBtn = m_bag->GetItemBtnByItem(m_forgeItem);
						if (itemBtn) {
							itemBtn->ChangeItem(m_forgeItem, false);
							m_forgeItem = NULL;
						}
					}
					m_forgeItem = item;
					equip->ChangeItem(item, true);
					m_lbEquipForge->SetText(item->getItemNameWithAdd().c_str());
					this->RefreshEnancedInfo(item);
				}
			} else {
				if (desButton == m_itemFuzhu) {
					m_itemFuzhu->ChangeItem(item, false);
					if (m_fuzhuItem) {
						NDUIItemButton* itemBtn = m_bag->GetItemBtnByItem(m_fuzhuItem);
						if (itemBtn) {
							itemBtn->ChangeItem(m_fuzhuItem, false);
							m_fuzhuItem = NULL;
						}
					}
					m_fuzhuItem = item;
					equip->ChangeItem(item, true);
					stringstream ss;
					ss << item->getItemName() << "×1";
					m_lbConsumeFuzhu->SetText(ss.str().c_str());
				}
			}
		}
	}
	return true;
}

int EquipForgeScene::getAddPoint(int enhancedId, Byte btAddition, int srcPoint) {
	return Item::getOnlyAdditionPoint(enhancedId, (btAddition+1), srcPoint) - Item::getOnlyAdditionPoint(enhancedId, btAddition, srcPoint);
}

void EquipForgeScene::RefreshEnancedInfo(Item* item)
{
	NDItemType* itemType = ItemMgrObj.QueryItemType(item->iItemType);
	EnhancedObj* enhance = ItemMgrObj.QueryEnhancedType(item->getEnhanceId() + item->iAddition + 1);
	if (!itemType || !enhance) {
		m_lbConsumeItem->SetText("");
		m_lbConsumeMoney->SetText("");
		return;
	}
	stringstream sb;
	NDItemType& itemTypeObj = *itemType;
	if (itemTypeObj.m_data.m_life > 0) {
		sb << NDCommonCString("life") << "+" << getAddPoint(itemTypeObj.m_data.m_enhancedId, item->iAddition, itemTypeObj.m_data.m_life ) << "\n";
	}
	if (itemTypeObj.m_data.m_mana > 0) {
		sb << NDCommonCString("magic") << "+" << getAddPoint(itemTypeObj.m_data.m_enhancedId, item->iAddition, itemTypeObj.m_data.m_mana) << "\n";
	}
	if (itemTypeObj.m_data.m_atk > 0) {
		sb << NDCommonCString("PhyAtk") << "+" << getAddPoint(itemTypeObj.m_data.m_enhancedId, item->iAddition, itemTypeObj.m_data.m_atk) << "\n";
	}
	if (itemTypeObj.m_data.m_def > 0) {
		sb << NDCommonCString("PhyDef") << "+" << getAddPoint(itemTypeObj.m_data.m_enhancedId, item->iAddition, itemTypeObj.m_data.m_def) << "\n";
	}
	if (itemTypeObj.m_data.m_mag_atk != 0) {
		sb << NDCommonCString("FaShuAtk") << "+" << getAddPoint(itemTypeObj.m_data.m_enhancedId, item->iAddition, itemTypeObj.m_data.m_mag_atk) << "\n";
	}
	if (itemTypeObj.m_data.m_mag_def != 0) {
		sb << NDCommonCString("FaShuDef") << "+" << getAddPoint(itemTypeObj.m_data.m_enhancedId, item->iAddition, itemTypeObj.m_data.m_mag_def) << "\n";
	}
	m_lbEquipDes->SetText(sb.str().c_str(), 0, 0, 60, ccc4(8, 8, 8, 255));
	
	// 消耗物品银两
	NDItemType* reqItem = ItemMgrObj.QueryItemType(enhance->req_item);
	if (reqItem) {
		sb.str("");
		sb << reqItem->m_name << "×" << enhance->req_num;
		m_lbConsumeItem->SetText(sb.str().c_str());
	}
	if (enhance->req_money > 0) {
		sb.str("");
		sb << NDCommonCString("money") << "×" << enhance->req_money;
		m_lbConsumeMoney->SetText(sb.str().c_str());
	}
}

bool EquipForgeScene::OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch)
{
	if (button->IsKindOfClass(RUNTIME_CLASS(NDUIItemButton)))
	{
		Item* item = ((NDUIItemButton*)button)->GetItem();
		
		if (!item) 
			return false;
		
		NDPicture* pic = ItemImage::GetItemByIconIndex(item->getIconIndex());
		
		if (pic && m_imageMouse) 
		{
			m_imageMouse->SetPicture(pic, true);
			
			CGSize size = pic->GetSize();
			
			m_imageMouse->SetFrameRect(CGRectMake(moveTouch.x-size.width/2, moveTouch.y-size.height/2, pic->GetSize().width, pic->GetSize().height));
			
			return true;
		}
	}
	
	return false;
}

bool EquipForgeScene::OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange)
{
	m_imageMouse->SetPicture(NULL);
	if (button == m_equipForge) {
		if (outOfRange) {
			m_lbEquipForge->SetText(NDCommonCString("equip"));
			m_equipForge->ChangeItem(NULL);
			m_lbEquipDes->SetText("");
			m_lbConsumeItem->SetText("");
			m_lbConsumeMoney->SetText("");
			if (m_forgeItem) {
				NDUIItemButton* itemBtn = m_bag->GetItemBtnByItem(m_forgeItem);
				if (itemBtn) {
					itemBtn->ChangeItem(m_forgeItem, false);
					m_forgeItem = NULL;
				}
			}
		}
	} else if (button == m_itemFuzhu) {
		if (outOfRange) {
			m_lbConsumeFuzhu->SetText("");
			m_itemFuzhu->ChangeItem(NULL);
			if (m_fuzhuItem) {
				NDUIItemButton* itemBtn = m_bag->GetItemBtnByItem(m_fuzhuItem);
				if (itemBtn) {
					itemBtn->ChangeItem(m_fuzhuItem, false);
					m_fuzhuItem = NULL;
				}
			}
		}
	}
	return false;
}



