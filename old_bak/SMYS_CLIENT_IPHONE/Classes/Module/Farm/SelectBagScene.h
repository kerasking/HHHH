/*
 *  SelectBagScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-5-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _SELECT_BAG_SCENE_H_
#define _SELECT_BAG_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "GameItemBag.h"
#include "NDUIButton.h"
#include "ImageNumber.h"

using namespace NDEngine;

class SelectBagScene :
public NDScene,
public GameItemBagDelegate,
public NDUIButtonDelegate
{
	DECLARE_CLASS(SelectBagScene)
public:
	SelectBagScene();
	~SelectBagScene();
	
	void Initialization(int iType, int iNpcID); override
	
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	
	void OnButtonClick(NDUIButton* button); override
	
	void AfterClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
private:
	void UpdateBag();
	
private:
	NDUIMenuLayer	*m_menuLayer;
	GameItemBag	*m_itembagPlayer;
	
	ImageNumber *m_imageNumMoney, *m_imageNumEMoney;
	
	NDPicture		*m_picMoney, *m_picEMoney;
	NDUIImage		*m_imageMoney, *m_imageEMoney;
	
	//NDPicture		*m_picBag; NDUIImage *m_imageBag;
	
	NDUILabel		*m_lbTitle;
	int m_iType, m_iNpcID;
};



#endif //_SELECT_BAG_SCENE_H_