/*
 *  EquipForgeScene.h
 *  DragonDrive
 *
 *  Created by wq on 11-9-7.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __EQUIP_FORGE_SCENE_H__
#define __EQUIP_FORGE_SCENE_H__

#include "NDCommonScene.h"
#include "NewGamePlayerBag.h"

using namespace NDEngine;

/***
* ÁÙÊ±ÐÔ×¢ÊÍ ¹ùºÆ
* this class
*/
// class EquipForgeScene :
// 	public NDCommonScene,
// 	public NDUIDialogDelegate
// {
// 	DECLARE_CLASS(EquipForgeScene)
// 	static EquipForgeScene* s_instance;
// public:
// 	static EquipForgeScene* GetCurInstance() {
// 		return s_instance;
// 	}
// 	
// 	void processEquipImprove();
// 	void processDelItem(int idItem);
// 	
// public:
// 	EquipForgeScene();
// 	~EquipForgeScene();
// 	
// 	void Initialization(); override
// 	
// 	void OnButtonClick(NDUIButton* button);
// 	
// 	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch);
// 	
// 	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch);
// 	
// 	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange);
// 	
// 	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex);
// 	
// private:
// 	NewGameItemBag* m_bag;
// 	NDUILabel* m_lbEquipForge;
// 	NDUILabelScrollLayer* m_lbEquipDes;
// 	NDUILabel* m_lbConsumeItem;
// 	NDUILabel* m_lbConsumeMoney;
// 	NDUILabel* m_lbConsumeFuzhu;
// 	NDUIButton* m_btnConfirm;
// 	NDUIItemButton* m_equipForge;
// 	NDUIItemButton* m_itemFuzhu;
// 	NDUIImage *m_imageMouse;
// 	Item* m_forgeItem;
// 	Item* m_fuzhuItem;
// 	
// private:
// 	void RefreshEnancedInfo(Item* item);
// 	int getAddPoint(int enhancedId, Byte btAddition, int srcPoint);
// };

#endif