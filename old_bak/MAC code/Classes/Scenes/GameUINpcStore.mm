/*
 *  GameUINpcStore.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-18.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameUINpcStore.h"
#include "NDUIItemButton.h"
#include "GameRoleNode.h"
#include "ImageNumber.h"
#include "NDDirector.h"
#include "GameScene.h"
#include "NDDataTransThread.h"
#include "NDTransData.h"
#include "NDPlayer.h"
#include "NDUtility.h"
#include "CGPointExtension.h"
#include "ItemMgr.h"
#include "NDUISynLayer.h"
#include "NDNpc.h"
#include "NDMapMgr.h"
#include "GamePlayerBagScene.h"
#include "NDConstant.h"
#include "NDPath.h"
#include <sstream>

#define title_height 28
#define bottom_height 42

#define btn_begin_x	(10)
#define btn_begin_y	(33)
#define self_btn_begin_y (156)
#define btn_inter_w	(5)
#define btn_inter_h (5)

#define page_begin_y (248)
#define page_w (60)
#define page_h (26)
#define page_inter (5)

#define money_begin_y (131)
#define self_money_begin_y (255)

#define scroll_begin_x (436)
#define scroll_w (28)

#define PREVIEW_LEFT (1)
#define PREVIEW_RIGHT (2)

#define per_scroll_len (btn_inter_h+ITEM_CELL_H)

void NpcStoreUpdateMoney()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameNpcStoreScene)))
	{
		return;
	}
	
	NDNode *node = scene->GetChild(UILAYER_NPCSHOP_TAG);
	
	if ( node)
	{
		((GameUINpcStore*)node)->UpdateMoney();
	}
}

void NpcStoreUpdateBag()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameNpcStoreScene)))
	{
		return;
	}
	
	NDNode *node = scene->GetChild(UILAYER_NPCSHOP_TAG);
	
	if ( node)
	{
		((GameUINpcStore*)node)->UpdateBag();
	}
}

void NpcStoreUpdateSlod()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (!scene || !scene->IsKindOfClass(RUNTIME_CLASS(GameNpcStoreScene)))
	{
		return;
	}
	
	NDNode *node = scene->GetChild(UILAYER_NPCSHOP_TAG);
	
	if ( node)
	{
		CloseProgressBar;
		((GameUINpcStore*)node)->UpdateSold();
	}
}
/////////////////////////////////////////////

enum
{
	eOP_Begin = 100,
	eOP_Buy = eOP_Begin,
	eOP_BuyAmount,
	eOP_PreView,
	eOP_CancelProView,
	eOP_Compare,
	eOP_End,
};

/////////////////////////////////////////////
CUiMoney::CUiMoney()
{
}

CUiMoney::~CUiMoney()
{
}

bool CUiMoney::Init(NDUINode* pParent, int nX, int nY, int nNum, bool bMoney)
{
	if (!pParent) {
		return false;
	}
	m_nPosX	= nX;
	m_nPosY = nY;
	m_bMoney= bMoney;
	NDPicture* pPic = NULL;
	if (m_bMoney) {
		pPic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("money.png"));
	}
	else {
		pPic = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("emoney.png"));
	}
	pPic->Cut(CGRectMake(0, 0, IMG_WIDTH, IMG_HEIGHT));
	m_pImage =  new NDUIImage;
	if (!m_pImage) {
		return false;
	}
	m_pImage->Initialization();
	m_pImage->SetPicture(pPic, true);
	m_pImage->SetFrameRect(CGRectMake(m_nPosX, m_nPosY, IMG_WIDTH, IMG_HEIGHT));
	
	m_pImgNum = new ImageNumber;
	if (!m_pImgNum) {
		delete m_pImage;
		m_pImage = NULL;
		return false;
	}
	m_pImgNum->Initialization();
	m_pImgNum->SetTitleRedNumber(nNum);
	m_pImgNum->SetFrameRect(CGRectMake(m_nPosX+IMG_WIDTH+ IMG_SPACE, m_nPosY, NUM_WIDTH, NUM_HEIGHT));
	
	pParent->AddChild(m_pImage);
	pParent->AddChild(m_pImgNum);
	this->Show();
	return true;
}

void CUiMoney::SetNum(int nNum)
{
	m_pImgNum->SetTitleRedNumber(nNum);
}

void CUiMoney::Show()
{
	m_pImage->SetVisible(true);
	m_pImgNum->SetVisible(true);
}

void CUiMoney::UnShow()
{
	m_pImage->SetVisible(false);
	m_pImgNum->SetVisible(false);
}

//////////////////////////////////////

class FrameLayer : public NDUILayer
{
	DECLARE_CLASS(FrameLayer)
	
public:
	FrameLayer(){}
	~FrameLayer(){}
	void Initialization() override
	{		
		NDUILayer::Initialization();
		this->EnableEvent(false);
	}
	void draw() override
	{
		if (!DrawEnabled()) return;
		
		NDUILayer::draw();
		
		CGRect scrRect = this->GetScreenRect();
		DrawLine(scrRect.origin, 
				 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
				 ccc4(0	, 0, 0,255),
				 1);
		DrawLine(scrRect.origin, 
				 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y),
				 ccc4(0, 0, 0,255),
				 1);
		DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y), 
				 ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
				 ccc4(0, 0, 0,255),
				 1);
		DrawLine(ccp(scrRect.origin.x+scrRect.size.width, scrRect.origin.y+scrRect.size.height),
				 ccp(scrRect.origin.x, scrRect.origin.y+scrRect.size.height),
				 ccc4(0, 0, 0,255),
				 1);
	}
};

IMPLEMENT_CLASS(FrameLayer, NDUILayer)
//////////////////////////////////////////////
IMPLEMENT_CLASS(GameUINpcStore, NDUIMenuLayer)

std::vector<GameUINpcStore::ShopItem*> GameUINpcStore::vec_sell_item;

GameUINpcStore::GameUINpcStore()
{
#define fastinit(arrvar) memset(arrvar, NULL, sizeof(arrvar))
//		fastinit(m_picMoney); fastinit(m_picEMoney); fastinit(m_imageMoney); fastinit(m_imageEMoney);
//		fastinit(m_imageNumMoney); fastinit(m_imageNumEMoney); 
		fastinit(m_btnPages); fastinit(m_picPages);
		fastinit(m_Scroll); fastinit(btns); fastinit(m_dlgOperate);
#undef fastinit
	
	m_dlgKaiTong = NULL;
	m_role = NULL; m_focus = NULL; m_roleframe = NULL;
	m_tip = NULL;
	
	m_iNPCSelRow = 0; m_iNPCMaxRow = 0;
	m_iSelfSelRow = 0; m_iSelfMaxRow = 3;
	m_iCurSelfPage = 0;
	
	m_dlgSell = NULL;
	
	isShowPreivew = false;
	
	m_iNPCID = 0;
	
	m_btnShop	= NULL;
	m_btnBuyBack= NULL;
	m_nShopIndex= SHOP_INDEX_SHOP;
}

GameUINpcStore::~GameUINpcStore()
{
//	SAFE_DELETE(m_picMoney[eTypeNPC]); SAFE_DELETE(m_picMoney[eTypeSelf]);
//	SAFE_DELETE(m_picEMoney[eTypeNPC]); SAFE_DELETE(m_picEMoney[eTypeSelf]);
	//for (int i = 0; i< MAX_PAGE_COUNT; i++) 
//	{
//		SAFE_DELETE(m_picPages[i]);
//	}
	
	ClearNpcItems();
	SAFE_DELETE(m_focus);
	ItemMgrObj.repackEquip();
}

void GameUINpcStore::Initialization(int iNPCID/* = 0*/)
{
	m_iNPCID = iNPCID;
	
	NDUIMenuLayer::Initialization();
	
	if ( this->GetCancelBtn() ) 
	{
		this->GetCancelBtn()->SetDelegate(this);
	}
	
	CGSize winsize = NDDirector::DefaultDirector()->GetWinSize();

	int iPageBeginX = (winsize.width-page_inter*3-page_w*4)/2;
	for (int i = 0; i < MAX_PAGE_COUNT; i++)
	{
		CGSize picSize;
		m_picPages[i] = PictureNumber::SharedInstance()->TitleGoldNumber(i+1);
		m_btnPages[i] = new NDUIButton;
		m_btnPages[i]->Initialization();
		m_btnPages[i]->SetDelegate(this);
	
		picSize = m_picPages[i]->GetSize();
		iPageBeginX += (page_inter+page_w)*(i==0?0:1);
		
		m_btnPages[i]->SetFrameRect(CGRectMake(iPageBeginX, page_begin_y, page_w, page_h));
		m_btnPages[i]->SetImage(m_picPages[i], true, CGRectMake((page_w-picSize.width)/2, (page_h-picSize.height)/2, picSize.width, picSize.height));
		//m_btnPages[i]->SetFocusColor(ccc4(20, 59, 64, 255));
		m_btnPages[i]->SetBackgroundColor(ccc4(56, 110, 110, 255));
		m_btnPages[i]->CloseFrame();
		this->AddChild(m_btnPages[i]);
	}
	m_btnPages[m_iCurSelfPage]->SetBackgroundColor(ccc4(20, 59, 64, 255));
	
	m_objMoney.Init(this, btn_begin_x, money_begin_y, 0);
	m_objEMoney.Init(this, btn_begin_x+110, money_begin_y, 0);
	m_objSelfMoney.Init(this, btn_begin_x,self_money_begin_y, 0);
	m_objSelfEMoney.Init(this, btn_begin_x+360,self_money_begin_y, 0);
	
	for(int i = eTypeBegin; i < eTypeEnd; i++)
	{
		int iBeginX = btn_begin_x, iBeginY = i == eTypeNPC ? btn_begin_y : self_btn_begin_y;
		for (int j=0; j < max_row*max_col; j++) 
		{
			btns[i][j] = new NDUIItemButton;
			NDUIItemButton*& btn = btns[i][j];
			btn->Initialization();
			btn->SetDelegate(this);
			btn->SetFrameRect(CGRectMake(iBeginX+(btn_inter_w+ITEM_CELL_W)*(j%max_col), iBeginY+(btn_inter_h+ITEM_CELL_H)*(j/max_col), ITEM_CELL_W, ITEM_CELL_H));
			
			this->AddChild(btn);
			btn->ChangeItem(NULL);
		}
		
		m_Scroll[i] = new NDUIVerticalScrollBar;
		m_Scroll[i]->Initialization();
		m_Scroll[i]->SetFrameRect(CGRectMake(scroll_begin_x, iBeginY, scroll_w, 2*ITEM_CELL_H+btn_inter_h));
		//m_Scroll[i]->SetCurrentContentY(0);
//		m_Scroll[i]->SetContentHeight(10);
		m_Scroll[i]->SetDelegate(this);
		this->AddChild(m_Scroll[i]);
	}
	
	m_Scroll[eTypeSelf]->SetContentHeight(3*per_scroll_len*max_row);
	
	m_focus = new ItemFocus;
	m_focus->Initialization();
	m_focus->SetFrameRect(btns[eTypeNPC][0]->GetFrameRect());
	this->AddChild(m_focus);
	
	m_tip = new LayerTip;
	m_tip->Initialization();
	m_tip->SetTextFontSize(13);
	m_tip->SetTextColor(ccc4(199, 89, 0, 255));
	m_tip->Hide(); 
	this->AddChild(m_tip);
	
	m_roleframe = new FrameLayer;
	m_roleframe->Initialization();
	m_roleframe->SetFrameRect(CGRectMake(122, 221, 49, 57));
	m_roleframe->SetBackgroundColor(ccc4(202, 203, 189, 255));
	this->AddChild(m_roleframe);
	m_role = new GameRoleNode;
	m_role->Initialization();
	//以下两行固定用法
	m_role->SetFrameRect(CGRectMake(0, 0, winsize.width, winsize.height));
	m_role->SetDisplayPos(ccp(147,274));
	m_roleframe->AddChild(m_role,8);
	//roleframe->SetVisible(false);
	m_roleframe->EnableDraw(false);
	m_role->EnableDraw(false);
	
	m_btnShop	= new NDUIButton;
	m_btnShop->Initialization();
	m_btnShop->SetDelegate(this);
	m_btnShop->SetTitle(NDCString("ShopBotton"));
	m_btnShop->CloseFrame();
	m_btnShop->SetFontColor(ccc4(255,255,0,255));
	m_btnShop->SetFrameRect(CGRectMake(20, 2, 60, title_height-3));
	m_btnShop->SetBackgroundColor(ccc4(20, 59, 64, 255));
	this->AddChild(m_btnShop);
	
	m_btnBuyBack	= new NDUIButton;
	m_btnBuyBack->Initialization();
	m_btnBuyBack->SetDelegate(this);
	m_btnBuyBack->SetTitle(NDCString("BuyBackBotton"));
	m_btnBuyBack->CloseFrame();
	m_btnBuyBack->SetFontColor(ccc4(255,255,0,255));
	m_btnBuyBack->SetFrameRect(CGRectMake(85, 2, 60, title_height-3));
	m_btnBuyBack->SetBackgroundColor(ccc4(56, 110, 110, 255));
	this->AddChild(m_btnBuyBack);
	
	m_nShopIndex	= SHOP_INDEX_SHOP;
	
	UpdateNpcData();
	UpdateBag();
	UpdateStore();
	UpdateMoney();
	UpdateText();
	UpdateFocus();
}

