/* *  BattleFieldShop.mm *  DragonDrive * *  Created by jhzheng on 11-11-3. *  Copyright 2011 __MyCompanyName__. All rights reserved. * */#include "BattleFieldShop.h"#include "NDUtility.h"#include "NDCommonControl.h"#include "ItemImage.h"#include "NDPlayer.h"#include "NDTransData.h"#include "NDDataTransThread.h"#include "NDUISynLayer.h"#include "NDPath.h"#include "NDMsgDefine.h"#include "ItemMgr.h"#include <sstream>#pragma mark 战场商店信息#define max_buy_count (100)IMPLEMENT_CLASS(BattleFieldShopInfo, NDUILayer)BattleFieldShopInfo::BattleFieldShopInfo(){	m_btnCurItemButton = NULL;		m_lbItemName = m_lbItemLvl = NULL;		m_imgMedal = m_imgRepute = NULL;		m_lbReqMedal = m_lbReqRepute = NULL;		m_descScroll = NULL;		m_slide = NULL;		m_btnBuy = NULL;		memset(m_btnGood, 0, sizeof(m_btnGood));		m_lbMedal = m_lbRepute = NULL;		m_btnPrev = m_btnNext = NULL;		m_lbPage = NULL;		m_iCurPage = 0;		m_iShopType = 0;		m_iCurItemType = 0;}BattleFieldShopInfo::~BattleFieldShopInfo(){}void BattleFieldShopInfo::Initialization(int shopType){	NDAsssert(BattleField::mapItemInfo.find(shopType) != BattleField::mapItemInfo.end());		m_iShopType = shopType;	NDUILayer::Initialization();		InitAttrPanel();		InitItemPanel();		UpdateCurpageGoods();		OnButtonClick(m_btnGood[0]);		Update();}void BattleFieldShopInfo::OnButtonClick(NDUIButton* button){	if (button == m_btnNext)	{		ShowNext();	}	else if (button == m_btnPrev)	{		ShowPrev();	}	else if (button == m_btnBuy)	{		DealBuy();	}	else	{		OnClickGoodItem(button);	}}void BattleFieldShopInfo::Update() // 包括AttrPanel, 令牌, 荣誉值{	UpdateAttrPanel();		UpdateReputeAndMedal();}void BattleFieldShopInfo::InitAttrPanel(){	NDPicturePool& pool = *(NDPicturePool::DefaultPool());		NDPicture* picBagLeftBg = pool.AddPicture(NDPath::GetImgPathNew("bag_left_bg.png"));		CGSize sizeBagLeftBg = picBagLeftBg->GetSize();		NDUILayer *layer = new NDUILayer;	layer->Initialization();	layer->SetBackgroundImage(picBagLeftBg, true);	layer->SetFrameRect(CGRectMake(0, 12, sizeBagLeftBg.width, sizeBagLeftBg.height));	this->AddChild(layer);		m_btnCurItemButton = new NDUIItemButton;	m_btnCurItemButton->Initialization();	m_btnCurItemButton->ShowItemCount(false);	m_btnCurItemButton->SetFrameRect(CGRectMake(18, 14, 42, 42));	layer->AddChild(m_btnCurItemButton);		m_lbItemName = new NDUILabel;	m_lbItemName->Initialization();	m_lbItemName->SetTextAlignment(LabelTextAlignmentLeft);	m_lbItemName->SetFontSize(18);	m_lbItemName->SetFrameRect(CGRectMake(73, 14, 200, 20));	//m_lbItemName->SetText("天宫战斧");	m_lbItemName->SetFontColor(ccc4(136, 41, 41, 255));	layer->AddChild(m_lbItemName);		m_lbItemLvl = new NDUILabel;	m_lbItemLvl->Initialization();	m_lbItemLvl->SetTextAlignment(LabelTextAlignmentLeft);	m_lbItemLvl->SetFontSize(16);	m_lbItemLvl->SetFrameRect(CGRectMake(73, 38, 200, 20));	//m_lbItemLvl->SetText("等级需求: 14级");	m_lbItemLvl->SetFontColor(ccc4(136, 41, 41, 255));	layer->AddChild(m_lbItemLvl);		m_imgMedal = new NDUIImage;	m_imgMedal->Initialization();	m_imgMedal->SetFrameRect(CGRectMake(18, 65, 23, 23));	layer->AddChild(m_imgMedal);		m_lbReqMedal = new NDUILabel;	m_lbReqMedal->Initialization();	m_lbReqMedal->SetTextAlignment(LabelTextAlignmentLeft);	m_lbReqMedal->SetFontSize(14);	m_lbReqMedal->SetFrameRect(CGRectMake(55, 70, 200, 20));	m_lbReqMedal->SetText("8888888");	layer->AddChild(m_lbReqMedal);		m_imgRepute = new NDUIImage;	m_imgRepute->Initialization();	m_imgRepute->SetFrameRect(CGRectMake(112, 65, 23, 23));	layer->AddChild(m_imgRepute);		m_lbReqRepute = new NDUILabel;	m_lbReqRepute->Initialization();	m_lbReqRepute->SetTextAlignment(LabelTextAlignmentLeft);	m_lbReqRepute->SetFontSize(14);	m_lbReqRepute->SetFrameRect(CGRectMake(139, 70, 200, 20));	m_lbReqRepute->SetText("8888888");	layer->AddChild(m_lbReqRepute);		NDPicture *picCut = pool.AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png"));		CGSize sizeCut = picCut->GetSize();		NDUIImage* imageCut = new NDUIImage;	imageCut->Initialization();	imageCut->SetPicture(picCut, true);	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, 95, sizeCut.width, sizeCut.height));	imageCut->EnableEvent(false);	layer->AddChild(imageCut);		picCut = pool.AddPicture(NDPath::GetImgPathNew("bag_left_fengge.png"));	imageCut = new NDUIImage;	imageCut->Initialization();	imageCut->SetPicture(picCut, true);	imageCut->SetFrameRect(CGRectMake((sizeBagLeftBg.width-sizeCut.width)/2, 175, sizeCut.width, sizeCut.height));	imageCut->EnableEvent(false);	layer->AddChild(imageCut);		m_descScroll = new NDUIContainerScrollLayer;	m_descScroll->Initialization();	m_descScroll->SetFrameRect(CGRectMake(10, 100, sizeBagLeftBg.width-20, 70));	layer->AddChild(m_descScroll);		SetDescContent("");		m_slide = new NDSlideBar;	m_slide->Initialization(CGRectMake(0, 180, sizeBagLeftBg.width-10, 44), 127, true);	m_slide->SetMin(0);	m_slide->SetMax(0);	m_slide->SetCur(0);	layer->AddChild(m_slide);		m_btnBuy = new NDUIButton;	m_btnBuy->Initialization();	m_btnBuy->SetFrameRect(CGRectMake(7, 228, 48, 24));	m_btnBuy->SetFontColor(ccc4(255, 255, 255, 255));	m_btnBuy->SetFontSize(12);	m_btnBuy->CloseFrame();	m_btnBuy->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png")),							  pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")),							  false, CGRectZero, true);	m_btnBuy->SetTitle(NDCommonCString("buy"));	m_btnBuy->SetDelegate(this);							 		layer->AddChild(m_btnBuy);}void BattleFieldShopInfo::InitItemPanel(){	NDPicturePool& pool = *(NDPicturePool::DefaultPool());		int startX = 217, startY = 17,		intervalW = 4, intervalH = 5,		itemW = 42, itemH = 42;		for (int i = 0; i < max_btns; i++) 	{		int x = startX+(i % col)*(itemW+intervalW),			y = startY+(i / col)*(itemH+intervalH);		NDUIItemButton*& btn = m_btnGood[i];		btn = new NDUIItemButton;		btn->Initialization();		btn->SetDelegate(this);		btn->SetFrameRect(CGRectMake(x, y, itemW, itemH));		this->AddChild(btn);	}		NDUILayer* backlayer = new NDUILayer;	backlayer->Initialization();	backlayer->SetBackgroundColor(ccc4(129, 98, 54, 255));	backlayer->SetFrameRect(CGRectMake(startX, startY+(max_btns/col)*(itemH+intervalH), itemW*col+intervalW*(col-1), 20));	backlayer->SetTouchEnabled(false);	this->AddChild(backlayer);			NDPicture *picEMoney = pool.AddPicture(NDPath::GetImgPathNew("bag_bagemoney.png"));	NDPicture *picMoney = pool.AddPicture(NDPath::GetImgPathNew("bag_bagmoney.png"));		unsigned int interval = 8;		NDPicture* tmpPics[2];	tmpPics[0] = picEMoney;	tmpPics[1] = picMoney; 		int width = backlayer->GetFrameRect().size.width,		height = backlayer->GetFrameRect().size.height,		framewidth = width/2;		for (int i = 0; i < 2; i++) 	{		CGSize sizePic = tmpPics[i]->GetSize();		int startx = (i == 0 ? interval : interval+framewidth),			imageY = (height-sizePic.height)/2,			numY = (height-14)/2;		NDUIImage *image = new NDUIImage;		image->Initialization();		image->SetPicture(tmpPics[i], true);		image->SetFrameRect(CGRectMake(startx, imageY, sizePic.width,sizePic.height));		backlayer->AddChild(image);				NDUILabel *tmpLable = NULL;		if (i == 0)		{			tmpLable = m_lbMedal = new NDUILabel; 		}		else if (i == 1)		{			tmpLable = m_lbRepute = new NDUILabel; 		}				if (tmpLable == NULL) continue;				tmpLable->Initialization();		tmpLable->SetTextAlignment(LabelTextAlignmentLeft);		tmpLable->SetFontSize(14);		tmpLable->SetFrameRect(CGRectMake(startx+sizePic.width+interval, numY, width, height));		tmpLable->SetText("8888888");		tmpLable->SetFontColor(ccc4(255, 255, 255, 255));		backlayer->AddChild(tmpLable);	}		m_btnPrev = new NDUIButton;	m_btnPrev->Initialization();	m_btnPrev->SetFrameRect(CGRectMake(startX+10, 232, 36, 36));	m_btnPrev->SetDelegate(this);	m_btnPrev->SetImage(pool.AddPicture(NDPath::GetImgPathNew("pre_page.png")), true, CGRectMake(0, 4, 36, 31), true);	m_btnPrev->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);	this->AddChild(m_btnPrev);		m_btnNext = new NDUIButton;	m_btnNext->Initialization();	m_btnNext->SetFrameRect(CGRectMake(backlayer->GetFrameRect().origin.x										   +backlayer->GetFrameRect().size.width-10-36, 										   232, 36, 36));	m_btnNext->SetDelegate(this);	m_btnNext->SetImage(pool.AddPicture(NDPath::GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);	m_btnNext->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);	this->AddChild(m_btnNext);		m_lbPage = new NDUILabel;	m_lbPage->Initialization();	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter);	m_lbPage->SetFontSize(16);	m_lbPage->SetFontColor(ccc4(136, 41, 41, 255));	m_lbPage->SetFrameRect(CGRectMake(m_btnPrev->GetFrameRect().origin.x, 									  m_btnPrev->GetFrameRect().origin.y, 									  m_btnNext->GetFrameRect().origin.x									  +m_btnNext->GetFrameRect().size.width									  -m_btnPrev->GetFrameRect().origin.x, 									  m_btnPrev->GetFrameRect().size.height));	m_lbPage->SetText("8888888");	this->AddChild(m_lbPage);}void BattleFieldShopInfo::ChangeAttrPanel(int bfItemType){	Item *item = NULL;		if (bfItemType > 0)		item = new Item(bfItemType);		m_btnCurItemButton->ChangeItem(item);		std::stringstream itemName, itemReqLvl;		if (item)	{		itemName << item->getItemName();				itemReqLvl << NDCommonCString("LevelRequire") << ": " << item->getReq_level() << NDCommonCString("Ji");	}		m_lbItemName->SetText(itemName.str().c_str());		m_lbItemLvl->SetText(itemReqLvl.str().c_str());		std::stringstream medal, repute;		BFItemInfo bfItemInfo;	if (GetBattleFieldItemInfo(bfItemType, bfItemInfo))	{		medal << bfItemInfo.medalReq;				repute << bfItemInfo.honourReq;				m_imgMedal->SetPicture(ItemImage::GetItemPicByType(bfItemInfo.medalItemType), true);	}	else 	{		m_imgMedal->SetPicture(NULL, true);	}		m_lbReqMedal->SetText(medal.str().c_str());		m_lbReqRepute->SetText(repute.str().c_str());	std::stringstream desc;		if (item)	{		desc << item->makeItemDes(false, true);	}		SetDescContent(desc.str().c_str());		if (!this->IsVisibled())	{		m_descScroll->SetVisible(false);	}	SetBuyCount(0, GetCanBuyMaxCount(bfItemType));	}int  BattleFieldShopInfo::GetAttrPanelBFItemType(){	return m_iCurItemType;}void BattleFieldShopInfo::DealBuy(){	Item* item = m_btnCurItemButton->GetItem();		if (!item) return;		int curBuyCount = GetCurBuyCount();	if (!CheckBuyCount(curBuyCount))	{		showDialog(NDCommonCString("tip"), NDCommonCString("BuyCountError"));		return;	}		ShowProgressBar;	NDTransData bao(_MSG_SHOP);	bao << int(item->iItemType) << int(0xffffffff) << (unsigned char)Item::_SHOPACT_BUY << (unsigned char)curBuyCount;	SEND_DATA(bao);}int BattleFieldShopInfo::GetCurBuyCount(){	return m_slide->GetCur();}int BattleFieldShopInfo::GetCanBuyMaxCount(int bfItemType){	int maxBuyCount = 0;		BFItemInfo bfItemInfo;		if (GetBattleFieldItemInfo(bfItemType, bfItemInfo))	{		NDPlayer& player = NDPlayer::defaultHero();				int playerMedalCount = GetMedalCount(bfItemInfo.medalItemType);				int canBuyMedal = 0, canBuyHonour = 0;				if (bfItemInfo.medalReq != 0)			canBuyMedal = playerMedalCount / bfItemInfo.medalReq;				if (bfItemInfo.honourReq != 0)			canBuyHonour = player.GetCanUseRepute() / bfItemInfo.honourReq;				maxBuyCount = canBuyMedal > canBuyHonour ? canBuyHonour : canBuyMedal;	}			return maxBuyCount;}void BattleFieldShopInfo::SetBuyCount(int minCount, int maxCount){	m_slide->SetMin(minCount);	m_slide->SetMax(max_buy_count, true);}bool BattleFieldShopInfo::CheckBuyCount(int buyCount){	if (buyCount <= 0 || buyCount > max_buy_count)		return false;		Item* item = m_btnCurItemButton->GetItem();		if (!item)		return false;		return true;}void BattleFieldShopInfo::ShowNext(){	if (m_iCurPage+1 >= GetGoodPageCount())	{		showDialog(NDCommonCString("tip"), NDCommonCString("LastPageTip"));		return;	}		m_iCurPage += 1;		UpdateCurpageGoods();}void BattleFieldShopInfo::ShowPrev(){	if (m_iCurPage-1 < 0)	{		showDialog(NDCommonCString("tip"), NDCommonCString("FirstPageTip"));		return;	}		m_iCurPage -= 1;		UpdateCurpageGoods();}void BattleFieldShopInfo::OnClickGoodItem(NDUIButton *btn){	NDUIItemButton *clickItemBtn = NULL;	for (int i = 0; i < max_btns; i++) 	{		if (m_btnGood[i] == btn)		{			clickItemBtn = (NDUIItemButton*)btn;			break;		}	}		if (!clickItemBtn)		return;		Item *item = clickItemBtn->GetItem();		if (item && item->iItemType == m_iCurItemType)	{		std::vector<std::string> op;		item->makeItemDialog(op);	}			m_iCurItemType = item == NULL ? 0 : item->iItemType;		UpdateAttrPanel();}void BattleFieldShopInfo::UpdateCurpageGoods() // 包括商品,页标签{	map_bf_iteminfo_it it = BattleField::mapItemInfo.find(m_iShopType);		if (it != BattleField::mapItemInfo.end())	{		vec_bf_item& itemlist = it->second;				int size = itemlist.size();				int startIndex = m_iCurPage*max_btns,		    endIndex = (m_iCurPage+1)*max_btns;				for (int i = startIndex; i < endIndex; i++) 		{			int btnIndex = i-startIndex;						int curItemType = 0;						if (i < size)			{				BFItemInfo& bfItemInfo = itemlist[i];				curItemType = bfItemInfo.itemType;			}						if (btnIndex < max_btns && btnIndex >= 0 && m_btnGood[btnIndex])			{				Item *item = NULL;								if (curItemType != 0)					item = new Item(curItemType);								m_btnGood[btnIndex]->ChangeItem(item);			}		}	}		if (!m_lbPage) return;		std::stringstream ss;		int pageCount = GetGoodPageCount();	int curPage = pageCount == 0 ? 0 : m_iCurPage + 1;		ss << curPage << "/" << pageCount;		m_lbPage->SetText(ss.str().c_str());}void BattleFieldShopInfo::UpdateAttrPanel(){	ChangeAttrPanel(m_iCurItemType);}void BattleFieldShopInfo::UpdateReputeAndMedal(){	int iItemType = 0;		map_bf_iteminfo_it itShop = BattleField::mapItemInfo.find(m_iShopType);	if (itShop != BattleField::mapItemInfo.end())	{		for_vec(itShop->second, vec_bf_item_it)		{			iItemType = (*it).medalItemType;						break;		}	}	NDPlayer& player = NDPlayer::defaultHero();		std::stringstream repute, medal;		medal << GetMedalCount(iItemType);		repute << player.GetCanUseRepute(); 		m_lbRepute->SetText(repute.str().c_str());		m_lbMedal->SetText(medal.str().c_str());}bool BattleFieldShopInfo::SetDescContent(const char *text, ccColor4B color/*=ccc4(0, 0, 0, 255)*/, unsigned int fontsize/*=12*/){	if (!m_descScroll) return false;		m_descScroll->RemoveAllChildren(true);		if (!text) return false;		int width = m_descScroll->GetFrameRect().size.width;	CGSize textSize;	textSize.width = width;	textSize.height = NDUITextBuilder::DefaultBuilder()->StringHeightAfterFilter(text, textSize.width, fontsize);		NDUIText* memo = NDUITextBuilder::DefaultBuilder()->Build(text, 															  fontsize, 															  textSize, 															  color,															  true);	memo->SetFrameRect(CGRectMake(0, 0, textSize.width, textSize.height));			m_descScroll->AddChild(memo);		m_descScroll->refreshContainer();		return true;}int BattleFieldShopInfo::GetGoodPageCount(){	map_bf_iteminfo_it it = BattleField::mapItemInfo.find(m_iShopType);		if (it != BattleField::mapItemInfo.end())	{		vec_bf_item& itemlist = it->second;				return itemlist.size() / max_btns + ( (itemlist.size() % max_btns) != 0 ? 1 : 0);	}		return 0;}bool BattleFieldShopInfo::GetBattleFieldItemInfo(int bfItemType, BFItemInfo& bfItemInfo){	map_bf_iteminfo_it itShop = BattleField::mapItemInfo.find(m_iShopType);	if (itShop != BattleField::mapItemInfo.end())	{		for_vec(itShop->second, vec_bf_item_it)		{			if ((*it).itemType != bfItemType)				continue;							bfItemInfo = *it;						return true;		}	}		return false;}int BattleFieldShopInfo::GetMedalCount(int medalItemType){	return ItemMgrObj.GetBagItemCount(medalItemType);}#pragma mark 战场商店IMPLEMENT_CLASS(BattleFieldShop, NDCommonLayer)BattleFieldShop::BattleFieldShop(){}BattleFieldShop::~BattleFieldShop(){}void BattleFieldShop::Initialization(){	NDPicturePool& pool = *(NDPicturePool::DefaultPool());		map_bf_desc& mapBfDesc = BattleField::mapDesc;		//NDAsssert(!mapBfDesc.empty());		float maxTitleLen = 0.0f;		for(map_bf_desc_it it = mapBfDesc.begin(); it != mapBfDesc.end(); it++)	{		CGSize textSize = getStringSize(it->second.c_str(), 18);				if (textSize.width > maxTitleLen)			maxTitleLen = textSize.width;	}		maxTitleLen += 36;		NDCommonLayer::Initialization(maxTitleLen);		int i = 0;		for(map_bf_desc_it it = mapBfDesc.begin(); it != mapBfDesc.end(); it++, i++)	{		TabNode* tabnode = this->AddTabNode();				tabnode->SetImage(pool.AddPicture(NDPath::GetImgPathNew("newui_tab_unsel.png"), maxTitleLen, 31), 						  pool.AddPicture(NDPath::GetImgPathNew("newui_tab_sel.png"), maxTitleLen, 34),						  pool.AddPicture(NDPath::GetImgPathNew("newui_tab_selarrow.png")));				tabnode->SetText(it->second.c_str());				tabnode->SetTextColor(ccc4(245, 226, 169, 255));				tabnode->SetFocusColor(ccc4(173, 70, 25, 255));				tabnode->SetTextFontSize(18);				NDUIClientLayer *client = this->GetClientLayer(i);				CGSize clientsize = this->GetClientSize();						BattleFieldShopInfoNew *info = new BattleFieldShopInfoNew;		info->Initialization(it->first);		info->SetFrameRect(CGRectMake(0, 0, clientsize.width, clientsize.height));		client->AddChild(info);	}		this->SetTabFocusOnIndex(0, true);}void BattleFieldShop::UpdateShopInfo(){	uint i = 0;	NDUIClientLayer *client = NULL;		while ((client = GetClientLayer(i++))) 	{		const std::vector<NDNode*>& children = client->GetChildren();		for_vec(children, std::vector<NDNode*>::const_iterator)		{			if (!(*it)->IsKindOfClass(RUNTIME_CLASS(BattleFieldShopInfoNew)))				continue;							BattleFieldShopInfoNew *info =	(BattleFieldShopInfoNew*)(*it);						//if (!info->IsVisibled())			//	continue;							info->Update();		}	}}#pragma mark 战场商品IMPLEMENT_CLASS(ShopUIItem, NDUIButton)ShopUIItem::ShopUIItem(){		//m_bFocus = false;		m_btnItem = NULL;}ShopUIItem::~ShopUIItem(){}void ShopUIItem::Initialization(){	NDUIButton::Initialization();		this->CloseFrame();		m_btnItem = new NDUIItemButton;	m_btnItem->Initialization();	m_btnItem->SetFrameRect(CGRectMake(2, 2, 42, 42));	m_btnItem->EnableEvent(false);	m_btnItem->SetShowItemOnly(true);	this->AddChild(m_btnItem);}void ShopUIItem::draw(){	NDUIButton::draw();		if (!this->IsVisibled()) 	{		return;	}		CGRect scrRect = this->GetScreenRect();			bool focus = false;		if (this->GetParent() 		&& this->GetParent()->IsKindOfClass(RUNTIME_CLASS(NDUILayer))		&& ((NDUILayer*)this->GetParent())->GetFocus() == this) 	{		focus = true;	}		//draw focus 	ccColor4B linecolor, bgcolor;	if (focus) 	{		linecolor = INTCOLORTOCCC4(0x6b9e9c);		bgcolor = INTCOLORTOCCC4(0xc6cbb5);				}	else 	{		linecolor = INTCOLORTOCCC4(0xffb402);		bgcolor = INTCOLORTOCCC4(0xffdc78);		}		this->SetBackgroundColor(bgcolor);		DrawPolygon(CGRectMake(scrRect.origin.x, scrRect.origin.y, scrRect.size.width, scrRect.size.height-1),linecolor, 1);	DrawPolygon(CGRectMake(scrRect.origin.x+1, scrRect.origin.y+1, scrRect.size.width-2, scrRect.size.height-3), linecolor, 1);}void ShopUIItem::ChangeItem(Item* item){	if (!m_btnItem) return;		m_btnItem->ChangeItem(item);}CGSize ShopUIItem::GetContentStartSize(){	return CGSizeMake(46, 2);}int  ShopUIItem::GetItemType(){	if (!m_btnItem) return 0;		Item *item = m_btnItem->GetItem();		return item == NULL ? 0 : item->iItemType;}Item* ShopUIItem::GetItem(){	if (!m_btnItem) return NULL;		return m_btnItem->GetItem();}#pragma mark 战场商城商品-新IMPLEMENT_CLASS(BFShopUIItem, ShopUIItem)BFShopUIItem::BFShopUIItem(){	m_lbItemName = NULL;		m_imgMedal = m_imgRepute = NULL;		m_lbReqMedal = m_lbReqRepute = NULL;		m_iShopType = 0;}BFShopUIItem::~BFShopUIItem(){}void BFShopUIItem::Initialization(int shopType){	ShopUIItem::Initialization();		m_iShopType = shopType;		CGSize sizestart = this->GetContentStartSize();		sizestart.height = 0.0f;		m_lbItemName = new NDUILabel;	m_lbItemName->Initialization();	m_lbItemName->SetTextAlignment(LabelTextAlignmentLeft);	m_lbItemName->SetFontSize(12);	m_lbItemName->SetFrameRect(CGRectMake(sizestart.width, sizestart.height, 200, 20));	//m_lbItemName->SetText("天宫战斧");	m_lbItemName->SetFontColor(ccc4(136, 41, 41, 255));	this->AddChild(m_lbItemName);		m_imgMedal = new NDUIImage;	m_imgMedal->Initialization();	m_imgMedal->SetFrameRect(CGRectMake(sizestart.width, sizestart.height+12, 16, 16));	this->AddChild(m_imgMedal);		m_lbReqMedal = new NDUILabel;	m_lbReqMedal->Initialization();	m_lbReqMedal->SetTextAlignment(LabelTextAlignmentLeft);	m_lbReqMedal->SetFontSize(12);	m_lbReqMedal->SetFrameRect(CGRectMake(sizestart.width+25, sizestart.height+15, 200, 20));	m_lbReqMedal->SetText("8888888");	this->AddChild(m_lbReqMedal);		NDPicture *picHonour = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("honur12.png"));	m_imgRepute = new NDUIImage;	m_imgRepute->Initialization();	m_imgRepute->SetFrameRect(CGRectMake(sizestart.width, sizestart.height+27, 16, 16));	m_imgRepute->SetPicture(picHonour, true);	this->AddChild(m_imgRepute);		m_lbReqRepute = new NDUILabel;	m_lbReqRepute->Initialization();	m_lbReqRepute->SetTextAlignment(LabelTextAlignmentLeft);	m_lbReqRepute->SetFontSize(12);	m_lbReqRepute->SetFrameRect(CGRectMake(sizestart.width+25, sizestart.height+30, 200, 20));	m_lbReqRepute->SetText("8888888");	this->AddChild(m_lbReqRepute);}void BFShopUIItem::ChangeBFShopItem(int bfItemType){	Item *item = NULL;		if (bfItemType > 0)		item = new Item(bfItemType);		this->ChangeItem(item);		std::stringstream itemName;		if (item)	{		itemName << item->getItemName();	}		m_lbItemName->SetText(itemName.str().c_str());		std::stringstream medal, repute;		BFItemInfo bfItemInfo;		if (GetBattleFieldItemInfo(bfItemType, bfItemInfo))	{		medal << bfItemInfo.medalReq;				repute << bfItemInfo.honourReq;				//m_imgMedal->SetPicture(ItemImage::GetItemPicByType(bfItemInfo.medalItemType), true);		if (bfItemInfo.medalItemType == 28200012)		{ // 洛阳令			m_imgMedal->SetPicture(			NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("luoyanling16.png")),			true);		}		else if (bfItemInfo.medalItemType == 28200011)		{ // 兴洛令			m_imgMedal->SetPicture(								   NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("xinluoling16.png")),								   true);		}	}	else 	{		m_imgMedal->SetPicture(NULL, true);	}		m_lbReqMedal->SetText(medal.str().c_str());		m_lbReqRepute->SetText(repute.str().c_str());}bool BFShopUIItem::GetBattleFieldItemInfo(int bfItemType, BFItemInfo& bfItemInfo){	map_bf_iteminfo_it itShop = BattleField::mapItemInfo.find(m_iShopType);	if (itShop != BattleField::mapItemInfo.end())	{		for_vec(itShop->second, vec_bf_item_it)		{			if ((*it).itemType != bfItemType)				continue;						bfItemInfo = *it;						return true;		}	}		return false;}#pragma mark 战场商店信息-新IMPLEMENT_CLASS(BattleFieldShopInfoNew, NDUILayer)BattleFieldShopInfoNew::BattleFieldShopInfoNew(){	m_slide = NULL;		m_btnBuy = NULL;		memset(m_btnGood, 0, sizeof(m_btnGood));		m_lbMedal = m_lbRepute = NULL;		m_btnPrev = m_btnNext = NULL;		m_lbPage = NULL;		m_iCurPage = 0;		m_iShopType = 0;		m_iCurItemType = 0;		m_scrollItem = NULL;		m_imgLingPai = NULL;}BattleFieldShopInfoNew::~BattleFieldShopInfoNew(){}void BattleFieldShopInfoNew::Initialization(int shopType){	NDAsssert(BattleField::mapItemInfo.find(shopType) != BattleField::mapItemInfo.end());		m_iShopType = shopType;		NDUILayer::Initialization();		m_scrollItem = new NDUIContainerScrollLayer;	m_scrollItem->Initialization();	//m_scrollItem->SetTouchEnabled(false);	//m_scrollItem->SetBackgroundColor(ccc4(173, 69, 23, 255));	m_scrollItem->SetFrameRect(CGRectMake(8, 10, 480-32-8, 205));	this->AddChild(m_scrollItem);		InitAttrPanel();		InitItemPanel();		m_scrollItem->refreshContainer(GetGoodPageCount()*205);		if (!m_vGoods.empty())	{		m_scrollItem->SetFocus(m_vGoods[0]);				m_iCurItemType = m_vGoods[0]->GetItemType();	}		//UpdateCurpageGoods();		Update();}void BattleFieldShopInfoNew::OnButtonClick(NDUIButton* button){	if (button == m_btnNext)	{		ShowNext();				//if (m_btnGood[0])		//	m_btnGood[0]->SetItemFocus(true, true);	}	else if (button == m_btnPrev)	{		ShowPrev();				//if (m_btnGood[0])		//	m_btnGood[0]->SetItemFocus(true, true);	}	else if (button == m_btnBuy)	{		DealBuy();	}	else if (button->IsKindOfClass(RUNTIME_CLASS(BFShopUIItem)))	{		OnFocusShopUIItem((BFShopUIItem*)button);	}}void BattleFieldShopInfoNew::OnFocusShopUIItem(ShopUIItem* shopUiItem){	/*	for (int i = 0; i < max_btns; i++) 	{		if (!m_btnGood[i] || m_btnGood[i] == shopUiItem) continue;		m_btnGood[i]->SetItemFocus(false);	}	*/		OnClickGoodItem(shopUiItem);}void BattleFieldShopInfoNew::Update() // 包括AttrPanel, 令牌, 荣誉值{	UpdateAttrPanel();		UpdateReputeAndMedal();}void BattleFieldShopInfoNew::InitAttrPanel(){	NDPicturePool& pool = *(NDPicturePool::DefaultPool());		int startX = 8, startY = 236;		m_btnBuy = new NDUIButton;	m_btnBuy->Initialization();	m_btnBuy->SetFrameRect(CGRectMake(startX+15, startY+10, 48, 24));	m_btnBuy->SetFontColor(ccc4(255, 255, 255, 255));	m_btnBuy->SetFontSize(12);	m_btnBuy->CloseFrame();	m_btnBuy->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("bag_btn_normal.png")),								   pool.AddPicture(NDPath::GetImgPathNew("bag_btn_click.png")),								   false, CGRectZero, true);	m_btnBuy->SetTitle(NDCommonCString("buy"));	m_btnBuy->SetDelegate(this);							 		this->AddChild(m_btnBuy);		m_slide = new NDSlideBar;	m_slide->Initialization(CGRectMake(100, startY-2, 297-100, 44), 127, true);	m_slide->SetMin(0);	m_slide->SetMax(0);	m_slide->SetCur(0);	m_slide->SetBackgroundImage(NULL, false);	this->AddChild(m_slide);		m_btnPrev = new NDUIButton;	m_btnPrev->Initialization();	m_btnPrev->SetFrameRect(CGRectMake(311, startY, 36, 36));	m_btnPrev->SetDelegate(this);	m_btnPrev->SetImage(pool.AddPicture(NDPath::GetImgPathNew("pre_page.png")), true, CGRectMake(0, 4, 36, 31), true);	m_btnPrev->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);	this->AddChild(m_btnPrev);		m_btnNext = new NDUIButton;	m_btnNext->Initialization();	m_btnNext->SetFrameRect(CGRectMake(400, startY, 36, 36));	m_btnNext->SetDelegate(this);	m_btnNext->SetImage(pool.AddPicture(NDPath::GetImgPathNew("next_page.png")), true, CGRectMake(0, 4, 36, 31), true);	m_btnNext->SetBackgroundPicture(pool.AddPicture(NDPath::GetImgPathNew("btn_bg1.png")), NULL, false, CGRectZero, true);	this->AddChild(m_btnNext);		m_lbPage = new NDUILabel;	m_lbPage->Initialization();	m_lbPage->SetTextAlignment(LabelTextAlignmentCenter);	m_lbPage->SetFontSize(16);	m_lbPage->SetFontColor(ccc4(136, 41, 41, 255));	m_lbPage->SetFrameRect(CGRectMake(m_btnPrev->GetFrameRect().origin.x, 									  m_btnPrev->GetFrameRect().origin.y, 									  m_btnNext->GetFrameRect().origin.x									  +m_btnNext->GetFrameRect().size.width									  -m_btnPrev->GetFrameRect().origin.x, 									  m_btnPrev->GetFrameRect().size.height));	m_lbPage->SetText("8888888");	this->AddChild(m_lbPage);}void BattleFieldShopInfoNew::InitItemPanel(){	//NDPicturePool& pool = *(NDPicturePool::DefaultPool());		/*	int startX = 10, startY = 14,	intervalW = 4, intervalH = 5,	itemW = 142, itemH = 45;		for (int i = 0; i < max_btns; i++) 	{		int x = startX+(i % col)*(itemW+intervalW),		y = startY+(i / col)*(itemH+intervalH);		BFShopUIItem*& btn = m_btnGood[i];		btn = new BFShopUIItem;		btn->Initialization(m_iShopType);		btn->SetDelegate(this);		btn->SetFrameRect(CGRectMake(x, y, itemW, itemH));		this->AddChild(btn);	}	*/		int startX = 2, startY = 4,	intervalW = 4, intervalH = 5,	itemW = 142, itemH = 45;		map_bf_iteminfo_it it = BattleField::mapItemInfo.find(m_iShopType);		if (it != BattleField::mapItemInfo.end())	{		vec_bf_item& itemlist = it->second;				int size = itemlist.size();				for (int i = 0; i < size; i++) 		{			int x = startX+(i % col)*(itemW+intervalW),			y = startY+(i / col)*(itemH+intervalH);			BFShopUIItem*btn = new BFShopUIItem;			btn->Initialization(m_iShopType);			btn->SetDelegate(this);			btn->SetFrameRect(CGRectMake(x, y, itemW, itemH));			btn->ChangeBFShopItem(itemlist[i].itemType);			m_scrollItem->AddChild(btn);						m_vGoods.push_back(btn);		}	}		if (!m_lbPage) return;		std::stringstream ss;		int pageCount = GetGoodPageCount();	int curPage = pageCount == 0 ? 0 : m_iCurPage + 1;		ss << curPage << "/" << pageCount;		m_lbPage->SetText(ss.str().c_str());		NDUILayer* backlayer = new NDUILayer;	backlayer->Initialization();	backlayer->SetBackgroundColor(ccc4(129, 98, 54, 255));	backlayer->SetFrameRect(CGRectMake(10, 18+(max_btns/col)*(itemH+intervalH), 240-startX, 20));	backlayer->SetTouchEnabled(false);	this->AddChild(backlayer);		BFItemInfo bfItemInfo;	map_bf_iteminfo_it itShop = BattleField::mapItemInfo.find(m_iShopType);	if (itShop != BattleField::mapItemInfo.end())	{		for_vec(itShop->second, vec_bf_item_it)		{			bfItemInfo = *it;			break;		}	}		NDPicture *picLingPai = NULL;		if (bfItemInfo.medalItemType == 28200012)	{ // 洛阳令		picLingPai = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("luoyanling16.png"));	}	else if (bfItemInfo.medalItemType == 28200011)	{ // 兴洛令		picLingPai = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("xinluoling16.png"));	}	NDPicture *picHonour = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPathNew("honur12.png"));		unsigned int interval = 8;		NDPicture* tmpPics[2];	tmpPics[0] = picLingPai;	tmpPics[1] = picHonour; 		int width = backlayer->GetFrameRect().size.width,	height = backlayer->GetFrameRect().size.height,	framewidth = width/2;		for (int i = 0; i < 2; i++) 	{		CGSize sizePic = tmpPics[i]->GetSize();		int startx = (i == 0 ? interval : interval+framewidth),		imageY = (height-sizePic.height)/2,		numY = (height-14)/2;		NDUIImage *image = new NDUIImage;				if (i == 0) m_imgLingPai = image;				image->Initialization();		image->SetPicture(tmpPics[i], true);		image->SetFrameRect(CGRectMake(startx, imageY, sizePic.width,sizePic.height));		backlayer->AddChild(image);				NDUILabel *tmpLable = NULL;		if (i == 0)		{			tmpLable = m_lbMedal = new NDUILabel; 		}		else if (i == 1)		{			tmpLable = m_lbRepute = new NDUILabel; 		}				if (tmpLable == NULL) continue;				tmpLable->Initialization();		tmpLable->SetTextAlignment(LabelTextAlignmentLeft);		tmpLable->SetFontSize(14);		tmpLable->SetFrameRect(CGRectMake(startx+sizePic.width+interval, numY, width, height));		tmpLable->SetText("8888888");		tmpLable->SetFontColor(ccc4(255, 255, 255, 255));		backlayer->AddChild(tmpLable);	}}void BattleFieldShopInfoNew::ChangeAttrPanel(int bfItemType){	SetBuyCount(0, GetCanBuyMaxCount(bfItemType));	}int  BattleFieldShopInfoNew::GetAttrPanelBFItemType(){	return m_iCurItemType;}void BattleFieldShopInfoNew::DealBuy(){		int curBuyCount = GetCurBuyCount();	if (!CheckBuyCount(curBuyCount))	{		showDialog(NDCommonCString("tip"), NDCommonCString("BuyCountError"));		return;	}		ShowProgressBar;	NDTransData bao(_MSG_SHOP);	bao << int(m_iCurItemType) << int(0xffffffff) << (unsigned char)Item::_SHOPACT_BUY << (unsigned char)curBuyCount;	SEND_DATA(bao);}int BattleFieldShopInfoNew::GetCurBuyCount(){	return m_slide->GetCur();}int BattleFieldShopInfoNew::GetCanBuyMaxCount(int bfItemType){	return 100;	/*	int maxBuyCount = 0;		BFItemInfo bfItemInfo;		if (GetBattleFieldItemInfo(bfItemType, bfItemInfo))	{		NDPlayer& player = NDPlayer::defaultHero();				int playerMedalCount = GetMedalCount(bfItemInfo.medalItemType);				int canBuyMedal = 0, canBuyHonour = 0;				if (bfItemInfo.medalReq != 0)			canBuyMedal = playerMedalCount / bfItemInfo.medalReq;				if (bfItemInfo.honourReq != 0)			canBuyHonour = player.GetCanUseRepute() / bfItemInfo.honourReq;				maxBuyCount = canBuyMedal > canBuyHonour ? canBuyHonour : canBuyMedal;	}		return maxBuyCount;	*/}void BattleFieldShopInfoNew::SetBuyCount(int minCount, int maxCount){	m_slide->SetMin(minCount);	m_slide->SetCur(minCount);	m_slide->SetMax(max_buy_count, true);}bool BattleFieldShopInfoNew::CheckBuyCount(int buyCount){	if (buyCount <= 0 || buyCount > max_buy_count)		return false;	return true;}void BattleFieldShopInfoNew::ShowNext(){	/*	if (m_iCurPage+1 >= GetGoodPageCount())	{		showDialog(NDCommonCString("tip"), NDCommonCString("LastPageTip"));		return;	}	*/		int pageCount = GetGoodPageCount();		m_iCurPage = pageCount == 0 ? 0 : (m_iCurPage+1)%pageCount;		UpdateCurpageGoods();}void BattleFieldShopInfoNew::ShowPrev(){	/*	if (m_iCurPage-1 < 0)	{		showDialog(NDCommonCString("tip"), NDCommonCString("FirstPageTip"));		return;	}	*/		int pageCount = GetGoodPageCount();	if (m_iCurPage == 0)		m_iCurPage = pageCount == 0 ? 0 : pageCount-1;	else		m_iCurPage = pageCount == 0 ? 0 : m_iCurPage-1;		UpdateCurpageGoods();}void BattleFieldShopInfoNew::OnClickGoodItem(ShopUIItem* shopUiItem){	/*	BFShopUIItem *clickItemBtn = NULL;	for (int i = 0; i < max_btns; i++) 	{		if (m_btnGood[i] == shopUiItem)		{			clickItemBtn = (BFShopUIItem*)shopUiItem;			break;		}	}		if (!clickItemBtn)		return;			*/	Item* item = shopUiItem->GetItem();	if (item && item->iItemType == m_iCurItemType)	{		std::vector<std::string> op;		item->makeItemDialog(op);	}		if (!shopUiItem || !item)		m_iCurItemType = 0;	else		m_iCurItemType = item->iItemType;		UpdateAttrPanel();}void BattleFieldShopInfoNew::UpdateCurpageGoods() // 包括商品,页标签{	/*	map_bf_iteminfo_it it = BattleField::mapItemInfo.find(m_iShopType);		if (it != BattleField::mapItemInfo.end())	{		vec_bf_item& itemlist = it->second;				int size = itemlist.size();				int startIndex = m_iCurPage*max_btns,		endIndex = (m_iCurPage+1)*max_btns;				for (int i = startIndex; i < endIndex; i++) 		{			int btnIndex = i-startIndex;						int curItemType = 0;						if (i < size)			{				BFItemInfo& bfItemInfo = itemlist[i];				curItemType = bfItemInfo.itemType;			}						if (btnIndex < max_btns && btnIndex >= 0 && m_btnGood[btnIndex])			{				m_btnGood[btnIndex]->ChangeBFShopItem(curItemType);								m_btnGood[btnIndex]->SetVisible(this->IsVisibled() && curItemType != 0);			}		}	}	*/		size_t size = m_vGoods.size();		size_t top = m_iCurPage * max_btns;		if (top < size && m_scrollItem)	{		m_scrollItem->ScrollNodeToTop(m_vGoods[top]);		m_scrollItem->SetFocus(m_vGoods[top]);		m_iCurItemType = m_vGoods[top]->GetItemType();		UpdateAttrPanel();	}		if (!m_lbPage) return;		std::stringstream ss;		int pageCount = GetGoodPageCount();	int curPage = pageCount == 0 ? 0 : m_iCurPage + 1;		ss << curPage << "/" << pageCount;		m_lbPage->SetText(ss.str().c_str());}void BattleFieldShopInfoNew::UpdateAttrPanel(){	ChangeAttrPanel(m_iCurItemType);}void BattleFieldShopInfoNew::UpdateReputeAndMedal(){	int iItemType = 0;		map_bf_iteminfo_it itShop = BattleField::mapItemInfo.find(m_iShopType);	if (itShop != BattleField::mapItemInfo.end())	{		for_vec(itShop->second, vec_bf_item_it)		{			iItemType = (*it).medalItemType;						break;		}	}		NDPlayer& player = NDPlayer::defaultHero();		std::stringstream repute, medal;		medal << GetMedalCount(iItemType);		repute << player.GetCanUseRepute(); 		m_lbRepute->SetText(repute.str().c_str());		m_lbMedal->SetText(medal.str().c_str());}int BattleFieldShopInfoNew::GetGoodPageCount(){	map_bf_iteminfo_it it = BattleField::mapItemInfo.find(m_iShopType);		if (it != BattleField::mapItemInfo.end())	{		vec_bf_item& itemlist = it->second;				return itemlist.size() / max_btns + ( (itemlist.size() % max_btns) != 0 ? 1 : 0);	}		return 0;}bool BattleFieldShopInfoNew::GetBattleFieldItemInfo(int bfItemType, BFItemInfo& bfItemInfo){	map_bf_iteminfo_it itShop = BattleField::mapItemInfo.find(m_iShopType);	if (itShop != BattleField::mapItemInfo.end())	{		for_vec(itShop->second, vec_bf_item_it)		{			if ((*it).itemType != bfItemType)				continue;						bfItemInfo = *it;						return true;		}	}		return false;}int BattleFieldShopInfoNew::GetMedalCount(int medalItemType){	return ItemMgrObj.GetBagItemCount(medalItemType);}