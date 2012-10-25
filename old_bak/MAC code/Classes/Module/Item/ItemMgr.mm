/*
 *  ItemMgr.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "ItemMgr.h"
#include "NDPlayer.h"
#include "NDMapMgr.h"
#include "NDItemType.h"
#include "NDPath.h"
#include "define.h"
#include "NDPath.h"
#include "JavaMethod.h"
#include "NDBattlePet.h"
#include "NDConstant.h"
#include <sstream>
#include "NDUIDialog.h"
#include "NDUISynLayer.h"
#include "GamePlayerBagScene.h"
#include "GameScene.h"
#include "NDDirector.h"
#include "TaskListener.h"
#include "GameStorageScene.h"
#include "VipStoreScene.h"
#include "PetSkillCompose.h"
#include "SuitTypeObj.h"
#include "AuctionUILayer.h"
#include "VendorUILayer.h"
#include "VendorBuyUILayer.h"
#include "TradeUILayer.h"
#include "IniLoad.h"
#include "GameNewItemBag.h"
#include "NewGamePlayerBag.h"
#include "EquipForgeScene.h"
#include "NewEquipRepair.h"
#include "BattleFieldScene.h"
#include "NewVipStoreScene.h"
#include "GameUINpcStore.h"
#include "PlayerInfoScene.h"

#include "ScriptGlobalEvent.h"

using std::stringstream;
using namespace NDEngine;

const Byte ITEM_USE = 1;

ItemMgr::ItemMgr()
{
	for (int i = Item::eEP_Begin; i<Item::eEP_End; i++) 
	{
		m_EquipList[i] = NULL;
	}
	
	for (int i = Item::eEP_Begin; i<Item::eEP_End; i++) 
	{
		roleEuiptItemsOK[i] = false;
	}
	
	NDNetMsgPoolObj.RegMsg(_MSG_ITEMINFO, this);
	NDNetMsgPoolObj.RegMsg(_MSG_EQUIP_EFFECT, this); // 装备是否失效
	NDNetMsgPoolObj.RegMsg(_MSG_ITEM_ATTRIB, this);
	NDNetMsgPoolObj.RegMsg(_MSG_ITEM_DEL, this);
	NDNetMsgPoolObj.RegMsg(_MSG_ITEM, this);
	NDNetMsgPoolObj.RegMsg(_MSG_STONE, this);
	NDNetMsgPoolObj.RegMsg(_MSG_STONEINFO, this);
	NDNetMsgPoolObj.RegMsg(_MSG_LIMIT, this);
	NDNetMsgPoolObj.RegMsg(_MSG_QUERY_DESC, this);
	NDNetMsgPoolObj.RegMsg(_MSG_TIDY_UP_BAG, this);
	NDNetMsgPoolObj.RegMsg(_MSG_ITEMKEEPER, this);
	NDNetMsgPoolObj.RegMsg(_MSG_SHOP_CENTER, this); // 商城
	NDNetMsgPoolObj.RegMsg(_MSG_EQUIP_SET_CFG, this);
	NDNetMsgPoolObj.RegMsg(_MSG_EQUIP_BIND, this);
	NDNetMsgPoolObj.RegMsg(_MSG_SHOP_CENTER_GOODS_TYPE, this);
	
	
	//this->LoadItemTypeIndex();
	//SuitTypeObj::LoadSuitTypeIndex();
	//LoadItemAddtion();
	//this->LoadEnhancedTypeIndex();
	
	m_iBags = 0;
	m_iStorages = 0;
}

ItemMgr::~ItemMgr()
{
	for (int i = Item::eEP_Begin; i<Item::eEP_End; i++) 
	{
		SAFE_DELETE(m_EquipList[i]);
	}
	
	for (MAP_ITEMTYPE::iterator it = m_mapItemType.begin(); it != m_mapItemType.end(); it++) {
		delete it->second;
	}
	
	for (MAP_ENHANCEDTYPE_IT itEnhanced = m_mapEnhancedType.begin(); itEnhanced != m_mapEnhancedType.end(); itEnhanced++) {
		SAFE_DELETE(itEnhanced->second);
	}
	
	std::vector<Item*>::iterator itBag = m_vecBag.begin();
	for (; itBag != m_vecBag.end(); itBag++) 
	{
		SAFE_DELETE(*itBag);
	}
	m_vecBag.clear();
	
	std::vector<Item*>::iterator itStorage = m_vecStorage.begin();
	for (; itStorage != m_vecStorage.end(); itStorage++) 
	{
		SAFE_DELETE(*itStorage);
	}
	m_vecStorage.clear();
	
	this->RemoveSoldItems();
	ItemMgrObj.repackEquip();
}

void ItemMgr::quitGame()
{
	for (int i = Item::eEP_Begin; i<Item::eEP_End; i++) 
	{
		if (m_EquipList[i])
		{
			delete m_EquipList[i];
			m_EquipList[i] = NULL;
		}
	}
	
	for (int i = Item::eEP_Begin; i<Item::eEP_End; i++) 
	{
		roleEuiptItemsOK[i] = false;
	}
	
	VEC_ITEM_IT it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		delete (*it);
	}
	m_vecBag.clear();
	
	VEC_ITEM_IT it2 = m_vecStorage.begin();
	for (; it2 != m_vecStorage.end(); it2++)
	{
		delete (*it2);
	}
	m_vecStorage.clear();
	
	this->RemoveSoldItems();
	
	m_iBags = 0;
	m_iStorages = 0;
	
	ClearVipItem();
}

/*处理感兴趣的网络消息*/
bool ItemMgr::process(MSGID msgID, NDTransData* data, int len)
{
	switch (msgID) {
		case _MSG_ITEMINFO:
			processItemInfo(data,len);
			break;
		case _MSG_EQUIP_EFFECT:
			processEquipEffect(data,len);
			break;
		case _MSG_ITEM_ATTRIB:
			processItemAttrib(data,len);
			break;
		case _MSG_ITEM_DEL:
			processItemDel(data,len);
			break;
		case _MSG_ITEM:
			processItem(data,len);
			break;
		case _MSG_STONE:
			processStone(data,len);
			break;
		case _MSG_STONEINFO:
			processStoneInfo(data,len);
			break;
		case _MSG_LIMIT:
			processLimit(data,len);
			break;
		case _MSG_QUERY_DESC:
			processQueryDesc(data,len);
			break;
		case _MSG_TIDY_UP_BAG:
			processTidyUpBag(data,len);
			break;
		case _MSG_ITEMKEEPER:
			processItemKeeper(data,len);
			break;
		case _MSG_SHOP_CENTER:
			processShopCenter(data,len);
			break;
		case _MSG_EQUIP_SET_CFG:
			processEquipSetCfg(data, len);
			break;
		case _MSG_EQUIP_BIND:
			processEquipBind(data, len);
			break;
		case _MSG_SHOP_CENTER_GOODS_TYPE:
			processShopCenterGoodsType(*data);
		default:
			break;
	}
	
	CloseProgressBar;
	
	return true;
}

Item* ItemMgr::QueryOtherItem(int idItem)
{
	for (VEC_ITEM_IT it = this->m_vOtherItems.begin(); it != this->m_vOtherItems.end(); it++) {
		if ((*it)->iID == idItem) {
			return *it;
		}
	}
	return NULL;
}

void ItemMgr::RemoveOtherItems()
{
	for (VEC_ITEM_IT it = this->m_vOtherItems.begin(); it != this->m_vOtherItems.end(); it++) {
		SAFE_DELETE(*it);
	}
	
	this->m_vOtherItems.clear();
}

