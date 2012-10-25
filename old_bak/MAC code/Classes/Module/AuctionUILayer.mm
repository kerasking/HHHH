/*
 *  AuctionUILayer.mm
 *  DragonDrive
 *
 *  Created by wq on 11-4-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "AuctionUILayer.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "SocialTextLayer.h"
#include "ItemViewText.h"
#include "Auction_Item.h"
#include "NDUISynLayer.h"
#include "Auction_Item.h"
#include "AuctionDef.h"
#include "GlobalDialog.h"
#include <sstream>
using namespace std;

enum {
	AUCTION_CELL_HEIGHT = 43,
};

enum {
	TAG_DLG_SHANG_JIA = 1,
	TAG_DLG_PRICE = 2,
	TAG_PRICE_MONEY = 3,
	TAG_PRICE_EMONEY = 4,
	TAG_DLG_XIA_JIA,
	TAG_DLG_CHU_JIA,
	TAG_BID_ITEM,
};

IMPLEMENT_CLASS(AuctionUILayer, NDUIMenuLayer)

AuctionUILayer* AuctionUILayer::s_instance = NULL;

void AuctionUILayer::Show(int type)
{
	if (!s_instance) {
		NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameScene))) {
			GameScene* gameScene = (GameScene*)scene;
			AuctionUILayer *list = new AuctionUILayer;
			list->Initialization();
			gameScene->AddChild(list, UILAYER_Z);
			gameScene->SetUIShow(true);
		} else {
			return;
		}
	}
	
	if (s_instance) {
		s_instance->queryType = type;
	}
}

Auction_Item* AuctionUILayer::getAuctionItem(int itemID)
{
	for (VEC_AUCTION_ITEM_IT it = m_vElement.begin(); it != m_vElement.end(); it++) {
		if ((*it)->iID == itemID) {
			return *it;
		}
	}
	return NULL;
}

bool AuctionUILayer::processItemDescQuery(NDTransData& data)
{
	if (s_instance) {
		int idItem = 0; data >> idItem;
		std::string strContent = data.ReadUnicodeString();
		
		Item *item = s_instance->m_itemBag->GetFocusItem();
		if (item && item->iID == idItem) {
			vector<string> vStrOpt;
			vStrOpt.push_back(NDCommonCString("ShangJia"));
			
			NDUIDialog *dlgItemOpt = new NDUIDialog;
			dlgItemOpt->Initialization();
			dlgItemOpt->SetTag(TAG_DLG_SHANG_JIA);
			dlgItemOpt->SetDelegate(s_instance);
			dlgItemOpt->Show(item->getItemNameWithAdd().c_str(),
				  strContent.c_str(), NDCommonCString("return"), vStrOpt);
		} else {
			Auction_Item* aucItem = s_instance->getAuctionItem(idItem);
			if (aucItem) {
				// 显示操作选项
				string des = aucItem->getAuctionItemStr(strContent, false, true);
				stringstream sb;
				sb << aucItem->getItemName();
				if (aucItem->iAddition > 0) {
					sb << "+" << aucItem->iAddition;
				}
				
				NDUIDialog* dlgOpt = new NDUIDialog;
				dlgOpt->Initialization();
				
				NDPlayer& role = NDPlayer::defaultHero();
				string strOpt;
				OBJID idTag = TAG_DLG_XIA_JIA;
				if (role.m_id == aucItem->iOwnerID) {
					strOpt = (NDCommonCString("XiaJia"));
				} else {
					idTag = TAG_DLG_CHU_JIA;
					strOpt = (NDCString("ChuJiaJingPai"));
				}
				
				dlgOpt->SetDelegate(s_instance);
				dlgOpt->SetTag(idTag);
				dlgOpt->Show(sb.str().c_str(), des.c_str(), NDCommonCString("return"), strOpt.c_str(), NDCommonCString("ChaKang"), NULL);
			}
		}
		
		return true;
	}
	return false;
}

void AuctionUILayer::OnAuctioin(NDTransData& data)
{
	CloseProgressBar;
	int action = data.ReadByte();
	int intValue1 = data.ReadInt();
	int intValue2 = data.ReadInt();
	
	if ((action != AUCTION_BIDDEN) &&
	    (action != AUCTION_UP_TRUE)) {
		m_btnPage->SetPages(m_btnPage->GetCurPage(), intValue2);
	}
	
	switch (action) {
		case AUCTION_DOWN:
			this->deleteItem(intValue1);
			break;
		case AUCTION_BIDDEN:
			GlobalShowDlg(NDCommonCString("tip"), NDCString("ChuJiaSucess"));
			break;
		case AUCTION_UP_TRUE:
			this->addUpAuctionItem(intValue2);
			GlobalShowDlg(NDCommonCString("tip"), NDCString("ShanJiaTip"));
			break;
		case AUCTION_A_PRICE:
			this->deleteItem(intValue1);
			GlobalShowDlg(NDCommonCString("tip"), NDCString("PaiTip"));
			break;
	}
}

void AuctionUILayer::deleteItem(int itemID) {
	for (VEC_AUCTION_ITEM_IT it = m_vElement.begin(); it != m_vElement.end(); it++) {
		if ((*it)->iID == itemID) {
			SAFE_DELETE(*it);
			m_vElement.erase(it);
			this->refreshMainList();
			break;
		}
	}
}

void AuctionUILayer::addUpAuctionItem(int priceType) {
	if (m_vElement.size() < 5) {
		NDPlayer& role = NDPlayer::defaultHero();
		Auction_Item* aucItem = new Auction_Item(tobeUpItem.iItemType);
		m_vElement.push_back(aucItem);
		aucItem->iID = tobeUpItem.iID;
		aucItem->iOwnerID = tobeUpItem.iOwnerID;
		aucItem->iItemType = tobeUpItem.iItemType;
		aucItem->itemBidderID = role.m_id;
		aucItem->iAmount = tobeUpItem.iAmount;
		NSDate *upDate = [NSDate date];
		aucItem->time = [upDate timeIntervalSince1970];
		aucItem->minPrice = this->m_qipai;
		aucItem->maxPrice = this->m_yikou;
		aucItem->byHole = tobeUpItem.byHole;
		aucItem->iAddition = tobeUpItem.iAddition;
		// /** 0金币 1银币 */
		aucItem->payType = priceType;
		aucItem->bidderName = role.m_name;
		
		this->refreshMainList();
	}
}