void GameUINpcStore::draw()
{
	NDUIMenuLayer::draw();
	
	if (isShowPreivew) 
	{
		//NDPlayer::defaultHero().SetSpriteDir(direct);
		m_roleframe->EnableDraw(true);
		m_role->EnableDraw(true);
	}
	else 
	{
		m_roleframe->EnableDraw(false);
		m_role->EnableDraw(false);
	}

}

void GameUINpcStore::OnButtonClick(NDUIButton* button)
{
	if (button == this->GetCancelBtn())
	{
		if (this->GetParent() && this->GetParent()->IsKindOfClass(RUNTIME_CLASS(GameNpcStoreScene))) 
		{
			//((GameScene*)(this->GetParent()))->SetUIShow(false);
//			this->RemoveFromParent(true);
			NDDirector::DefaultDirector()->PopScene();
		}
		return;
	}
	else if (button == m_btnShop) {
		if (m_nShopIndex != SHOP_INDEX_SHOP) {
			m_nShopIndex = SHOP_INDEX_SHOP;
			m_btnShop->SetBackgroundColor(ccc4(20, 59, 64, 255));
			m_btnBuyBack->SetBackgroundColor(ccc4(56, 110, 110, 255));
			m_iNPCSelRow	= 0;
			this->UpdateStore();
			if (m_stFocus.iFoucsType == eTypeNPC) {
				m_stFocus.iIndex= 0;
				this->UpdateFocus();
			}
			this->UpdateText();
			this->UpdateMoney();
		}
		return;
	}
	else if (button == m_btnBuyBack) {
		if (m_nShopIndex != SHOP_INDEX_BUY_BACK) {
			m_nShopIndex = SHOP_INDEX_BUY_BACK;
			m_btnBuyBack->SetBackgroundColor(ccc4(20, 59, 64, 255));
			m_btnShop->SetBackgroundColor(ccc4(56, 110, 110, 255));
			m_iNPCSelRow	= 0;
			this->UpdateSold();
			if (m_stFocus.iFoucsType == eTypeNPC) {
				m_stFocus.iIndex= 0;
				this->UpdateFocus();
			}
			this->UpdateText();
			this->UpdateMoney();
		}
		return;
	}
	
	for (int i = 0; i < MAX_PAGE_COUNT; i++) 
	{
		if (button == m_btnPages[i])
		{
			OnSelPage(i);
			break;
		}
	}
	
	for (int i = eTypeBegin; i < eTypeEnd; i++) 
	{
		for (int j = 0; j < max_col*max_row; j++) 
		{
			if (btns[i][j] == button) 
			{
				OnSelItem(i, j);
				break;
			}
		}
	}
	
}