void ItemMgr::processItemInfo(NDTransData* data, int len)
{	
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	
	GameScene* gamescene = (GameScene*)(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));
	
	unsigned char itemCount = 0; (*data) >> itemCount; // 接收的物品个数
	
	for (int j = 0; j < itemCount; j++) {
		int itemID = 0; (*data) >> itemID; // 物品的Id 4个字节
		int ownerID = 0; (*data) >> ownerID; // 物品的所有者id 4个字节
		int itemType = 0; (*data) >> itemType; // 物品类型 id 4个字节
		int dwAmount = 0; (*data) >> dwAmount;// 物品数量/耐久度 4个字节
		int itemPosition = 0; (*data) >> itemPosition; // 物品位置 4个字节
		int btAddition = 0; (*data) >> btAddition; // 装备追加 4个字节
		unsigned char bindState = 0; (*data) >> bindState; // 绑定状态
		unsigned char btHole = 0; (*data) >> btHole; // 装备有几个洞
		int createTime = 0; (*data) >> createTime; // 创建时间
		unsigned short sAge = 0; (*data) >> sAge;// 骑宠寿命
		unsigned char stoneCount = 0; (*data) >> stoneCount;
		
		Item *item = new Item;
		item->iID = itemID;
		item->iOwnerID = ownerID;
		item->iItemType = itemType;
		item->iAmount = dwAmount;
		item->iPosition = itemPosition;
		item->iAddition = btAddition;
		item->byBindState = bindState;
		item->byHole = btHole;
		item->iCreateTime = createTime;
		item->sAge = sAge;
		
		if (stoneCount > 0) 
		{
			for (int i = 0; i < stoneCount; i++) 
			{
				int stoneID = 0; (*data) >> stoneID;
				Item *stoneItem = new Item(stoneID);
				item->vecStone.push_back(stoneItem);
			}
		}
		
		if (itemPosition == POSITION_STORAGE) 
		{ // 仓库
			bool bolHas = false;
			for (int i = 0; i < int(m_vecStorage.size()); i++) 
			{
				Item *item2 = m_vecStorage[i];
				if (item2->iID == item->iID) {
					bolHas = true;
				}
			}
			if (!bolHas) {
				m_vecStorage.push_back(item);
				GameStorageAddItem(eGameStorage_Storage, *item);
				//if (Storage.instance != null) {
//					Storage.instance.storageItemPanel.insertAnItem(item);
//				}
			} else {
				SAFE_DELETE(item);
			}
			continue;
		} else if (itemPosition == POSITION_MAIL) 
		{ // 邮件物品
			m_vOtherItems.push_back(item);
		} else if (itemPosition == POSITION_AUCTION) 
		{ // 之前拍卖的,暂时先加上,防止数据库 有之前的脏数据,
			// 如果正常运行是不会有91的值出现
			delete item; //功能未开，暂时delete
		}else if (itemPosition == POSITION_SOLD) 
		{ // 已出售的物品
			m_mapSoldItems[item->iID] = item;
		} else 
		{ // 增加的是背包中的物品
			// 其他玩家物品
			NDPlayer& role = NDPlayer::defaultHero();
			if (role.m_id != item->iOwnerID) { // 其他玩家物品
				this->m_vOtherItems.push_back(item);
			} else {
				bool bolHandle = false;
				for (VEC_ITEM_IT it = this->m_vecBag.begin(); it != m_vecBag.end(); it++) {
					if (item->iID == (*it)->iID) {
						int nItemTypeUseInScript = item->iItemType;
						(*it)->iAmount = item->iAmount;
						(*it)->iItemType = item->iItemType;
						(*it)->iAddition = item->iAddition;
						(*it)->byHole = item->byHole;
						(*it)->iCreateTime = item->iCreateTime;
						SAFE_DELETE(item);
						bolHandle = true;
						ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
						break;
					}
				}
				
				if (!bolHandle) {
					// 增加到背包中
					if (itemPosition == POSITION_PACK) 
					{// 背包中的
						m_vecBag.push_back(item);
						if (bagscene)
						{
							bagscene->AddItemToBag(item);
						}
						
						CUIPet* uiPet = PlayerInfoScene::QueryPetScene();
						
						if (uiPet)
						{
							uiPet->PetBagAddItem(item->iID);
						}
						
						GameStorageAddItem(eGameStorage_Bag, *item);
						updateTaskItemData(*item, true);
						int nItemTypeUseInScript = item->iItemType;
						ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
					} else 
					{// 装备上的
						
						Item::eEquip_Pos pos = getEquipListPos(item);
						if (pos == Item::eEP_End) 
						{
							SAFE_DELETE(item);
							NDLog(@"装备列表位置有问题");
						}
						else 
						{
							SAFE_DELETE(m_EquipList[pos]);
							m_EquipList[pos] = item;
						}
						
						NDItemType* item_type = ItemMgrObj.QueryItemType(itemType);
						
						if (!item_type ) 
						{
							continue;
						}
						
						int nID = item_type->m_data.m_lookface;
						int quality = itemType % 10;
						
						if (nID == 0) 
						{
							continue;
						}
						int aniId = 0;
						if (nID > 100000) 
						{
							aniId = (nID % 100000) / 10;
						}
						if (aniId >= 1900 && aniId < 2000 || nID >= 19000 && nID < 20000 || nID == 1210|| nID == 1220) 
						{// 战宠
							//NDPlayer& player = NDPlayer::defaultHero();
//							NDBattlePet*& pet =  player.battlepet;
//							pet = new NDBattlePet();
//							pet->Initialization(nID);
//							pet->quality = quality;
//							pet->SetPosition(player.GetPosition());
//							pet->m_id = itemID;
//							pet->SetOwnerID(player.m_id);
							/*
							 if (NDPlayer::defaultHero().m_faceRight) 
							 {
							 NDPlayer::defaultHero().foreX = NDPlayer::defaultHero().GetPosition().x/16 - 16;
							 }
							 else 
							 {
							 NDPlayer::defaultHero().foreX = NDPlayer::defaultHero().GetPosition().x/16 + 16;
							 }
							 NDPlayer::defaultHero().foreY = NDPlayer::defaultHero().GetPosition().y/16;
							 */
							
							//pet->SetPosition(NDPlayer::defaultHero().GetPosition());
							//					pet->m_faceRight = NDPlayer::defaultHero().m_faceRight;
							//					pet->SetCurrentAnimation(MONSTER_STAND, !pet->m_faceRight);
							
						} else 
						{
							NDPlayer::defaultHero().SetEquipment(nID, quality);
						}
					}
				}
			}
		}
		
	}
	
	if (bagscene) 
	{
		bagscene->UpdateEquipList();
	}
	
	if (gamescene) 
	{
		gamescene->RefreshQuickItem();
	}
	
	BattleFieldScene::UpdateShop();
}

void ItemMgr::processEquipEffect(NDTransData* data, int len)
{
	unsigned char ucCount = 0; (*data) >> ucCount;
	for (int i = 0; i < ucCount; i++) 
	{
		int itemID = 0; (*data) >> itemID;
		unsigned char effect = 0; (*data) >> effect; effect =  (effect + 1) % 2;
		for (int j = Item::eEP_Begin; j < Item::eEP_End; j++) 
		{
			Item *item = m_EquipList[j];
			if (item != NULL && item->iID == itemID) 
			{
				roleEuiptItemsOK[j] = effect;
				break;
			}
		}
	}
}