void AuctionUILayer::processAuction(NDTransData& data)
{
	if (s_instance) {
		s_instance->OnAuctioin(data);
	}
}

void AuctionUILayer::OnAuctionInfo(NDTransData& data)
{
	CloseProgressBar;
	int itemNum = data.ReadByte();
	for (int k = 0; k < itemNum; k++) {
		int iRecord = data.ReadByte();
		if (iRecord == 0) {
			this->releaseElement();
		}
		
		int idItem = data.ReadInt();
		int idOwner = data.ReadInt();
		int idItemType = data.ReadInt();
		
		Auction_Item* aucItem = new Auction_Item(idItemType);
		this->m_vElement.push_back(aucItem);
		
		aucItem->iID = idItem;
		aucItem->iOwnerID = idOwner;
		aucItem->itemBidderID = data.ReadInt();
		aucItem->iAmount = data.ReadInt();
		aucItem->time = data.ReadInt();
		aucItem->minPrice = data.ReadInt();
		aucItem->maxPrice = data.ReadInt();
		aucItem->iAddition = data.ReadByte();
		aucItem->byHole = data.ReadByte();
		aucItem->payType = data.ReadByte();
		
		int stoneAmount = data.ReadByte();
		aucItem->bidderName = data.ReadUnicodeString();
		
		if (stoneAmount > 0) {
			for (int i = 0; i < stoneAmount; i++) {
				aucItem->AddStone(data.ReadInt());
			}
		}
		
		aucItem->seq = iRecord;
	}
	
	this->refreshMainList();
}

