/*
 *  GameStorageScene.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "GameStorageScene.h"
#include "NDDirector.h"
#include "NDUtility.h"
#include "ItemMgr.h"
#include "Item.h"
#include "NDPlayer.h"
#include "NDNpc.h"
#include "NDMapMgr.h"
#include "ImageNumber.h"
#include "NDUIItemButton.h"
#include "GameUINpcStore.h"
#include "GameUIPlayerList.h"
#include "NDUISynLayer.h"
#include "FarmStorage.h"
#include "NDPath.h"
#include <sstream>

GameStorageScene* GetGameStorageScene();

// iType->0(仓库), 1(背包)
void GameStorageAddItem(int iType, Item& item)
{
	GameStorageScene* scene = GetGameStorageScene();
	if (!scene) 
	{
		return;
	}
	
	scene->AddItem(iType,item);
}

// iType->0(仓库), 1(背包)
void GameStorageDelItem(int iType, Item& item)
{
	GameStorageScene* scene = GetGameStorageScene();
	if (!scene) 
	{
		return;
	}
	
	scene->DelItem(iType,item);
}

void GameStorageUpdateMoney()
{
	GameStorageScene* scene = GetGameStorageScene();
	if (!scene) 
	{
		return;
	}
	
	scene->UpdateMoney();
}

void GameStorageUpdateLimit(int iType)
{
	GameStorageScene* scene = GetGameStorageScene();
	if (!scene) 
	{
		return;
	}
	
	scene->UpdateLimit(iType);
}

GameStorageScene* GetGameStorageScene()
{
	GameStorageScene* res = NULL;
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameStorageScene))) 
	{
		res = (GameStorageScene*)scene;
	}
	
	return res;
}

void GameStorageUpdateFarm()
{
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameStorageScene))) 
	{
		((GameStorageScene*)scene)->UpdateFarm();
	}
}

///////////////////////////////////////////

#define title_height 28
#define bottom_height 42

#define btn_begin_x	(10)
#define btn_begin_y	(33)
#define self_btn_begin_y (156)
#define btn_inter_w	(5)
#define btn_inter_h (5)

#define storage_page_begin_y (125)
#define page_begin_y (248)
#define page_w (60)
#define page_h (26)
#define page_inter (5)

#define self_money_begin_y (255)

#define scroll_begin_x (436)
#define scroll_w (28)

#define per_scroll_len (btn_inter_h+ITEM_CELL_H)

enum
{
	eOP_Begin = 2000,
	eOP_SaveItem = eOP_Begin,
	eOP_GetItem,
	eOP_QueryItem,
	eOP_Cancel,
	
	// 农场仓库
	eOP_FarmItemSave, //存
	eOP_FarmItemGet, //取
	eOP_FarmItemClose,
	
	eOP_End,
};

enum  
{
	eCustomViewNone = 0,
	eCustomViewSave,
	eCustomViewGet,
	eCustomViewFarmItemGet,
};

IMPLEMENT_CLASS(GameStorageScene, NDScene)

GameStorageScene::GameStorageScene()
{
#define fastinit(arrvar) memset(arrvar, NULL, sizeof(arrvar))
	fastinit(m_imageMoney); fastinit(m_imageEMoney); fastinit(m_picMoney); fastinit(m_picEMoney);
	fastinit(m_imageNumMoney); fastinit(m_imageNumEMoney); fastinit(m_btnPages); fastinit(m_picPages);
	fastinit(m_Scroll); fastinit(btns);
#undef fastinit
	m_menulayerBG = NULL;
	m_imageTitle = NULL;
	m_picTitle = NULL;
	m_btnSave = NULL;
	m_btnGet = NULL;
	m_dlgKaiTong = NULL;
	m_focus = NULL;
	m_tip = NULL;
	
	m_picSave = NULL;
	m_picGet = NULL;
	
	m_viewSave = NULL; 
	m_viewGet = NULL;
	
	m_tlOperate = NULL;
	
	m_iSelRow[eTypeBag] = 0; m_iSelRow[eTypeStorage] = 0;
	m_iCurPage[eTypeBag] = 0; m_iCurPage[eTypeStorage] = 0;
	
	m_bFarmStorge = false;
	m_viewFarmItemGet = NULL;
}

GameStorageScene::~GameStorageScene()
{
	SAFE_DELETE(m_picMoney[eTypeBag]); SAFE_DELETE(m_picMoney[eTypeStorage]);
	SAFE_DELETE(m_picEMoney[eTypeBag]); SAFE_DELETE(m_picEMoney[eTypeStorage]);
	
	SAFE_DELETE(m_focus);
	
	SAFE_DELETE(m_picTitle);
}

GameStorageScene* GameStorageScene::Scene()
{
	GameStorageScene *scene = new GameStorageScene;
	scene->Initialization();
	return scene;
}

void GameStorageScene::Initialization(bool bFarmStorge/*=false*/)
{
	m_bFarmStorge = bFarmStorge;
	
	FarmStorageDialog* dlg = FarmStorageDialog::GetInstance();
	if (!dlg && m_bFarmStorge) 
	{
		return;
	}
	
	NDScene::Initialization();
	
	CGSize winSize = NDDirector::DefaultDirector()->GetWinSize();
	
	m_menulayerBG = new NDUIMenuLayer;
	m_menulayerBG->Initialization();
	this->AddChild(m_menulayerBG);
	
	if (m_menulayerBG->GetCancelBtn()) 
	{
		m_menulayerBG->GetCancelBtn()->SetDelegate(this);
	}
	
	m_picTitle = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("titles.png"));
	m_picTitle->Cut(CGRectMake(80, 140, 40, 22));
	CGSize sizeTitle = m_picTitle->GetSize();
	
	m_imageTitle =  new NDUIImage;
	m_imageTitle->Initialization();
	m_imageTitle->SetPicture(m_picTitle);
	m_imageTitle->SetFrameRect(CGRectMake((winSize.width-sizeTitle.width)/2, (title_height-sizeTitle.height)/2, sizeTitle.width, sizeTitle.height));
	m_menulayerBG->AddChild(m_imageTitle);
	
	m_picSave = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("deposit.png"));
	m_btnSave = new NDUIButton;
	m_btnSave->Initialization();
	m_btnSave->SetDelegate(this);
	m_btnSave->SetImage(m_picSave);
	m_btnSave->CloseFrame();
	CGSize sizeSave = m_picSave->GetSize();
	m_btnSave->SetFrameRect(CGRectMake(138, (winSize.height-bottom_height)+(bottom_height-sizeSave.height)/2, sizeSave.width, sizeSave.height));
	m_menulayerBG->AddChild(m_btnSave);
	
	m_picGet = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("withdrawal.png"));
	m_btnGet = new NDUIButton;
	m_btnGet->Initialization();
	m_btnGet->SetDelegate(this);
	m_btnGet->SetImage(m_picGet);
	m_btnGet->CloseFrame();
	CGSize sizeGet = m_picGet->GetSize();
	m_btnGet->SetFrameRect(CGRectMake(300, (winSize.height-bottom_height)+(bottom_height-sizeGet.height)/2, sizeGet.width, sizeGet.height));
	m_menulayerBG->AddChild(m_btnGet);

	for(int i = eTypeBegin; i < eTypeEnd; i++)
	{
	   m_picMoney[i] = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("money.png"));
	   m_picMoney[i]->Cut(CGRectMake(0, 0, 16, 16)); 
	   m_picEMoney[i] = NDPicturePool::DefaultPool()->AddPicture(NDPath::GetImgPath("emoney.png"));
	   m_picEMoney[i]->Cut(CGRectMake(0, 0, 16, 16));
	   
	   m_imageMoney[i] =  new NDUIImage;
	   m_imageMoney[i]->Initialization();
	   m_imageMoney[i]->SetPicture(m_picMoney[i]);
	   m_menulayerBG->AddChild(m_imageMoney[i]);
	   
	   m_imageEMoney[i] =  new NDUIImage;
	   m_imageEMoney[i]->Initialization();
	   m_imageEMoney[i]->SetPicture(m_picEMoney[i]);
	   m_menulayerBG->AddChild(m_imageEMoney[i]);
	}
	
	CGSize sizeMoney = m_picMoney[eTypeStorage]->GetSize();
	CGSize sizeEMoney = m_picEMoney[eTypeStorage]->GetSize();
	
	m_imageMoney[eTypeStorage]->SetFrameRect(CGRectMake(90, (title_height-sizeMoney.width)/2+3, sizeMoney.width, sizeMoney.height));
	m_imageEMoney[eTypeStorage]->SetFrameRect(CGRectMake(330, (title_height-sizeEMoney.width)/2+3, sizeEMoney.width, sizeEMoney.height));

	m_imageMoney[eTypeBag]->SetFrameRect(CGRectMake(btn_begin_x, self_money_begin_y, sizeMoney.width, sizeMoney.height));
	m_imageEMoney[eTypeBag]->SetFrameRect(CGRectMake(btn_begin_x+360, self_money_begin_y, sizeEMoney.width, sizeEMoney.height));
	
	for(int i = eTypeBegin; i < eTypeEnd; i++)
	{
	   m_imageNumMoney[i] = new ImageNumber;
	   m_imageNumMoney[i]->Initialization();
	   m_imageNumMoney[i]->SetTitleRedNumber(8888);
	   m_menulayerBG->AddChild(m_imageNumMoney[i]);
	   
	   m_imageNumEMoney[i] = new ImageNumber;
	   m_imageNumEMoney[i]->Initialization();
	   m_imageNumEMoney[i]->SetTitleRedNumber(8888);
	   m_menulayerBG->AddChild(m_imageNumEMoney[i]);
	}

	m_imageNumMoney[eTypeStorage]->SetFrameRect(CGRectMake(90+20,(title_height-sizeMoney.width)/2+3,90,11));
	m_imageNumEMoney[eTypeStorage]->SetFrameRect(CGRectMake(330+20,(title_height-sizeMoney.width)/2+3,90,11));

	m_imageNumMoney[eTypeBag]->SetFrameRect(CGRectMake(btn_begin_x+20,self_money_begin_y,90,11));
	m_imageNumEMoney[eTypeBag]->SetFrameRect(CGRectMake(btn_begin_x+360+20,self_money_begin_y,90,11));
	
	for(int i = eTypeBegin; i < eTypeEnd; i++)
	{
		int iPageBeginX = (winSize.width-page_inter*3-page_w*4)/2;
		int iPageBeginY = (i == eTypeStorage ? storage_page_begin_y : page_begin_y);
		for (int j = 0; j < MAX_PAGE_COUNT; j++)
		{
			CGSize picSize;
			m_picPages[i][j] = PictureNumber::SharedInstance()->TitleGoldNumber(j+1);
			m_btnPages[i][j] = new NDUIButton;
			m_btnPages[i][j]->Initialization();
			m_btnPages[i][j]->SetDelegate(this);
			
			picSize = m_picPages[i][j]->GetSize();
			iPageBeginX += (page_inter+page_w)*(j==0?0:1);
			
			m_btnPages[i][j]->SetFrameRect(CGRectMake(iPageBeginX, iPageBeginY, page_w, page_h));
			m_btnPages[i][j]->SetImage(m_picPages[i][j], true, CGRectMake((page_w-picSize.width)/2, (page_h-picSize.height)/2, picSize.width, picSize.height));
			m_btnPages[i][j]->SetBackgroundColor(ccc4(56, 110, 110, 255));
			m_btnPages[i][j]->CloseFrame();
			m_menulayerBG->AddChild(m_btnPages[i][j]);
		}
	}
	
	for(int i = eTypeBegin; i < eTypeEnd; i++)
	{
		int iBeginX = btn_begin_x, iBeginY = i == eTypeStorage ? btn_begin_y : self_btn_begin_y;
		for (int j=0; j < max_row*max_col; j++) 
		{
			btns[i][j] = new NDUIItemButton;
			NDUIItemButton*& btn = btns[i][j];
			btn->Initialization();
			btn->SetDelegate(this);
			btn->SetFrameRect(CGRectMake(iBeginX+(btn_inter_w+ITEM_CELL_W)*(j%max_col), iBeginY+(btn_inter_h+ITEM_CELL_H)*(j/max_col), ITEM_CELL_W, ITEM_CELL_H));

			m_menulayerBG->AddChild(btn);
			btn->ChangeItem(NULL);
		}

		m_Scroll[i] = new NDUIVerticalScrollBar;
		m_Scroll[i]->Initialization();
		m_Scroll[i]->SetFrameRect(CGRectMake(scroll_begin_x, iBeginY, scroll_w, 2*ITEM_CELL_H+btn_inter_h));
		m_Scroll[i]->SetCurrentContentY(0);
		m_Scroll[i]->SetContentHeight((container_max_row)*per_scroll_len*2);
		m_Scroll[i]->SetDelegate(this);
		m_menulayerBG->AddChild(m_Scroll[i]);
	}

	m_focus = new ItemFocus;
	m_focus->Initialization();
	m_focus->SetFrameRect(btns[eTypeStorage][0]->GetFrameRect());
	m_menulayerBG->AddChild(m_focus,0);

	m_tip = new LayerTip;
	m_tip->Initialization();
	m_tip->SetTextFontSize(13);
	m_tip->SetTextColor(ccc4(199, 89, 0, 255));
	m_tip->Hide();
	m_menulayerBG->AddChild(m_tip);
	
	m_topLayerEx = new NDUITopLayerEx;
	m_topLayerEx->Initialization();
	m_topLayerEx->SetFrameRect(CGRectMake(0, 0, winSize.width, winSize.height));
	m_menulayerBG->AddChild(m_topLayerEx);
	
	m_tlOperate = new NDUITableLayer;
	m_tlOperate->Initialization();
	m_tlOperate->VisibleSectionTitles(false);
	m_tlOperate->SetDelegate(this);
	m_tlOperate->SetVisible(false);
	m_topLayerEx->AddChild(m_tlOperate);
	
	m_btnPages[eTypeStorage][m_iCurPage[eTypeStorage]]->SetBackgroundColor(ccc4(20, 59, 64, 255));
	m_btnPages[eTypeBag][m_iCurPage[eTypeBag]]->SetBackgroundColor(ccc4(20, 59, 64, 255));
	
	for(int i = eTypeBegin; i < eTypeEnd; i++)
	{
		LoadData(i);
		UpdateGui(i);
	}
	
	UpdateMoney();
	UpdateText();
	UpdateFocus();
	
	if (m_bFarmStorge) 
	{
		for (int i = eTypeBegin; i < eTypeEnd; i++) 
		{
			if (m_imageMoney[i]) m_imageMoney[i]->SetVisible(false);
			if (m_imageEMoney[i]) m_imageEMoney[i]->SetVisible(false);
			if (m_imageNumMoney[i]) m_imageNumMoney[i]->SetVisible(false);
			if (m_imageNumEMoney[i]) m_imageNumEMoney[i]->SetVisible(false);
		}
		
		if (m_btnSave) m_btnSave->SetVisible(false);
		if (m_btnGet) m_btnGet->SetVisible(false);
	}
}