void ItemMgr::processItemAttrib(NDTransData* data, int len)
{
	int itemID = 0; (*data) >> itemID; // 物品的Id 4个字节
	
	int action = 0; (*data) >> action; // 行为,目前只有_ITEM _AMOUNT
	
	int amount = 0; (*data) >> amount; // 物品数量
	
	GameScene* gamescene = (GameScene*)(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	
	switch (action)
	{
		case ITEMDATA_AMOUNT:
		{
			bool bolProed = false;
			
			Item *itemBag = NULL;
			
			if ( HasItemByType(ITEM_BAG, itemID, itemBag) )
			{
				itemBag->iAmount = amount;
				updateTaskItemData(*itemBag, true); // 更新任务物品
				//bolProed = true;
				
				int nItemTypeUseInScript = itemBag->iItemType;
				ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
				
				if (gamescene) 
				{
					gamescene->RefreshQuickItem();
				}
				
				CUIPet* uiPet = PlayerInfoScene::QueryPetScene();
				
				if (uiPet)
				{
					uiPet->PetBagItemCount(itemBag->iID);
				}
				
				if (bagscene) 
				{
					bagscene->UpdateItem(itemBag->iID);
				}
				break;
			}
			
				
			if (!bolProed) 
			{
				// 更新仓库中的物品
				
				Item *itemStorage = NULL;
				
				if ( HasItemByType(ITEM_STORAGE, itemID, itemStorage) )
				{
					itemStorage->iAmount = amount;
					//bolProed = true;
					break;
				}
			}
			
			if (!bolProed)
			{
				
				Item *itemEquip = NULL;
				
				if ( HasItemByType(ITEM_EQUIP, itemID, itemEquip) )
				{
					bool bSetEquipState = false;
					if (itemEquip->iAmount == 0 || amount == 0)
					{
						bSetEquipState = true;
					}
					
					itemEquip->iAmount = amount;
					
					if (bSetEquipState)
					{// 如果耐久度为0，检测下有无损坏
						setEquipState();
					}
					//bolProed = true;
					break;
				}
			}
			// 更新装备界面
//			if (EquipUIScreen.instance != null) {
//				EquipUIScreen.instance.updateCurItem(true);
//			}
			break;
		}
		case ITEMDATA_POSITION: 
		{ // action==2时,穿上装备 amount表示物品的位置相当于postion
			if (this->ChangeItemPosSold(itemID, amount)) {
				return;
			}
			Item *itemBag = NULL;
			
			if ( HasItemByType(ITEM_BAG, itemID, itemBag) )
			{
				int itemType = itemBag->iItemType;
				int equipType = Item::getIdRule(itemType, Item::ITEM_EQUIP); // 装备类型
				int equipItem = -1;
				int  changeItem = -1;
				
				switch (amount) {
					case 1: { // 头盔
						equipItem = Item::eEP_Head;
						break;
					}
					case 2: { // 肩膀
						equipItem = Item::eEP_Shoulder;
						break;
					}
					case 3: {// 胸甲
						equipItem = Item::eEP_Armor;
						break;
					}
					case 4: {// 护腕
						equipItem = Item::eEP_Shou;
						break;
					}
					case 5: {// 腰带--披风
						equipItem = Item::eEP_YaoDai;
						break;
					}
					case 6: {// 护腿
						equipItem = Item::eEP_HuTui;
						break;
					}
					case 7: {// 鞋子
						equipItem = Item::eEP_Shoes;
						break;
					}
					case 8: {// 项链
						equipItem = Item::eEP_XianLian;
						break;
					}
					case 9: {// 耳环
						equipItem = Item::eEP_ErHuan;
						break;
					}
					case 10: {// 护符 徽记
						equipItem = Item::eEP_HuiJi;
						break;
					}
					case 11: {// 左戒指
						equipItem = Item::eEP_LeftRing;
						break;
					}
					case 12: {// 右戒指
						equipItem = Item::eEP_RightRing;
						break;
					}
					case 13: {// 左武器
						equipItem = Item::eEP_MainArmor;
						if (equipType == 1) {
							if (m_EquipList[Item::eEP_FuArmor] != NULL) {
								changeItem = Item::eEP_FuArmor;
							}
						} else if (m_EquipList[Item::eEP_FuArmor] != NULL) {// 不是装双手武器，判断是否装备副手武器。
							int itemtype = m_EquipList[Item::eEP_FuArmor]->iItemType;
							int type1 = Item::getIdRule(itemtype, Item::ITEM_CLASS); // 装备类型
							int type2 = Item::getIdRule(itemType, Item::ITEM_CLASS);
							if (type1 != type2) {
								changeItem = Item::eEP_FuArmor;
							}
						}
						
						break;
					}
					case 14: {// 右武器
						equipItem = Item::eEP_FuArmor;
						
						Item *tempI = m_EquipList[Item::eEP_MainArmor];
						if (tempI != NULL) {
							int tempEquipType = Item::getIdRule(tempI->iItemType,
																Item::ITEM_EQUIP);
							
							if (tempEquipType == 1) {
								// unpackEquip(T.roleEuiptItems[6]);
								changeItem = Item::eEP_MainArmor;
							}
						}
						
						break;
					}
					case 80: { // 坐骑
						equipItem = Item::eEP_Ride;
						break;
					}
					case 81: { // 勋章
						equipItem =  Item::eEP_Decoration;
						break;
					}
				}
				
				if (equipItem == -1)
				{
					DelItem(ITEM_BAG, itemID);
				}else 
				{
					DelItem(ITEM_BAG, itemID, false);
					
					unpackEquip(equipItem, false);
					
					m_EquipList[equipItem] = itemBag;
					
					NDItemType* item_type = ItemMgrObj.QueryItemType(itemBag->iItemType);
					
					if (item_type ) 
					{
						int nID = item_type->m_data.m_lookface;
						int quality = itemType % 10;;
						
						//if (equipItem == Item::eEP_Pet)
						//{
							//NDBattlePet*& pet =  NDPlayer::defaultHero().battlepet;
//							pet = new NDBattlePet;
//							pet->Initialization(nID);
//							pet->quality = quality;
//							pet->m_faceRight = !NDPlayer::defaultHero().m_faceRight;
//							pet->SetPosition(NDPlayer::defaultHero().GetPosition());
//							pet->m_id = itemBag->iID;
//							pet->SetOwnerID(NDPlayer::defaultHero().m_id);
						//}
						//else
						{
							NDPlayer& player = NDPlayer::defaultHero();
							player.SetEquipment(nID, quality);
							if (player.GetParent() && player.GetParent()->IsKindOfClass(RUNTIME_CLASS(NDMapLayer)))
								NDPlayer::defaultHero().SetAction(false);
						}
					}
					
					unpackEquip(changeItem, false);
				}
			}
			break;
		}
		case ITEMDATA_PLUNDER:
		{
			Item *itemEquip = NULL;
			
			if ( HasItemByType(ITEM_EQUIP, itemID, itemEquip) )
			{
				itemEquip->sAge = amount;
				break;
			}
			break;
		}
	}
	
	if (bagscene)
	{
		bagscene->UpdateEquipList();
		bagscene->updateCurItem();
	}
	
	setEquipState();
	
	PetSkillCompose::refresh();
}

void ItemMgr::processItemDel(NDTransData* data, int len)
{
	unsigned char itemAmount = 0; (*data) >> itemAmount;
	std::vector<int> vecItemID;
	for (int i = 0; i < itemAmount; i++) 
	{
		int itemID = 0; (*data) >> itemID;
		vecItemID.push_back(itemID);
	}
	
	// 卸载装备, 注:这里的物品删除不是因为做了卸载装备操作,可能是PK等,所以这里不用对背包界面进行处理
	bool bUnpack = false;
	std::vector<int>::iterator it = vecItemID.begin();
	for (; it != vecItemID.end(); it++)
	{
		Item *itemEquip = NULL;
		if ( HasItemByType(ITEM_EQUIP, *it, itemEquip))
		{
			//if (EquipUIScreen.instance != null) { 
//				EquipUIScreen.instance
//				.unpackEquip(T.roleEuiptItems[i]);
//			} else {
//				T.roleEuiptItems[i].changeItem(null);
//				EquipUIScreen.unpackEquipOfRole(item.itemType);
//				// setEquipState();
//			}
			DelItem(ITEM_EQUIP, *it);
			bUnpack = true;
		}
		
		Item *itemBag = NULL;
		if ( HasItemByType(ITEM_BAG, *it, itemBag))
		{
			DelItem(ITEM_BAG, *it);
			updateTaskItemData(*itemBag, true);
			//其它操作
		}
		
		Item *itemStorage = NULL;
		if ( HasItemByType(ITEM_STORAGE, *it, itemStorage))
		{
			DelItem(ITEM_STORAGE, *it);
			//其它操作
		}
		
		Item *itemSold = NULL;
		if ( HasItemByType(ITEM_SOLD, *it, itemSold))
		{
			DelItem(ITEM_SOLD, *it);
			NpcStoreUpdateBag();
			NpcStoreUpdateSlod();
			NpcStoreUpdateMoney();
		}
	}
	
	if (bUnpack)
	{
		setEquipState();
	}
	
	PetSkillCompose::refresh();
}

void ItemMgr::processItem(NDTransData* data, int len)
{

	int itemID;
	unsigned char action;
	(*data) >> itemID >> action;
	
	switch (action) {
		case Item::ITEM_UNEQUIP: { // 装备卸下
			for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
			{
				Item* item = m_EquipList[i];
				if (item && item->iID == itemID)
				{
					unpackEquip(i,true);
					break;
				}
			}
			break;
		}
		case Item::ITEM_QUERY:
		{
			Item* item = NULL;
			if (m_vOtherItems.size()) 
			{
				item = m_vOtherItems[0];
			}
			
			if (!item) 
			{
				HasItemByType(ITEM_BAG, itemID, item);
			}
			
			if (item) 
			{
				std::string tempStr = item->makeItemDes(false, true);
				std::stringstream name;
				name << item->getItemNameWithAdd();
				
				GlobalShowDlg(name.str().c_str(), tempStr.c_str());
			}
			else 
			{
				GlobalShowDlg(NDCommonCString("error"), NDCommonCString("CantFindItem"));
			}
		}
			break;
		case Item::_ITEMACT_REPAIR:
		{
			refreshEquipAmount(itemID, 0);
			NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
			if (bagscene) 
				bagscene->updateCurItem();
		}
			//EquipUIScreen.refreshEquipAmount(itemID, (byte) 0);
//			setEquipState();
//			if (EquipUIScreen.instance != null) {
//				EquipUIScreen.instance.refreshCurItemText();
//				EquipUIScreen.instance.updateEquip();
//			}
			break;
		case Item::_ITEMACT_REPAIR_ALL:
		{
			refreshEquipAmount(itemID, 1);
			NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
			if (bagscene)
				bagscene->updateCurItem();
		}
			//EquipUIScreen.refreshEquipAmount(itemID, (byte) 1);
//			setEquipState();
//			if (EquipUIScreen.instance != null) {
//				EquipUIScreen.instance.refreshCurItemText();
//				EquipUIScreen.instance.updateEquip();
//			}
			break;
		case Item::_ITEMACT_USETYPE:
			//if (itemID == Item.CLEAR_POINT) { // 洗点之符
//				dialog = new Dialog("洗点成功", "你已成功清洗了所有属性点", Dialog.PRIV_HIGH);
//				T.addDialog(dialog);
//			}
			break;
	}
	
}

void ItemMgr::processStone(NDTransData* data, int len)
{
	unsigned char n = 0; (*data) >> n;
	if (n == Item::LIFESKILL_INLAY) {
		int idItem = 0; (*data) >> idItem;
		int idStoneType = 0; (*data) >> idStoneType;
		
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item* item = *it;
			if (item->iID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}
		
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if ( item && item->iID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}
		
		NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GameInlayScene)))
		{
			 NDDirector::DefaultDirector()->PopScene();
		}
		
		NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
		if (bagscene) 
			bagscene->updateCurItem();
		
		showDialog("", NDCommonCString("XianQiangSucess"));
	} else if (n == Item::LIFESKILL_DIGOUT) {
		showDialog("", NDCommonCString("WaChuSucess"));
		
		int idItem = 0; (*data) >> idItem;
		
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item* item = *it;
			if (item->iID == idItem)
			{
				item->DelAllStone();
			}
		}	
		
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if (item && item->iID == idItem)
			{
				item->DelAllStone();
			}
		}
		
	} else {
		// InlayDialog.faile();
	}
}

