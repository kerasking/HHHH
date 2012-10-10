/*
 *  NewEquipRepair.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-9-27.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
 
#ifndef _NEW_EQUIP_REPAIR_H_
#define _NEW_EQUIP_REPAIR_H_
 
#include "NDCommonScene.h"
#include "GameNewItemBag.h"
#include "NDUIItemButton.h"
#include "NDUIDialog.h"
#include "NDLightEffect.h"
#include "NDCommonControl.h"

class NewEquipRepairLayer :
public NDUILayer,
public NDUIButtonDelegate,
public NewGameItemBagDelegate,
public NDUIDialogDelegate
{
	DECLARE_CLASS(NewEquipRepairLayer)
	
public:
	NewEquipRepairLayer();
	~NewEquipRepairLayer();
	
	void Initialization(); override
	void OnButtonClick(NDUIButton* button); override
	bool OnButtonLongClick(NDUIButton* button); override
	bool OnClickCell(NewGameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	void OnClickPage(NewGameItemBag* itembag, int iPage); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void dealRepairAll();
	void refresh();
private:
	void UpdateEquipList();
	void InitEquipItemList(int iEquipPos, Item* item);
	void ShowHammerAni(bool show, CGRect rect=CGRectZero);
	void ShowHammerAllAni(bool show);
	void repairItem(Item* item);
	void repairAllItem();
	int getEquipRepairCharge(Item* item, int type);// type表示0修单件还是1全部
	int repairEveryMoney(int equipPrice, int dwAmount,int equipAllAmount);
private:
	static NewEquipRepairLayer* s_instance;
	NewGameItemBag *m_itembagPlayer;
	NDUILayer		*m_layerEquip;
	NDUIItemButton	*m_cellinfoEquip[Item::eEP_End];
	Item			*m_curItem;
	NDUISpriteNode	*m_hammer;
	NDUISpriteNode	*m_hammerAll;
	NDUIButton		*m_btnAll;
	unsigned int	m_uiCurPage;
public:
	static void refreshAmount(){}
};

class NewEquipRepairScene :
public NDCommonScene
{
	DECLARE_CLASS(NewEquipRepairScene)
	
public:	
	NewEquipRepairScene();
	
	~NewEquipRepairScene();
	
	static NewEquipRepairScene* Scene();
	
	void Initialization(); override
	
	void OnButtonClick(NDUIButton* button); override
	
private:
	NewEquipRepairLayer *m_layerRepair;
private:
	void InitRepair(NDUIClientLayer* client);
};

#endif // _NEW_EQUIP_REPAIR_H_
