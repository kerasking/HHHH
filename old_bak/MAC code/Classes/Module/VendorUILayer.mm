/*
 *  VendorUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-3-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "VendorUILayer.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "NDPlayer.h"
#include "GlobalDialog.h"
#include "GameScene.h"
#include "NDConstant.h"
#include "NDUISynLayer.h"
#include "NDMapMgr.h"
#include "AnimationList.h"
#include "VendorBuyUILayer.h"
#include "ItemViewText.h"
#include "NDPath.h"
#include <sstream>

enum {
	START_X = 10,
	START_Y = 36,
	
	ITEM_SIZE_WH = 42,
	
	SOLD_LIST_CELL_HEIGHT = ITEM_SIZE_WH + 1,
	SOLD_LIST_MAX_HEIGHT = 250,
	
	TAG_BAG_OPT = 1,
	TAG_VENDOR_OPT = 2,
	
	TAG_INPUT_YINLIANG = 3,
	TAG_INPUT_YUANBAO = 4,
	
	TAG_VENDOR = 5,
	TAG_CANCEL = 6,
	TAG_VENDORING = 7,
	
	TAG_BTN_YINLIANG = 8,
	TAG_BTN_YUANBAO = 9,
	TAG_BTN_DETAIL = 10,
};

VendorUILayer* VendorUILayer::s_instance = NULL;

IMPLEMENT_CLASS(VendorUILayer, NDUIMenuLayer)

void VendorUILayer::Show(GameScene* scene)
{
	if (s_instance) {
		if (s_instance->GetParent() == NULL) {
			scene->AddChild(s_instance, UILAYER_Z);
		}
	} else {
		VendorUILayer* vendor = new VendorUILayer;
		vendor->Initialization();
		scene->AddChild(vendor, UILAYER_Z);
	}
}

bool VendorUILayer::isUILayerShown()
{
	return s_instance != NULL;
}

void VendorUILayer::reset()
{
	SAFE_DELETE(s_instance);
}

void VendorUILayer::UpdateMoney()
{
	s_instance->InnerUpdateMoney();
}

void VendorUILayer::InnerUpdateMoney()
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

void VendorUILayer::boothSuccess()
{
	NDUILayer* layerAccept = new NDUILayer;
	layerAccept->Initialization();
	layerAccept->SetBackgroundColor(ccc4(252, 66, 66, 100));
	layerAccept->SetFrameRect(CGRectMake(START_X - 3, START_Y - 2, 180.0f, 186.0f));
	layerAccept->SetTag(TAG_VENDORING);
	this->AddChild(layerAccept);
	
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	pic->Cut(CGRectMake(80, 20, 40, 20));
	this->m_btnVendor->SetImage(pic, true, CGRectMake(10.0f, 2.0f, 40.0f, 20.0f));
	m_btnVendor->SetTag(TAG_CANCEL);
	
	this->m_itemMoney->SetSmallWhiteNumber(0, false);
	this->m_itemEMoney->SetSmallWhiteNumber(0, false);
	
	this->m_curFocusBtn = NULL;
}

void VendorUILayer::boothCancel()
{
	NDUISynLayer::Close();
	
	this->RemoveChild(TAG_VENDORING, true);
	
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	pic->Cut(CGRectMake(180, 60, 40, 20));
	this->m_btnVendor->SetImage(pic, true, CGRectMake(8.0f, 2.0f, 40.0f, 20.0f));
	m_btnVendor->SetTag(TAG_VENDOR);
}

void VendorUILayer::processMsgBooth(NDTransData& data)
{
	NDPlayer& role = NDPlayer::defaultHero();
	NDMapMgr& mgr = NDMapMgrObj;
	int action = data.ReadByte();
	int booth = data.ReadInt();
	int itemId = data.ReadInt();
	
	if(booth == role.m_id) {
		NDUISynLayer::Close();
	}
	
	if (action == BOOTH_ADD) { // 开始摆摊
		if (booth == role.m_id) {
			if (s_instance) {
				s_instance->boothSuccess();
				role.UpdateState(USERSTATE_BOOTH, true);
			}
		} else {
			NDManualRole* r = mgr.GetManualRole(booth);
			if (r) {
				r->UpdateState(USERSTATE_BOOTH, true);
			}
		}
	} else if (action == BOOTH_REPEAL) { // 收摊
		if (booth == role.m_id) {
			role.UpdateState(USERSTATE_BOOTH, false);
			if (s_instance) {
				s_instance->boothCancel();
			}
		} else {
			NDManualRole* r = mgr.GetManualRole(booth);
			if (r) {
				r->UpdateState(USERSTATE_BOOTH, false);
				VendorBuyUILayer::Close();
			}
		}
	} else if (action == BOOTH_BUY || action == BOOTH_SUCCESS) { // 物品被购买
		if (s_instance) {
			s_instance->removeItem(itemId);
		}
		VendorBuyUILayer::RemoveItem(itemId);
	}else if (action == BOOTH_QUEST)
	{
		if (!VendorBuyUILayer::isUILayerShown()) 
		{
			NDTransData data;
			VendorBuyUILayer::Show(data);
		}
	}
}

void VendorUILayer::removeItem(int idItem)
{
	Item* item = NULL;
	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
		for (NSUInteger c = 0; c < ITEM_COL; c++) {
			item = this->m_btnVendorItem[r][c]->GetItem();
			if (item && item->iID == idItem) {
				this->m_btnVendorItem[r][c]->ChangeItem(NULL);
				
				// 加入卖出列表
				this->m_vSellItems.push_back(item);
				return;
			}
		}
	}
}

VendorUILayer::VendorUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	
	m_bagItem = NULL;
	
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
	
	m_btnVendor = NULL;
	m_btnSoldList = NULL;
	
	m_curFocusBtn = NULL;
}

VendorUILayer::~VendorUILayer()
{
	s_instance = NULL;
	SAFE_DELETE(m_picMoney);
	SAFE_DELETE(m_picEMoney);
	this->releaseItems();
}

void VendorUILayer::releaseItems()
{
	for (VEC_ITEM_IT it = this->m_vBagItems.begin(); it != this->m_vBagItems.end(); it++) {
		SAFE_DELETE(*it);
	}
	this->m_vBagItems.clear();
}

void VendorUILayer::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
//	NDUILabel* title = new NDUILabel; 
//	title->Initialization(); 
//	title->SetText("摆摊"); 
//	title->SetFontSize(15); 
//	title->SetTextAlignment(LabelTextAlignmentCenter); 
//	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
//	title->SetFontColor(ccc4(255, 240, 0,255));
//	this->AddChild(title);
	
	NDPicture* picTitle = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	picTitle->Cut(CGRectMake(180, 60, 40, 19));
	
	NDUIImage* imgTitle = new NDUIImage();
	imgTitle->Initialization();
	imgTitle->SetPicture(picTitle, true);
	imgTitle->SetFrameRect(CGRectMake(220, 5, picTitle->GetSize().width, picTitle->GetSize().height));
	this->AddChild(imgTitle);
	
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	
	for (VEC_ITEM_IT it = itemlist.begin(); it != itemlist.end(); it++) {
		Item* item = new Item;
		*item = *(*it);
		this->m_vBagItems.push_back(item);
	}
	
	this->m_bagItem = new GameItemBag;
	m_bagItem->Initialization(m_vBagItems);
	m_bagItem->SetDelegate(this);
	m_bagItem->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_bagItem->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	this->AddChild(m_bagItem);
	
	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
		for (NSUInteger c = 0; c < ITEM_COL; c++) {
			NDUIItemButton* btn = new NDUIItemButton;
			btn->Initialization();
			btn->SetDelegate(this);
			btn->SetFrameRect(CGRectMake(START_X + c * (ITEM_SIZE_WH + 2),
						     START_Y + r * (ITEM_SIZE_WH + 4),
						     ITEM_SIZE_WH, ITEM_SIZE_WH));
			this->AddChild(btn);
			this->m_btnVendorItem[r][c] = btn;
		}
	}
	
	this->m_itemEMoney = new ImageNumber;
	m_itemEMoney->Initialization();
	m_itemEMoney->SetSmallWhiteNumber(0, false);
	m_itemEMoney->SetFrameRect(CGRectMake(34, 228, 62, 20));
	m_itemEMoney->SetTouchEnabled(false);
	this->AddChild(m_itemEMoney);
	
	this->m_itemMoney = new ImageNumber;
	m_itemMoney->Initialization();
	m_itemMoney->SetSmallWhiteNumber(0, false);
	m_itemMoney->SetFrameRect(CGRectMake(121, 228, 62, 20));
	m_itemMoney->SetTouchEnabled(false);
	this->AddChild(m_itemMoney);
	
	NDPlayer& role = NDPlayer::defaultHero();
	this->m_bagEMoney = new ImageNumber;
	m_bagEMoney->Initialization();
	m_bagEMoney->SetSmallWhiteNumber(role.eMoney, false);
	m_bagEMoney->SetFrameRect(CGRectMake(221, 293, 62, 20));
	m_bagEMoney->SetTouchEnabled(false);
	this->AddChild(m_bagEMoney);
	
	this->m_bagMoney = new ImageNumber;
	m_bagMoney->Initialization();
	m_bagMoney->SetSmallWhiteNumber(role.money, false);
	m_bagMoney->SetFrameRect(CGRectMake(338, 293, 62, 20));
	m_bagMoney->SetTouchEnabled(false);
	this->AddChild(m_bagMoney);
	
	this->m_picMoney = new NDPicture;
	m_picMoney->Initialization(NDPath::GetImgPath("money.png"));
	
	this->m_picEMoney = new NDPicture;
	m_picEMoney->Initialization(NDPath::GetImgPath("emoney.png"));
	
	this->m_btnVendor = new NDUIButton;
	m_btnVendor->Initialization();
	m_btnVendor->SetDelegate(this);
	m_btnVendor->SetTag(TAG_VENDOR);
	m_btnVendor->SetBackgroundColor(ccc4(57, 109, 107, 255));
	
	NDPicture* pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	pic->Cut(CGRectMake(180, 60, 40, 20));
	
	m_btnVendor->SetImage(pic, true, CGRectMake(8.0f, 2.0f, 40.0f, 20.0f));
	m_btnVendor->SetFrameRect(CGRectMake(10.0f, 244.0f, 66.0f, 25.0f));
	this->AddChild(m_btnVendor);
	
	this->m_btnSoldList = new NDUIButton;
	m_btnSoldList->Initialization();
	m_btnSoldList->SetDelegate(this);
	m_btnSoldList->SetBackgroundColor(ccc4(57, 109, 107, 255));
	
	pic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	pic->Cut(CGRectMake(0, 40, 60, 20));
	
	m_btnSoldList->SetImage(pic, true, CGRectMake(3.0f, 0.0f, 60.0f, 20.0f));
	m_btnSoldList->SetFrameRect(CGRectMake(118.0f, 244.0f, 66.0f, 25.0f));
	this->AddChild(m_btnSoldList);
}

void VendorUILayer::draw()
{
	NDUIMenuLayer::draw();
	
	this->m_picEMoney->DrawInRect(CGRectMake(12.0f, 225.0f, 16.0f, 16.0f));
	this->m_picMoney->DrawInRect(CGRectMake(101.0f, 225.0f, 16.0f, 16.0f));
	
	this->m_picEMoney->DrawInRect(CGRectMake(202.0f, 291.0f, 16.0f, 16.0f));
	this->m_picMoney->DrawInRect(CGRectMake(320.0f, 291.0f, 16.0f, 16.0f));
	
	if (this->m_curFocusBtn) {
		CGRect rectCurFocus = this->m_curFocusBtn->GetScreenRect();
		rectCurFocus.origin.x -= 1;
		rectCurFocus.origin.y -= 1;
		rectCurFocus.size.width += 2;
		rectCurFocus.size.height += 2;
		DrawPolygon(rectCurFocus, ccc4(189, 56, 0, 255), 1);
	}
}

void VendorUILayer::OnClickPage(GameItemBag* itembag, int iPage)
{
	
}

bool VendorUILayer::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	// 显示操作选项
	if (bFocused && item) {
		if (!this->m_optLayer) {
			// 显示操作选项
			NDUITableLayer* opt = new NDUITableLayer;
			opt->Initialization();
			opt->VisibleSectionTitles(false);
			opt->SetDelegate(this);
			opt->SetTag(TAG_BAG_OPT);
			
			int nHeight = 0;
			CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
			
			NDDataSource* ds = new NDDataSource;
			NDSection* sec = new NDSection;
			ds->AddSection(sec);
			opt->SetDataSource(ds);
			
			NDUIButton* btn = NULL;
			
			if (!this->GetChild(TAG_VENDORING)) {
				btn = new NDUIButton;
				btn->Initialization();
				btn->SetTitle(NDCommonCString("MoneyTrade"));
				btn->SetTag(TAG_BTN_YINLIANG);
				btn->SetFocusColor(ccc4(253, 253, 253, 255));
				sec->AddCell(btn);
				nHeight += 30;
				
				btn = new NDUIButton;
				btn->Initialization();
				btn->SetTitle(NDCommonCString("EMoneyTrade"));
				btn->SetTag(TAG_BTN_YUANBAO);
				btn->SetFocusColor(ccc4(253, 253, 253, 255));
				sec->AddCell(btn);
				nHeight += 30;
			}
			
			btn = new NDUIButton;
			btn->Initialization();
			btn->SetTitle(NDCommonCString("detail"));
			btn->SetTag(TAG_BTN_DETAIL);
			btn->SetFocusColor(ccc4(253, 253, 253, 255));
			sec->AddCell(btn);
			nHeight += 30;
			
			opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - nHeight) / 2, 94, nHeight));
			
			sec->SetFocusOnCell(0);
			
			this->m_optLayer = new NDOptLayer;
			this->m_optLayer->Initialization(opt);
			this->AddChild(m_optLayer);
		}
	}
	return false;
}

bool VendorUILayer::OnCustomViewConfirm(NDUICustomView* customView)
{
	OBJID idTag = customView->GetTag();
	Item* bagItem = this->m_bagItem->GetFocusItem();
	
	if (bagItem == NULL) {
		return true;
	}
	
	PAIR_VENDOR_ITEM_PRICE price;
	
	VerifyViewNum(*customView);
	
	if (idTag == TAG_INPUT_YINLIANG) {
		string strYinliang = customView->GetEditText(0);
		int yinliang = atoi(strYinliang.c_str());
		if (yinliang <= 0 || yinliang > MAX_MONEY) {
			customView->ShowAlert(NDCommonCString("InputNumRange"));
			return false;
		}
		
		price.second = yinliang;
	} else if (idTag == TAG_INPUT_YUANBAO) {
		string strYuanBao = customView->GetEditText(0);
		int yuanbao = atoi(strYuanBao.c_str());
		if (yuanbao <= 0 || yuanbao > MAX_EMONEY) {
			customView->ShowAlert(NDCommonCString("InputNumRange"));
			return false;
		}
		
		price.first = yuanbao;
	}
	
	if (this->PutItemToVendor(bagItem, price)) {
		this->m_bagItem->DelItem(bagItem->iID);
	}
	
	return true;
}

bool VendorUILayer::PutItemToVendor(Item* item, PAIR_VENDOR_ITEM_PRICE& price)
{
	if (!item) {
		return false;
	}
	Item* tempItem = NULL;
	for (NSUInteger r = 0; r < ITEM_ROW; r++) {
		for (NSUInteger c = 0; c < ITEM_COL; c++) {
			tempItem = this->m_btnVendorItem[r][c]->GetItem();
			if (tempItem == NULL) {
				this->m_btnVendorItem[r][c]->ChangeItem(item);
				this->m_mapItemPrice[item->iID] = price;
				return true;
			}
		}
	}
	return false;
}

void VendorUILayer::showSoldList()
{
	if (this->m_vSellItems.size() == 0) {
		showDialog(NDCommonCString("tip"), NDCommonCString("NoSellItem"));
		return;
	}
	
	NDUITableLayer* opt = new NDUITableLayer;
	opt->Initialization();
	opt->VisibleSectionTitles(false);
	
	int nHeight = 0;
	
	NDDataSource* ds = new NDDataSource;
	NDSection* sec = new NDSection;
	sec->SetRowHeight(42);
	ds->AddSection(sec);
	opt->SetDataSource(ds);
	
	ItemViewText* cell = NULL;
	
	Item* item = NULL;
	bool bChangeClr = false;
	for (VEC_ITEM_IT it = this->m_vSellItems.begin(); it != m_vSellItems.end(); it++) {
		stringstream ss;
		item = *it;
		// 查询价格
		PAIR_VENDOR_ITEM_PRICE& price = this->m_mapItemPrice[item->iID];
		ss << item->getItemName();
		if (price.first > 0) {
			ss << " " << NDCommonCString("emoney") << ":" << price.first;
		} else if (price.second > 0) {
			ss << " " << NDCommonCString("money") << ":" << price.second;
		}
		
		cell = new ItemViewText;
		cell->Initialization(item, ss.str().c_str(), CGSizeMake(250.0f, SOLD_LIST_CELL_HEIGHT));
		
		if (bChangeClr) {
			cell->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			cell->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		bChangeClr = !bChangeClr;
		
		sec->AddCell(cell);
		nHeight += SOLD_LIST_CELL_HEIGHT;
	}
	
	if (nHeight > SOLD_LIST_MAX_HEIGHT) {
		nHeight = SOLD_LIST_MAX_HEIGHT;
	}
	sec->SetFocusOnCell(0);
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	opt->SetFrameRect(CGRectMake((winSize.width - 250.0f) / 2, (winSize.height - nHeight) / 2, 250.0f, nHeight));
	
	this->m_optLayer = new NDOptLayer;
	this->m_optLayer->Initialization(opt);
	this->AddChild(m_optLayer);
}

void VendorUILayer::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->m_optLayer) {
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		} else {
			if (this->GetChild(TAG_VENDORING)) { // 摆摊中
				this->RemoveFromParent(false);
			} else { // 未摆摊
				if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameScene))) 
				{
					((GameScene*)(this->GetParent()))->SetUIShow(false);
				}
				this->RemoveFromParent(true);
			}
		}
	} else if (button == this->m_btnVendor) {
		if (m_btnVendor->GetTag() == TAG_VENDOR) { // 摆摊
			// 发送摆摊消息
			Item* item = NULL;
			vector<Item*> vItems;
			vector<PAIR_VENDOR_ITEM_PRICE> vPrices;
			for (NSUInteger r = 0; r < ITEM_ROW; r++) {
				for (NSUInteger c = 0; c < ITEM_COL; c++) {
					item = this->m_btnVendorItem[r][c]->GetItem();
					if (item != NULL) {
						vItems.push_back(item);
						vPrices.push_back(this->m_mapItemPrice[item->iID]);
					}
				}
			}
			
			if (vItems.size() > 0) {
				NDUISynLayer::Show();
				NDTransData bao(_MSG_BOOTH_APPLY);
				bao << Byte(vItems.size());
				for (size_t i = 0; i < vItems.size(); i++) {
					Item* item = vItems.at(i);
					bao << item->iID;
					PAIR_VENDOR_ITEM_PRICE& price = vPrices.at(i);
					bao << price.second << price.first;
				}
				SEND_DATA(bao);
			} else {
				showDialog(NDCommonCString("WenXinTip"), NDCommonCString("SelNoneItem"));
			}
			
		} else if (m_btnVendor->GetTag() == TAG_CANCEL) { // 取消
			NDUISynLayer::Show();
			NDTransData bao(_MSG_BOOTH);
			Byte data[9] = {
				BOOTH_REPEAL, 0, 0, 0, 0, 0, 0, 0, 0
			};
			
			for (int i = 0; i < 9; i++) {
				bao << data[i];
			}
			SEND_DATA(bao);
		}
	} else if (button == this->m_btnSoldList) {
		this->showSoldList();
	} else {
		for (uint r = 0; r < ITEM_ROW; r++) {
			for (uint c = 0; c < ITEM_COL; c++) {
				if (button == this->m_btnVendorItem[r][c]) {
					if (this->m_curFocusBtn == button && this->m_curFocusBtn->GetItem()) { // 显示取回选项
						NDUITableLayer* opt = new NDUITableLayer;
						opt->Initialization();
						opt->VisibleSectionTitles(false);
						opt->SetDelegate(this);
						opt->SetTag(TAG_VENDOR_OPT);
						
						CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
						opt->SetFrameRect(CGRectMake((winSize.width - 94) / 2, (winSize.height - 30) / 2, 94, 30));
						
						NDDataSource* ds = new NDDataSource;
						NDSection* sec = new NDSection;
						ds->AddSection(sec);
						opt->SetDataSource(ds);
						
						NDUIButton* btn = new NDUIButton;
						btn->Initialization();
						btn->SetTitle(NDCommonCString("QuXia"));
						btn->SetFocusColor(ccc4(253, 253, 253, 255));
						sec->AddCell(btn);
						
						sec->SetFocusOnCell(0);
						
						this->m_optLayer = new NDOptLayer;
						this->m_optLayer->Initialization(opt);
						this->AddChild(m_optLayer);
					} else { // 更新价格
						this->m_curFocusBtn = (NDUIItemButton*)button;
						Item* item = m_curFocusBtn->GetItem();
						PAIR_VENDOR_ITEM_PRICE price = item == NULL ? make_pair(0, 0) : this->m_mapItemPrice[item->iID];
						this->m_itemEMoney->SetSmallWhiteNumber(price.first, false);
						this->m_itemMoney->SetSmallWhiteNumber(price.second, false);
					}
				}
			}
		}
	}
}

void VendorUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	OBJID idTableTag = table->GetTag();
	switch (idTableTag) {
		case TAG_BAG_OPT:
		{
			Item* item = this->m_bagItem->GetFocusItem();
			if (!item) 
				break;
			
			OBJID idBtnTag = cell->GetTag();
			switch (idBtnTag) {
				case TAG_BTN_YINLIANG: // 银币
				{
					if (!item->isItemCanTrade()) 
					{
						NDUIDialog* dlg = new NDUIDialog();
						dlg->Initialization();
						dlg->Show(NDCommonCString("error"), NDCommonCString("TradeItemTip"), NULL, NULL);
						break;
					}
					
					NDUICustomView *view = new NDUICustomView;
					view->Initialization();
					view->SetTag(TAG_INPUT_YINLIANG);
					view->SetDelegate(this);
					std::vector<int> vec_id; vec_id.push_back(1);
					std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("SaleByMoney"));
					view->SetEdit(1, vec_id, vec_str);
					view->SetEditMaxLength(9, 0);
					view->Show();
					this->AddChild(view);
					
					this->m_optLayer->RemoveFromParent(true);
					this->m_optLayer = NULL;
				}
					break;
				case TAG_BTN_YUANBAO: // 金币
				{
					if (!item->isItemCanTrade()) 
					{
						NDUIDialog* dlg = new NDUIDialog();
						dlg->Initialization();
						dlg->Show(NDCommonCString("error"), NDCommonCString("TradeItemTip"), NULL, NULL);
						break;
					}
					
					NDUICustomView *view = new NDUICustomView;
					view->Initialization();
					view->SetTag(TAG_INPUT_YUANBAO);
					view->SetDelegate(this);
					std::vector<int> vec_id; vec_id.push_back(1);
					std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("SaleByEMoney"));
					view->SetEdit(1, vec_id, vec_str);
					view->SetEditMaxLength(9, 0);
					view->Show();
					this->AddChild(view);
					this->m_optLayer->RemoveFromParent(true);
					this->m_optLayer = NULL;
				}
					break;
				case TAG_BTN_DETAIL: // 详细
				{
					if (item) {
						if (item->isFormula() || item->isItemPet() || item->isSkillBook()) {
							sendQueryDesc(item->iID);
						} else {
							GlobalShowDlg(item->getItemName(), item->makeItemDes(false, false));
						}
					}
				}
					break;
				default:
					break;
			}
		}
			break;
		case TAG_VENDOR_OPT: // 取回
		{
			if (this->m_curFocusBtn) {
				Item* item = this->m_curFocusBtn->GetItem();
				this->m_curFocusBtn->ChangeItem(NULL);
				this->m_bagItem->AddItem(item);
				this->m_itemEMoney->SetSmallWhiteNumber(0, false);
				this->m_itemMoney->SetSmallWhiteNumber(0, false);
				this->m_mapItemPrice.erase(item->iID);
			}
			this->m_optLayer->RemoveFromParent(true);
			this->m_optLayer = NULL;
		}
			break;
		default:
			break;
	}
}