void ItemMgr::processStoneInfo(NDTransData* data, int len)
{
	unsigned char btAmount = 0; (*data) >> btAmount; // 镶嵌的数量
	for (int i = 0; i < btAmount; i++) {
		int idItem = 0; (*data) >> idItem;
		int idStoneType = 0; (*data) >> idStoneType;
		
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item* item = *it;
			if (item->iID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}
		
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++)
		{
			Item* item = m_EquipList[i];
			if (item->iID == idItem)
			{
				item->AddStone(idStoneType);
			}
		}
	}

}

void ItemMgr::processLimit(NDTransData* data, int len)
{
//	unsigned char action = 0; (*data) >> action;
//	if (action == 0) {
//		m_iStorages+=1;
//		showDialog(NDCommonCString("tip"), NDCommonCString("BuyStorageSucc"));
//		GameStorageUpdateLimit(eGameStorage_Storage);
//	} else {
//		m_iBags+=1;
//		showDialog(NDCommonCString("tip"), NDCommonCString("BuyBagSucc"));
//		//NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
////		if (scene && scene->IsKindOfClass(RUNTIME_CLASS(GamePlayerBagScene)))
////		{
////			GamePlayerBagScene* bagscene = (GamePlayerBagScene*)scene;
////			bagscene->UpdateBagNum(m_iBags);
////		}
////		GameStorageUpdateLimit(eGameStorage_Bag);
//	
//		// 有用到GameItemBag的界面不用更新背包数了,统一由该静态方法更新
//		GameItemBag::UpdateBagNum(m_iBags);
//		NewGameItemBag::UpdateBagNum(m_iBags);
//		NewGamePetBag::UpdateBagNum(m_iBags);
//	}
}

void ItemMgr::processQueryDesc(NDTransData* data, int len)
{
	CloseProgressBar;
	
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	NDScene *scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (bagscene)
	{
		int idItem = 0; (*data) >> idItem;
		std::string strContent = data->ReadUnicodeString();
		
		///Item *itembag = NULL;
		/*
		if (HasItemByType(ITEM_BAG, idItem, itembag))
		{
			showDialog(itembag->getItemNameWithAdd().c_str(), strContent.c_str());
		}
		*/
	}
	else if (scene && scene->IsKindOfClass(RUNTIME_CLASS(PetSkillCompose))) 
	{
		data->ReadInt();
		std::string str = data->ReadUnicodeString();
		GlobalShowDlg(NDCommonCString("SkillView"), str);
	}
	else if (VendorUILayer::isUILayerShown() ||
		 VendorBuyUILayer::isUILayerShown() ||
		 NewTradeLayer::isUILayerShown())
	{
		int idItem = 0; (*data) >> idItem;
		std::string strContent = data->ReadUnicodeString();
		
		Item *item = this->QueryOtherItem(idItem);
		if (!item) {
			HasItemByType(ITEM_BAG, idItem, item);
		}
		
		if (item) {
			showDialog(item->getItemNameWithAdd().c_str(), strContent.c_str());
		}
	}
	else
	{
		if (AuctionUILayer::processItemDescQuery(*data)) {
			return;
		}
	}

	// else if (null != ChatUI.instance
//			   || null != VendorBuyDialog.instance
//			   || null != TradeDialog.instance
//			   || null!= EmailReceiveScreen.instance) {
//		in = new BytesArrayInput(data);
//		int idItem = in.readInt();
//		String str = in.readString();
//		Item item = T.findOtherItemById(idItem);
//		if (item == null) {
//			item = T.findUserItemById(idItem);
//		}
//		if (item == null) {
//			item = T.findEquipUserItemById(idItem);
//		}
//		Dialog dialog;
//		if (item != null) {
//			dialog = item.makeDescDialog(str, Dialog.PRIV_HIGH);
//		} else {
//			dialog = new Dialog("错误", "找不到该物品", Dialog.PRIV_HIGH);
//		}
//		T.addDialog(dialog);
//	} else if (null != UIVendorViewCtrl.instance) {
//		in = new BytesArrayInput(data);
//		int idItem = in.readInt();
//		String str = in.readString();
//		Item item = (Item) T.findUserItemById(idItem);
//		Dialog dialog;
//		if (item != null) {
//			dialog = item.makeDescDialog(str, Dialog.PRIV_HIGH);
//		} else {
//			dialog = new Dialog("错误", "找不到该物品", Dialog.PRIV_HIGH);
//		}
//		T.addDialog(dialog);
//	} else if (null != Auction.instance) {
//		Auction.instance.onQueryDesc(data);
//	} else if (null != SkillDialog.instance) {
//		in = new BytesArrayInput(data);
//		in.readInt();
//		String str = in.readString();
//		T.showErrorDialog("技能查看", str);
//	}
}

void ItemMgr::processTidyUpBag(NDTransData* data, int len)
{
	//T.sortItemList();
//	for (int i = 0; i < T.itemList.size(); i++) {
//		Item item = (Item) T.itemList.elementAt(i);
//		item.itemSeq = i;
//	}
//	
//	if (EquipUIScreen.instance != null) {
//		EquipUIScreen.instance.zhengLi();
//	}
	
	SortBag();
	
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	if (bagscene)
		bagscene->UpdateBag();
}

void ItemMgr::processItemKeeper(NDTransData* data, int len)
{
	int value = data->ReadInt();
	int action = data->ReadInt();
	data->ReadInt();
	NDPlayer& player = NDPlayer::defaultHero();
	switch (action) {
		case MSG_STORAGE_MONEY_SAVE:
			if (value >= 0) {
				player.iStorgeMoney += value;
				GameStorageUpdateMoney();
			}
			break;
		case MSG_STORAGE_MONEY_DRAW:
			if (value >= 0) {
				player.iStorgeMoney -= value;
				GameStorageUpdateMoney();
			}
			break;
		case MSG_STORAGE_MONEY_QUERY:
			player.iStorgeMoney = value;
			GameStorageUpdateMoney();
			break;
		case MSG_STORAGE_ITEM_IN:
		{
			Item *itemI = NULL;
			// 将物品从背包中移除 已经在ITEM协议中移除了 并放入了T.storageItemList
			for (int i = 0; i < int(m_vecStorage.size()); i++) {
				Item *item = m_vecStorage[i];
				if (item->iID == value) {
					//itemI = item;
					GameStorageDelItem(eGameStorage_Bag, *item);
					//Storage.instance.bagItemPanel.dellAnItem(itemI);
					break;
				}
			}
			CloseProgressBar;
			break;
		}
		case MSG_STORAGE_ITEM_OUT:
		{
			Item *itemI = NULL;
			// 将物品从仓库中移除
			for (int i = 0; i < int(m_vecStorage.size()); i++) {
				Item *item = m_vecStorage[i];
				if (item->iID == value) {
					//itemI = item;
					GameStorageDelItem(eGameStorage_Storage, *item);
					//EquipUIScreen.removeItemFromItemViews(
//														  Storage.instance.storageItemPanel.getItemViews(),
//														  itemI);
					m_vecStorage.erase(m_vecStorage.begin()+i);
					DelItem(ITEM_STORAGE, value, true);
					break;
				}
			}
			CloseProgressBar;
			break;
		}
		case MSG_STORAGE_ITEM_QUERY:
			NDDirector::DefaultDirector()->PushScene(GameStorageScene::Scene());
			break;
		case MSG_STORAGE_EMONEY_SAVE:
			if (value >= 0) {
				player.iStorgeEmoney += value;
				GameStorageUpdateMoney();
			}
			break;
		case MSG_STORAGE_EMONEY_DRAW:
			if (value >= 0) {
				player.iStorgeEmoney -= value;
				GameStorageUpdateMoney();
			}
			break;
		case MSG_STORAGE_EMONEY_QUERY:
			player.iStorgeEmoney = value;
			NDDirector::DefaultDirector()->PushScene(GameStorageScene::Scene());
			break;
	}
}