void GameStorageScene::OnButtonClick(NDUIButton* button)
{
	if (button == m_menulayerBG->GetCancelBtn())
	{
		NDDirector::DefaultDirector()->PopScene();
		return;
	}
	
	if (button == m_btnSave) 
	{
		NDPlayer& player = NDPlayer::defaultHero();
		std::stringstream ssMoney, ssEMoney;
		ssMoney << NDCommonCString("InputMoneyMax") << player.money << ")";
		ssEMoney << NDCommonCString("InputEMoneyMax") << player.eMoney << ")";
		NDUICustomView* view = new NDUICustomView;
		view->Initialization();
		view->SetDelegate(this);
		std::vector<int> vec_id; 
		std::vector<std::string> vec_str; 
		vec_id.push_back(1); vec_str.push_back(ssMoney.str());
		vec_id.push_back(2); vec_str.push_back(ssEMoney.str());
		view->SetEdit(2, vec_id, vec_str);
		view->Show();
		view->SetTag(eCustomViewSave);
		this->AddChild(view);
		return;
	}
	else if (button == m_btnGet) 
	{
		NDPlayer& player = NDPlayer::defaultHero();
		std::stringstream ssMoney, ssEMoney;
		ssMoney << NDCommonCString("InputMoneyMax") << player.iStorgeMoney << ")";
		ssEMoney << NDCommonCString("InputEMoneyMax") << player.iStorgeEmoney << ")";
		NDUICustomView *view = new NDUICustomView;
		view->Initialization();
		view->SetDelegate(this);
		std::vector<int> vec_id; 
		std::vector<std::string> vec_str; 
		vec_id.push_back(1); vec_str.push_back(ssMoney.str());
		vec_id.push_back(2); vec_str.push_back(ssEMoney.str());
		view->SetEdit(2, vec_id, vec_str);
		view->Show();
		view->SetTag(eCustomViewGet);
		this->AddChild(view);
		return;
	}
	
	for (int i = eTypeBegin; i < eTypeEnd; i++) 
	{
		for (int j = 0; j < MAX_PAGE_COUNT; j++) 
		{
			if (button == m_btnPages[i][j])
			{
				OnSelPage(i, j);
				return;
			}
		}
	}
	
	for (int i = eTypeBegin; i < eTypeEnd; i++) 
	{
		for (int j = 0; j < max_col*max_row; j++) 
		{
			if (btns[i][j] == button) 
			{
				OnSelItem(i, j);
				return;
			}
		}
	}
}

