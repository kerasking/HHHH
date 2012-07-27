/*
 *  GameStorageScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-23.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_STORAGE_SCENE_H_
#define _GAME_STORAGE_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "NDUITableLayer.h"
#include "NDUICustomView.h"
#include "GameItemBag.h"
#include "NDUIDialog.h"
#include "NDUIImage.h"

using namespace NDEngine;

enum
{
	eGameStorage_Storage = 0,
	eGameStorage_Bag,
};

// iType->0(仓库), 1(背包)
void GameStorageAddItem(int iType, Item& item);

// iType->0(仓库), 1(背包)
void GameStorageDelItem(int iType, Item& item);

void GameStorageUpdateMoney();

// iType->0(仓库), 1(背包)
void GameStorageUpdateLimit(int iType);

void GameStorageUpdateFarm();

///////////////////////////////////////////

class Item;
class ImageNumber;
class NDUIItemButton;
class LayerTip;
class NDUITopLayerEx;

class  GameStorageScene :
public NDScene,
public NDUIButtonDelegate,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public NDUICustomViewDelegate,
public NDUIDialogDelegate,
public NDUIVerticalScrollBarDelegate
{
	DECLARE_CLASS( GameStorageScene)
public:
	 GameStorageScene();
	 ~GameStorageScene();
	
	static GameStorageScene* Scene();
	void Initialization(bool bFarmStorge=false); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnDialogClose(NDUIDialog* dialog); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void OnVerticalScrollBarUpClick(NDUIVerticalScrollBar* scrollBar); override
	void OnVerticalScrollBarDownClick(NDUIVerticalScrollBar* scrollBar); override
	
	// iType-> 0(仓库), 1(背包)
	void AddItem(int iType, Item& item);
	void DelItem(int iType, Item& item);
	void UpdateMoney();
	
	// iType->0(仓库), 1(背包)
	void UpdateLimit(int iType);
	
	void UpdateFarm();
private:
	void LoadData(int iType);
	void UpdateGui(int iType);
	void UpdateText();
	void UpdateFocus();
	
	void OnSelItem(int iType, int iIndex);
	void AdjustGui(int iType, bool bUp );
	void OnSelPage(int iType, int iPageIndex);
	
	Item* GetSelItem();
	
	void InitTLContent(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	
	bool GetFarmItem(int iType, std::vector<Item*>& vec_item);
	void sendAccessInfo(int act,int itemID,int amount);
	
	Item* GetFarmItemByID(int iItemID);
private:
	enum { eTypeBegin = 0, eTypeStorage = eTypeBegin, eTypeBag, eTypeEnd, };
	NDUIMenuLayer *m_menulayerBG;
	NDUIImage *m_imageTitle; NDPicture *m_picTitle;
	NDUIButton *m_btnSave, *m_btnGet; NDPicture *m_picSave, *m_picGet;
	
	NDUIImage *m_imageMoney[eTypeEnd], *m_imageEMoney[eTypeEnd];
	NDPicture *m_picMoney[eTypeEnd], *m_picEMoney[eTypeEnd];
	ImageNumber *m_imageNumMoney[eTypeEnd], *m_imageNumEMoney[eTypeEnd];
	
	NDUIButton *m_btnPages[eTypeEnd][MAX_PAGE_COUNT]; NDPicture *m_picPages[eTypeEnd][MAX_PAGE_COUNT];
	
	NDUIVerticalScrollBar *m_Scroll[eTypeEnd];
	
	enum{ max_row =2, max_col=9,};
	NDUIItemButton *btns[eTypeEnd][max_row*max_col];
	
	NDUIDialog *m_dlgKaiTong;
	
	NDUICustomView *m_viewSave, *m_viewGet;

	ItemFocus *m_focus;
	
	LayerTip *m_tip;
	
	NDUITableLayer *m_tlOperate;
	
	NDUITopLayerEx	*m_topLayerEx;
	
	struct s_focusinfo 
	{
		int iFoucsType;
		int iIndex;
		bool bHasFoucs;
		s_focusinfo(){ iFoucsType=eTypeStorage; iIndex = 0;}
	};
	
	s_focusinfo m_stFocus;
	
	enum { container_max_row = 3,};
	int m_iSelRow[eTypeEnd];
	int m_iCurPage[eTypeEnd];	
	
	struct s_item_info
	{
		int ids[MAX_PAGE_COUNT][24];
		int maxpage;
		
		s_item_info(){ 
			clear();
		}
		
		void clear() { memset(ids, 0, sizeof(ids)); maxpage = 0; }
		
		void setpage(int page) { 
			if (page < 0) maxpage = 0;
			else if (page > MAX_PAGE_COUNT) maxpage = MAX_PAGE_COUNT;
			else maxpage = page;
		}
		
		int add(int iID){
			if (iID <= 0) {
				return -1;
			}
			for (int i = 0; i < maxpage; i++) {
				for (int j = 0; j < 24; j++) {
					if (ids[i][j] == 0)
					{
						ids[i][j] = iID;
						return i*24+j;
					}
				}
			}
			return -1;
		}
		
		int del(int iID){
			if (iID <= 0) {
				return -1;
			}
			for (int i = 0; i < maxpage; i++) {
				for (int j = 0; j < 24; j++) {
					if (ids[i][j] == iID)
					{
						ids[i][j] = 0;
						return i*24+j;
					}
				}
			}
			return -1;
		}
		
		int GetID(int iPageIndex, int iIndex){
			if (iPageIndex < 0 || iPageIndex >= maxpage || iIndex < 0 || iIndex >= 24) return 0;
			return ids[iPageIndex][iIndex];
		}
	};
	s_item_info m_ItemInfo[eTypeEnd];
	
	bool m_bFarmStorge;
	std::vector<Item*> m_vecFarmItem;
	NDUICustomView *m_viewFarmItemGet;
};

#endif // _GAME_STORAGE_SCENE_H_