void AuctionUILayer::processAuctionInfo(NDTransData& data)
{
	if (s_instance) {
		s_instance->OnAuctionInfo(data);
	}
}

void AuctionUILayer::releaseElement()
{
	for (VEC_AUCTION_ITEM_IT it = this->m_vElement.begin(); it != this->m_vElement.end(); it++) {
		SAFE_DELETE(*it);
	}
	m_vElement.clear();
}

void AuctionUILayer::refreshMainList()
{
	// 清除相关数据
	this->m_curSelEle = NULL;
	
	if (this->m_optLayer) {
		this->m_optLayer->RemoveFromParent(true);
		this->m_optLayer = NULL;
	}
	
	NDDataSource *ds = m_tlMain->GetDataSource();
	ds->Clear();
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	sec->SetRowHeight(42);
	
	bool bChangeClr = false;
	ItemViewText* cell = NULL;
	Auction_Item* item = NULL;
	int n = 0;
	for (VEC_AUCTION_ITEM_IT it = m_vElement.begin(); it != m_vElement.end(); it++) {
		n++;
		item = *it;
		cell = new ItemViewText;
		cell->Initialization(item, item->getAuctionItemStr(true, false, false).c_str(), CGSizeMake(198, AUCTION_CELL_HEIGHT));
		
		if (bChangeClr) {
			cell->SetBackgroundColor(INTCOLORTOCCC4(0xc3d2d5));
		} else {
			cell->SetBackgroundColor(INTCOLORTOCCC4(0xe3e5da));
		}
		
		bChangeClr = !bChangeClr;
		sec->AddCell(cell);
	}
	sec->SetFocusOnCell(0);
	
	NDUIRecttangle* cellEmpty = NULL;
	for (; n < 5; n++) {
		cellEmpty = new NDUIRecttangle;
		cellEmpty->Initialization();
		cellEmpty->SetColor(ccc4(231, 231, 222, 255));
		sec->AddCell(cellEmpty);
	}
	
	this->m_tlMain->ReflashData();
}

AuctionUILayer::AuctionUILayer()
{
	NDAsssert(s_instance == NULL);
	s_instance = this;
	this->m_tlMain = NULL;
	this->m_curSelEle = NULL;
	this->m_optLayer = NULL;
	this->m_btnPage = NULL;
	this->m_itemBag = NULL;
	m_qipai = 0;
	m_yikou = 0;
}

AuctionUILayer::~AuctionUILayer()
{
	s_instance = NULL;
	this->releaseElement();
}

void AuctionUILayer::OnButtonClick(NDUIButton* button)
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
				this->RemoveFromParent(true);
			}
		}
	}
}

void AuctionUILayer::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (this->m_tlMain == table) {
		if (cell->IsKindOfClass(RUNTIME_CLASS(ItemViewText))) {
			this->m_curSelEle = (Auction_Item*)((ItemViewText*)cell)->GetItem();
			if (this->m_curSelEle) {
				if (m_curSelEle->isFormula() || m_curSelEle->isSkillBook()) {
					sendQueryDesc(m_curSelEle->iID);
				} else {
					// 显示操作选项
					string des = m_curSelEle->getAuctionItemStr(false, true, true);
					stringstream sb;
					sb << m_curSelEle->getItemName();
					if (m_curSelEle->iAddition > 0) {
						sb << "+" << m_curSelEle->iAddition;
					}
					
					NDUIDialog* dlgOpt = new NDUIDialog;
					dlgOpt->Initialization();
					
					NDPlayer& role = NDPlayer::defaultHero();
					string strOpt;
					OBJID idTag = TAG_DLG_XIA_JIA;
					if (role.m_id == m_curSelEle->iOwnerID) {
						strOpt = (NDCommonCString("XiaJia"));
					} else {
						idTag = TAG_DLG_CHU_JIA;
						strOpt = (NDCString("ChuJiaJingPai"));
					}
					
					dlgOpt->SetDelegate(this);
					dlgOpt->SetTag(idTag);
					dlgOpt->Show(sb.str().c_str(), des.c_str(), NDCommonCString("return"), strOpt.c_str(), NDCommonCString("ChaKang"), NULL);
				}
			}
		}
	}
}

