/*
 *  VendorBuyUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-25.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __VENDOR_BUY_UI_LAYER_H__
#define __VENDOR_BUY_UI_LAYER_H__

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

class VendorBuyUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate
//public NDUITableLayerDelegate ///< 临时性注释 郭浩
{
	DECLARE_CLASS(VendorBuyUILayer)
	
	enum {
		ITEM_ROW = 3,
		ITEM_COL = 8,
	};
	
	VendorBuyUILayer();
	~VendorBuyUILayer();
	
	void OnButtonClick(NDUIButton* button);
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
public:
	static int s_idVendor;
	static void Show(NDTransData& data);
	static void Close();
	static void RemoveItem(int idItem);
	static bool isUILayerShown(){return true;} ///< 临时性更改 郭浩
	static void UpdateMoney();
	
	void InnerUpdateMoney();
	
	void Initialization(NDTransData& data);
	void draw();
	
private:
	static VendorBuyUILayer* s_instance;
	
private:
	
	typedef pair<int/*money*/, int/*eMoney*/> PAIR_VENDOR_ITEM_PRICE;
	
	typedef map<int, PAIR_VENDOR_ITEM_PRICE> MAP_ITEM_PRICE;
	typedef MAP_ITEM_PRICE::iterator MAP_ITEM_PRICE_IT;
	
	VEC_ITEM& m_vSellingItem;
	
	NDUIItemButton* m_btnVendorItem[ITEM_ROW][ITEM_COL];
	MAP_ITEM_PRICE m_mapItemPrices;
	NDOptLayer* m_optLayer;
	
	ImageNumber* m_itemMoney;
	ImageNumber* m_itemEMoney;
	
	ImageNumber* m_bagMoney;
	ImageNumber* m_bagEMoney;
	
	NDPicture* m_picMoney;
	NDPicture* m_picEMoney;
	
	NDUIItemButton* m_curFocusBtn;
	
	NDUILabel* m_lbItemName;
	
private:
	void releaseItems();
	void removeItem(int idItem);
};

#endif