/*
 *  EquipUpgradeScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-4-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _EQUIP_UP_GRADE_SCENE_H_
#define _EQUIP_UP_GRADE_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "NDUIButton.h"
#include "GameItemBag.h"
#include "NDUICheckBox.h"
#include "NDUIDialog.h"
#include "NDUIItemButton.h"

using namespace NDEngine;

enum  
{
	EQUIP_UPGRADE = 1, // 装备改良
	EQUIP_ENHANCE = 2, // 装备追加
	EQUIP_UPLEVEL = 3, // 装备升级
};
enum
{
	EQUIP_IM_QUALITY = 0, // 装备升级上发 (下发时表成功)
	EQUIP_IM_QUALITY_FALSE = 1, // 装备升级下发表失败
	EQUIP_IM_ENHANCE = 2, // 上发 (下发时表成功)
	EQUIP_IM_ENHANCE_FALSE = 3,// 下发表失败
	EQUIP_IM_ADD_HOLE = 4,// 开洞
	EQUIP_IM_QUALITY_DISTROY = 5, // 装备升级 直接爆掉
	EQUIP_IM_UPLEV = 6,
};

class EquipUpgradeScene :
public NDScene,
public NDUIButtonDelegate,
public GameItemBagDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(EquipUpgradeScene)
	
public:
	EquipUpgradeScene();
	~EquipUpgradeScene();
	
	void Initialization(int iType); hide
	
	void OnButtonClick(NDUIButton* button); override
	
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	
	void OnDialogClose(NDUIDialog* dialog); override
	
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override

	static void Refresh();
private:
	void ResetGui();
	Item* checkHasItem(int itemType);
	bool checkItemCanEnhance(Item* item);
	bool checkIsEquip(Item* item);
	void PushEquip(Item* item);
private:
	NDUIMenuLayer *m_menulayerBG;
	NDUIItemButton *m_btnEquip, *m_btnEquip2;
	GameItemBag *m_itemBag;
	NDPicture *m_picTitle;
	NDUILabel *m_lbName, *m_lbName2;
	
	int m_iType;
	ItemFocus *m_itemfocus;
	bool m_bFoucusEquip;
	int m_iCurOperateIndex;
	NDUIDialog *m_dlgBag;
	NDUIDialog *m_dlgSend;
	
private:
	static EquipUpgradeScene* s_instance;
};

#endif // _EQUIP_UP_GRADE_SCENE_H_