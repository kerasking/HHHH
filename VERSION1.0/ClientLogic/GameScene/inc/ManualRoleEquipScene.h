/*
 *  ManualRoleEquipScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-3-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MANUAL_ROLE_EQUIP_SCENE_H_
#define _MANUAL_ROLE_EQUIP_SCENE_H_

#include "NDScene.h"
#include "NDUIButton.h"
#include "NDUILayer.h"
#include "NDManualRole.h"
#include "NDUIMenuLayer.h"
#include "NDUILabel.h"
#include "NDUIImage.h"
#include "NDPicture.h"
#include "NDUIDialog.h"
#include "GameItemBag.h"

using namespace NDEngine;

class Item;
class ManualRoleNode : public NDUILayer
{
	DECLARE_CLASS(ManualRoleNode)
public:
	ManualRoleNode();
	~ManualRoleNode();
	
	void Initialization(int lookface, int iID); hide
	void draw(); override
	
	void uppackEquip(int iPos);
	void unpackAllEquip();
	void packEquip(Item* equip);
	void setPosition(CCPoint pos);
	void setFace(bool bRight);
	int getID();
	
	void Hide();
	void Show();
private:
	NDManualRole		*m_role;
};

////////////////////////////////////////

//class NDUIMenuLayer;
//class NDUILayer;
//class NDUILabel;
//class NDUIImage;
//class NDPicture;
class NDUIItemButton;
class TextBGLayer;

/***
* 临时性注释 郭浩
* this class
*/
// class ManualRoleEquipScene :
// public NDScene,
// public NDUIButtonDelegate,
// public NDUIDialogDelegate
// {
// 	DECLARE_CLASS(ManualRoleEquipScene)
// public:
// 	ManualRoleEquipScene();
// 	~ManualRoleEquipScene();
// 	
// 	void Initialization(); override
// 	void OnButtonClick(NDUIButton* button); override
// 	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
// 	
// 	void SetRole(int lookface, int iID);
// 	void LoadRoleEquip(std::vector<Item*>& vec_item);
// 	
// 	Item* GetSuitItem(int idItem);
// private:
// 	int GetItemPos(Item& item);
// 	void OnSelItem(int iIndex, bool bHasFocus);
// 	std::string getEquipPositionInfo(int index);
// private:
// 	enum  
// 	{
// 		eMR_Begin = 0,				 
// 		eMR_HuJian = eMR_Begin,		// 护肩
// 		eMR_TouKui,					// 头盔
// 		eMR_YiFu,					// 衣服
// 		eMR_XianLiang,				// 项链
// 		eMR_ErHuan,					// 耳环
// 		eMR_PiFeng,					// 披风
// 		eMR_WuQi,					// 武器
// 		eMR_FuShou,					// 副手
// 		eMR_HuiJi,					// 徽记
// 		eMR_FuWang,					// 护腕
// 		eMR_Pet,					// 宠物
// 		eMR_HuTui,					// 护腿
// 		eMR_XieZhi,					// 鞋子
// 		eMR_LRing,					// 戒指
// 		eMR_RRing,					// 戒指
// 		eMR_Ride,					// 坐骑
// 		eMR_End,
// 	};
// 	
// 	NDUIMenuLayer		*m_layerBG;
// 	NDUILayer			*m_layerTitleBG;
// 	NDUILabel			*m_lbTitle;	
// 	NDUIImage			*m_imageTitle; NDPicture *m_picTitle;
// 	NDUIItemButton		*m_btns[eMR_End];
// 	TextBGLayer			*m_layerText;
// 	ManualRoleNode		*m_nodeManualRole;
// 	ItemFocus			*m_itemfocus; int m_iFocusIndex;
// };

#endif _MANUAL_ROLE_EQUIP_SCENE_H_