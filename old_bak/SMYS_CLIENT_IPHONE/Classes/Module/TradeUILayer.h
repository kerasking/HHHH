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

enum 
{
	ITEM_ROW = 2,
	ITEM_COL = 4,
};

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

	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	bool OnButtonLongClick(NDUIButton* button);
	void OnDlgTradeConfirm(NDUILayer *dlg, unsigned int value1, unsigned int value2); override
	void OnButtonClick(NDUIButton* button); override
	void commitTrade();
	void cancelTrade();
	
	static void SendTrade(int data, Byte action);
	static void processTrade(NDManualRole* tradeRole, int nData, int action);
	static bool isUILayerShown() {return true;} ///< 临时性更改 郭浩
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