void GameUINpcStore::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_dlgKaiTong) 
	{
		int iTag = dialog->GetTag();
		if (iTag < 0 || iTag >= MAX_PAGE_COUNT) 
		{
		}
		else 
		{
			ShowProgressBar;
			NDTransData bao(_MSG_LIMIT);
			bao << (unsigned char)(1);
			SEND_DATA(bao);
		}
	}
	else if (dialog == m_dlgOperate[eTypeNPC]) 
	{
		if (buttonIndex < m_vecOperate.size()) 
		{
			int iOP = m_vecOperate[buttonIndex];
			if (iOP == eOP_Buy) 
			{
				Item* pItem = this->GetFocusItem();
				if (m_nShopIndex == SHOP_INDEX_SHOP) {
					NDPlayer& player = NDPlayer::defaultHero();
					if (player.IsFocusNpcValid() && pItem) 
					{
						sendBuyOrSell(pItem->iItemType, player.GetFocusNpcID(), Item::_SHOPACT_BUY, 1);
					}
				}else if (m_nShopIndex == SHOP_INDEX_BUY_BACK) {
					ShowProgressBar;
					NDTransData bao(_MSG_BUYBACK_ACTION);
					bao << (int)(pItem->iID);
					SEND_DATA(bao);
				}
			}
			else if (iOP == eOP_BuyAmount) 
			{
				NDUICustomView *view = new NDUICustomView;
				view->Initialization();
				view->SetDelegate(this);
				std::vector<int> vec_id; vec_id.push_back(1);
				std::vector<std::string> vec_str; vec_str.push_back(NDCommonCString("InputAmount100"));
				view->SetEdit(1, vec_id, vec_str);
				view->Show();
				this->AddChild(view);
			}
			else if (iOP == eOP_PreView) 
			{
				ShopItem *item = GetSelShopItem();
				NDPlayer& player = NDPlayer::defaultHero();
				if (player.IsFocusNpcValid() && item) 
				{
					isShowPreivew = true;
					if (m_stFocus.iIndex < max_col / 2) 
					{
						direct = PREVIEW_RIGHT;
					} else {
						direct = PREVIEW_LEFT;
					}
				}
				
				previewEquip(item);
			}
			else if (iOP == eOP_CancelProView) 
			{
				isShowPreivew = false;
			}
			else if (iOP == eOP_Compare) 
			{
				ShopItem *item = GetSelShopItem();
				NDPlayer& player = NDPlayer::defaultHero();
				if (player.IsFocusNpcValid() && item) 
				{
					int comparePosition = GamePlayerBagScene::getComparePosition(item);
					Item *tempItem = ItemMgrObj.GetEquipItem(comparePosition);
					std::string tempStr = Item::makeCompareItemDes(tempItem, item, 2);
					showDialog("", tempStr.c_str());
				}
			}
		}
	}
	else if (dialog == m_dlgOperate[eTypeSelf]) 
	{
		Item *item = GetSelItem();
		if (item) 
		{
			std::vector<int> ids = Item::getItemType(item->iItemType);
			// ItemType.PINZHI.length - 2为传说
			if (ids[0] <= 1 && ids[7] >= NDItemType::PINZHI_LEN() - 2) 
			{
				std::stringstream ss; ss << NDCommonCString("ShopSaleTip") << NDItemType::PINZHI(ids[7]) << "，" << NDCommonCString("ShopSaleTip2");
				m_dlgSell = new NDUIDialog;
				m_dlgSell->Initialization();
				m_dlgSell->SetDelegate(this);
				m_dlgSell->Show(NDCommonCString("WenXinTip"), ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
			} 
			else 
			{
				NDPlayer& player = NDPlayer::defaultHero();
				if (player.IsFocusNpcValid()) 
				{
					sendBuyOrSell(item->iID, player.GetFocusNpcID(), Item::_SHOPACT_SELL, item->iAmount);
				}
			}
		}
	}
	else if ( dialog == m_dlgSell)
	{
		Item *item = GetSelItem();
		if (item) 
		{
			NDPlayer& player = NDPlayer::defaultHero();
			if (player.IsFocusNpcValid()) 
			{
				sendBuyOrSell(item->iID, player.GetFocusNpcID(), Item::_SHOPACT_SELL, item->iAmount);
			}
		}
	}
	
	dialog->Close();
}