void AuctionUILayer::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	OBJID idTag = dialog->GetTag();
	switch (idTag) {
		case TAG_DLG_SHANG_JIA:
		{
			if (buttonIndex == 0)
			{ // 上架
				NDUIDialog* dlgPrice = new NDUIDialog;
				dlgPrice->Initialization();
				//dlgPrice->SetWidth(130);
				dlgPrice->SetDelegate(this);
				dlgPrice->SetTag(TAG_DLG_PRICE);
				dlgPrice->Show(NULL, NDCommonCString("SelectMoneyType"), NULL, NDCommonCString("money"), NDCommonCString("emoney"), NULL);
			}
			else if (buttonIndex == 1)
			{ // 查看
				Item *item = m_itemBag->GetFocusItem();
				if (!item) break;
				
				if (item->isItemPet() || item->isFormula() || item->isSkillBook()) {
					sendQueryDesc(item->iID);
				}
				else 
				{
					showDialog(item->getItemNameWithAdd().c_str(), 
							item->makeItemDes(false, true).c_str());
				}

			}
		}
			break;
		case TAG_DLG_PRICE:
		{
			if (buttonIndex == 0) {
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetTag(TAG_PRICE_MONEY);
				view->SetDelegate(this);
				std::vector<int> vec_id;
				vec_id.push_back(1);
				vec_id.push_back(2);
				std::vector<std::string> vec_str;
				vec_str.push_back(NDCString("QiPaiPrice"));
				vec_str.push_back(NDCString("YiKouPrice"));
				view->SetEdit(2, vec_id, vec_str);
				view->Show();
				this->AddChild(view);
			} else if (buttonIndex == 1) {
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetTag(TAG_PRICE_EMONEY);
				view->SetDelegate(this);
				std::vector<int> vec_id;
				vec_id.push_back(1);
				vec_id.push_back(2);
				std::vector<std::string> vec_str;
				vec_str.push_back(NDCString("QiPaiEPrice"));
				vec_str.push_back(NDCString("YiKouEPrice"));
				view->SetEdit(2, vec_id, vec_str);
				view->Show();
				this->AddChild(view);
			}
		}
			break;
		case TAG_PRICE_MONEY:
		case TAG_PRICE_EMONEY:
		{
			Item *item = this->m_itemBag->GetFocusItem();
			if (item) {
				this->tobeUpItem = *item;
				ShowProgressBar;
				NDTransData bao(_MSG_SHELVE);
				bao << item->iID << this->m_qipai << this->m_yikou
				<< (idTag == TAG_PRICE_MONEY ? Byte(1) : Byte(0));
				SEND_DATA(bao);
				this->m_itemBag->DelItem(item->iID);
			}
		}
			break;
		case TAG_DLG_XIA_JIA:
		{
			if (!m_curSelEle)
			{
				break;
			}
			if (buttonIndex == 1)
			{ // 查看
				Item *item = m_curSelEle;
				if (!item) return;
				
				if (item->isItemPet() || item->isFormula() || item->isSkillBook()) {
					sendQueryDesc(item->iID);
				}
				else 
				{
					showDialog(item->getItemNameWithAdd().c_str(), 
							   item->makeItemDes(false, true).c_str());
				}
			}
			else if (buttonIndex == 0)
			{
				NDTransData bao(_MSG_AUCTION);
				bao << Byte(AUCTION_DOWN) << m_curSelEle->iID << 0;
				SEND_DATA(bao);
				ShowProgressBar;
			}
		}
			break;
		case TAG_DLG_CHU_JIA:
		{
			if (!m_curSelEle)
			{
				break;
			}
			if (buttonIndex == 1)
			{ // 查看
				Item *item = m_curSelEle;
				if (!item) return;
				
				if (item->isItemPet() || item->isFormula() || item->isSkillBook()) {
					sendQueryDesc(item->iID);
				}
				else 
				{
					showDialog(item->getItemNameWithAdd().c_str(), 
							   item->makeItemDes(false, true).c_str());
				}
			}
			else if (buttonIndex == 0)
			{
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetTag(TAG_BID_ITEM);
				view->SetDelegate(this);
				std::vector<int> vec_id;
				vec_id.push_back(1);
				std::vector<std::string> vec_str;
				vec_str.push_back(NDCString("InputPaiPrice"));
				view->SetEdit(1, vec_id, vec_str);
				
				stringstream ss;
				ss << (m_curSelEle->minPrice + 1);
				view->SetEditText(ss.str().c_str(), 0);
				view->Show();
				this->AddChild(view);
			}
		}
			break;
		default:
			break;
	}
	dialog->Close();
}