void GameStorageScene::OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section)
{
	if (table == m_tlOperate) 
	{
		if (cell && cell->IsKindOfClass(RUNTIME_CLASS(NDUIButton))) 
		{
			Item *item = GetSelItem();
			NDPlayer& player = NDPlayer::defaultHero();
			if (item && player.IsFocusNpcValid()) 
			{
				int iOP = cell->GetTag();
				int iNPCID = player.GetFocusNpcID();
				switch (iOP) 
				{
					case eOP_SaveItem:
					{
						if (!item->isItemCanStore()) {
							showDialog(NDCommonCString("tip"), NDCommonCString("ItemCantInStorage"));
						} else {
							NDTransData bao(_MSG_ITEMKEEPER);
							bao << (int)item->iID << (unsigned char)MSG_STORAGE_ITEM_IN << iNPCID;
							SEND_DATA(bao);
						}
					}
						break;
					case eOP_GetItem:
					{
						NDTransData bao(_MSG_ITEMKEEPER);
						bao << (int)item->iID << (unsigned char)MSG_STORAGE_ITEM_OUT << iNPCID;
						SEND_DATA(bao);
					}
						break;
					case eOP_QueryItem:
					{
						std::vector<std::string> vec_str;
						item->makeItemDialog(vec_str);
					}
						break;
					case eOP_Cancel:
						break;
					case eOP_FarmItemClose:
						break;
					case eOP_FarmItemSave:
					{
						FarmStorageDialog* dlg = FarmStorageDialog::GetInstance();
						if (dlg) 
						{
							const std::vector<FarmEntityData>& entitys = dlg->GetFarmEntitys();
							
							std::vector<FarmEntityData>::const_iterator it = entitys.begin();
							for (; it != entitys.end(); it++) {
								if (!(*it).node || !(*it).node->GetStateBar()) {
									continue;
								}
								NDUIStateBar *bar = (*it).node->GetStateBar();
								if (item->iItemType == (*it).itemType) {
									if (bar->GetCurNum() >= bar->GetMaxNum()) {
										showDialog(NDCommonCString("WenXinTip"), NDCommonCString("StorageFull"));
									}else {
										sendAccessInfo(2,item->iID,0);
									}
									break;
								}
							}
						}
					}
						break;
					case eOP_FarmItemGet:
					{
						NDUICustomView *view = new NDUICustomView;
						view->Initialization();
						view->SetDelegate(this);
						std::vector<int> vec_id; 
						std::vector<std::string> vec_str; 
						vec_id.push_back(1); vec_str.push_back(NDCommonCString("InputItemAmount"));
						view->SetEdit(1, vec_id, vec_str);
						view->Show();
						view->SetTag(eCustomViewFarmItemGet);
						this->AddChild(view);
					}
						break;

					default:
						break;
				}
			}
		}
	}
	
	table->SetVisible(false);
}