void ItemMgr::processShopCenter(NDTransData* data, int len)
{
	int flag = data->ReadByte();
	int itemNum = data->ReadByte();
	std::vector<int> idList;
	std::stringstream sb; sb << "flag" << flag;
	sb << (" 物品ID列表为");
	
	for (int i = 0; i < itemNum; i++) {
		int goodsType = data->ReadByte();
		int itemID = data->ReadInt();
		int price = data->ReadInt();
		
		// 预先加载item type信息
		QueryItemType(itemID);
		
		VipItem *vItem = new VipItem();
		vItem->vipType = goodsType;
		vItem->itemId = itemID;
		vItem->price = price;
		vItem->item = new Item(itemID);
		
		map_vip_item_it it = m_mapVipItem.find(goodsType);
		if (it == m_mapVipItem.end()) 
		{
			vec_vip_item itemlist;
			itemlist.push_back(vItem);
			m_mapVipItem.insert(map_vip_item_pair(goodsType, itemlist));
		}
		else
		{
			vec_vip_item& itemlist = it->second;
			itemlist.push_back(vItem);
		}
	
		sb << (itemID);
		sb << ";";
	}

	//if (DepolyCfg.debug) {
//		ChatUI.addChatRecodeChatList(new ChatRecord(1, "商店物品", sb
//													.toString()));
//	}

	if (flag == 1) 
	{
		//NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene());
	}
}	

void ItemMgr::processEquipSetCfg(NDTransData* data, int len)
{
	int btAmount = data->ReadByte();
	for (int i = 0; i < btAmount; i++) {
		SuitTypeObj suitTypeObj;
		suitTypeObj.iID = data->ReadInt();
		suitTypeObj.name = data->ReadUnicodeString();		
		suitTypeObj.equip_id_1=data->ReadInt();
		suitTypeObj.equip_name_1=data->ReadUnicodeString();
		suitTypeObj.equip_id_2=data->ReadInt();
		suitTypeObj.equip_name_2=data->ReadUnicodeString();
		suitTypeObj.equip_id_3=data->ReadInt();
		suitTypeObj.equip_name_3=data->ReadUnicodeString();
		suitTypeObj.equip_id_4=data->ReadInt();
		suitTypeObj.equip_name_4=data->ReadUnicodeString();
		suitTypeObj.equip_id_5=data->ReadInt();
		suitTypeObj.equip_name_5=data->ReadUnicodeString();
		suitTypeObj.equip_id_6=data->ReadInt();
		suitTypeObj.equip_name_6=data->ReadUnicodeString();
		suitTypeObj.equip_id_7=data->ReadInt();
		suitTypeObj.equip_name_7=data->ReadUnicodeString();
		suitTypeObj.equip_set_1_num=data->ReadByte();
		suitTypeObj.equip_set_1_des=data->ReadUnicodeString();
		suitTypeObj.equip_set_2_num=data->ReadByte();
		suitTypeObj.equip_set_2_des=data->ReadUnicodeString();
		suitTypeObj.equip_set_3_num=data->ReadByte();
		suitTypeObj.equip_set_3_des=data->ReadUnicodeString();
		suitTypeObj.isUpData=true;
		// 以服务端为准,存储或更新内存数据
		std::map<int, SuitTypeObj>::iterator it = SuitTypeObj::SuitTypeObjs.find(suitTypeObj.iID);
		if (it != SuitTypeObj::SuitTypeObjs.end()) 
		{
			SuitTypeObj::SuitTypeObjs.erase(it);
		}
		SuitTypeObj::SuitTypeObjs.insert(std::map<int, SuitTypeObj>::value_type(suitTypeObj.iID, suitTypeObj));
	}
}

void ItemMgr::processEquipBind(NDTransData* data, int len)
{
	CloseProgressBar;
	int result = data->ReadByte();
	int itemId = data->ReadInt();
	if (result == 0) { // 绑定成功
		GlobalShowDlg(NDCommonCString("TipInfo"), NDCommonCString("BindSucc"));
		Item *res = NULL;
		if (HasItemByType(ITEM_BAG, itemId, res)) 
		{
			//if (res) res->byBindState = BIND_STATE_BIND;
//			
//			Item *itemPet = GetEquipItem(Item::eEP_Pet);
//			
//			HeroPetInfo::PetData* pet = &NDMapMgrObj.petInfo.m_data;
//			
//			if (pet && itemPet && res && res->iID == itemPet->iID) 
//			{
//				pet->bindStatus = BIND_STATE_BIND;
//			}
		}
	} else if (result == 1) { // 解除绑定成功
		GlobalShowDlg(NDCommonCString("TipInfo"), NDCommonCString("DeBindSucc"));
		Item *res = NULL;
		if (HasItemByType(ITEM_BAG, itemId, res)) 
		{
			if (res) res->byBindState = BIND_STATE_UNBIND;
		}
	}
}

void ItemMgr::processShopCenterGoodsType(NDTransData& data)
{
	int btAmount = data.ReadByte();
	
	for (int i = 0; i < btAmount; i++) 
	{
		int btGoodsType = data.ReadByte();
		
		std::string strGoodsName = data.ReadUnicodeString();
		
		m_mapVipDesc[btGoodsType] = strGoodsName;
		
		NDLog(@"系统商场类型[%d],名字[%@]", btGoodsType, [NSString stringWithUTF8String:strGoodsName.c_str()]);
	}
	

	NDDirector::DefaultDirector()->PushScene(NewVipStoreScene::Scene());
	
	CloseProgressBar;

	
	//BattleFieldScene *scene = BattleFieldScene::Scene();
	//scene->SetTabFocusOnIndex(eBattleFieldShop);
	//NDDirector::DefaultDirector()->PushScene(scene);
	
	//CloseProgressBar;
}

EquipPropAddtions ItemMgr::GetEquipAddtionProp()
{
	EquipPropAddtions result;
	for (int i=Item::eEP_Begin; i<Item::eEP_End; i++) 
	{
		Item *item = m_EquipList[i];
		if (item) 
		{
			NDItemType *itemtype = QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result.iPowerAdd += itemtype->m_data.m_atk_point_add;
				result.iTiZhiAdd += itemtype->m_data.m_def_point_add;
				result.iMinJieAdd += itemtype->m_data.m_dex_point_add;
				result.iZhiLiAdd += itemtype->m_data.m_mag_point_add;
			}
			
		}
	}
	return result;
}

Item::eEquip_Pos ItemMgr::getEquipListPos(Item* item) 
{
	
	Item::eEquip_Pos  pos; pos = Item::eEP_End;
	
	if (!item) 
	{
		return pos;
	}
	
	switch (item->iPosition) 
	{
		case 1: 
		{ // 头盔
			pos = Item::eEP_Head;
			break;
		}
		case 2: 
		{ // 肩膀
			pos = Item::eEP_Shoulder;
			break;
		}
		case 3: 
		{// 胸甲
			pos = Item::eEP_Armor;
			break;
		}
		case 4: 
		{// 手
			pos = Item::eEP_Shou;
			break;
		}
		case 5: 
		{// 腰带--披风
			pos = Item::eEP_YaoDai;
			break;
		}
		case 6: 
		{// 护腿
			pos = Item::eEP_HuTui;
			break;
		}
		case 7: 
		{// 鞋子
			pos = Item::eEP_Shoes;
			break;
		}
		case 8: 
		{// 项链
			pos = Item::eEP_XianLian;
			break;
		}
		case 9: 
		{// 耳环
			pos = Item::eEP_ErHuan;
			break;
		}
		case 10: 
		{// 护符 徽记
			pos = Item::eEP_HuiJi;
			break;
		}
		case 11: 
		{// 左戒指
			pos = Item::eEP_LeftRing;
			break;
		}
		case 12: 
		{// 右戒指
			pos = Item::eEP_RightRing;
			break;
		}
		case 13: 
		{// 主武器
			pos = Item::eEP_MainArmor;
			break;
		}
		case 14: 
		{// 副武器
			pos = Item::eEP_FuArmor;
			break;
		}
		case 80: 
		{ // 坐骑
			pos = Item::eEP_Ride;
			break;
		}
		case 81: 
		{ // 勋章
			pos = Item::eEP_Decoration;
			break;
		}
	}
	return pos;
}

