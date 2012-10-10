/*
 *  RemoveStoneScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "GameItemBag.h"
#include "NDUICheckBox.h"
#include "NDUIDialog.h"
#include "NDUIItemButton.h"
#include "NDUICheckBox.h"

using namespace NDEngine;

class RemoveStoneScene :
public NDScene,
public NDUIButtonDelegate,
public GameItemBagDelegate,
public NDUIDialogDelegate,
public NDUICheckBoxDelegate
{
	DECLARE_CLASS(RemoveStoneScene)
	
public:
	RemoveStoneScene();
	~RemoveStoneScene();
	
	void Initialization(); hide
	
	void OnButtonClick(NDUIButton* button); override
	
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	
	void OnDialogClose(NDUIDialog* dialog); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	
	void OnCBClick( NDUICheckBox* cb ); override
	
	static void Refresh();
private:
	void ResetGui();
	
	void UpdateEquipInfo(Item* item);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUIItemButton *m_btnEquip;
	GameItemBag *m_itemBag;
	NDPicture *m_picTitle;
	NDUILabel *m_lbName;
	NDUICheckBox *m_check;
	
	enum { eStoneNum = 6,};
	NDUIItemButton *m_btnStoneItem[eStoneNum];
	bool m_StoneDigout[eStoneNum];
	int m_iStoneFocusIndex;

	ItemFocus *m_itemfocus;
	enum { foucus_equip=10, focus_bag, focus_other,};
	int m_iFocusIndex;
	int m_iCurOperateIndex;
	NDUIDialog *m_dlgBag;
	NDUIDialog *m_dlgSend;
	
private:
	static RemoveStoneScene* s_instance;
};