bool GameStorageScene::OnCustomViewConfirm(NDUICustomView* customView)
{
	VerifyViewNum(*customView);
	
	int tag = customView->GetTag();
	
	if (tag == eCustomViewFarmItemGet) 
	{
		std::string amout =	customView->GetEditText(0);
		if (amout.empty()) {
			return true;
		}
		
		int iAmount = atoi(amout.c_str());
		if (iAmount == 0) 
		{
			customView->ShowAlert(NDCommonCString("NumInvalid"));
			return false;
		}
		
		Item* item = GetSelItem();
		if (item && iAmount <= item->iAmount) {
			sendAccessInfo(1,item->iID, iAmount);
		}
		
		return true;
	}
	
	VerifyViewNum1(*customView);
	
	std::string strMoney =	customView->GetEditText(0);
	std::string strEMoney =	customView->GetEditText(1);
	
	if (strMoney.empty() && strEMoney.empty()) 
	{
		return true;
	}
	
	NDPlayer& player = NDPlayer::defaultHero();
	if (!player.IsFocusNpcValid()) 
	{
		return true;
	}
	
	int iNPCID = player.GetFocusNpcID();
	
	int iMoney = atoi(strMoney.c_str());
	int iEMoney = atoi(strEMoney.c_str());
	
	if (iMoney == 0 && iEMoney == 0) 
	{
		customView->ShowAlert(NDCommonCString("NumInvalid"));
		return false;
	}
	
	if (tag == eCustomViewSave) 
	{
		if (iMoney > player.money ) 
		{
			customView->ShowAlert(NDCommonCString("MoneyBuZhu"));
			return false;
		}
		
		if (iEMoney > player.eMoney ) 
		{
			customView->ShowAlert(NDCommonCString("EMoneyBuZhu"));
			return false;
		}
		
		if (iMoney > 0 && iMoney <= player.money ) 
		{
			NDTransData bao(_MSG_ITEMKEEPER);
			bao << iMoney << (unsigned char)MSG_STORAGE_MONEY_SAVE << iNPCID;
			SEND_DATA(bao);
		}
		
		if (iEMoney > 0 && iEMoney <= player.eMoney ) 
		{
			NDTransData bao(_MSG_ITEMKEEPER);
			bao << iEMoney << (unsigned char)MSG_STORAGE_EMONEY_SAVE << iNPCID;
			SEND_DATA(bao);
		}
	}
	else if (tag == eCustomViewGet) 
	{
		if (iMoney > player.iStorgeMoney ) 
		{
			customView->ShowAlert(NDCommonCString("MoneyBuZhu"));
			return false;
		}
		
		if (iEMoney > player.iStorgeEmoney ) 
		{
			customView->ShowAlert(NDCommonCString("EMoneyBuZhu"));
			return false;
		}
		
		if (iMoney > 0 && iMoney <= player.iStorgeMoney ) 
		{
			NDTransData bao(_MSG_ITEMKEEPER);
			bao << iMoney << (unsigned char)MSG_STORAGE_MONEY_DRAW << iNPCID;
			SEND_DATA(bao);
		}
		
		if (iEMoney > 0 && iEMoney <= player.iStorgeEmoney ) 
		{
			NDTransData bao(_MSG_ITEMKEEPER);
			bao << iEMoney << (unsigned char)MSG_STORAGE_EMONEY_DRAW << iNPCID;
			SEND_DATA(bao);
		}
	}
	
	return true;
}