EnhancedObj* ItemMgr::QueryEnhancedType(int idEnhancedType)
{
	MAP_ENHANCEDTYPE_IT it = m_mapEnhancedType.find(idEnhancedType);
	if (it != m_mapEnhancedType.end()) {
		return it->second;
	} else {
		MAP_ENHANCEDTYPE_INDEX::iterator itIndex = m_mapEnhancedTypeIndex.find(idEnhancedType);
		if (itIndex != m_mapEnhancedTypeIndex.end())
		{
			//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
			NSString *type = [NSString stringWithFormat:@"%s", NDPath::GetResPath("enhancedtype.ini")];
			NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:type];
			
			if (stream)
			{
				[stream open];
				
				EnhancedObj* pType = new EnhancedObj;
				
				[stream setProperty:[NSNumber numberWithInt:itIndex->second] forKey:NSStreamFileCurrentOffsetKey];
				
				pType->idType = [stream readInt];
				pType->addpoint = [stream readShort];
				pType->percent = [stream readByte];
				pType->req_item = [stream readInt];
				pType->req_num = [stream readByte];
				pType->req_money = [stream readInt];
				
				m_mapEnhancedType[idEnhancedType] = pType;
				
				[stream close];
				
				return pType;
			}
		}
	}
	
	return NULL;
}

NDItemType* ItemMgr::QueryItemType(OBJID idItemType)
{
	MAP_ITEMTYPE::iterator it = m_mapItemType.find(idItemType);
	if (it != m_mapItemType.end()) {
		return it->second;
	} else {
		MAP_ITEMTYPE_INDEX::iterator itIndex = m_mapItemTypeIndex.find(idItemType);
		if (itIndex != m_mapItemTypeIndex.end())
		{
			//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
			NSString *itemtype = [NSString stringWithFormat:@"%s", NDPath::GetResPath("itemtype.ini")];
			NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:itemtype];
			
			if (stream)
			{
				[stream open];
				
				NDItemType* pItemType = new NDItemType();
				
				[stream setProperty:[NSNumber numberWithInt:itIndex->second] forKey:NSStreamFileCurrentOffsetKey];
				
				pItemType->m_data.m_id = [stream readInt];
				pItemType->m_name = [[stream readUTF8String] UTF8String];
				pItemType->m_data.m_level = [stream readByte];
				pItemType->m_data.m_req_profession = [stream readInt];
				pItemType->m_data.m_req_level = [stream readShort];
				pItemType->m_data.m_req_sex = [stream readShort];
				pItemType->m_data.m_req_phy = [stream readShort];
				pItemType->m_data.m_req_dex = [stream readShort];
				pItemType->m_data.m_req_mag = [stream readShort];
				pItemType->m_data.m_req_def = [stream readShort];
				pItemType->m_data.m_price = [stream readInt];
				pItemType->m_data.m_emoney = [stream readInt];
				pItemType->m_data.m_save_time = [stream readInt];
				pItemType->m_data.m_life = [stream readShort];
				pItemType->m_data.m_mana = [stream readInt];
				pItemType->m_data.m_amount_limit = [stream readShort];
				pItemType->m_data.m_hard_hitrate = [stream readShort];
				pItemType->m_data.m_mana_limit = [stream readShort];
				pItemType->m_data.m_atk_point_add = [stream readShort];
				pItemType->m_data.m_def_point_add = [stream readShort];
				pItemType->m_data.m_mag_point_add = [stream readShort];
				pItemType->m_data.m_dex_point_add = [stream readShort];
				pItemType->m_data.m_atk = [stream readShort];
				pItemType->m_data.m_mag_atk = [stream readShort];
				pItemType->m_data.m_def = [stream readShort];
				pItemType->m_data.m_mag_def = [stream readShort];
				pItemType->m_data.m_hitrate = [stream readShort];
				pItemType->m_data.m_atk_speed = [stream readShort];
				pItemType->m_data.m_dodge = [stream readShort];
				pItemType->m_data.m_monopoly = [stream readShort];
				pItemType->m_data.m_lookface = [stream readInt];
				pItemType->m_data.m_iconIndex = [stream readInt];
				pItemType->m_data.m_holeNum = [stream readByte];
				pItemType->m_data.m_suitData = [stream readInt];				
				pItemType->m_des = [[stream readUTF8String] UTF8String];
				pItemType->m_data.m_idUplev = [stream readInt];
				pItemType->m_data.m_enhancedId = [stream readInt];
				pItemType->m_data.m_enhancedStatus = [stream readInt];
				pItemType->m_data.m_recycle_time = [stream readInt];
				
				if (pItemType->m_des.length() < 4) { // 1个汉字以下不显示
					pItemType->m_des.clear();
				}
				
				m_mapItemType[idItemType] = pItemType;
				
				[stream close];
				
				return pItemType;
			}
		}
	}
	
	return NULL;
}

