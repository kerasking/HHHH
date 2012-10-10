/*
 *  GameItemBag.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-21.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_ITEM_BAG_H_
#define _GAME_ITEM_BAG_H_

#include "NDUILayer.h"
#include "NDUIButton.h"
#include "NDPicture.h"
#include "NDUIImage.h"
#include "Item.h"
#include "NDUIBaseGraphics.h"
#include "define.h"
#include "NDUIDialog.h"
#include <vector>

using namespace NDEngine;
using namespace std;

#define ITEM_BAG_W						(275)
#define ITEM_BAG_H						(240)

#define ITEM_CELL_INTERVAL_W			(2)
#define ITEM_CELL_INTERVAL_H			(3)

#define ITEM_CELL_W						(42)
#define ITEM_CELL_H						(42)

#define MAX_PAGE_COUNT					(4)
#define MAX_CELL_PER_PAGE				(24)

#define ITEM_BAG_C						(6)
#define ITEM_BAG_R						(4)

#define BKCOLOR4 (ccc4(227, 229, 218, 255))
#define BKCOLOR3 (ccc3(227, 229, 218))

#define FOCUS_DURATION_TIME (15)

struct CellInfo 
{
	NDUIButton		*button; 
	NDPicture		*m_picBack;
	NDPicture		*m_picItem;
	Item			*item;
	NDUILayer		*backDackLayer;
	NDUIImage		*m_imgBack;
	
	CellInfo()
	{
		button = NULL;
		m_picBack = NULL;
		m_picItem = NULL;
		item = NULL;
		backDackLayer = NULL;
		m_imgBack = NULL;
	}
	
	void setBackDack(bool bSet){ 
		if(backDackLayer){
			backDackLayer->EnableDraw(bSet);
		}
	}
};

class ItemFocus;
class Item;
class GameItemBag;
class GameItemBagDelegate
{
public:
	virtual void OnClickPage(GameItemBag* itembag, int iPage)													{}
	/**bFocused,表示该事件发生前该Cell是否处于Focus状态*/
	virtual bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)		{ return false;}
	/*ret=true*/
	virtual void AfterClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused)		{}
};

class GameItemBag : public NDUILayer , public NDUIButtonDelegate, public NDUIDialogDelegate
{
	DECLARE_CLASS(GameItemBag)
public:
	GameItemBag();
	~GameItemBag();
	
	void Initialization(vector<Item*>& itemlist); override
	void SetPageCount(int iPage){ if(iPage<=0) return; m_iTotalPage = iPage > MAX_PAGE_COUNT ? MAX_PAGE_COUNT : iPage; }
	void draw(); override
	void OnButtonClick(NDUIButton* button); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void UpdateItemBag(vector<Item*>& itemlist);
	void UpdateItemBag(vector<Item*>& itemlist, vector<int> filter);
	bool AddItem(Item* item);
	bool DelItem(int iItemID);
	bool AddItemByIndex(int iCellIndex, Item* item);
	bool DelItemByIndex(int iCellIndex);
	bool IsFocus();
	void DeFocus();
	void SetTitle(string title);
	void SetTitleColor(ccColor4B color);
	Item* GetFocusItem();
	/**更新当前选中物品文本*/
	void UpdateTitle();
	
	// 获取某页某个索引物品
	Item* GetItem(int iPage, int iIndex);
	
	//该接口只提供给网络消息用来设置背包数
	static void UpdateBagNum(int iNum);
private:
	void ShowFocus();
	void ShowPage(int iPage);
	void HidePage(int iPage);
	void InitCellItem(int iIndex, Item* item, bool bShow);
private:
	CellInfo* m_arrCellInfo[MAX_CELL_PER_PAGE*MAX_PAGE_COUNT];
	NDUILayer *m_backlayer;
	NDUILabel *m_lbTitle;
	NDUIButton *m_btnPages[MAX_PAGE_COUNT]; NDPicture *m_picPages[MAX_PAGE_COUNT];
	NDUIImage *m_imagePages[MAX_PAGE_COUNT];
	
	NDUIPolygon *m_polygonCorner[4];
	NDUILine	*m_line[12];
	
	int m_iCurpage;
	int m_iFocusIndex;
	ItemFocus *m_itemfocus;
public:
	static int m_iTotalPage;
};
////////////////////////////////////////////////////////////////
class ItemFocus : public NDUINode
{
	DECLARE_CLASS(ItemFocus)
public:
	ItemFocus();
	~ItemFocus();
	
	void Initialization(); override
	void draw(); override
	void SetFrameRect(CGRect rect);
private:
	void ResetFocus();
	void Update();
private:
	NDPicture *m_picFocus; NDPicture *m_picFocusMirror; CGSize m_sizeFocus;
	NDUIImage *m_imageFocus, *m_imageFocusMirror;
	
	unsigned int m_iFocusUpdateDif;
	unsigned int m_iFocusCurFrame;
};

#endif // _GAME_ITEM_BAG_H_ 