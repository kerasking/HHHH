/*
 *  GameItemInlay.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-8-13.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_ITEM_INLAY_H_
#define _GAME_ITEM_INLAY_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "GameItemBag.h"
#include "Item.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUICustomView.h"
#include "NDUISpecialLayer.h"

using namespace NDEngine;

class GameInlayScene : 
	public NDScene, 
	public NDUIButtonDelegate
	//public NDUITableLayerDelegate ///< ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
{
public:
	DECLARE_CLASS(GameInlayScene)
public:
	GameInlayScene();
	~GameInlayScene();
	void Initialization(int itemID, int itemType); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);  override
private:
	void InitCellItem(int iIndex, Item* item, bool bShow);
private:
	enum  
	{
		e_display_col = 8,
		e_display_row = 4,
	};
	CellInfo *m_stoneInfo[e_display_col*e_display_row];
	int m_iFocusIndex;
	ItemFocus *m_itemfocus;
	NDUITableLayer *m_tlShare;
	NDUIMenuLayer	*m_menuLayer;
	NDUITopLayer	*m_toplayer;
	NDUILayer		*m_layerBGTitle;
	NDUILabel		*m_lbTitle;
	NDPicture *m_picInlay; NDUIImage *m_imageInlay;
	int m_iItemID;
	NDUIPolygon *m_polygonCorner[4];
	NDUILine	*m_line[12];
	bool m_bStone;
};

#endif // _GAME_ITEM_INLAY_H_