void GameUINpcStore::OnDialogClose(NDUIDialog* dialog)
{
	if (dialog == m_dlgKaiTong) 
	{
		m_dlgKaiTong = NULL;
	}
	else if (dialog == m_dlgOperate[eTypeNPC]) 
	{
		m_vecOperate.clear();
	}
	else if ( dialog == m_dlgSell)
	{
		m_dlgSell = NULL;
	}
}

void GameUINpcStore::OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar)
{
	if (scrollBar == m_Scroll[eTypeNPC]) 
	{
		AdjustGui(eTypeNPC, true);
	}
	else if (scrollBar == m_Scroll[eTypeSelf]) 
	{
		AdjustGui(eTypeSelf, true);
	}
}

void GameUINpcStore::OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar)
{
	if (scrollBar == m_Scroll[eTypeNPC]) 
	{
		AdjustGui(eTypeNPC, false);
	}
	else if (scrollBar == m_Scroll[eTypeSelf]) 
	{
		AdjustGui(eTypeSelf, false);
	}
}

void GameUINpcStore::OnCustomViewCancle(NDUICustomView* customView)
{
	
}

bool GameUINpcStore::OnCustomViewConfirm(NDUICustomView* customView)
{
	std::string stramount =	customView->GetEditText(0);
	if (!stramount.empty())
	{
		VerifyViewNum(*customView);
		
		int iBuyCount = atoi(stramount.c_str());
		if(iBuyCount>100 || iBuyCount < 0){
			customView->ShowAlert(NDCommonCString("ShopBuy100"));
			return false;
		}
		else
		{
			ShopItem *item = GetSelShopItem();
			NDPlayer& player = NDPlayer::defaultHero();
			int iNPCID = 0;
			
			if (player.GetFocusNpc() && m_iNPCID == 0) {
				iNPCID = player.GetFocusNpcID();
			}else {
				iNPCID = m_iNPCID;	
			}

			
			if (item) 
			{
				sendBuyOrSell(item->iItemType, iNPCID, Item::_SHOPACT_BUY, iBuyCount);
			}
		}
	}
	
	return true;
}

