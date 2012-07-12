/*
 *  TradeUILayer.h
 *  DragonDrive
 *
 *  Created by wq on 11-3-14.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#ifndef __TRADE_UI_LAYER_H__
#define __TRADE_UI_LAYER_H__

#include "NDUIMenuLayer.h"
#include "NDUIItemButton.h"
#include "GameItemBag.h"
#include "NDUITableLayer.h"
#include "ImageNumber.h"
#include "NDPicture.h"
#include "ItemMgr.h"
#include "NDManualRole.h"
#include "NDUICustomView.h"

using namespace NDEngine;

enum {
	ITEM_ROW = 2,
	ITEM_COL = 4,
};

/*
class TradeUILayer :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public GameItemBagDelegate,
public NDUITableLayerDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(TradeUILayer)
	TradeUILayer();
	~TradeUILayer();
	
	void OnClickPage(GameItemBag* itembag, int iPage);
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused);
	
	bool OnCustomViewConfirm(NDUICustomView* customView);
	
public:
	static void SendTrade(int data, Byte action);
	static void processTrade(NDManualRole* tradeRole, int nData, int action);
	static bool isUILayerShown();
	static void Close();
	
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	void draw(); override
	
	virtual void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);
	
private:
	int m_idTradeRole;
	GameItemBag *m_bagItem;
	NDUIItemButton* m_btnOtherItem[ITEM_ROW][ITEM_COL];
	NDUIItemButton* m_btnOurItem[ITEM_ROW][ITEM_COL];
	NDUITableLayer* m_opt;
	
	ImageNumber* m_ourMoney;
	ImageNumber* m_ourEMoney;
	ImageNumber* m_otherMoney;
	ImageNumber* m_otherEMoney;
	
	ImageNumber* m_bagMoney;
	ImageNumber* m_bagEMoney;
	
	NDPicture* m_picMoney;
	NDPicture* m_picEMoney;
	
	NDUIButton* m_btnOurMoney;
	NDUIButton* m_btnOurEMoney;
	
	NDUIButton* m_curFocusBtn;
	
	NDUILayer *m_optLayer;
	
private:
	void AddTradeItem();
	void ShowItemDetail(Item* item);
	void AddItem(OBJID idItem);
	void AddMoney(int nMoney);
	void AddEMoney(int nEMoney);
	void AcceptTrade(int idTrade);
	
private:
	static TradeUILayer* s_instance;
};
*/

#include "NDCommonScene.h"
#include "NDCommonControl.h"
#include "GameNewItemBag.h"

class DlgTradeMoney;
class DlgTradeAmount;

class DlgTradeDelegate
{
public:
	virtual void OnDlgTradeConfirm(NDUILayer *dlg, unsigned int value1, unsigned int value2) {}
};



class NewTradeLayer :
public NDUILayer,
public DlgTradeDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(NewTradeLayer)
	
public:
	NewTradeLayer();
	~NewTradeLayer();
	
	void Initialization(); override
	void OnClickPage(NewGameItemBag* itembag, int iPage); override
	/**bFocus,表示该事件发生前该Cell是否处于Focus状态*/
	//bool OnClickCell(NewGameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	//bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	//bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	bool OnButtonLongClick(NDUIButton* button);
	void OnDlgTradeConfirm(NDUILayer *dlg, unsigned int value1, unsigned int value2); override
	void OnButtonClick(NDUIButton* button); override
	void commitTrade();
	void cancelTrade();
	
	static void SendTrade(int data, Byte action);
	static void processTrade(NDManualRole* tradeRole, int nData, int action);
	static bool isUILayerShown();
	static void Close();
private:
	void AddTradeItem();
	void ShowItemDetail(Item* item);
	void AddItem(OBJID idItem);
	void AddMoney(int nMoney);
	void AddEMoney(int nEMoney);
	void AcceptTrade(int idTrade);
	
	static NewTradeLayer* s_instance;
	
private:
	void InitItem(bool isSelf, CGRect rect,NDUINode *parent);
	void ShowSelfCommitLayer(bool show, CGRect rect=CGRectZero);
	void ShowOtherCommitLayer(bool show, CGRect rect=CGRectZero);
	void ShowDialog(bool money, int itemID=0);
	bool IsSelfBtnDragIn(NDUIButton* button);
	int	 findEmptyIndex();
private:
	NewGameItemBag *m_itembagPlayer;
	NDUIItemButton* m_btnOtherItem[ITEM_ROW][ITEM_COL];
	NDUIItemButton* m_btnOurItem[ITEM_ROW][ITEM_COL];
	NDUILabel		*m_lbRoleName, *m_lbEMoneyOther, *m_lbMoneyOther, *m_lbEMoneySelf, *m_lbMoneySelf;
	NDUILayer		*m_layerCommitOther, *m_layerCommitSelf;
	NDUIButton		*m_btnMoney;
	int m_idTradeRole;
	
	DlgTradeMoney	*m_dlgMoney;
	DlgTradeAmount	*m_dlgAmount;
	unsigned int	m_uiTradeMoney, m_uiTradeEmoney;
	bool			m_isInAcceptState;
};

class NewTradeScene :
public NDCommonScene
{
	DECLARE_CLASS(NewTradeScene)
	
public:	
	NewTradeScene();
	
	~NewTradeScene();
	
	static NewTradeScene* Scene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
		
private:
	NDUIButton *m_btnCommit;
	NewTradeLayer *m_layerTrade;
private:
	void InitTrade(NDUIClientLayer* client);
};

#endif