void GameStorageScene::OnDialogClose(NDUIDialog* dialog)
{
	if (dialog == m_dlgKaiTong) 
	{
		m_dlgKaiTong = NULL;
	}
}

void GameStorageScene::OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex)
{
	if (dialog == m_dlgKaiTong) 
	{
		int iTag = dialog->GetTag();
		if (iTag < eTypeBegin || iTag >= eTypeEnd) 
		{
		}
		else 
		{
			ShowProgressBar;
			NDTransData bao(_MSG_LIMIT);
			bao << (unsigned char)(iTag == eTypeBag ? 1 : 0);
			SEND_DATA(bao);
		}
		
		dialog->Close();
	}	
}

void GameStorageScene::OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar)
{
	if (scrollBar == m_Scroll[eTypeStorage]) 
	{
		AdjustGui(eTypeStorage, true);
	}
	else if (scrollBar == m_Scroll[eTypeBag]) 
	{
		AdjustGui(eTypeBag, true);
	}
}

void GameStorageScene::OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar)
{
	if (scrollBar == m_Scroll[eTypeStorage]) 
	{
		AdjustGui(eTypeStorage, false);
	}
	else if (scrollBar == m_Scroll[eTypeBag]) 
	{
		AdjustGui(eTypeBag, false);
	}
}

// 0->背包, 1->仓库
void GameStorageScene::AddItem(int iType, Item& item)
{
	if (iType < eTypeBegin || iType >= eTypeEnd) 
	{
		return;
	}
	
	m_ItemInfo[iType].add(item.iID);
	UpdateGui(iType);
	UpdateText();
}

void GameStorageScene::DelItem(int iType, Item& item)
{
	if (iType < eTypeBegin || iType >= eTypeEnd) 
	{
		return;
	}
	m_ItemInfo[iType].del(item.iID);
	UpdateGui(iType);
	UpdateText();
}

