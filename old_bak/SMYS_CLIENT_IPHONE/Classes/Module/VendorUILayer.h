/*
 *  VendorUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __VENDOR_UI_LAYER_H__
#define __VENDOR_UI_LAYER_H__

#include "NDUIMenuLayer.h"
#include "NDUIItemButton.h"
#include "GameItemBag.h"
#include "NDUITableLayer.h"
#include "ImageNumber.h"
#include "NDPicture.h"
#include "ItemMgr.h"
#include "NDManualRole.h"
#include "NDUICustomView.h"
#include "NDOptLayer.h"
#include "GameScene.h"

using namespace NDEngine;

class VendorUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public GameItemBagDelegate,
//public NDUITableLayerDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(VendorUILayer)
	
	enum {
		ITEM_ROW = 4,
		ITEM_COL = 4,
	};
	
	VendorUILayer();
	~VendorUILayer();
	
	void OnClickPage(GameItemBag* itembag, int iPage);
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused);
	bool OnCustomViewConfirm(NDUICustomView* customView);
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
public:
	static void Show(GameScene* scene);
	static void reset();
	static void processMsgBooth(NDTransData& data);
	static bool isUILayerShown() { return true;} ///< 临时性更改 郭浩
	static void UpdateMoney();
	
	void InnerUpdateMoney();
	
	void Initialization();
	void draw();
	
private:
	static VendorUILayer* s_instance;
	
private:
	
	typedef pair<int/*eMoney*/, int/*money*/> PAIR_VENDOR_ITEM_PRICE;
	typedef map<int, PAIR_VENDOR_ITEM_PRICE> MAP_ITEM_PRICE;
	typedef MAP_ITEM_PRICE::iterator MAP_ITEM_PRICE_IT;
	
	VEC_ITEM m_vBagItems; // 此处为背包物品的拷贝复制,需要自己释放
	VEC_ITEM m_vSellItems; // 需要自己释放
	
	GameItemBag *m_bagItem;
	NDUIItemButton* m_btnVendorItem[ITEM_ROW][ITEM_COL];
	MAP_ITEM_PRICE m_mapItemPrice;
	NDOptLayer* m_optLayer;
	
	ImageNumber* m_itemMoney;
	ImageNumber* m_itemEMoney;
	
	ImageNumber* m_bagMoney;
	ImageNumber* m_bagEMoney;
	
	NDPicture* m_picMoney;
	NDPicture* m_picEMoney;
	
	NDUIButton* m_btnVendor;
	NDUIButton* m_btnSoldList;
	
	NDUIItemButton* m_curFocusBtn;
	
private:
	bool PutItemToVendor(Item* item, PAIR_VENDOR_ITEM_PRICE& price);
	void releaseItems();
	void boothSuccess();
	void boothCancel();
	void removeItem(int idItem);
	void showSoldList();
};

#endif