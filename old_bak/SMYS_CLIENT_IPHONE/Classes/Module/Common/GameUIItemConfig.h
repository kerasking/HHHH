/*
 *  GameUIItemConfig.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-4.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_UI_ITEM_CONFIG_H_
#define _GAME_UI_ITEM_CONFIG_H_

#include "NDUIItemButton.h"
#include "NDUILayer.h"
#include "Item.h"
#include "NDDataPersist.h"
#include "GameNewItemBag.h"
#include "NDScene.h"

using namespace NDEngine;

#pragma mark 战斗内物品配置

class GameUIItemConfigDelegate
{
public:
	virtual void OnItemConfigFinish() {}
};

class GameUIItemConfig :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(GameUIItemConfig)
	
public:
	
	GameUIItemConfig();
	
	~GameUIItemConfig();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	
	void refreshButtons(std::vector<Item*>& vec_item);
	
	void refreshSpeedBar(std::vector<Item*>& vec_item);
	
private:
	void SetSpeedBar(unsigned int index, Item* item);
	
	void SwapSpeedBar(unsigned int src, unsigned int dest);
	
	void LoadSpeedBarData();
	
	void SaveSpeedBarData();
	
	void AddPageItemBtn();
	
	void AddPageBtn();
	
	void AddSpeedBtn();
	
	void ShowPage();
	
	int findSpeedBarEmptyPos(int itemtype, bool insert=false);
	
	void draw(); override

private:
	enum { max_page = 4, };
	
	std::vector<NDUIItemButton*> m_vecBtn, m_vecSpeedBtn;
	
	NDUIButton *m_btnPage[max_page];

	//NDUILayer		*m_layerSpeedBar;
	
	std::vector<ItemBarCellInfo> m_vecSpeedBar;
	
	unsigned int m_curPage;
	
	std::map<int, Item*> m_recyleItems;
	
	std::map<int, NDPicture*> m_recylePictures;
	
	NDUIButton *m_btnClose;
	
	NDUIImage *m_imageMouse;
	
	NewGameItemBag *m_bag;
	
	NDPicture *m_picOption, *m_picOptionSel;
	
	NDPicture *m_picSpeedNums[3];
};

#pragma mark 主界面物品配置

class GameMainUIItemConfigDelegate
{
public:
	virtual void OnItemConfigFinish() {}
};

class GameMainUIItemConfig :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(GameMainUIItemConfig)
	
public:
	
	GameMainUIItemConfig();
	
	~GameMainUIItemConfig();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	
	void refreshButtons(std::vector<Item*>& vec_item);
	
	void refreshSpeedBar(std::vector<Item*>& vec_item);
	
private:
	void SetSpeedBar(unsigned int index, Item* item);
	
	void SwapSpeedBar(unsigned int src, unsigned int dest);
	
	void LoadSpeedBarData();
	
	void SaveSpeedBarData();
	
	void AddPageItemBtn();
	
	void AddPageBtn();
	
	void AddSpeedBtn();
	
	void ShowPage();
	
	int findSpeedBarEmptyPos(int itemtype, bool insert=false);
	
	void draw(); override
	
private:
	enum { max_page = 4, };
	
	std::vector<NDUIItemButton*> m_vecBtn, m_vecSpeedBtn;
	
	NDUIButton *m_btnPage[max_page];
	
	//NDUILayer		*m_layerSpeedBar;
	
	std::vector<ItemBarCellInfo> m_vecSpeedBar;
	
	unsigned int m_curPage;
	
	std::map<int, Item*> m_recyleItems;
	
	std::map<int, NDPicture*> m_recylePictures;
	
	NDUIButton *m_btnClose;
	
	NDUIImage *m_imageMouse;
	
	NewGameItemBag *m_bag;
	
	NDPicture *m_picOption, *m_picOptionSel;
	
	NDPicture *m_picSpeedNums[3];
};

class GameMainUIItemConfigScene : public NDScene
{
	DECLARE_CLASS(GameMainUIItemConfigScene)
	
static GameMainUIItemConfigScene* Scene();
};

#endif // _GAME_UI_ITEM_CONFIG_H_