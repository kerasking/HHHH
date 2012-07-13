/*
 *  BattleFieldShop.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-11-3.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _BATTLE_FIELD_SHOP_H_
#define _BATTLE_FIELD_SHOP_H_

#include "NDCommonScene.h"
#include "NDUIItemButton.h"
#include "NDCommonControl.h"
#include "BattleFieldData.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

#pragma mark 战场商店信息
class BattleFieldShopInfo :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(BattleFieldShopInfo)
	
	enum { max_btns = 20, col = 5, };
	
public:
	BattleFieldShopInfo();
	
	~BattleFieldShopInfo();
	
	void Initialization(int shopType); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void Update(); // 包括AttrPanel, 令牌, 荣誉值
	
private:
	NDUIItemButton				*m_btnCurItemButton;
	NDUILabel					*m_lbItemName, *m_lbItemLvl;
	NDUIImage					*m_imgMedal, *m_imgRepute;
	NDUILabel					*m_lbReqMedal, *m_lbReqRepute;
	
	NDUIContainerScrollLayer	*m_descScroll;
	
	NDSlideBar					*m_slide;
	
	NDUIButton					*m_btnBuy;
	
	NDUIItemButton				*m_btnGood[max_btns];
	
	NDUILabel					*m_lbMedal, *m_lbRepute;
	
	NDUIButton					*m_btnPrev, *m_btnNext;
	
	NDUILabel					*m_lbPage;
	
	int							m_iCurPage;
	
	int							m_iShopType;
	
	int							m_iCurItemType;
	
private:
	void InitAttrPanel();
	void InitItemPanel();
	
	void ChangeAttrPanel(int bfItemType);
	int  GetAttrPanelBFItemType();
	
	void DealBuy();
	int GetCurBuyCount();
	int GetCanBuyMaxCount(int bfItemType);
	void SetBuyCount(int minCount, int maxCount);
	bool CheckBuyCount(int buyCount);
	
	void ShowNext();
	void ShowPrev();
	void OnClickGoodItem(NDUIButton *btn);
	
	void UpdateCurpageGoods(); // 包括商品,页标签
	void UpdateAttrPanel();
	void UpdateReputeAndMedal();
	
	bool SetDescContent(const char *text, ccColor4B color=ccc4(0, 0, 0, 255), unsigned int fontsize=12);
	int GetGoodPageCount();
	
	bool GetBattleFieldItemInfo(int bfItemType, BFItemInfo& bfItemInfo);
	
	int GetMedalCount(int medalItemType);
};


#pragma mark 战场商店

class BattleFieldShop :
public NDCommonLayer
{
	DECLARE_CLASS(BattleFieldShop)
public:
	BattleFieldShop();
	~BattleFieldShop();
	
	void Initialization(); override
	
	void UpdateShopInfo();
};

#pragma mark 商城商品-新

class ShopUIItem : public NDUIButton
{
	DECLARE_CLASS(ShopUIItem)
	
public:
	ShopUIItem();
	
	~ShopUIItem();
	
	void Initialization(); override
	
	void draw(); override
	
	void ChangeItem(Item* item);
	
	int  GetItemType(); 
	
	Item* GetItem();
	
	CGSize GetContentStartSize();
	
protected:
	NDUIItemButton		*m_btnItem;
};

#pragma mark 战场商城商品-新

class BFShopUIItem : public ShopUIItem
{
	DECLARE_CLASS(BFShopUIItem)
	
public:
	BFShopUIItem();
	
	~BFShopUIItem();
	
	void Initialization(int shopType); override
	
	void ChangeBFShopItem(int bfItemType);
	
private:
	NDUILabel					*m_lbItemName;
	NDUIImage					*m_imgMedal, *m_imgRepute;
	NDUILabel					*m_lbReqMedal, *m_lbReqRepute;
	int							m_iShopType;
private:
	bool GetBattleFieldItemInfo(int bfItemType, BFItemInfo& bfItemInfo);
};

#pragma mark 战场商店信息-新
class BattleFieldShopInfoNew :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(BattleFieldShopInfoNew)
	
	enum { max_btns = 12, col = 3, };
	
public:
	BattleFieldShopInfoNew();
	
	~BattleFieldShopInfoNew();
	
	void Initialization(int shopType); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void OnFocusShopUIItem(ShopUIItem* shopUiItem);
	
	void Update(); // 包括AttrPanel, 令牌, 荣誉值
	
private:
	NDSlideBar					*m_slide;
	
	NDUIButton					*m_btnBuy;
	
	BFShopUIItem				*m_btnGood[max_btns];
	
	NDUILabel					*m_lbMedal, *m_lbRepute;
	
	NDUIButton					*m_btnPrev, *m_btnNext;
	
	NDUILabel					*m_lbPage;
	
	int							m_iCurPage;
	
	int							m_iShopType;
	
	int							m_iCurItemType;
	
	
	NDUIContainerScrollLayer	*m_scrollItem;
	
	std::vector<BFShopUIItem*>  m_vGoods;
	
	NDUIImage					*m_imgLingPai;
	
private:
	void InitAttrPanel();
	void InitItemPanel();
	
	void ChangeAttrPanel(int bfItemType);
	int  GetAttrPanelBFItemType();
	
	void DealBuy();
	int GetCurBuyCount();
	int GetCanBuyMaxCount(int bfItemType);
	void SetBuyCount(int minCount, int maxCount);
	bool CheckBuyCount(int buyCount);
	
	void ShowNext();
	void ShowPrev();
	void OnClickGoodItem(ShopUIItem* shopUiItem);
	
	void UpdateCurpageGoods(); // 包括商品,页标签
	void UpdateAttrPanel();
	void UpdateReputeAndMedal();
	
	int GetGoodPageCount();
	
	bool GetBattleFieldItemInfo(int bfItemType, BFItemInfo& bfItemInfo);
	
	int GetMedalCount(int medalItemType);
};

#endif // _BATTLE_FIELD_SHOP_H_