bool AuctionUILayer::OnCustomViewConfirm(NDUICustomView* customView)
{
	VerifyViewNum(*customView);
	
	OBJID idTag = customView->GetTag();
	switch (idTag) {
		case TAG_PRICE_MONEY:
		case TAG_PRICE_EMONEY:
		{
			VerifyViewNum1(*customView);
			// 校验价格
			string strQipai = customView->GetEditText(0);
			string strYikou = customView->GetEditText(1);
			bool bStrError = false;
			
			if (strQipai.empty() || strYikou.empty()) {
				bStrError = true;
			} else {
				for (string::iterator it = strQipai.begin(); it != strQipai.end(); it++) {
					if (!(*it >= '0' && *it <= '9')) {
						bStrError = true;
						break;
					}
				}
				for (string::iterator it = strYikou.begin(); it != strYikou.end(); it++) {
					if (!(*it >= '0' && *it <= '9')) {
						bStrError = true;
						break;
					}
				}
			}

			if (bStrError) {
				customView->ShowAlert(NDCommonCString("NumberRequireTip"));
				return false;
			}
			m_qipai = atoi(strQipai.c_str());
			m_yikou = atoi(strYikou.c_str());
			
			if (m_qipai < 0 || m_qipai > 1999999999) {
				customView->ShowAlert(NDCString("ReinputTip1"));
				return false;
			}
			
			if (m_yikou < 0 || m_yikou > 2000000000) {
				customView->ShowAlert(NDCString("ReinputTip2"));
				return false;
			}
			
			if (m_yikou <= m_qipai) {
				customView->ShowAlert(NDCString("YiKouTip"));
				return false;
			}
			
			// 上架确认提示
			NDUIDialog* dlgConfirm = new NDUIDialog;
			dlgConfirm->Initialization();
			dlgConfirm->SetTag(idTag);
			dlgConfirm->SetDelegate(this);
			string dlgTitle = idTag == TAG_PRICE_MONEY ? NDCommonCString("money") : NDCommonCString("emoney");
			stringstream sb;
			sb << NDCommonCString("QiPaiPrice") << ":" << m_qipai << "\n" << NDCommonCString("YiKouPrice") << ":";
			if (m_yikou == 0) {
				sb << NDCommonCString("unlimit");
			} else {
				sb << (m_yikou);
			}
			dlgConfirm->Show(dlgTitle.c_str(), sb.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
		}
			break;
		case TAG_BID_ITEM:
		{
			string strBidPrice = customView->GetEditText(0);
			
			NDPlayer& role = NDPlayer::defaultHero();
			int roleMoney = m_curSelEle->payType == 0 ? role.eMoney : role.money;
			
			int bidPrice = atoi(strBidPrice.c_str());
			if (bidPrice <= 0) {
				customView->ShowAlert(NDCString("InputPriceError"));
				return false;
			} else if (bidPrice > roleMoney) {
				customView->ShowAlert(NDCString("InputMoneyError"));
				return false;
			}
			
			NDTransData bao(_MSG_AUCTION);
			bao << Byte(AUCTION_BIDDEN) << m_curSelEle->iID << bidPrice;
			SEND_DATA(bao);
		}
			break;
		default:
			break;
	}
	
	return true;
}

void AuctionUILayer::Initialization()
{
	NDUIMenuLayer::Initialization();
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	NDUILabel* title = new NDUILabel;
	title->Initialization();
	title->SetText(NDCString("PaiMaiHang"));
	title->SetFontSize(15);
	title->SetTextAlignment(LabelTextAlignmentCenter);
	title->SetFrameRect(CGRectMake(0, 5, winsize.width, 15));
	title->SetFontColor(ccc4(255, 240, 0,255));
	this->AddChild(title);
	
	this->m_tlMain = new NDUITableLayer;
	m_tlMain->Initialization();
	m_tlMain->SetDelegate(this);
	m_tlMain->SetFrameRect(CGRectMake(5, 31, 198, 215));
	m_tlMain->VisibleSectionTitles(false);
	m_tlMain->SetBackgroundColor(ccc4(255, 255, 255, 0));
	this->AddChild(m_tlMain);
	
	NDDataSource *ds = new NDDataSource;
	m_tlMain->SetDataSource(ds);
	
	NDSection* sec = new NDSection;
	ds->AddSection(sec);
	sec->SetRowHeight(42);
	
	NDUIRecttangle* cell = NULL;
	for (int i = 0; i < 5; i++) {
		cell = new NDUIRecttangle;
		cell->Initialization();
		cell->SetColor(ccc4(231, 231, 222, 255));
		sec->AddCell(cell);
	}
	sec->SetFocusOnCell(0);
	m_btnPage = new NDPageButton;
	m_btnPage->Initialization(CGRectMake(26.0f, 250.0f, 160.0f, 24.0f));
	m_btnPage->SetDelegate(this);
	this->AddChild(m_btnPage);
	
	std::vector<Item*>& itemlist = ItemMgrObj.GetPlayerBagItems();
	this->m_itemBag = new GameItemBag;
	m_itemBag->Initialization(itemlist);
	m_itemBag->SetDelegate(this);
	m_itemBag->SetPageCount(ItemMgrObj.GetPlayerBagNum());
	m_itemBag->SetFrameRect(CGRectMake(203, 31, ITEM_BAG_W, ITEM_BAG_H));
	m_itemBag->SetTitleColor(ccc4(255, 255, 255, 255));
	this->AddChild(m_itemBag);
}

void AuctionUILayer::OnPageChange(int nCurPage, int nTotalPage)
{
	ShowProgressBar;
	NDTransData bao(_MSG_AUCTION);
	if (this->queryType == 3) {
		bao << Byte(AUCTION_QUEST);
	} else {
		bao << Byte(AUCTION_PAGE);
	}
	bao << (0);
	bao << (nCurPage);
	SEND_DATA(bao);
}

bool AuctionUILayer::OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)
{
	if (bFocused && item) {
		if (item->isItemCanTrade()) {
//			if (item->isItemPet() || item->isFormula() || item->isSkillBook()) {
//				sendQueryDesc(item->iID);
//			} else 
			{
				// 显示操作选项
				vector<string> vStrOpt;
				vStrOpt.push_back(NDCommonCString("ShangJia"));
				vStrOpt.push_back(NDCommonCString("ChaKang"));
				NDUIDialog* dlgItemOpt = item->makeItemDialog(vStrOpt);
				dlgItemOpt->SetTag(TAG_DLG_SHANG_JIA);
				dlgItemOpt->SetDelegate(this);
			}
		} else {
			showDialog(NDCommonCString("tip"), NDCString("ItemPaiError"));
		}

	}
	return false;
}