void ItemMgr::LoadItemTypeIndex()
{
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *itemtypeTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("itemtypeTable.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:itemtypeTable];
	
	if (stream)
	{
		[stream open];
		
		int size = [stream readInt];
		
		for (int i = 0; i < size; i++)
		{
			OBJID idItemType = [stream readInt];
			int index = [stream readInt];
			m_mapItemTypeIndex.insert(MAP_ITEMTYPE_INDEX::value_type(idItemType, index));
		}
		
		[stream close];
	}
}

void ItemMgr::LoadEnhancedTypeIndex()
{
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *itemtypeTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("enhancedtypeTable.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:itemtypeTable];
	
	if (stream)
	{
		[stream open];
		
		int size = [stream readInt];
		
		for (int i = 0; i < size; i++)
		{
			OBJID idType = [stream readInt];
			int index = [stream readInt];
			m_mapEnhancedTypeIndex.insert(MAP_ENHANCEDTYPE_INDEX::value_type(idType, index));
		}
		
		[stream close];
	}
}

void ItemMgr::LoadItemAddtion()
{
	//NSString *resPath = [NSString stringWithUTF8String:NDPath::GetResourcePath().c_str()];
	NSString *itemAdditionTable = [NSString stringWithFormat:@"%s", NDPath::GetResPath("addition.ini")];
	NSInputStream *stream  = [NSInputStream inputStreamWithFileAtPath:itemAdditionTable];
	
	if (stream)
	{
		[stream open];
		
		while ( [stream hasBytesAvailable] ) 
		{
			int tempAddLevel = 0;
			
			int readLen = [stream read:(uint8_t *)(&tempAddLevel) maxLength:1];
			
			if ( !readLen ) 
			{
				break;
			}
			
			//int tempAddLevel = [stream readByte];
			
			int tempPercent = [stream readShort];
			
			m_mapItemAddtion.insert(map_item_addtion_pair(tempAddLevel, tempPercent));
		}
		
		[stream close];
	}
}

int ItemMgr::QueryPercentByLevel(int level)
{
	map_item_addtion_it it = m_mapItemAddtion.find(level);
	if (it != m_mapItemAddtion.end()) 
	{
		return it->second;
	}
	return 0;
}

void ItemMgr::ReplaceItemType(NDItemType* itemtype)
{
	if (!itemtype) 
	{
		return;
	}
	MAP_ITEMTYPE::iterator it = m_mapItemType.find(itemtype->m_data.m_id);
	if (it != m_mapItemType.end()) {
		delete it->second;
		m_mapItemType.erase(it);
	}
	m_mapItemType[itemtype->m_data.m_id] = itemtype;
}

void ItemMgr::SetBagLitmit( int iLimit )
{
	m_iBags = iLimit;
}
bool ItemMgr::IsBagFull()
{
	return int(m_vecBag.size()) == BAG_ITEM_NUM * m_iBags;
}
void ItemMgr::SetStorageLitmit( int iLimit )
{
	m_iStorages = iLimit;
}

void ItemMgr::unpackEquip(int iPos, bool bUpdateGui)
{
	NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
	
	if (!( iPos < Item::eEP_Begin || iPos >= Item::eEP_End || !m_EquipList[iPos] ))
	{
		int iItemType = m_EquipList[iPos]->iItemType;
		m_vecBag.push_back(m_EquipList[iPos]);
		if (bagscene)
		{
			bagscene->AddItemToBag(m_EquipList[iPos]);
		}
		int nItemTypeUseInScript = m_EquipList[iPos]->iItemType;
		ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
		m_EquipList[iPos] = NULL;
		unpackEquipOfRole(iItemType);
	}
	
	if (bUpdateGui && bagscene)
	{
		bagscene->UpdateEquipList();
	}
	
	setEquipState();
}

void ItemMgr::unpackEquipOfRole(int itemType)
{
	NDPlayer& player = NDPlayer::defaultHero();
	// 卸下后改变角色外观
	std::vector<int> idRule = Item::getItemType(itemType);// 分析物品id
	// ，
	// 1
	// 和2位是装备类型
	if (idRule[0] == 0) {// 装备
		int equipType = idRule[1] * 10 + idRule[2];
		if (equipType < 30) {// 武器
			
			if (m_EquipList[Item::eEP_MainArmor] == NULL) {// 卸下主武器
				player.unpackEquip(Item::eEP_MainArmor);
				//if (m_EquipList[Item::eEP_FuArmor] != NULL) {// 副武器还在
//					player.SetSecWeaponType(ONE_HAND_WEAPON);
//				} else {
//					player.SetSecWeaponType(WEAPON_NONE);
//				}
			}
			if (m_EquipList[Item::eEP_FuArmor] == NULL) {// 卸下副武器
				player.unpackEquip(Item::eEP_FuArmor);
				//if (m_EquipList[Item::eEP_MainArmor] != NULL) {// 主武器还在
//					player.SetWeaponType(ONE_HAND_WEAPON);
//				} else {
//					player.SetWeaponType(WEAPON_NONE);
//				}
			}
			
		} else if (equipType == 41) {// 头盔
			player.unpackEquip (Item::eEP_Head);
		} else if (equipType == 43) {// 胸甲
			player.unpackEquip(Item::eEP_Armor);
		} else if (equipType == 31) {// 盾
			player.unpackEquip(Item::eEP_FuArmor);
		} else if (equipType == 32) {// 法器
			player.unpackEquip(Item::eEP_FuArmor);
		} else if (equipType == 45) {// 腰带 -- 披风
			player.unpackEquip(Item::eEP_YaoDai);
		}
	}
	int petType = idRule[0] * 10 + idRule[1];
	if (petType == 11) {// 卸下溜宠
		//player.uppackBattlePet();
	} else if (petType == 14) {// 卸下骑宠
		player.unpackEquip(Item::eEP_Ride);
	}
}

void ItemMgr::setEquipState()
{
	bool bWeaponBroken = false, bDefBroken = false, bRidePetBroken = false;
	for (int i = Item::eEP_Begin; i < Item:: eEP_End; i++)
	{
		if (m_EquipList[i])
		{
			if (m_EquipList[i]->iAmount == 0)
			{
				if (Item::isWeapon(m_EquipList[i]->iItemType))
				{
					bWeaponBroken = true;
				}
				else if (Item::isDefEquip(m_EquipList[i]->iItemType)
						 || Item::isAccessories(m_EquipList[i]->iItemType) )
				{
					bDefBroken = true;
				}
						 
				if(m_EquipList[i]->iAmount == 0 || m_EquipList[i]->sAge == 0)
				{
					bRidePetBroken = true;
				}
			}
		}
	}
						 
	GameScene::SetWeaponBroken(bWeaponBroken);
	GameScene::SetDefBroken(bDefBroken);
	GameScene::SetDefBroken(bRidePetBroken);
}


void ItemMgr::refreshEquipAmount(int itemId, int type)
{
	switch (type) {
		case 0: {
			for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
			{
				Item *item = m_EquipList[i];
				if (item && item->iID == itemId)
				{
					int equipAllAmount = item->getAmount_limit();
					item->iAmount = equipAllAmount;
					
					NewEquipRepairLayer::refreshAmount();
					return;
				}
			}
			
			std::vector<Item*>::iterator it = m_vecBag.begin();
			for (; it != m_vecBag.end(); it++)
			{
				Item *item = *it;
				if (item && item->iID == itemId) 
				{
					int equipAllAmount = item->getAmount_limit();
					item->iAmount = equipAllAmount;
					NewEquipRepairLayer::refreshAmount();
					return;
				}
			}
			break;
			
		}
		case 1: { // 修身上全部
			for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
			{
				Item *item = m_EquipList[i];
				if (item && item->isEquip() && !item->isRidePet() )
				{
					int equipAllAmount = item->getAmount_limit();
					item->iAmount = equipAllAmount;
				}
			}
			NewEquipRepairLayer::refreshAmount();
			return;
		}
	}
}

Item* ItemMgr::GetSuitItem(int idItem)
{
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
	{
		if (m_EquipList[i]) 
		{
			Item *item = m_EquipList[i];
			if (item->iItemType/10 == idItem) 
			{
				return item;
			}
		}
	}
	
	return NULL;
}

void ItemMgr::repackEquip()
{
	NDPlayer& player = NDPlayer::defaultHero();
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
	{
		if (i == Item::eEP_Ride) 
		{
			continue;
		}
		player.unpackEquip(i);
	}
	
	
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
	{
		if (m_EquipList[i] && i != Item::eEP_Ride) 
		{
			NDItemType* item_type = ItemMgrObj.QueryItemType(m_EquipList[i]->iItemType);
			if (!item_type) 
			{
				continue;
			}
			int nID = item_type->m_data.m_lookface;
			int quality = m_EquipList[i]->iItemType % 10;
			player.SetEquipment(nID, quality);
		}
	}
}

void ItemMgr::GetEnhanceItem(VEC_ITEM& itemlist)
{
	itemlist.clear();
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++) 
	{
		Item *item = *it;
		if (item) 
		{
			if (item->isCanEnhance() || (item->iItemType >= 28010000 && item->iItemType <= 28019999)) {
				itemlist.push_back(item);
			}
		}
	}
}

void ItemMgr::GetBattleUsableItem(std::vector<Item*>& itemlist)
{
	itemlist.clear();
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++) 
	{
		Item *item = *it;
		if (item) 
		{
			NDItemType *itemtype = QueryItemType(item->iItemType);
			int monopoly = 0;
			if (itemtype) 
			{
				monopoly = itemtype->m_data.m_monopoly;
			}
			if ( item->iItemType / 10000000 == 2 && ( (monopoly & ITEMTYPE_MONOPOLY_BATTLE) == ITEMTYPE_MONOPOLY_BATTLE )
				) 
				itemlist.push_back(item);
		}
	}
}

void ItemMgr::GetCanUsableItem(std::vector<Item*>& itemlist)
{
	itemlist.clear();
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++) 
	{
		Item *item = *it;
		if (item && item->isItemCanUse() && !item->isEquip()) 
		{
			bool hasExist = false;
			for_vec(itemlist, VEC_ITEM_IT)
			{
				if ((*it)->iItemType == item->iItemType)
				{
					hasExist = true;
					
					break;
				}
			}
			
			if (!hasExist)
				itemlist.push_back(item);
		}
	}
}

void ItemMgr::SortBag()
{
	if (m_vecBag.empty())
	{
		return;
	}
	std::sort(m_vecBag.begin(), m_vecBag.end(), ItemTypeLessThan());
}

int ItemMgr::GetBagItemCount(int iType)
{
	int count = 0;
	
	for_vec(m_vecBag, VEC_ITEM_IT)
	{
		Item *item = *it;
		if (item && item->iItemType == iType) 
		{
			if (item->iAmount > 0) 
			{
				count += item->iAmount;
			} 
			else 
			{
				count++;
			}
		}
	}
	
	return count;
}

Item* ItemMgr::GetBagItemByType(int idItemType)
{
	std::vector<Item*>::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item && item->iItemType == idItemType) 
		{
			return item;
		}
	}
	return NULL;
}

bool ItemMgr::HasItemByType(int iType, int iItemID, Item*& itemRes)
{
	bool bRet = false;
	
	if (iType ==ITEM_BAG)
	{// 背包
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item *item = *it;
			if (item && item->iID == iItemID) 
			{
				itemRes =  item;
				bRet = true;
				break;
			}
		}
	}
	else if (iType ==ITEM_STORAGE)
	{//仓库
		std::vector<Item*>::iterator it = m_vecStorage.begin();
		for (; it != m_vecStorage.end(); it++)
		{
			Item *item = *it;
			if (item && item->iID == iItemID) 
			{
				itemRes =  item;
				bRet = true;
				break;
			}
		}
	}
	else if (iType ==ITEM_EQUIP)
	{//装备
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
		{
			Item *item = m_EquipList[i];
			if (item && item->iID == iItemID)
			{
				itemRes =  item;
				bRet = true;
				break;
			}
		}
	}
	else if (iType ==ITEM_SOLD)
	{// 已售出
		MAP_ITEM::iterator itSold = m_mapSoldItems.find(iItemID);
		if(itSold != m_mapSoldItems.end())
		{
			itemRes = itSold->second;
			bRet = true;
		}
	}
	
	return bRet;
}

