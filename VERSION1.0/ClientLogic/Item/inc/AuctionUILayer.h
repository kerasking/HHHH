/*
 *  AuctionUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-4-15.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __AUCTION_UI_LAYER_H__
#define __AUCTION_UI_LAYER_H__

#include "define.h"
#include "NDUIMenuLayer.h"
#include "NDUITableLayer.h"
#include "SocialElement.h"
#include "NDOptLayer.h"
#include "NDPageButton.h"
#include "NDUIButton.h"
#include "NDUICustomView.h"
#include "NDUIDialog.h"
#include "GameItemBag.h"

using namespace NDEngine;

class Auction_Item;
typedef vector<Auction_Item*> VEC_AUCTION_ITEM;
typedef VEC_AUCTION_ITEM::iterator VEC_AUCTION_ITEM_IT;

class AuctionUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public IPageButtonDelegate,
public NDUICustomViewDelegate,
public GameItemBagDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(AuctionUILayer)
public:
	static void Show(int type);
	static void processAuction(NDTransData& data);
	static void processAuctionInfo(NDTransData& data);
	static bool processItemDescQuery(NDTransData& data);
	
private:
	static AuctionUILayer* s_instance;
	AuctionUILayer();
	~AuctionUILayer();
	
public:
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused);
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
	bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	void OnPageChange(int nCurPage, int nTotalPage);
	void Initialization();
	
	void OnAuctionInfo(NDTransData& data);
	void OnAuctioin(NDTransData& data);
	
private:
	NDUITableLayer* m_tlMain;
	Auction_Item* m_curSelEle;
	NDOptLayer* m_optLayer;
	NDPageButton* m_btnPage;
	
	VEC_AUCTION_ITEM m_vElement;
	
	/**
	 * 1 我的拍卖 2 有过滤条件 3 全部,没有条件 4 按物品名
	 */
	int queryType;
	
	GameItemBag* m_itemBag;
	
	int m_qipai;
	int m_yikou;
	
	Item tobeUpItem;
	
private:
	void refreshMainList();
	void releaseElement();
	void addUpAuctionItem(int priceType);
	void deleteItem(int itemID);
	Auction_Item* getAuctionItem(int itemID);
};

bool AuctionUILayer::processItemDescQuery( NDTransData& data )
{
	return true;
}

#endif