void GameUINpcStore::UpdateBag()
{
	VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
	m_iCurSelfPage = m_iCurSelfPage < 0 || m_iCurSelfPage >= MAX_PAGE_COUNT ? 0 : m_iCurSelfPage;
	m_iSelfSelRow = m_iSelfSelRow < 0 || m_iSelfSelRow >= m_iSelfMaxRow-1 ? 0 : m_iSelfSelRow;
	int iStart = m_iCurSelfPage*MAX_CELL_PER_PAGE+m_iSelfSelRow*max_col;
	int iEnd = m_iCurSelfPage*MAX_CELL_PER_PAGE+(m_iSelfSelRow+2)*max_col;
	int iSize = vec_item.size();
	
	for (int i = iStart, iIndex = 0; i < iEnd; i++, iIndex++) 
	{
		Item *item = NULL;
		if (i < iSize) 
		{
			item = vec_item[i];
		}
		
		if (m_iSelfSelRow == m_iSelfMaxRow - 2 && iIndex >= max_row*max_col - 3 && btns[eTypeSelf][iIndex]) 
		{
			btns[eTypeSelf][iIndex]->SetVisible(false);
			btns[eTypeSelf][iIndex]->EnableDraw(false);
		}
		else 
		{
			if (btns[eTypeSelf][iIndex]) 
			{
				btns[eTypeSelf][iIndex]->ChangeItem(item);
			}
			btns[eTypeSelf][iIndex]->SetVisible(true);
			btns[eTypeSelf][iIndex]->EnableDraw(true);
		}

	}
	
	//if (m_Scroll[eTypeSelf]) 
//	{
//		m_Scroll[eTypeSelf]->SetCurrentContentY(m_iSelfSelRow);
//		m_Scroll[eTypeSelf]->SetContentHeight(m_iSelfMaxRow);
//	}
}
void GameUINpcStore::UpdateStore()
{
	if (m_nShopIndex != SHOP_INDEX_SHOP) {
		return;
	}
	m_iNPCSelRow = m_iNPCSelRow < 0 || m_iNPCSelRow >= m_iNPCMaxRow-1 ? 0 : m_iNPCSelRow;
	int iStart = m_iNPCSelRow*max_col;
	int iEnd = (m_iNPCSelRow+2)*max_col;
	int iSize = vec_sell_item.size();
	for (int i = iStart, iIndex = 0; i < iEnd; i++, iIndex++) 
	{
		Item *item = NULL;
		if (i < iSize) 
		{
			item = vec_sell_item[i];
		}
		
		if (btns[eTypeNPC][iIndex]) 
		{
			btns[eTypeNPC][iIndex]->ChangeItem(item);
		}
		
	}
}

void GameUINpcStore::UpdateSold()
{
	if (m_nShopIndex != SHOP_INDEX_BUY_BACK) {
		return;
	}
	m_iNPCSelRow = m_iNPCSelRow < 0 || m_iNPCSelRow >= m_iNPCMaxRow-1 ? 0 : m_iNPCSelRow;
	int iStart = m_iNPCSelRow*max_col;
	int iEnd = (m_iNPCSelRow+2)*max_col;
	
	m_vecSoldItemId.clear();
	ItemMgrObj.GetSoldItemsId(m_vecSoldItemId);
	int iSize = m_vecSoldItemId.size();
	for (int i = iStart, iIndex = 0; i < iEnd; i++, iIndex++) 
	{
		Item *pItem = NULL;
		if (i < iSize) 
		{
			OBJID idItem = m_vecSoldItemId[i];
			if (idItem) {
				pItem	= ItemMgrObj.QueryItem(idItem);
			}
		}
		
		if (btns[eTypeNPC][iIndex]) 
		{
			btns[eTypeNPC][iIndex]->ChangeItem(pItem);
		}
	}
}

