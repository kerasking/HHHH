#ifndef _NEW_GAME_PLAYER_BAG_H_
#define _NEW_GAME_PLAYER_BAG_H_

#include "NDScene.h"
#include "NDUIMenuLayer.h"
#include "Item.h"
#include "NDUITableLayer.h"
#include "NDUIDialog.h"
#include "NDUICustomView.h"
#include "GameItemBag.h"
#include "GameNewItemBag.h"
#include "NDUIItemButton.h"
#include "NDScrollLayer.h"

using namespace NDEngine;

enum  
{
	NEW_SHOW_EQUIP_BEGIN = 0,
	NEW_SHOW_EQUIP_NORMAL = NEW_SHOW_EQUIP_BEGIN,		//玩家背包正常
	NEW_SHOW_EQUIP_REPAIR,							//修理
	NEW_SHOW_EQUIP_END,
};

typedef enum
{
	BagItemOperate_Begin = 100,
	BagItemOperate_Use = BagItemOperate_Begin,
	BagItemOperate_Learn,
	BagItemOperate_Inlay,
	BagItemOperate_Active,
	BagItemOperate_Compare,
	BagItemOperate_Bind,
	BagItemOperate_Drop,
	BagItemOperate_CaiFeng,
	BagItemOperate_ChaKang,
	BagItemOperate_chuShou,
	BagItemOperate_End,
}BagItemOperate;

void NewGamePlayerBagUpdateMoney();

class ImageNumber;

class GameRoleNode;

class BagItemInfo;

class BagItemInfoDelegate
{
public:
	virtual void OnBagItemInfoOperate(BagItemInfo* bagiteminfo, Item* item, BagItemOperate op) {}
};

class BagItemInfo :
public NDUILayer,
public NDUIButtonDelegate
{
	DECLARE_CLASS(BagItemInfo)
	
	BagItemInfo();
	
	~BagItemInfo();
	
public:
	
	void Initialization(); override
	
	void ChangItem(Item* item, bool onlylook=false);
	
	void OnButtonClick(NDUIButton* button); override
	
private:
	
	void refreshLabel(Item& item);
	
	void refreshOperate(Item* item, bool onlylook=false);
	
private:
	NDUIItemButton *m_btnItem;
	
	NDUIButton *m_btnClose;
	
	unsigned int m_uiOpMaxCols;
	
	typedef std::vector<NDUIButton*> vec_btn;
	
	typedef vec_btn::iterator vec_btn_it;
	
	vec_btn m_vOpBtn;
	
	NDUILabel *m_lbItemName, *m_lbItemLvl;
	
	NDUILabelScrollLayer *m_lslText;
};

class NewPlayerBagLayer : 
public NDUILayer, 
public NewGameItemBagDelegate, 
public NDUIButtonDelegate,
//public NDUITableLayerDelegate, ///< 临时性注释 郭浩
public NDUIDialogDelegate,
public NDUICustomViewDelegate,
public BagItemInfoDelegate
{
	friend class BagItemInfo;
	
	DECLARE_CLASS(NewPlayerBagLayer)
public:
	NewPlayerBagLayer();
	~NewPlayerBagLayer();
	
	void Initialization(int iShowType = NEW_SHOW_EQUIP_NORMAL); override
	void OnClickPage(NewGameItemBag* itembag, int iPage); override
	bool OnClickCell(NewGameItemBag* itembag, int iPage, int iCellIndex, Item* item, bool bFocused); override
	void OnButtonClick(NDUIButton* button); override
	void OnDialogButtonClick(NDUIDialog* dialog, unsigned int buttonIndex); override
	void OnDialogClose(NDUIDialog* dialog); override
	bool OnCustomViewConfirm(NDUICustomView* customView); override
	void OnCustomViewCancle(NDUICustomView* customView); override
	void OnBagItemInfoOperate(BagItemInfo* bagiteminfo, Item* item, BagItemOperate op); override
	bool OnBagButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch, bool del); override
	bool OnDropItem(NewGameItemBag* itembag, Item* item); override
	
	bool OnButtonDragOut(NDUIButton* button, CGPoint beginTouch, CGPoint moveTouch, bool longTouch); override
	bool OnButtonDragOutComplete(NDUIButton* button, CGPoint endTouch, bool outOfRange); override
	bool OnButtonDragIn(NDUIButton* desButton, NDUINode *uiSrcNode, bool longTouch); override
	
	void UpdateBagNum(int iNum) { if (m_itembagPlayer) m_itembagPlayer->SetPageCount(iNum); } 
	void UpdateEquipList(){}
	void AddItemToBag(Item* item){}
	void UpdateBag(){}
	void UpdateMoney(){}

	void updateCurItem(){}
	static std::string getEquipPositionInfo(int index);
	
	void DelBagItem(int iItemID){}
	
	void UpdateItem(int iItemID){}
	
	static int getComparePosition(Item* item);
	
	void SetVisible(bool visible);
	
	static NewPlayerBagLayer* GetInstance() {return 0;}
	
	static int GetIconIndexByEquipPos(int pos);
private:
	void InitEquipItemList(int iEquipPos, Item* item);
	
	void DropOperate(Item* item);
private:
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
	
	void ShowBagInfo(bool show);
private:
	NDUIMenuLayer	*m_menuLayer;
	NDUILayer		*m_layerEquip;
	NewGameItemBag	*m_itembagPlayer;
	ImageNumber *m_imageNumMoney, *m_imageNumEMoney;
	
	NDPicture		*m_picMoney, *m_picEMoney;
	NDUIImage		*m_imageMoney, *m_imageEMoney;
	
	NDPicture		*m_picBag; NDUIImage *m_imageBag;
	
	NDUILayer		*m_layerRole;
	GameRoleNode	*m_GameRoleNode;
	
	NDUIItemButton	*m_cellinfoEquip[Item::eEP_End];
	NDUIImage		*m_imageMouse;
	
	BagItemInfo		*m_bagInfo;
	bool			m_bagInfoShow;
	
	std::map<int, NDPicture*> m_recylePictures;
	
	int m_iFocusIndex;
	ItemFocus *m_itemfocus;
	
	NDUITableLayer *m_tlShare;
	
	NDUIDialog *m_dlgRemoteSale;
	
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
		
		bool empty() { return item == NULL; }
	};
	
	bag_cell_info m_bagOPInfo;
	bag_cell_info m_equipOPInfo;
	
	int m_iShowType;
private:
	static NewPlayerBagLayer* s_instance;
};

#endif // _NEW_GAME_PLAYER_BAG_H_