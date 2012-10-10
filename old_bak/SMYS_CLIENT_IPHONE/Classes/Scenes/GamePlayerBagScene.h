/*
 *  GamePlayerBagScene.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-2-22.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _GAME_PLAYER_BAG_SCENE_H_
#define _GAME_PLAYER_BAG_SCENE_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "GameItemBag.h"
#include "Item.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUICustomView.h"
#include "GameItemInlay.h"

using namespace NDEngine;

enum  
{
	SHOW_EQUIP_BEGIN = 0,
	SHOW_EQUIP_NORMAL = SHOW_EQUIP_BEGIN,		//玩家背包正常
	SHOW_EQUIP_REPAIR,							//修理
	SHOW_EQUIP_END,
};

void GamePlayerBagUpdateMoney();

class ImageNumber;

class GameRoleNode;

class GamePlayerBagScene : 
public NDScene, 
public GameItemBagDelegate, 
public NDUIButtonDelegate,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public NDUIDialogDelegate,
public NDUICustomViewDelegate
{
	DECLARE_CLASS(GamePlayerBagScene)
public:
	GamePlayerBagScene();
	~GamePlayerBagScene();
	
	static GamePlayerBagScene* Scene();
	void Initialization(int iShowType = SHOW_EQUIP_NORMAL); override
	void OnClickPage(GameItemBag* itembag, int iPage); override
	/**bFocus,表示该事件发生前该Cell是否处于Focus状态*/
	bool OnClickCell(GameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	void OnButtonClick(NDUIButton* button); override
	void OnTableLayerCellSelected(NDUITableLayer* table, NDUINode* cell, unsigned int cellIndex, NDSection* section);  override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnDialogClose(NDUIDialog* dialog); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnCustomViewCancle(NDUICustomView* customView); override
	
	void UpdateBagNum(int iNum) { if (m_itembagPlayer) m_itembagPlayer->SetPageCount(iNum); } 
	void UpdateEquipList();
	void AddItemToBag(Item* item){ if (!item || !m_itembagPlayer) return; m_itembagPlayer->AddItem(item); }
	void UpdateBag();
	void UpdateMoney();
	/**外部可调用,移植过来的,只做更新当前界面物品显示内容*/
	void updateCurItem();
	static std::string getEquipPositionInfo(int index);
	
	void DelBagItem(int iItemID) { if (m_itembagPlayer) m_itembagPlayer->DelItem(iItemID); } 
	
	static int getComparePosition(Item* item){return 0;}
private:
	void ResetTopTLLayer(bool bResetInfo);
	void InitEquipItemList(int iEquipPos, Item* item);
private:
	void InitTLContentWithVec(NDUITableLayer* tl, std::vector<std::string> vec_str);
	void InitTLContentWithVecEquip(NDUITableLayer* tl, std::vector<std::string> vec_str, std::vector<int> vec_id);
	void InitTLContent(NDUITableLayer* tl, const char* text, ...);
	bool HasCompareEquipPosition(Item* otheritem);
	void notHasEquipItem(int iPos);
	void hasEquipItem(Item* item, int iPos);
	std::string getRepairDesc(Item* item);
	int getEquipRepairCharge(Item* item, int type);// type表示0修单件还是1全部
	int repairEveryMoney(int equipPrice, int dwAmount,int equipAllAmount);
	bool checkItemLimit(Item* item, bool isShow);
	void repairItem(Item* item);
	void repairAllItem();
	void InlayItem();
private:
	NDUIMenuLayer	*m_menuLayer;
	NDUILayer		*m_layerEquip;
	GameItemBag	*m_itembagPlayer;
	ImageNumber *m_imageNumMoney, *m_imageNumEMoney;
	
	NDPicture		*m_picMoney, *m_picEMoney;
	NDUIImage		*m_imageMoney, *m_imageEMoney;
	
	NDPicture		*m_picBag; NDUIImage *m_imageBag;
	
	NDUILayer		*m_layerRole;
	GameRoleNode	*m_GameRoleNode;
	
	CellInfo		*m_cellinfoEquip[Item::eEP_End];
	
	int m_iFocusIndex;
	ItemFocus *m_itemfocus;
	
	NDUITableLayer *m_tlShare;
	
	struct bag_cell_info 
	{
		enum  
		{
			e_op_none = 0,
			e_op_use,
			e_op_drop,
			e_op_caifeng,
			e_op_xuexi,
			e_op_kaitong,
			e_op_bind,
			e_op_sale,
			e_op_end, 
		};
		
		int iIndex;
		Item* item;
		int operate;
		
		bag_cell_info()
		{
			reset();
		}
		
		void reset() { iIndex = -1; item = NULL; operate = e_op_none; }
		
		void set(int index, Item* itemptr) { iIndex = index; item = itemptr; }
		
		void setoperate(int op){ if(op < e_op_none || op >= e_op_end) return; operate = op; }
		
		bool empty() { return iIndex == -1 || item == NULL; }
	};
	
	bag_cell_info m_bagOPInfo;
	bag_cell_info m_equipOPInfo;
	
	NDUITableLayer *m_tlPickEquip;
	
	NDUITopLayer *m_toplayer;
	
	int m_iShowType;
};

#endif // _GAME_PLAYER_BAG_SCENE_H_