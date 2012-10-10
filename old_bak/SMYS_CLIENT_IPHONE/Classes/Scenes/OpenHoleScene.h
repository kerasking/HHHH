/*
 *  OpenHoleScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
 
 #ifndef _OPEN_HOLE_SCENE_H_
 #define _OPEN_HOLE_SCENE_H_
 
#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "GameItemBag.h"
#include "NDUICheckBox.h"
#include "NDUIDialog.h"
#include "NDUIItemButton.h"

using namespace NDEngine;

class OpenHoleScene :
public NDScene,
public NDUIButtonDelegate,
public GameItemBagDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(OpenHoleScene)
	
public:
	OpenHoleScene();
	~OpenHoleScene();
	
	void Initialization(); hide
	
	void OnButtonClick(NDUIButton* button); override
	
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	
	void OnClickPage(GameItemBag* itembag, int iPage); override
	
	void OnDialogClose(NDUIDialog* dialog); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	static void Refresh();
private:
	void OnSelect(Item* item);
	void UpdateEquipInfo(Item* item);
	void ResetGui();;
	int GetMaterialCount();
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUIItemButton *m_btnEquip;
	GameItemBag *m_itemBag;
	NDUILabel *m_lbTip;
private:
	static OpenHoleScene* s_instance;
};

 
 #endif // _OPEN_HOLE_SCENE_H_