bool ItemMgr::DelItem(int iType, int iItemID, bool bClear/*=true*/)
{
	bool bRet = false;
	
	if (iType ==ITEM_BAG)
	{// 背包
		std::vector<Item*>::iterator it = m_vecBag.begin();
		for (; it != m_vecBag.end(); it++)
		{
			Item *item = *it;
			if (item && item->iID == iItemID) 
			{
				int nItemTypeUseInScript = item->iItemType;
				GameScene* gamescene = (GameScene*)(NDDirector::DefaultDirector()->GetScene(RUNTIME_CLASS(GameScene)));
				NewPlayerBagLayer* bagscene = NewPlayerBagLayer::GetInstance();
				if (bagscene)
					bagscene->DelBagItem(iItemID);
					
				CUIPet *uiPet = PlayerInfoScene::QueryPetScene();
				
				if (uiPet)
				{
					uiPet->PetBagDelItem(iItemID);
				}
				
				EquipForgeScene* forge = EquipForgeScene::GetCurInstance();
				if (forge) {
					forge->processDelItem(iItemID);
				}
				
				if (bClear) 
				{
					delete item;
				}
				
				m_vecBag.erase(it);
				bRet = true;
				
				if (gamescene) 
				{
					gamescene->RefreshQuickItem();
				}
				
				if (bClear) 
				{
					ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
				}
				
				break;
			}
		}
		
		PetSkillCompose::refresh();
	}
	else if (iType ==ITEM_STORAGE)
	{//仓库
		std::vector<Item*>::iterator it = m_vecStorage.begin();
		for (; it != m_vecStorage.end(); it++)
		{
			Item *item = *it;
			if (item && item->iID == iItemID) 
			{
				int nItemTypeUseInScript = item->iItemType;
				if (bClear) 
				{
					delete item;
				}
				m_vecBag.erase(it);
				bRet = true;
				if (bClear) 
				{
					ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
				}
				break;
			}
		}
	}
	else if (iType ==ITEM_EQUIP)
	{//装备
		for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
		{
			Item *item = m_EquipList[i];
			if (item && item->iID == iItemID)
			{
				int nItemTypeUseInScript = item->iItemType;
				if (bClear) 
				{
					delete item;
				}
				m_EquipList[i] = NULL;
				bRet = true;
				setEquipState();
				if (bClear) 
				{
					ScriptGlobalEvent::OnEvent(GE_ITEM_UPDATE, nItemTypeUseInScript);
				}
				break;
			}
		}
		
	}
	else if (iType ==ITEM_SOLD)
	{// 已售出
		MAP_ITEM::iterator itSold = m_mapSoldItems.find(iItemID);
		if(itSold != m_mapSoldItems.end())
		{
			Item *item = itSold->second;
			if (bClear) 
			{
				delete item;
			}
			bRet = true;
			m_mapSoldItems.erase(itSold);
		}
	}
	
	return bRet;
}
						 
bool ItemMgr::UseItem(Item* item)
{
	//ShowProgressBar;
	sendItemUse(*item);
	//if (FreshmanTaskManager.BEGIN_FRESHMAN_TASK) { 任务相关
//		if (FreshmanTaskManager.getInstance().getCurTaskId() == FreshmanTaskManager.TASK_USE_ITEM) {
//			if (item.getItemType() == FreshmanTaskManager.USE_ITEM_TYPE) {
//				FreshmanTaskManager.getInstance().setCurTaskFinish(true);
//				FreshmanTaskManager.getInstance().sendTaskFinishMsg(
//																	FreshmanTaskManager.TASK_USE_ITEM, true);
//			}
//		} else if (FreshmanTaskManager.getInstance().getCurTaskId() == FreshmanTaskManager.TASK_FEED_PET) {
//			if (item.getItemType() == FreshmanTaskManager.FEED_PET_ITEM_TYPE) {
//				FreshmanTaskManager.getInstance().setCurTaskFinish(true);
//				FreshmanTaskManager.getInstance().sendTaskFinishMsg(
//																	FreshmanTaskManager.TASK_FEED_PET, true);
//			}
//		}
//	}
	
	return true;
}

void ItemMgr::ClearVipItem()
{
	map_vip_item_it itMap = m_mapVipItem.begin();
	for (; itMap != m_mapVipItem.end(); itMap++) 
	{
		vec_vip_item& items = itMap->second;
		for_vec(items, vec_vip_item_it)
		{
			delete *it;
		}
		items.clear();
	}
	m_mapVipItem.clear();
	
	m_mapVipDesc.clear();
}

///////////////////////////////////////////////////////////////////
Item* ItemMgr::QueryItem(OBJID idItem)
{
	// 背包
	VEC_ITEM::iterator it = m_vecBag.begin();
	for (; it != m_vecBag.end(); it++)
	{
		Item *item = *it;
		if (item && OBJID(item->iID) == idItem) 
		{
			return item;
		}
	}

	//仓库
	it = m_vecStorage.begin();
	for (; it != m_vecStorage.end(); it++)
	{
		Item *item = *it;
		if (item && OBJID(item->iID) == idItem) 
		{
			return item;
		}
	}

	//装备
	for (int i = Item::eEP_Begin; i < Item::eEP_End; i++) 
	{
		Item *item = m_EquipList[i];
		if (item && OBJID(item->iID) == idItem)
		{
			return item;
		}
	}

	// 已售出
	MAP_ITEM::iterator itSold = m_mapSoldItems.find(idItem);
	if(itSold != m_mapSoldItems.end())
	{
		return itSold->second;
	}

	return this->QueryOtherItem((int)idItem);
}

void ItemMgr::RemoveSoldItems()
{
	MAP_ITEM::iterator itSold = m_mapSoldItems.begin();
	for (; itSold != m_mapSoldItems.end(); itSold++) 
	{
		SAFE_DELETE(itSold->second);
	}
	m_mapSoldItems.clear();
}

void ItemMgr::GetSoldItemsId(ID_VEC& vecId)
{
	MAP_ITEM::iterator itSold = m_mapSoldItems.begin();
	for (; itSold != m_mapSoldItems.end(); itSold++) 
	{
		if ((itSold->second)){
			vecId.push_back(itSold->second->iID);
		}
	}
}

bool ItemMgr::ChangeItemPosSold(OBJID idItem, int nPos)
{
	Item* pItem = NULL;
	if (nPos == POSITION_SOLD) {
		if (this->HasItemByType(ITEM_BAG, idItem, pItem)) {
			this->DelItem(ITEM_BAG, idItem, false);
			m_mapSoldItems[idItem] = pItem;
		}
	}
	else if (nPos == POSITION_PACK) {
		if (this->HasItemByType(ITEM_SOLD, idItem, pItem)) {
			this->DelItem(ITEM_SOLD, idItem, false);
			m_vecBag.push_back(pItem);
		}
	}
	
	if (pItem) {
		NpcStoreUpdateBag();
		NpcStoreUpdateSlod();
		NpcStoreUpdateMoney();
		return true;
	}

	return false;
}

///////////////////////////////////////////////////////////////////
void sendItemUse(Item& item) {
	NDItemType* itemType = ItemMgrObj.QueryItemType(item.iItemType);
	NDAsssert(itemType != NULL);
	
	/*
	NDPlayer& player = NDPlayer::defaultHero();
	if (itemType->m_data.m_req_level > player.level) {
		stringstream ss;
		ss << "无法使用，该物品的使用等级为" << int(itemType->m_data.m_level);
		showDialog("操作失败", ss.str().c_str());
		return;
	}
	*/
	
	ShowProgressBar;
	
	NDTransData bao(_MSG_ITEM);
	bao << (int)item.iID << (unsigned char)(Item::ITEM_USE);
	
	SEND_DATA(bao);
}

void sendDropItem(Item& item) {
	ShowProgressBar;
	NDTransData bao(_MSG_ITEM);
	bao << (int)item.iID << (unsigned char)Item::ITEM_DROP;
	SEND_DATA(bao);
}
						 
void sendItemRepair(int itemID, int action) {
	ShowProgressBar;
	NDTransData bao(_MSG_ITEM);
	bao << itemID << (unsigned char)action;
	SEND_DATA(bao);
}

int GetItemPos(Item& item)
{
	int iRes = Item::eEP_End;
	switch (item.iPosition) {
		case 1: { // 头盔
			iRes = Item::eEP_Head;
			break;
		}
		case 2: { // 肩膀
			iRes = Item::eEP_Shoulder;
			break;
		}
		case 3: {// 胸甲
			iRes = Item::eEP_Armor;
			break;
		}
		case 4: {// 护腕
			iRes = Item::eEP_Shou;
			break;
		}
		case 5: {// 腰带--披风
			iRes = Item::eEP_YaoDai;
			break;
		}
		case 6: {// 护腿
			iRes = Item::eEP_HuTui;
			break;
		}
		case 7: {// 鞋子
			iRes = Item::eEP_Shoes;
			break;
		}
		case 8: {// 项链
			iRes = Item::eEP_XianLian;
			break;
		}
		case 9: {// 耳环
			iRes = Item::eEP_ErHuan;
			break;
		}
		case 10: {// 护符 徽记
			iRes = Item::eEP_HuiJi;
			break;
		}
		case 11: {// 左戒指
			iRes = Item::eEP_LeftRing;
			break;
		}
		case 12: {// 右戒指
			iRes = Item::eEP_RightRing;
			break;
		}
		case 13: {// 左武器
			iRes = Item::eEP_MainArmor;
			break;
		}
		case 14: {// 右武器
			iRes = Item::eEP_FuArmor;
			break;
		}
		case 80: { // 坐骑
			iRes = Item::eEP_Ride;
			break;
		}
		case 81: { // 勋章
			iRes = Item::eEP_Decoration;
			break;
		}
	}
	
	return iRes;
}