void GameUINpcStore::OnSelPage(int iPageIndex)
{
	if (iPageIndex < 0 ||  iPageIndex >= MAX_PAGE_COUNT) 
	{
		return;
	}
	
	if (iPageIndex >= ItemMgrObj.GetPlayerBagNum())
	{
		stringstream ss; ss << NDCommonCString("KaiTongBag") << (iPageIndex+1) << NDCommonCString("NeedSpend");
		if (iPageIndex == 1) {
			ss << 200;
		} else if (iPageIndex == 2) {
			ss << 500;
		} else if (iPageIndex == 3) {
			ss << 1000;
		}
		
		ss << NDCommonCString("ge") << NDCommonCString("emoney");
		
		m_dlgKaiTong = new NDUIDialog;
		m_dlgKaiTong->Initialization();
		m_dlgKaiTong->SetTag(iPageIndex);
		m_dlgKaiTong->SetDelegate(this);
		m_dlgKaiTong->Show("", ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
	}
	else 
	{
		if (m_iCurSelfPage != iPageIndex) 
		{
			if (m_btnPages[m_iCurSelfPage]) 
			{
				m_btnPages[m_iCurSelfPage]->SetBackgroundColor(ccc4(56, 110, 110, 255));
			}
			if (m_btnPages[iPageIndex]) 
			{
				m_btnPages[iPageIndex]->SetBackgroundColor(ccc4(20, 59, 64, 255));
			}
			
			m_iCurSelfPage = iPageIndex;
			
			m_iSelfSelRow = 0;
			
			if (m_stFocus.iFoucsType == eTypeSelf) 
			{
				m_stFocus.iIndex = -1;
				m_stFocus.bHasFoucs = false;
			}
			
			UpdateBag();
	
			UpdateFocus();
			
			UpdateMoney();
			
			UpdateText();
		}
	}

}

void GameUINpcStore::UpdateFocus()
{
	if (m_stFocus.iFoucsType < eTypeBegin || m_stFocus.iFoucsType >= eTypeEnd) 
	{
		return;
	}
	
	if (m_stFocus.iIndex == -1) 
	{
		if ( m_focus ) m_focus->EnableDraw(false);
	}
	else
	{
		if (m_focus && btns[m_stFocus.iFoucsType][m_stFocus.iIndex]) 
		{
			m_focus->SetFrameRect(btns[m_stFocus.iFoucsType][m_stFocus.iIndex]->GetFrameRect());
			m_focus->EnableDraw(true);
			
			int iRow = m_stFocus.iIndex / max_col;
			if (m_Scroll[m_stFocus.iFoucsType]) 
			{
				m_Scroll[m_stFocus.iFoucsType]->SetCurrentContentY(
					(max_row*per_scroll_len) * (m_stFocus.iFoucsType == eTypeNPC ? m_iNPCSelRow+iRow : m_iSelfSelRow+iRow)
				);
			}
		}
	}
}


void GameUINpcStore::UpdateText()
{
	if (!m_tip) 
	{
		return;
	}
	
	std::stringstream showTextStr;
	Item* pItem = this->GetFocusItem();
	if (pItem) {
		if (m_stFocus.iFoucsType == eTypeNPC) {
			if (m_nShopIndex == SHOP_INDEX_SHOP) {
				showTextStr << pItem->getItemName();
			}
			else if (m_nShopIndex == SHOP_INDEX_BUY_BACK) {
				if (pItem->isEquip()) {// 装备
					showTextStr << (pItem->getItemNameWithAdd());
				} else {
					if (pItem->iAmount > 1) {
						showTextStr << pItem->getItemName() << " x " << pItem->iAmount;
					} else {
						showTextStr << pItem->getItemName();
					}
				}
			}
		}
		else if (m_stFocus.iFoucsType == eTypeSelf) {
			if (pItem->isEquip()) {// 装备
				showTextStr << (pItem->getItemNameWithAdd());
			} else {
				if (pItem->iAmount > 1) {
					showTextStr << pItem->getItemName() << " x " << pItem->iAmount;
				} else {
					showTextStr << pItem->getItemName();
				}
			}
		}
	}
	
	if (m_stFocus.iIndex == -1) 
	{
		m_tip->Hide();
	}
	else
	{
		if (m_focus && btns[m_stFocus.iFoucsType][m_stFocus.iIndex]) 
		{

			CGRect rect = btns[m_stFocus.iFoucsType][m_stFocus.iIndex]->GetScreenRect();
			m_tip->SetText(showTextStr.str());
			//m_tip->SetTextColor(INTCOLORTOCCC4(getItemColor(item)));
			
			CGSize size = m_tip->GetTipSize();
			
			int iX = 0;
			if (m_stFocus.iIndex%max_col < max_col/2) 
			{
				iX = rect.origin.x;
			}
			else 
			{
				iX = rect.origin.x+rect.size.width-size.width;
			}
			
			if (m_stFocus.iIndex == max_col)
			{
				iX += rect.size.width;
				rect.origin.y -= rect.size.height / 2;
				
			}

			m_tip->SetFrameRect(CGRectMake(iX, rect.origin.y+rect.size.height+2, rect.size.width, rect.size.height));
			m_tip->Show();
		}
		else 
		{
			m_tip->Hide();
		}

	}
}

void GameUINpcStore::UpdateMoney()
{
	NDPlayer& player = NDPlayer::defaultHero();
	
	NDNpc *focusNpc = player.GetFocusNpc();
	if (!focusNpc) 
	{
		return;
	}
	Item* pItem = this->GetFocusItem();
	if (pItem) {
		if (m_stFocus.iFoucsType == eTypeSelf) {
			int iMoney = 0;
			if (pItem->iAmount > 1 && !pItem->isEquip()) 
			{
				iMoney = int(pItem->getPrice()/2*pItem->iAmount);
			}
			else
			{
				iMoney = int(pItem->getPrice()/2);
			}
			
			m_objMoney.SetNum(iMoney);
			m_objMoney.Show();
			m_objEMoney.UnShow();
		}
		else if (m_stFocus.iFoucsType == eTypeNPC) {
			if (m_nShopIndex == SHOP_INDEX_SHOP) {
				int npcCamp = focusNpc->GetCamp();
				int discount = 100;
				if (npcCamp - 1 >= 0 && npcCamp - 1 < 7) 
				{
					discount = getDiscount(NDMapMgrObj.zhengYing[npcCamp - 1]);
				}
				
				int iMoney = int(pItem->getPrice()*discount/100);
				int iEmoney = int(pItem->getEmoney()*discount/100);
				
				m_objMoney.SetNum(iMoney);
				m_objEMoney.SetNum(iEmoney);
				
				if ((static_cast<ShopItem*>(pItem))->GetPayType() == PAY_TYPE_EMONEY) {
					m_objMoney.UnShow();
					m_objEMoney.Show();
				}
				else {
					m_objMoney.Show();
					m_objEMoney.UnShow();
				}
			}
			else if (m_nShopIndex == SHOP_INDEX_BUY_BACK) {
				int iMoney = 0;
				if (pItem->iAmount > 1 && !pItem->isEquip()) 
				{
					iMoney = int(pItem->getPrice()/2*pItem->iAmount);
				}
				else
				{
					iMoney = int(pItem->getPrice()/2);
				}
				
				m_objMoney.SetNum(iMoney);
				m_objMoney.Show();
				m_objEMoney.UnShow();
			}
		}
	}
	else {
		m_objMoney.UnShow();
		m_objEMoney.UnShow();
	}

	m_objSelfMoney.SetNum(player.money);
	m_objSelfMoney.Show();
	m_objSelfEMoney.SetNum(player.eMoney);
	m_objSelfEMoney.Show();
}

Item* GameUINpcStore::GetSelItem()
{
	Item *res = NULL;
	
	if (m_stFocus.iIndex == -1) 
	{
		return res;
	}
	
	int iIndex = -1;
	
	if (m_stFocus.iFoucsType == eTypeSelf) 
	{
		VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
		iIndex = m_iCurSelfPage*MAX_CELL_PER_PAGE+m_iSelfSelRow*max_col + m_stFocus.iIndex;
		if (iIndex < int(vec_item.size())) 
		{
			res = vec_item[iIndex];
		}
	}
 
	return res;
}

GameUINpcStore::ShopItem* GameUINpcStore::GetSelShopItem()
{
	ShopItem* res = NULL;
	
	if (m_stFocus.iIndex == -1) 
	{
		return res;
	}
	
	int iIndex = -1;
	
	if (m_stFocus.iFoucsType == eTypeNPC && SHOP_INDEX_SHOP == m_nShopIndex) 
	{
		iIndex = m_iNPCSelRow*max_col + m_stFocus.iIndex;
		if (iIndex < int(vec_sell_item.size()) )
		{
			res = vec_sell_item[iIndex];
		}
	}
	
	return res;
}

Item* GameUINpcStore::GetFocusItem()
{
	if (m_stFocus.iIndex == -1) 
	{
		return NULL;
	}
	int iIndex = -1;
	if (m_stFocus.iFoucsType == eTypeNPC) 
	{
		iIndex = m_iNPCSelRow*max_col + m_stFocus.iIndex;
		if (SHOP_INDEX_SHOP == m_nShopIndex) {
			if (iIndex < int(vec_sell_item.size()) )
			{
				return vec_sell_item[iIndex];
			}
		}
		else {
			if (iIndex < int(m_vecSoldItemId.size()) )
			{
				OBJID idItem = m_vecSoldItemId[iIndex];
				return ItemMgrObj.QueryItem(idItem);
			}
		}
	}
	else if (m_stFocus.iFoucsType == eTypeSelf) 
	{
		VEC_ITEM& vec_item = ItemMgrObj.GetPlayerBagItems();
		iIndex = m_iCurSelfPage*MAX_CELL_PER_PAGE+m_iSelfSelRow*max_col + m_stFocus.iIndex;
		if (iIndex < int(vec_item.size())) {
			return vec_item[iIndex];
		}
	}
	return NULL;
}

void GameUINpcStore::previewEquip(Item* item)
{
	ItemMgrObj.repackEquip();
	
	if (!item) 
	{
		return;
	}
	
	if (!item->isRidePet()) 
	{
		
		NDItemType* item_type = ItemMgrObj.QueryItemType(item->iItemType);
		if (!item_type) 
		{
			return;
		}
		int nID = item_type->m_data.m_lookface;
		int quality = item->iItemType % 10;
		NDPlayer::defaultHero().SetEquipment(nID, quality);
	}
}

void GameUINpcStore::UpdateNpcData()
{
	int iSize = vec_sell_item.size();
	m_iNPCMaxRow = iSize/max_col + (iSize%max_col != 0 ? 1 : 0);
	m_iNPCMaxRow = m_iNPCMaxRow < 3 ? 3 : m_iNPCMaxRow;
	if (m_Scroll[eTypeNPC]) 
	{
		m_Scroll[eTypeNPC]->SetContentHeight((m_iNPCMaxRow)*per_scroll_len*max_row);
	}
}

void GameUINpcStore::OnSelItem(int iType, int iIndex)
{
	if (m_stFocus.iIndex == iIndex && iType == m_stFocus.iFoucsType) 
	{
		Item* pItem = this->GetFocusItem();
		if (!pItem) {
			return;
		}
		// 生成对话框
		if (iType == eTypeNPC) 
		{
			std::vector<std::string> vec_str;
			
			if (m_nShopIndex == SHOP_INDEX_SHOP) {
				int iType = Item::getIdRule(pItem->iItemType, Item::ITEM_TYPE); // 物品类型
				if (iType == 0) 
				{ // 装备类
					vec_str.push_back(NDCommonCString("buy")); m_vecOperate.push_back(eOP_Buy);
					
					int comparePosition = GamePlayerBagScene::getComparePosition(pItem);
					
					if (comparePosition >= 0 && ItemMgrObj.HasEquip(comparePosition)) 
					{
						vec_str.push_back(NDCommonCString("CompareEquipWithSelf")); m_vecOperate.push_back(eOP_Compare);
					}
					
					if (!isShowPreivew) 
					{
						vec_str.push_back(NDCommonCString("PriviewEquip")); m_vecOperate.push_back(eOP_PreView);
					} 
					else 
					{
						vec_str.push_back(NDCommonCString("CancelPriview")); m_vecOperate.push_back(eOP_CancelProView);
					}
					
				} 
				else 
				{
					vec_str.push_back(NDCommonCString("buy")); m_vecOperate.push_back(eOP_BuyAmount);
				}
			}
			else if (m_nShopIndex == SHOP_INDEX_BUY_BACK) {
				vec_str.push_back(NDCString("BuyBackDlgBtn"));
				m_vecOperate.push_back(eOP_Buy);
			}
			
			m_dlgOperate[eTypeNPC] = pItem->makeItemDialog(vec_str);
			m_dlgOperate[eTypeNPC]->SetDelegate(this);
		}
		else if (iType == eTypeSelf)
		{
			m_dlgOperate[eTypeSelf] = new NDUIDialog;
			
			std::vector<std::string> vec_str;			
			if (pItem->isItemCanSale()) 
			{
				vec_str.push_back(NDCommonCString("MaiDiao"));
			}
			
			m_dlgOperate[eTypeSelf] = pItem->makeItemDialog(vec_str);
			m_dlgOperate[eTypeSelf]->SetDelegate(this);
		}

		return;
	}
	m_stFocus.iIndex = iIndex;
	m_stFocus.iFoucsType = iType;
	
	if ( isShowPreivew && iType == eTypeNPC) 
	{
		if (m_stFocus.iIndex < max_col / 2) 
		{
			direct = PREVIEW_RIGHT;
		} else {
			direct = PREVIEW_LEFT;
		}
		
		ShopItem* item = GetSelShopItem();
		previewEquip(item);
	}
	
	UpdateFocus();
	UpdateMoney();
	UpdateText();
}

void GameUINpcStore::AdjustGui(int iType, bool bUp )
{
	if (iType != m_stFocus.iFoucsType) 
	{
		m_stFocus.iFoucsType = iType;
		m_stFocus.iIndex = 0;
	}
	/*
	int iIndex = bUp ? m_stFocus.iIndex-max_col : m_stFocus.iIndex + max_col;
	if	(iType == eTypeNPC)
	{
		iIndex +=  m_iNPCSelRow * max_col;
	}
	else 
	{
		iIndex +=  m_iSelfSelRow * max_col;
	}
	*/
	int iRow = m_stFocus.iIndex / max_col;
	if (iRow == 0) 
	{
		if (bUp) 
		{
			if (iType == eTypeNPC) 
			{
				if (m_iNPCSelRow - 1 < 0) 
				{
					m_iNPCSelRow = m_iNPCMaxRow - 2;
					m_stFocus.iIndex = max_col;
				}
				else 
				{
					m_iNPCSelRow = m_iNPCSelRow - 1;
					m_stFocus.iIndex = 0;
				}				
			}
			else if (iType == eTypeSelf) 
			{
				if (m_iSelfSelRow - 1 < 0) 
				{
					m_iSelfSelRow = m_iSelfMaxRow - 2;
					m_stFocus.iIndex = max_col;
				}
				else 
				{
					m_iSelfSelRow = m_iSelfSelRow - 1;
					m_stFocus.iIndex = 0;
				}
			}
		}
		else
		{
			m_stFocus.iIndex = max_col;
		}
	}
	else if (iRow == 1)
	{
		if (!bUp) 
		{
			if (iType == eTypeNPC) 
			{
				if (m_iNPCSelRow  >= m_iNPCMaxRow - 2) 
				{
					m_iNPCSelRow = 0;
					m_stFocus.iIndex = 0;
				}
				else 
				{
					m_iNPCSelRow = m_iNPCSelRow + 1;
					m_stFocus.iIndex = max_col;
				}				
			}
			else if (iType == eTypeSelf) 
			{
				if (m_iSelfSelRow >= m_iSelfMaxRow -2) 
				{
					m_iSelfSelRow = 0;
					m_stFocus.iIndex = 0;
				}
				else 
				{
					m_iSelfSelRow = m_iSelfSelRow + 1;
					m_stFocus.iIndex = max_col;
				}
			}
		}
		else
		{
			m_stFocus.iIndex = 0;
		}
	}

	if (iType == eTypeNPC) 
	{
		if (SHOP_INDEX_SHOP == m_nShopIndex) {
			this->UpdateStore();
		}
		else if (SHOP_INDEX_BUY_BACK == m_nShopIndex) {
			this->UpdateSold();
		}
	}
	else if (iType == eTypeSelf) 
	{
		UpdateBag();
	}
	
	UpdateFocus();
	UpdateMoney();
	UpdateText();
}

void GameUINpcStore::ClearNpcItems()
{
	for (std::vector<ShopItem*>::iterator it = vec_sell_item.begin(); it != vec_sell_item.end(); it++) 
	{
		if (*it) 
		{
			delete *it;
		}
	}
	vec_sell_item.clear();
}

void GameUINpcStore::GenerateNpcItems(int ShopID)
{
	ClearNpcItems();
	
	map_npc_store_it it = NDMapMgrObj.m_mapNpcStore.find(ShopID);
	
	if (it == NDMapMgrObj.m_mapNpcStore.end()) return;
	
	vector<ShopItemInfo>& vShopItemInfo = it->second; 
	
	size_t size = vShopItemInfo.size();
	
	NDLog(@"\n====商品个数[%u]", size);
	
	for (size_t i = 0; i < size; i++) 
	{
		ShopItem* item = new ShopItem(vShopItemInfo[i].itemType);
		
		item->SetPayType(vShopItemInfo[i].payType);
		
		vec_sell_item.push_back(item);
	}
}

void GameUINpcStore::sendBuyOrSell(int itemId, int npcId, int action, int dwAmont) 
{
	ShowProgressBar;
	NDTransData bao(_MSG_SHOP);
	bao << int(itemId) << int(npcId) << (unsigned char)action << (unsigned char)dwAmont;
	SEND_DATA(bao);
}

//////////////////////////////////////////
IMPLEMENT_CLASS(GameNpcStoreScene, NDScene)

GameNpcStoreScene::GameNpcStoreScene()
{
}

GameNpcStoreScene::~GameNpcStoreScene()
{
}

GameNpcStoreScene* GameNpcStoreScene::Scene(int iNPCID/*=0*/)
{
	GameNpcStoreScene *scene = new GameNpcStoreScene;
	scene->Initialization(iNPCID);
	return scene;
}

void GameNpcStoreScene::Initialization(int iNPCID/*=0*/)
{
	NDScene::Initialization();
	
	GameUINpcStore *npcstore = new GameUINpcStore;
	npcstore->Initialization(iNPCID);
	this->AddChild(npcstore, UILAYER_Z, UILAYER_NPCSHOP_TAG);
}