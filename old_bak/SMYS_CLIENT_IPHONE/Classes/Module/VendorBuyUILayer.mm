/*
 *  VendorBuyUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "VendorBuyUILayer.h"
#include "NDUISynLayer.h"
#include "NDConstant.h"
#include "NDUtility.h"
#include "GlobalDialog.h"

enum {
	START_X = 56,
	START_Y = 56,
	
	ITEM_SIZE_WH = 42,
};

int VendorBuyUILayer::s_idVendor = 0;
VendorBuyUILayer* VendorBuyUILayer::s_instance = NULL;

IMPLEMENT_CLASS(VendorBuyUILayer, NDUIMenuLayer)

bool VendorBuyUILayer::isUILayerShown()
{
	return s_instance != NULL;
}

VendorBuyUILayer::VendorBuyUILayer() : m_vSellingItem(ItemMgrObj.GetOtherItem())
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->releaseItems();
	
	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
		for (NSUInteger c = 0; c < ITEM_COL; c++) {
			this->m_btnVendorItem[r][c] = NULL;
		}
	}
	
	m_optLayer = NULL;
	
	m_itemMoney = NULL;
	m_itemEMoney = NULL;
	
	m_bagMoney = NULL;
	m_bagEMoney = NULL;
	
	m_picMoney = NULL;
	m_picEMoney = NULL;
	
	m_curFocusBtn = NULL;
	
	m_lbItemName = NULL;
}

VendorBuyUILayer::~VendorBuyUILayer()
{
	s_instance = NULL;
	SAFE_DELETE(m_picMoney);
	SAFE_DELETE(m_picEMoney);
	this->releaseItems();
}

void VendorBuyUILayer::UpdateMoney()
{
	s_instance->InnerUpdateMoney();
}

void VendorBuyUILayer::InnerUpdateMoney()
{
	if (s_instance != NULL) 
	{
		NDPlayer& role = NDPlayer::defaultHero();
		if (m_bagMoney) 
		{
			m_bagEMoney->SetSmallWhiteNumber(role.eMoney, false);
		}
		
		if (m_bagEMoney) 
		{
			m_bagMoney->SetSmallWhiteNumber(role.money, false);
		}
	}	
}

void VendorBuyUILayer::releaseItems()
{
	for (VEC_ITEM_IT it = this->m_vSellingItem.begin(); it != m_vSellingItem.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vSellingItem.clear();
}

void VendorBuyUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
			{
				((GameScene*)(this->GetParent()))->SetUIShow(false);
			}
			this->RemoveFromParent(true);
		}
	} else {
		for (uint r = 0; r < ITEM_ROW; r++) {
			for (uint c = 0; c < ITEM_COL; c++) {
				if (button == this->m_btnVendorItem[r][c]) {
					if (this->m_curFocusBtn == button && this->m_curFocusBtn->GetItem()) { // 显示购买选项
						NDUITableLayer* opt = new NDUITableLayer;
						opt->Initialization();
						opt->VisibleSectionTitles(false);
						opt->SetDelegate(this);
						
						CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
						opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 60) / 2, 94, 60));
						
						NDDataSource* ds = new NDDataSource;
						NDSection* sec = new NDSection;
						ds->AddSection(sec);
						opt->SetDataSource(ds);
						
						NDUIButton* btn = new NDUIButton;
						btn->Initialization();
						btn->SetTitle(NDCommonCString("detail"));
						btn->SetFocusColor(ccc4(253, 253, 253, 255));
						sec->AddCell(btn);
						
						btn = new NDUIButton;
						btn->Initialization();
						btn->SetTitle(NDCommonCString("buy"));
						btn->SetFocusColor(ccc4(253, 253, 253, 255));
						sec->AddCell(btn);
						
						sec->SetFocusOnCell(0);
						
						this->m_optLayer = new NDOptLayer;
						this->m_optLayer->Initialization(opt);
						this->AddChild(m_optLayer);
					} else { // 更新
						this->m_curFocusBtn = (NDUIItemButton*)button;
						Item* item = this->m_curFocusBtn->GetItem();
						if (item) {
							this->m_lbItemName->SetText(item->makeItemName().c_str());
							MAP_ITEM_PRICE_IT it = this->m_mapItemPrices.find(item->iID);
							if (it != m_mapItemPrices.end()) {
								this->m_itemMoney->SetSmallWhiteNumber(it->second.first, false);
								this->m_itemEMoney->SetSmallWhiteNumber(it->second.second, false);
							}
						}
					}
				}
			}
		}
	}
}

void VendorBuyUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	Item* item = NULL;
	if (this->m_curFocusBtn) {
		item = m_curFocusBtn->GetItem();
	}
	
	if (!item) {
		return;
	}
	
	switch (cellIndex) {
		case 0: // 详细
		{
			if (item->isFormula() || item->isItemPet() || item->isSkillBook()) {
				sendQueryDesc(item->iID);
			} else {
				GlobalShowDlg(item->getItemName(), item->makeItemDes(false, false));
			}
		}
			break;
		case 1: // 购买
		{
			NDUISynLayer::Show();
			NDTransData bao(_MSG_BOOTH);
			bao << Byte(BOOTH_BUY) << s_idVendor << item->iID;
			SEND_DATA(bao);
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		}
			break;

		default:
			break;
	}
}

void VendorBuyUILayer::Show(NDTransData& data)
{
	NDUISynLayer::Close();
	
	if (s_instance) {
		s_instance->RemoveFromParent(true);
	}
	
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
		GameScene* gameScene = (GameScene*)scene;
		VendorBuyUILayer *layer = new VendorBuyUILayer;
		layer->Initialization(data);
		gameScene->AddChild(layer, UILAYER_Z);
		gameScene->SetUIShow(true);
	}
}

void VendorBuyUILayer::Close()
{
	if (s_instance) {
		s_instance->RemoveFromParent(true);
	}
}

void VendorBuyUILayer::RemoveItem(int idItem)
{
	if (s_instance) {
		s_instance->removeItem(idItem);
	}
}

void VendorBuyUILayer::removeItem(int idItem)
{
	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
		for (NSUInteger c = 0; c < ITEM_COL; c++) {
			Item* item = this->m_btnVendorItem[r][c]->GetItem();
			if (item && item->iID == idItem) {
				this->m_btnVendorItem[r][c]->ChangeItem(NULL);
				this->m_curFocusBtn = NULL;
				this->m_itemMoney->SetSmallWhiteNumber(0, false);
				this->m_itemEMoney->SetSmallWhiteNumber(0, false);
				this->m_lbItemName->SetText("");
				if (this->m_optLayer) {
					this->m_optLayer->RemoveFromParent(true);
					this->m_optLayer = NULL;
				}
				return;
			}
		}
	}
}

void VendorBuyUILayer::Initialization(NDTransData& data)
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel; 
	title->Initialization(); 
	title->SetText(NDCommonCString("ViewBoothItem")); 
	title->SetFontSize(15); 
	title->SetTextAlignment(LabelTextAlignmentCenter); 
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	int btItemCount = data.ReadByte(); // 数量
	
	for (int i = 0; i < btItemCount; i++) {
		Item* item = new Item;
		item->iID = data.ReadInt();
		item->iOwnerID = data.ReadInt();
		item->iItemType = data.ReadInt();
		item->iAmount= data.ReadInt();
		item->iPosition = data.ReadByte();
		item->iAddition = data.ReadByte(); // 追加
		
		item->byHole = data.ReadByte(); // 有几个宝石洞
		
		int money = data.ReadInt();
		int eMoney = data.ReadInt();
		this->m_mapItemPrices[item->iID] = make_pair(money, eMoney);
		
		int stoneCount = data.ReadByte(); // 数量
		for (int j = 0; j < stoneCount; j++) {
			item->AddStone(data.ReadInt());
		}
		
		this->m_vSellingItem.push_back(item);
	}
	
	size_t uItemIdx = 0;
	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
		for (NSUInteger c = 0; c < ITEM_COL; c++) {
			Item* item = NULL;
			uItemIdx = r * ITEM_COL + c;
			if (uItemIdx < m_vSellingItem.size()) {
				item = m_vSellingItem.at(uItemIdx);
			}
			
			NDUIItemButton* btn = new NDUIItemButton;
			btn->Initialization();
			btn->SetDelegate(this);
			btn->SetFrameRect(CGRectMake(START_X + c * (ITEM_SIZE_WH + 4),
						     START_Y + r * (ITEM_SIZE_WH + 4),
						     ITEM_SIZE_WH, ITEM_SIZE_WH));
			btn->ChangeItem(item);
			this->AddChild(btn);
			this->m_btnVendorItem[r][c] = btn;
		}
	}
	
	this->m_itemEMoney = new ImageNumber;
	m_itemEMoney->Initialization();
	m_itemEMoney->SetSmallWhiteNumber(0, false);
	m_itemEMoney->SetFrameRect(CGRectMake(251, 206, 62, 20));
	m_itemEMoney->SetTouchEnabled(false);
	this->AddChild(m_itemEMoney);
	
	this->m_itemMoney = new ImageNumber;
	m_itemMoney->Initialization();
	m_itemMoney->SetSmallWhiteNumber(0, false);
	m_itemMoney->SetFrameRect(CGRectMake(84, 206, 62, 20));
	m_itemMoney->SetTouchEnabled(false);
	this->AddChild(m_itemMoney);
	
	NDPlayer& role = NDPlayer::defaultHero();
	this->m_bagEMoney = new ImageNumber;
	m_bagEMoney->Initialization();
	m_bagEMoney->SetSmallWhiteNumber(role.eMoney, false);
	m_bagEMoney->SetFrameRect(CGRectMake(251, 241, 62, 20));
	m_bagEMoney->SetTouchEnabled(false);
	this->AddChild(m_bagEMoney);
	
	this->m_bagMoney = new ImageNumber;
	m_bagMoney->Initialization();
	m_bagMoney->SetSmallWhiteNumber(role.money, false);
	m_bagMoney->SetFrameRect(CGRectMake(84, 241, 62, 20));
	m_bagMoney->SetTouchEnabled(false);
	this->AddChild(m_bagMoney);
	
	this->m_picMoney = new NDPicture;
	m_picMoney->Initialization(GetImgPath("money.png"));
	
	this->m_picEMoney = new NDPicture;
	m_picEMoney->Initialization(GetImgPath("emoney.png"));
	
	this->m_lbItemName = new NDUILabel;
	m_lbItemName->Initialization();
	m_lbItemName->SetFontColor(ccc4(132, 40, 0, 255));
	m_lbItemName->SetFrameRect(CGRectMake(56, 220, 370, 18));
	m_lbItemName->SetTextAlignment(LabelTextAlignmentLeft);
	this->AddChild(m_lbItemName);
}

void VendorBuyUILayer::draw()
{
	NDUIMenuLayer::draw();
	
	DrawLine(CGPointMake(56, 195), CGPointMake(424, 195), ccc4(82, 93, 90, 255), 2);
	DrawLine(CGPointMake(56, 197), CGPointMake(424, 197), ccc4(156, 178, 148, 255), 2);
	DrawLine(CGPointMake(56, 199), CGPointMake(424, 199), ccc4(82, 93, 90, 255), 2);
	
	DrawFrame(0x234A2B, 50, 50, 380, 210);
	
	this->m_picEMoney->DrawInRect(CGRectMake(230.0f, 203.0f, 16.0f, 16.0f));
	this->m_picMoney->DrawInRect(CGRectMake(60.0f, 203.0f, 16.0f, 16.0f));
	
	this->m_picEMoney->DrawInRect(CGRectMake(230.0f, 238.0f, 16.0f, 16.0f));
	this->m_picMoney->DrawInRect(CGRectMake(60.0f, 238.0f, 16.0f, 16.0f));
	
	if (this->m_curFocusBtn) {
		CGRect rectCurFocus = this->m_curFocusBtn->GetScreenRect();
		rectCurFocus.origin.x -= 1;
		rectCurFocus.origin.y -= 1;
		rectCurFocus.size.width += 2;
		rectCurFocus.size.height += 2;
		DrawPolygon(rectCurFocus, ccc4(189, 56, 0, 255), 1);
	}
}