void GameStorageScene::LoadData(int iType)
{
	if (iType < eTypeBegin || iType >= eTypeEnd) 
	{
		return;
	}
	
	ItemMgr& mgr = ItemMgrObj;
	
	if (!m_bFarmStorge) 
	{
		VEC_ITEM& vec_item = iType == eTypeBag ? mgr.GetPlayerBagItems() : mgr.GetStorage();
		int iPageCounts = iType == eTypeBag ? mgr.GetPlayerBagNum() : mgr.GetStorageNum();
		
		s_item_info& info = m_ItemInfo[iType];
		info.setpage(iPageCounts);
		
		VEC_ITEM_IT it = vec_item.begin();
		for (; it != vec_item.end(); it++) 
		{
			Item* item = *it;
			if (item) 
			{
				info.add(item->iID);
			}
		}
	}
	else 
	{
		VEC_ITEM vec_item;
		m_ItemInfo[iType].clear();
		if (GetFarmItem(iType, vec_item)) {
			VEC_ITEM_IT it = vec_item.begin();
			for (; it != vec_item.end(); it++) 
			{
				int iPageCounts = iType == eTypeBag ? mgr.GetPlayerBagNum() : mgr.GetStorageNum();
				
				s_item_info& info = m_ItemInfo[iType];
				info.setpage(iPageCounts);
				
				Item* item = *it;
				if (item) 
				{
					info.add(item->iID);
				}
			}
		}
	}
}

void GameStorageScene::UpdateGui(int iType)
{
	if (iType < eTypeBegin || iType >= eTypeEnd) 
	{
		return;
	}
	
	m_iCurPage[iType] = m_iCurPage[iType] < 0 || m_iCurPage[iType] >= MAX_PAGE_COUNT ? 0 : m_iCurPage[iType];
	m_iSelRow[iType] = m_iSelRow[iType] < 0 || m_iSelRow[iType] >= container_max_row-1 ? 0 : m_iSelRow[iType];
	int iStart = m_iSelRow[iType]*max_col;
	int iEnd = (m_iSelRow[iType]+2)*max_col;
	
	s_item_info& info = m_ItemInfo[iType];
	ItemMgr& mgr = ItemMgrObj;
	
	for (int i = iStart, iIndex = 0; i < iEnd; i++, iIndex++) 
	{
		Item *item = NULL;
		int iItemID = info.GetID(m_iCurPage[iType], i);
		if (iItemID != 0) 
		{
			if (m_bFarmStorge && iType == eTypeStorage) 
			{
				item = GetFarmItemByID(iItemID);
			}
			else 
			{
				mgr.HasItemByType( iType == eTypeBag ? ITEM_BAG : ITEM_STORAGE, iItemID, item);
			}			
		}
		
		if (m_iSelRow[iType] == container_max_row - 2 && iIndex >= max_row*max_col - 3 && btns[iType][iIndex]) 
		{
			btns[iType][iIndex]->SetVisible(false);
			btns[iType][iIndex]->EnableDraw(false);
		}
		else 
		{
			if (btns[iType][iIndex]) 
			{
				btns[iType][iIndex]->ChangeItem(item);
				btns[iType][iIndex]->SetTag(item == NULL ? 0 : item->iID);
			}
			btns[iType][iIndex]->SetVisible(true);
			btns[iType][iIndex]->EnableDraw(true);
		}
		
	}
}

void GameStorageScene::UpdateMoney()
{
	NDPlayer& player = NDPlayer::defaultHero();
	if ( m_imageNumMoney[eTypeStorage] ) 
		m_imageNumMoney[eTypeStorage]->SetTitleRedNumber(player.iStorgeMoney);
	if ( m_imageNumEMoney[eTypeStorage] ) 
		m_imageNumEMoney[eTypeStorage]->SetTitleRedNumber(player.iStorgeEmoney);
		
	if ( m_imageNumMoney[eTypeBag] ) 
		m_imageNumMoney[eTypeBag]->SetTitleRedNumber(player.money);
	if ( m_imageNumEMoney[eTypeBag] ) 
		m_imageNumEMoney[eTypeBag]->SetTitleRedNumber(player.eMoney);
}

void GameStorageScene::UpdateLimit(int iType)
{
	if (iType < eTypeBegin || iType >= eTypeEnd) 
	{
		return;
	}
	
	ItemMgr& mgr = ItemMgrObj;
	
	int iPageCounts = iType == eTypeBag ? mgr.GetPlayerBagNum() : mgr.GetStorageNum();
	
	s_item_info& info = m_ItemInfo[iType];
	info.setpage(iPageCounts);
}

void GameStorageScene::UpdateText()
{
	if (!m_tip) 
	{
		return;
	}
	
	std::stringstream showTextStr;
	
	Item *item = GetSelItem();
	
	if (item) 
	{
//		if (item->isEquip()) 
//		{
//			int equipAllAmount = item->getAmount_limit();
//			showTextStr << item->getItemNameWithAdd() << " 耐久度: " << Item::getdwAmountShow(item->iAmount)
//						<< "/" << Item::getdwAmountShow(equipAllAmount);
//		} 
//		else 
//		{
//			if (item->iAmount > 1) 
//			{
//				if (m_bFarmStorge && m_stFocus.iFoucsType == eTypeStorage) 
//				{
//					showTextStr << item->getItemName() << " :" << item->iAmount << "/" << item->sAge;
//				}
//				else 
//				{
//					showTextStr << item->getItemName() << " x" << item->iAmount;
//				}
//			} 
//			else 
//			{
//				showTextStr << item->getItemName();
//			}
//		}
		showTextStr << item->getItemName();
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
			
			m_tip->SetFrameRect(CGRectMake(iX, rect.origin.y+rect.size.height+2, rect.size.width, rect.size.height));
			m_tip->Show();
		}
		else 
		{
			m_tip->Hide();
		}
		
	}
}

