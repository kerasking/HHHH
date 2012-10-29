/*
 *  GameUINpcStore.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_NPC_STORE_H_
#define _GAME_UI_NPC_STORE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUIDialog.h"
#include "GameItemBag.h"
#include "NDUITableLayer.h"
#include "NDUICustomView.h"
#include "NDTip.h"
#include <string>


using namespace NDEngine;

void NpcStoreUpdateMoney();
void NpcStoreUpdateBag();
void NpcStoreUpdateSlod();

/////////////////////////////////////////////////////

class ImageNumber;
class GameRoleNode;
class NDUIItemButton;
class FrameLayer;

class CUiMoney
{
public:
	CUiMoney();
	~CUiMoney();
	bool	Init(NDUINode* pParent, int nX, int nY, int nNum, bool bMoney = true);
	void	SetNum(int nNum);
	void	Show();
	void	UnShow();
	
protected:
	enum {IMG_WIDTH = 16, IMG_HEIGHT = 16, NUM_WIDTH = 91, NUM_HEIGHT = 11, IMG_SPACE = 4,};
	NDUIImage*		m_pImage;
	ImageNumber*	m_pImgNum;
	int				m_nPosX;
	int				m_nPosY;
	bool			m_bMoney;
};

class GameUINpcStore :
public NDUIMenuLayer,
public NDUIButtonDelegate,
public NDUIDialogDelegate,
public NDUIVerticalScrollBarDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(GameUINpcStore)
public:
	GameUINpcStore();
	~GameUINpcStore();
	
	void Initialization(int iNPCID = 0); override
	void draw(); override
	void OnButtonClick(NDUIButton* button); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnDialogClose(NDUIDialog* dialog); override
	
	void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar); override
	void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar); override
	
	void OnCustomViewCancle(NDUICustomView* customView); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	
	
	void UpdateBag();
	void UpdateStore();
	void UpdateSold();
	void UpdateMoney();
private:
	void UpdateNpcData();
	void OnSelItem(int iType, int iIndex);
	void AdjustGui(int iType, bool bUp );
	void OnSelPage(int iPageIndex);
	void UpdateFocus();
	void UpdateText();
	
	Item* GetSelItem();
	
	void previewEquip(Item* item);
	
	void sendBuyOrSell(int itemId, int npcId, int action, int dwAmont);
	
private:
	enum  { eTypeBegin = 0, eTypeNPC=eTypeBegin, eTypeSelf, eTypeEnd, };
	
	NDUIButton *m_btnPages[MAX_PAGE_COUNT]; NDPicture *m_picPages[MAX_PAGE_COUNT];
	
	NDUIVerticalScrollBar *m_Scroll[eTypeEnd];
	
	NDUIDialog *m_dlgKaiTong, *m_dlgOperate[eTypeEnd], *m_dlgSell;	
	

	enum{ max_row =2, max_col=9,};
	NDUIItemButton *btns[eTypeEnd][max_row*max_col];
	
	GameRoleNode *m_role; FrameLayer *m_roleframe;
		
	ItemFocus *m_focus;
	
	LayerTip *m_tip;
	
	struct s_focusinfo 
	{
		int iFoucsType;
		int iIndex;
		bool bHasFoucs;
		s_focusinfo(){ iFoucsType=eTypeNPC; iIndex = 0;}
	};
	
	s_focusinfo m_stFocus;
	
	int m_iNPCSelRow, m_iNPCMaxRow, m_iSelfSelRow, m_iSelfMaxRow;
	int m_iCurSelfPage;	
	
	bool isShowPreivew; int direct;
	
	std::vector<int> m_vecOperate;
	
public:
	static void GenerateNpcItems(int ShopID);

	class ShopItem : public Item
	{
		public:
			ShopItem(int itemtype) : Item(itemtype) {} 
		public:
			void SetPayType(int payType) { m_payType = payType; }
			int GetPayType() { return m_payType; }
		private:
			int m_payType;
	};
	
private:
	ShopItem* GetSelShopItem();
	Item* GetFocusItem();
	
private:
	static void ClearNpcItems();
	static std::vector<GameUINpcStore::ShopItem*> vec_sell_item;
	int m_iNPCID;
	
	enum SHOP_INDEX {
		SHOP_INDEX_SHOP		= 1,
		SHOP_INDEX_BUY_BACK	= 2,
	};
	NDUIButton* m_btnShop;
	NDUIButton* m_btnBuyBack;
	int			m_nShopIndex;
	
	ID_VEC		m_vecSoldItemId;
	CUiMoney	m_objMoney;
	CUiMoney	m_objEMoney;
	CUiMoney	m_objSelfMoney;
	CUiMoney	m_objSelfEMoney;
};

//////////////////////////////////////////
class GameNpcStoreScene : public NDScene
{
	DECLARE_CLASS(GameNpcStoreScene)
public:
	GameNpcStoreScene();
	~GameNpcStoreScene();
	static GameNpcStoreScene* Scene(int iNPCID=0);
	void Initialization(int iNPCID=0); override
};

#endif // _GAME_UI_NPC_STORE_H_