void GameStorageScene::UpdateFocus()
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
				m_Scroll[m_stFocus.iFoucsType]->SetCurrentContentY
				(
					(2*per_scroll_len) * (m_iSelRow[m_stFocus.iFoucsType]+iRow)
				);
			}
		}
	}
}

void GameStorageScene::OnSelItem(int iType, int iIndex)
{
	if (m_stFocus.iIndex == iIndex && iType == m_stFocus.iFoucsType) 
	{
		Item *item = GetSelItem();
		if (!item) 
		{
			return;
		}
	
		if (iType == eTypeStorage) 
		{
			std::vector<std::string> vec_str; std::vector<int> vec_id;
			
			if (!m_bFarmStorge) {
				vec_str.push_back(NDCommonCString("FangRuBag")); vec_id.push_back(eOP_GetItem);
				vec_str.push_back(NDCommonCString("ViewXianQing")); vec_id.push_back(eOP_QueryItem);
				vec_str.push_back(NDCommonCString("Cancel")); vec_id.push_back(eOP_Cancel);
			}else {
				vec_str.push_back(NDCommonCString("QuChu")); vec_id.push_back(eOP_FarmItemGet);
				vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_FarmItemClose);
			}

			InitTLContent(m_tlOperate, vec_str, vec_id);
		}
		else if (iType == eTypeBag)
		{
			std::vector<std::string> vec_str; std::vector<int> vec_id;
			
			if (!m_bFarmStorge) {
				vec_str.push_back(NDCommonCString("FangRuStorage")); vec_id.push_back(eOP_SaveItem);
				vec_str.push_back(NDCommonCString("ViewXianQing")); vec_id.push_back(eOP_QueryItem);
				vec_str.push_back(NDCommonCString("Cancel")); vec_id.push_back(eOP_Cancel);
			}else {
				vec_str.push_back(NDCommonCString("storage")); vec_id.push_back(eOP_FarmItemSave);
				vec_str.push_back(NDCommonCString("return")); vec_id.push_back(eOP_FarmItemClose);
			}

			InitTLContent(m_tlOperate, vec_str, vec_id);
		}
		
		return;
	}
	m_stFocus.iIndex = iIndex;
	m_stFocus.iFoucsType = iType;
	
	UpdateFocus();
	UpdateText();
}

void GameStorageScene::AdjustGui(int iType, bool bUp )
{
	if (iType < eTypeBegin || iType >= eTypeEnd) 
	{
		return;
	}
	
	if (iType != m_stFocus.iFoucsType) 
	{
		m_stFocus.iFoucsType = iType;
		m_stFocus.iIndex = 0;
	}
	
	//int iIndex = bUp ? m_stFocus.iIndex-max_col : m_stFocus.iIndex + max_col;
	//iIndex += m_iSelRow[iType] * max_col;
	
	int iRow = m_stFocus.iIndex / max_col;
	if (iRow == 0) 
	{
		if (bUp) 
		{
			if ( m_iSelRow[iType] - 1 < 0 )
			{
				m_iSelRow[iType] = container_max_row - 2;
				m_stFocus.iIndex = max_col;
			}
			else
			{
				m_iSelRow[iType] = m_iSelRow[iType] - 1;
				m_stFocus.iIndex = 0;
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
			if (m_iSelRow[iType]  >= container_max_row - 2) 
			{
				m_iSelRow[iType] = 0;
				m_stFocus.iIndex = 0;
			}
			else 
			{
				m_iSelRow[iType] = m_iSelRow[iType] + 1;
				m_stFocus.iIndex = max_col;
			}
		}
		else
		{
			m_stFocus.iIndex = 0;
		}
	}
	
	UpdateGui(iType);
	
	UpdateFocus();
	UpdateText();
}

void GameStorageScene::OnSelPage(int iType, int iPageIndex)
{
	if (iType < eTypeBegin || iType >= eTypeEnd || iPageIndex >= MAX_PAGE_COUNT) 
	{
		return;
	}
	
	s_item_info& info = m_ItemInfo[iType];
	if (iPageIndex >= info.maxpage) 
	{
		stringstream ss; ss << NDCommonCString("YaoKaiTong");
		if (iType == eTypeStorage) 
		{
			ss << NDCommonCString("CangKu");
		}
		else
		{
			ss << NDCommonCString("Bag");
		}
		
		ss << (iPageIndex+1) << NDCommonCString("NeedSpend");
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
		m_dlgKaiTong->SetTag(iType);
		m_dlgKaiTong->SetDelegate(this);
		m_dlgKaiTong->Show("", ss.str().c_str(), NDCommonCString("Cancel"), NDCommonCString("Ok"), NULL);
	}
	else 
	{
		if (m_iCurPage[iType] != iPageIndex) 
		{
			if (m_btnPages[iType][m_iCurPage[iType]]) 
			{
				m_btnPages[iType][m_iCurPage[iType]]->SetBackgroundColor(ccc4(56, 110, 110, 255));
			}
			if (m_btnPages[iType][iPageIndex]) 
			{
				m_btnPages[iType][iPageIndex]->SetBackgroundColor(ccc4(20, 59, 64, 255));
			}
			
			m_iCurPage[iType] = iPageIndex;
			
			m_iSelRow[iType] = 0;
			
			if (m_stFocus.iFoucsType == iType) 
			{
				m_stFocus.iIndex = -1;
				m_stFocus.bHasFoucs = false;
			}
			
			UpdateGui(iType);
			
			UpdateFocus();
			
			UpdateText();
		}
	}

}

Item* GameStorageScene::GetSelItem()
{
	Item *res = NULL;
	
	if (m_stFocus.iIndex == -1 || m_stFocus.iFoucsType < eTypeBegin || m_stFocus.iFoucsType >= eTypeEnd) 
	{
		return res;
	}
	
	s_item_info& info = m_ItemInfo[m_stFocus.iFoucsType];
	
	int iIndex = m_iSelRow[m_stFocus.iFoucsType]*max_col + m_stFocus.iIndex;
	int iItemID = info.GetID(m_iCurPage[m_stFocus.iFoucsType], iIndex);
	if (iItemID != 0) 
	{
		if (m_stFocus.iFoucsType == eTypeStorage && m_bFarmStorge) 
		{
			res = GetFarmItemByID(iItemID);
		}
		else 
		{
			ItemMgrObj.HasItemByType( m_stFocus.iFoucsType == eTypeBag ? ITEM_BAG : ITEM_STORAGE, iItemID, res);
		}
	}
	
	return res;
}

void GameStorageScene::InitTLContent(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id)
{
#define fastinit(text, iid) \
do \
{ \
NDUIButton *button = new NDUIButton; \
button->Initialization(); \
button->SetFrameRect(CGRectMake(0, 0, 120, 30)); \
button->SetTitle(text); \
button->SetTag(iid); \
button->SetFocusColor(ccc4(253, 253, 253, 255)); \
section->AddCell(button); \
} while (0);
	
	if (!tl || vec_str.empty() || vec_str.size() != vec_id.size())
	{
		return;
	}
	
	NDDataSource *dataSource = new NDDataSource;
	NDSection *section = new NDSection;
	section->UseCellHeight(true);
	std::vector<std::string>::iterator it = vec_str.begin();
	for (int iIDIndex = 0; it != vec_str.end(); it++, iIDIndex++)
	{
		fastinit(((*it).c_str()), vec_id[iIDIndex])
	}
	section->SetFocusOnCell(0);
	dataSource->AddSection(section);
	
	tl->SetFrameRect(CGRectMake((480-120)/2, (320-30*vec_str.size()-vec_str.size()-1)/2, 120, 30*vec_str.size()+vec_str.size()+1));
	tl->SetVisible(true);
	
	if (tl->GetDataSource())
	{
		tl->SetDataSource(dataSource);
		tl->ReflashData();
	}
	else
	{
		tl->SetDataSource(dataSource);
	}
	
#undef fastinit
}

bool GameStorageScene::GetFarmItem(int iType, VEC_ITEM& vec_item)
{
	FarmStorageDialog* dlg = FarmStorageDialog::GetInstance();
	if (!dlg) 
	{
		return false;
	}
	
	if (iType == eTypeStorage) 
	{
		for_vec(m_vecFarmItem, VEC_ITEM_IT)
		{
			delete *it;
		}
		m_vecFarmItem.clear();
		
		const std::vector<FarmEntityData>& entitys = dlg->GetFarmEntitys();
		
		std::vector<FarmEntityData>::const_iterator it = entitys.begin();
		for (; it != entitys.end(); it++) {
			if (!(*it).node || !(*it).node->GetStateBar()) {
				continue;
			}
			NDUIStateBar* bar = (*it).node->GetStateBar();
			if (bar->GetCurNum() > 0) {
				Item *item = new Item((*it).itemType);
				item->iID = ((*it).node)->GetTag();
				item->iAmount = bar->GetCurNum();
				item->sAge = bar->GetMaxNum();
				vec_item.push_back(item);
				m_vecFarmItem.push_back(item);
			}
		}
		
		return true;
	}
	else if (iType == eTypeBag)
	{
		int constrains[2] = {8,1};
		VEC_ITEM& bag = ItemMgrObj.GetPlayerBagItems();
		for_vec(bag, VEC_ITEM_IT)
		{
			Item *t_item = *it;
			
			if (t_item->iItemType == 59000030 || t_item->iItemType == 59000020) 
			{
				vec_item.push_back(t_item);
				continue;
			}
			
			std::vector<int> t_itemType = Item::getItemType(t_item->iItemType);
			for(int j=0;j<2;j++){
				if(t_itemType[j] != constrains[j]){
					break;
				}
				if(j==1){
					vec_item.push_back(t_item);
				}
			}
		}
		return true;
	}
	
	return false;
}

/**发送庄园仓库存取消息*/
void GameStorageScene::sendAccessInfo(int act,int itemID,int amount)
{
	ShowProgressBar;
	NDTransData bao(_MSG_STORAGE_ACCESS);
	bao << (unsigned char)act << int(itemID) << int(amount);
	SEND_DATA(bao);
}

Item* GameStorageScene::GetFarmItemByID(int iItemID)
{
	for_vec(m_vecFarmItem, VEC_ITEM_IT)
	{
		if ((*it)->iID == iItemID) 
		{
			return *it;
		}
	}
	
	return NULL;
}

void GameStorageScene::UpdateFarm()
{
	if (m_bFarmStorge) 
	{
		LoadData(eTypeStorage);
		UpdateGui(eTypeStorage);
		LoadData(eTypeBag);
		UpdateGui(eTypeBag);
		UpdateText();
	}
}
