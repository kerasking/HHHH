/*
 *  Item.mm
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
 *
 */

#include "Item.h"
#include "define.h"
#include "ItemMgr.h"
#include "NDItemType.h"
#include "EnumDef.h"
#include "NDUIDialog.h"
#include "NDUtility.h"
//#include "SuitTypeObj.h"
#include "NDScene.h"
#include "NDDirector.h"
//#include "ManualRoleEquipScene.h"
#include "NDUISynLayer.h"
#include "SuitTypeObj.h"
#include "ManualRoleEquipScene.h"
#include <sstream>

Item::Item()
{
	this->init();
}

Item::Item(int iItemType)
{
	this->init();
	this->iItemType = iItemType;
}

Item::Item(const Item& rhs)
{
	*this = rhs;
}

Item& Item::operator = (const Item& rhs)
{
	if (this == &rhs) {
		return *this;
	}
	
	this->iID = rhs.iID;						// 物品的Id
	this->iOwnerID = rhs.iOwnerID;			// 物品的所有者id
	this->iItemType = rhs.iItemType;			// 物品类型 id
	this->iAmount = rhs.iAmount;				// 物品数量/耐久度
	this->iPosition = rhs.iPosition;				// 物品位置
	this->iAddition = rhs.iAddition;				// 装备追加
	this->byBindState = rhs.byBindState;		// 绑定状态
	this->byHole = rhs.byHole;				// 装备有几个洞
	this->iCreateTime = rhs.iCreateTime;			// 创建时间
	this->sAge = rhs.sAge;					// 骑宠寿命
	this->active = rhs.active;
	
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		SAFE_DELETE(*it);
	}
	vecStone.clear();
	
	for (std::vector<Item*>::const_iterator it = rhs.vecStone.begin(); it != rhs.vecStone.end(); it++) {
		Item* stone = new Item;
		(*stone) = *(*it);
		this->vecStone.push_back(stone);
	}
	
	return *this;
}

void Item::init()
{
	iID = 0;					// 物品的Id
	iOwnerID = 0;				// 物品的所有者id
	iItemType = 0;				// 物品类型 id
	iAmount = 0;				// 物品数量/耐久度
	iPosition = 0;				// 物品位置
	iAddition = 0;				// 装备追加
	byBindState = 0;			// 绑定状态
	byHole = 0;				// 装备有几个洞
	iCreateTime = 0;			// 创建时间
	sAge = 0;					// 骑宠寿命
	active = false;
}

Item::~Item()
{
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		SAFE_DELETE(item);
	}
}

void Item::AddStone(int iItemType)
{
	Item* item = new Item(iItemType);
	vecStone.push_back(item);
}

void Item::DelStone(int iItemID)
{
	std::vector<Item*>::iterator it = vecStone.begin();
	for (; it != vecStone.end(); it++)
	{
		Item *item = *it;
		if (iItemID == (item->iID))
		{
			delete item;
			vecStone.erase(it);
			break;
		}
	}
}

void Item::DelAllStone()
{
	std::vector<Item*>::iterator it = vecStone.begin();
	for (; it != vecStone.end(); it++)
	{
		delete (*it);
	}
	vecStone.clear();
}

int Item::getInlayAtk_speed()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_atk_speed;
			}
		}
	}
	return result;
}

int Item::getInlayAtk()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_atk;
			}
		}
	}
	return result;
}

int Item::getInlayDef()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_def;
			}
		}
	}
	return result;
}

int Item::getInlayHard_hitrate()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_hard_hitrate;
			}
		}
	}
	return result;
}

int Item::getInlayMag_atk()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_mag_atk;
			}
		}
	}
	return result;
}

int Item::getInlayMag_def()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_mag_def;
			}
		}
	}
	return result;
}

int Item::getInlayMana_limit()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_mana_limit;
			}
		}
	}
	return result;
}

int Item::getInlayDodge()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_dodge;
			}
		}
	}
	return result;
}

int Item::getInlayHitrate()
{
	int result = 0;
	for (std::vector<Item*>::iterator it = vecStone.begin(); it != vecStone.end(); it++) 
	{
		Item* item = *it;
		if (item) 
		{
			NDItemType *itemtype = ItemMgrObj.QueryItemType(item->iItemType);
			if (itemtype) 
			{
				result += itemtype->m_data.m_hitrate;
			}
		}
	}
	return result;
}

int Item::getAdditionResult(int enhancedId, Byte btAddition, int srcPoint) {
	srcPoint += getOnlyAdditionPoint(enhancedId, btAddition, srcPoint);
	return srcPoint;
}

int Item::getOnlyAdditionPoint(int enhancedId, Byte btAddition, int srcPoint) {
	if (btAddition == 0 || srcPoint == 0) {
		return 0;
	}	
	EnhancedObj* enhancedObj=ItemMgrObj.QueryEnhancedType(enhancedId+btAddition);
	if(enhancedObj== NULL || (enhancedObj->addpoint==0 && enhancedObj->percent==0)){
		return 0;
	}	
	return srcPoint * enhancedObj->percent / 100 + enhancedObj->addpoint;
}

int Item::getPercentByLevel(int btAddition)
{
	return ItemMgrObj.QueryPercentByLevel(btAddition);
}

int Item::getMonopoly()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (itemtype) 
	{
		return itemtype->m_data.m_monopoly;
	}
	return 0;
}

int Item::getEnhanceId()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (itemtype) 
	{
		return itemtype->m_data.m_enhancedId;
	}
	return 0;
}

int Item::getIconIndex()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (itemtype) 
	{
		return itemtype->m_data.m_iconIndex;
	}
	return -1;
}

int Item::getItemColor()
{
	std::vector<int> ids = getItemType(iItemType);
	//int result = -1;
	int result = 0xe5cc80;
	if ( ids[0] > 1 ) 
	{
		return result;
	}
	if (ids[7] == 5) 
	{
		result = 0xc4c4c4;
	} 
	else if (ids[7] == 6)
	{
		result = 0x1eff00;
	} 
	else if (ids[7] == 7)
	{
		result = 0x0323ad;
	} 
	else if (ids[7] == 8)
	{
		result = 0xfc4a4a;
	}
	else if (ids[7] == 9)
	{
		result = 0xfa9631;
	}
	return result;
}

std::string Item::getItemDesc()
{
	stringstream sb;
	int type = getIdRule(iItemType,Item::ITEM_TYPE); // 物品类型
	sb << (getItemNameWithAdd());
	if (type == 0) {// 装备
		sb << " " << NDCommonCString("NaiJiuDu") << ": "
				  << getdwAmountShow(iAmount)
				  << "/"
				  << getdwAmountShow(getAmount_limit());
	} else if (isRidePet()) { // 骑宠
		sb << " " << NDCommonCString("TiLi") << ": " << iAmount << "/"
				  << getAmount_limit();
	} else {
		if (iAmount > 1) {
			sb << " x " << iAmount;
		}
	}
	return std::string(sb.str().c_str());
}

std::vector<int> Item::getItemType(int iType)
{
	std::vector<int> res;
	for (int i=0; i<8; i++)
	{
		res.push_back(iType/int(pow(10, 7-i))%10);
	}
	return res;
}

bool Item::isDefEquip(int itemType)
{ // 是否防具和副手,都算做防具
	std::vector<int> rule = getItemType(itemType);
	if (rule[0] == 0 && (rule[1] == 3 || rule[1] == 4)) {
		return true;
	}
	return false;
}

bool Item::isAccessories(int itemType)
{ // 是否饰品
	std::vector<int> rule = getItemType(itemType);
	if (rule[0] == 0 && rule[1] == 5) {
		return true;
	}
	return false;
}

bool Item::isWeapon(int itemType)
{ // 是否武器,包括单双手
	
	std::vector<int> rule = getItemType(itemType);
	if (rule[0] == 0 && (rule[1] == 1 || rule[1] == 2)) {
		return true;
	}
	return false;
}

std::string Item::makeCompareItemDes(Item* item, Item* otheritem, int whichStore)
{
	if (item == NULL || otheritem == NULL)
	{
		return NDCommonCString("wu");
	}
	Item& item1 = *item;
	Item& item2 = *otheritem;
	std::vector<int> ids1 = Item::getItemType(item1.iItemType);
	std::vector<int> ids2 = Item::getItemType(item2.iItemType);
	
	stringstream sb;
	
	// if (tempInt1 - 1 >= 0 && tempInt1 - 1 < ItemType.ITEMLEVEL.length) {
	sb << item1.getItemName() << "->" << item2.getItemName() + "\n";
	// }
	// if (tempInt2 - 1 >= 0 && tempInt2 - 1 < ItemType.ITEMLEVEL.length) {
	// }
	
	//int tempInt1 = item1.getItemLevel();
	//int tempInt2 = item2.getItemLevel();
	int tempInt1 = ids1[7];
	int tempInt2 = ids2[7];
	if (tempInt1 >= 0 && tempInt1 < NDItemType::PINZHI_LEN() && tempInt2 >= 0 && tempInt2 < NDItemType::PINZHI_LEN()) 
	{
		const char* pszTemp = __NDLOCAL_INNER_C_STRING("Common", "PingZhi");

		sb << NDCommonCString("PingZhi") << ":" << NDItemType::PINZHI(tempInt1) << "->";
		
		if (tempInt1 == tempInt2)
		{
			sb << (NDItemType::PINZHI(tempInt2));
		} 
		else if (tempInt1 < tempInt2) 
		{
			sb << (getAdd(NDItemType::PINZHI(tempInt2)));
		} 
		else 
		{
			sb << (getSub(NDItemType::PINZHI(tempInt2)));
		}
		sb << "\n";
	}
	
	tempInt1 = item1.vecStone.size();
	tempInt2 = item2.vecStone.size();
	sb << NDCommonCString("XiangQian") << "： +" << tempInt1 << "->";
	if (tempInt1 == tempInt2) {
		sb << "+" << tempInt2;
	} else if (tempInt1 < tempInt2) {
		stringstream ss; ss << "+" << tempInt2;
		sb << getAdd(ss.str());
	} else {
		stringstream ss; ss << "+" << tempInt2;
		sb << (getSub(ss.str()));
	}
	sb << ("\n");
	
	tempInt1 = item1.iAddition;
	tempInt2 = item2.iAddition;
	sb << NDCommonCString("QiangHua") << "： +" << tempInt1 << "->";
	if (tempInt1 == tempInt2) {
		sb << "+" << tempInt2;
	} else if (tempInt1 < tempInt2) {
		stringstream ss; ss << "+" << tempInt2;
		sb << (getAdd(ss.str()));
	} else {
		stringstream ss; ss << "+" << tempInt2;
		sb << (getSub(ss.str()));
	}
	sb << ("\n");
	
	tempInt1 = item1.getReq_profession();// T.atoi(itemtypes1[ItemType.
	// req_profession]);
	tempInt2 = item2.getReq_profession();// T.atoi(itemtypes2[ItemType.
	// req_profession]);
	if (tempInt1 - 1 >= 0 && tempInt1 - 1 < NDItemType::PROFESSION_LEN)
	{
		if (tempInt2 - 1 >= 0 && tempInt2 - 1 < NDItemType::PROFESSION_LEN) {
			sb << "(" << NDItemType::PROFESSION[tempInt1 - 1] << ")";
			sb << "->(" << NDItemType::PROFESSION[tempInt2 - 1] << ")";
		}
		sb << ("\n");
	}
	
	tempInt1 = item1.getMonopoly();// T.atoi(itemtypes1[ItemType.monopoly]);
	tempInt2 = item2.getMonopoly();// T.atoi(itemtypes2[ItemType.monopoly]);
	if (tempInt1 - 1 >= 0 && tempInt1 - 1 < NDItemType::MONOPOLY_LEN) {
		if (tempInt2 - 1 >= 0 && tempInt2 - 1 < NDItemType::MONOPOLY_LEN) {
			sb << NDItemType::MONOPOLY[tempInt1 - 1] << "\n";
			sb << "->" << NDItemType::MONOPOLY[tempInt2 - 1];
		}
		sb << ("\n");
	}
	
	std::vector<std::vector<std::string> > tempString;
	std::vector<std::string> str1, str2, str3, str4, str5; 
	str1.push_back(NDCommonCString("ShuanShouDao")); str1.push_back(NDCommonCString("ShuanShouJian")); str1.push_back(NDCommonCString("ShuanShouZhang")); str1.push_back(NDCommonCString("ShuanShouGong"));
	str2.push_back(NDCommonCString("DangShouDao")); str2.push_back(NDCommonCString("DangShouJian")); str2.push_back(NDCommonCString("BiShou")); str2.push_back(NDCommonCString("HuShouGou"));
	str3.push_back(NDCommonCString("DunPai")); str3.push_back(NDCommonCString("FuShouFaQi"));
	str4.push_back(NDCommonCString("TouKui")); str4.push_back(NDCommonCString("JianJia")); str4.push_back(NDCommonCString("XiongJia")); str4.push_back(NDCommonCString("HuWang"));
	str4.push_back(NDCommonCString("PiFeng")); str4.push_back(NDCommonCString("HuTui")); str4.push_back(NDCommonCString("XieZhi"));
	str5.push_back(NDCommonCString("XiangLiang")); str5.push_back(NDCommonCString("ErHuan")); str5.push_back(NDCommonCString("HuiJi")); str5.push_back(NDCommonCString("JieZhi"));
	tempString.push_back(str1); tempString.push_back(str2); tempString.push_back(str3); tempString.push_back(str4);  tempString.push_back(str5);
	
	if (ids1[1] - 1 > 0 && ids1[1] - 1 < int(tempString.size()) && ids1[2] - 1 > 0 && ids1[2] - 1 < int(tempString[ids1[1] - 1].size())) {
		if (ids2[1] - 1 > 0 && ids2[1] - 1 < int(tempString.size()) && ids2[2] - 1 > 0 && ids2[2] - 1 < int(tempString[ids2[1] - 1].size())) {
			sb << NDCommonCString("ZhongLei") << ":" << tempString[ids1[1] - 1][ids1[2] - 1];
			sb << "->" << tempString[ids2[1] - 1][ids2[2] - 1];
		}
		sb << ("\n");
	}
	
	if (ids1[0] == 0 && ids2[0] == 0) {// 装备
		tempInt1 = item1.getSave_time();
		tempInt2 = item2.getSave_time();
		if (tempInt1 > 0 || tempInt2 > 0) {
			sb << NDCommonCString("ValidDate") << ":"; 
			sb << (tempInt1 == 0 ? NDCommonCString("yongjiu") : getStringTime(tempInt1));
			sb << (" ->\n\t\t");
			sb << (tempInt2 == 0 ? NDCommonCString("yongjiu") : getStringTime(tempInt2));
			sb << ("\n");
		}
		
		tempInt1 = item1.getAtk_point_add();
		tempInt2 = item2.getAtk_point_add();// 力量
		int addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getAtk_point_add();
			if (x > 0) {
				addNum1 += x;
			}
		}
		int addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getAtk_point_add();
			if (x > 0) {
				addNum2 += x;
			}
		}
		std::string temp = getEffectString(NDCommonCString("Liliang"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getDef_point_add();
		tempInt2 = item2.getDef_point_add();// 体质
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getDef_point_add();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getDef_point_add();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("TiZhi"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getMag_point_add();
		tempInt2 = item2.getMag_point_add();// 智力
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getMag_point_add();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getMag_point_add();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("ZhiLi"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getDex_point_add();
		tempInt2 = item2.getDex_point_add();// 敏捷
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getDex_point_add();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getDex_point_add();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("MingJie"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getDodge();
		tempInt2 = item2.getDodge();// 闪避
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getDodge();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getDodge();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("Dodge"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getHitrate();
		tempInt2 = item2.getHitrate();// 物理命中
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getHitrate();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getHitrate();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("PhyHit"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getAtk();
		tempInt2 = item2.getAtk();// 物理攻击
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getAtk();
			if (x > 0) {
				addNum1 += x;
			}
		}
		if (item1.iAddition >= 1) {
			addNum1 += getOnlyAdditionPoint(item1.getEnhanceId(), item1.iAddition, tempInt1);
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getAtk();
			if (x > 0) {
				addNum2 += x;
			}
		}
		if (item2.iAddition >= 1) {
			addNum2 += getOnlyAdditionPoint(item2.getEnhanceId(), item2.iAddition, tempInt2);
		}
		temp = getEffectString(NDCommonCString("PhyAtk"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getMag_atk();// 魔法伤害
		tempInt2 = item2.getMag_atk();
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getMag_atk();
			if (x > 0) {
				addNum1 += x;
			}
		}
		if (item1.iAddition >= 1) {
			addNum1 += getOnlyAdditionPoint(item1.getEnhanceId(), item1.iAddition, tempInt1);
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getMag_atk();
			if (x > 0) {
				addNum2 += x;
			}
		}
		if (item2.iAddition >= 1) {
			addNum2 += getOnlyAdditionPoint(item2.getEnhanceId(), item2.iAddition, tempInt2);
		}
		temp = getEffectString(NDCommonCString("MagicHurt"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << temp;
		}
		
		tempInt1 = item1.getHard_hitrate();
		tempInt2 = item2.getHard_hitrate();// 物理暴击
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getHard_hitrate();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getHard_hitrate();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("CriticalHit"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getMana_limit();
		tempInt2 = item2.getMana_limit();// 魔法暴击
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getMana_limit();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getMana_limit();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("MagicCriticalHit"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getDef();// 物理防御
		tempInt2 = item2.getDef();
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getDef();
			if (x > 0) {
				addNum1 += x;
			}
		}
		if (item1.iAddition >= 1) {
			addNum1 += getOnlyAdditionPoint(item1.getEnhanceId(), item1.iAddition, tempInt1);
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getDef();
			if (x > 0) {
				addNum2 += x;
			}
		}
		if (item2.iAddition >= 1) {
			addNum2 += getOnlyAdditionPoint(item2.getEnhanceId(), item2.iAddition, tempInt2);
		}
		temp = getEffectString(NDCommonCString("PhyDef"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getMag_def();// 魔法抗性
		tempInt2 = item2.getMag_def();
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getMag_def();
			if (x > 0) {
				addNum1 += x;
			}
		}
		if (item1.iAddition >= 1) {
			addNum1 += getOnlyAdditionPoint(item1.getEnhanceId(), item1.iAddition, tempInt1);
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getMag_def();
			if (x > 0) {
				addNum2 += x;
			}
		}
		if (item2.iAddition >= 1) {
			addNum2 += getOnlyAdditionPoint(item2.getEnhanceId(), item2.iAddition, tempInt2);
		}
		temp = getEffectString(NDCommonCString("MagicDef"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getAtk_speed();
		tempInt2 = item2.getAtk_speed();// 攻击速度
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getAtk_speed();
			if (x > 0) {
				addNum1 += x;
			}
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getAtk_speed();
			if (x > 0) {
				addNum2 += x;
			}
		}
		temp = getEffectString(NDCommonCString("AtkSpeed"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getLife();// 生命
		tempInt2 = item2.getLife();
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getLife();
			if (x > 0) {
				addNum1 += x;
			}
		}
		if (item1.iAddition >= 1) {
			addNum1 += getOnlyAdditionPoint(item1.getEnhanceId(), item1.iAddition, tempInt1);
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getLife();
			if (x > 0) {
				addNum2 += x;
			}
		}
		if (item2.iAddition >= 1) {
			addNum2 += getOnlyAdditionPoint(item2.getEnhanceId(), item2.iAddition, tempInt2);
		}
		temp = getEffectString(NDCommonCString("life"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		tempInt1 = item1.getMana();// 法力
		tempInt2 = item2.getMana();
		addNum1 = 0;
		for (int j = 0; j < int(item1.vecStone.size()); j++) {
			Item *stoneItem = item1.vecStone[j];
			int x = stoneItem->getMana();
			if (x > 0) {
				addNum1 += x;
			}
		}
		if (item1.iAddition >= 1) {
			addNum1 += getOnlyAdditionPoint(item1.getEnhanceId(), item1.iAddition, tempInt1);
		}
		addNum2 = 0;
		for (int j = 0; j < int(item2.vecStone.size()); j++) {
			Item *stoneItem = item2.vecStone[j];
			int x = stoneItem->getMana();
			if (x > 0) {
				addNum2 += x;
			}
		}
		if (item2.iAddition >= 1) {
			addNum2 += getOnlyAdditionPoint(item2.getEnhanceId(), item2.iAddition, tempInt2);
		}
		temp = getEffectString(NDCommonCString("magic"), tempInt1, addNum1, tempInt2, addNum2);
		if (!temp.empty()) {
			sb << (temp);
		}
		
		switch (whichStore) {
			case 1: {
				
				tempInt1 = getdwAmountShow(item1.getAmount_limit());
				tempInt2 = getdwAmountShow(item2.iAmount);
				
				break;
			}
			case 2: {
				
				tempInt1 = getdwAmountShow(item1.iAmount);
				tempInt2 = getdwAmountShow(item2.getAmount_limit());
				
				break;
			}
			default: {
				
				tempInt1 = getdwAmountShow(item1.iAmount);
				tempInt2 = getdwAmountShow(item2.iAmount);
				
				break;
			}
		}
		
		sb << NDCommonCString("NaiJiuDu") << ":" << tempInt1 << "->";
		if (tempInt1 == tempInt2) {
			sb << "" << tempInt2;
		} else if (tempInt1 < tempInt2) {
			stringstream ss; ss << "" << tempInt2;
			sb << (getAdd(ss.str()));
		} else {
			stringstream ss; ss << "" << tempInt2;
			sb << (getSub(ss.str()));
		}
		sb << ("\n");
		
		tempInt1 = getdwAmountShow(item1.getAmount_limit());
		tempInt2 = getdwAmountShow(item2.getAmount_limit());// 最大耐久度
		
		sb << NDCommonCString("MaxNaiJiuDu") << ":" << tempInt1 << "->";
		if (tempInt1 == tempInt2) {
			sb << "" << tempInt2;
		} else if (tempInt1 < tempInt2) {
			stringstream ss; ss << "" << tempInt2;
			sb << (getAdd(ss.str()));
		} else {
			stringstream ss; ss << "" << tempInt2;
			sb << (getSub(ss.str()));
		}
	}
	
	return sb.str();
}

std::string Item::getEffectString(std::string name, int tempInt1, int addNum1, int tempInt2, int addNum2)
{
	stringstream sb;
	
	int sumInt1 = tempInt1 + addNum1;
	int sumInt2 = tempInt2 + addNum2;
	if (sumInt1 == sumInt2 && sumInt1 != 0) {
		sb << name << ":";
		sb << tempInt1;
		if (addNum1 > 0) {
			sb  << "(+" << addNum1 << ")";
		}
		sb << ("->");
		sb << (tempInt2);
		if (addNum2 > 0) {
			sb << "(+" << addNum2 << ")";
		}
	} else if (sumInt1 < sumInt2) {
		sb << name << ":";
		sb << (tempInt1);
		if (addNum1 > 0) {
			sb << "(+" << addNum1 << ")";
		}
		sb << ("->");
		
		stringstream tempBuffer;
		tempBuffer << (tempInt2);
		if (addNum2 > 0) {
			tempBuffer << "(+" << addNum2 << ")";
		}
		sb << (getAdd(tempBuffer.str()));
		
	} else if (sumInt1 > sumInt2) {
		sb << name << ":";
		sb << (tempInt1);
		if (addNum1 > 0) {
			sb << "(+" << addNum1 << ")";
		}
		sb << ("->");
		
		stringstream tempBuffer;
		tempBuffer << (tempInt2);
		if (addNum2 > 0) {
			tempBuffer << "(+" << addNum2 << ")";
		}
		sb << (getSub(tempBuffer.str()));
	} else {
		return "";
	}
	sb << "\n";
	return sb.str();
}

std::string Item::makeItemDes(bool bolIncludeName, bool bolShowColor)
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return std::string(NDCommonCString("wu"));
	}
	
	std::string color=NDItemType::getItemStrColor(iItemType % 10);
	
	stringstream sb;
	// 技能书,暂时复用lookface字段作为技能id的关联
	//		if (this.isSkillBook()) {
	//			sb.append("类型: 技能秘笈\n");
	//			BattleSkill sk = SkillManager.getInstance().getSkill(itemTypes.lookface);
	//			sb.append(sk.getSimpleDes(false));
	//			return sb.toString();
	//		}
	
	int type = iItemType / 10000000;
	
	// 以下为宝石附加的属性点(含追加)
	int atk_point_add = 0;		// 力量
	int def_point_add = 0;		// 体质
	int dex_point_add = 0;		// 敏捷
	int mag_point_add = 0;		// 智力
	int dodge = 0;				// 闪避
	int hitrate = 0;			// 物理命中
	int atk = 0;				// 物理攻击
	int def = 0;				// 物理防御
	int mag_atk = 0;			// 魔法攻击
	int mag_def = 0;			// 魔法防御
	int hard_hitrate = 0; 		// 物理暴击
	int mana_limit = 0;			// 魔法暴击
	int atk_speed = 0;			// 攻击速度
	int life = 0;				// 生命值追加
	int mana = 0;				// 魔法值追加
	
	if (type == 0 || type == 1)
	{ // 装备 & 宠物品质
		sb << NDCommonCString("PingZhi") << ": ";
		if(bolShowColor){
			sb << "<c" << color;
		}
		switch (iItemType % 10)
		{
			case 5:
			{
				sb << NDCommonCString("putong");
				break;
			}
			case 6:
			{
				if (iItemType == 0)
				{
					sb << NDCommonCString("jingzhi");
				} 
				else 
				{
					sb << NDCommonCString("youxiu");
				}
				break;
			}
			case 7:
			{
				sb << NDCommonCString("xiyou");
				break;
			}
			case 8:
			{
				if (iItemType == 0)
				{
					sb << NDCommonCString("sishi");
				}
				else
				{
					sb << NDCommonCString("wangmei");
				}
				break;
			}
			case 9:
			{
				sb << NDCommonCString("chuanshuo");
				break;
			}
		}
		if(bolShowColor){
			sb << "/e";
		}
		sb << "\n";
	}
	
	sb << NDCommonCString("type") << ": ";
	if (type == 0)
	{ // 装备
		switch (iItemType / 100000)
		{
			case 11: 
			{
				sb << NDCommonCString("ShuanShouDao");
				break;
			}
			case 12: 
			{
				sb << NDCommonCString("ShuanShouJian");
				break;
			}
			case 13: 
			{
				sb << NDCommonCString("ShuanShouZhang");
				break;
			}
			case 14:
			{
				sb << NDCommonCString("ShuanShouGong");
				break;
			}
			case 15:
			{
				sb << NDCommonCString("LongGun");
				break;
			}
			case 16:
			{
				sb << NDCommonCString("Gung");
				break;
			}
			case 21:
			{
				sb << NDCommonCString("DangShouDao");
				break;
			}
			case 22: 
			{
				sb << NDCommonCString("DangShouJian");
				break;
			}
			case 23: 
			{
				sb << NDCommonCString("BiShou");
				break;
			}
			case 24: 
			{
				sb << NDCommonCString("HuShouGou");
				break;
			}
			case 31: {
				sb << (NDCommonCString("DunPai"));
				break;
			}
			case 32:
			{
				sb << NDCommonCString("FuShouFaQi");
				break;
			}
			case 41:
			{
				sb << NDCommonCString("TouKui");
				break;
			}
			case 42:
			{
				sb << NDCommonCString("JianJia");
				break;
			}
			case 43:
			{
				sb << NDCommonCString("XiongJia");
				break;
			}
			case 44:
			{
				sb << (NDCommonCString("HuWang"));
				break;
			}
			case 45: {
				sb << NDCommonCString("PiFeng");
				break;
			}
			case 46: 
			{
				sb << NDCommonCString("HuTui");
				break;
			}
			case 47:
			{
				sb << NDCommonCString("XieZhi");
				break;
			}
			case 51:
			{
				sb << NDCommonCString("XiangLiang");
				break;
			}
			case 52:
			{
				sb << NDCommonCString("ErHuan");
				break;
			}
			case 53: 
			{
				sb << NDCommonCString("HuiJi");//护符
				break;
			}
			case 54:
			{
				sb << NDCommonCString("JieZhi");
				break;
			}
			case 55:
			{
				sb << NDCommonCString("HuiJi");
				break;
			}
			case 56:
			{
				sb << NDCommonCString("FaBao");
				break;
			}
		}
		sb << "\n";
		
		// 镶嵌
		/*
		if (byHole > 0) 
		{
			sb << "镶嵌：" << vecStone.size() << "/" << int(byHole) << ("\n");
			std::vector<Item*>::iterator it = vecStone.begin();
			
			if(int(vecStone.size())>0&&bolShowColor){
				sb << "<c199900 \n";
			}else{
				sb << "\n";
			}
			
			for(; it != vecStone.end(); it++)
			{
				Item* stone = *it;
				sb << stone->getItemName();
				sb << "\n";
				atk_point_add += stone->getAtk_point_add();
				def_point_add += stone->getDef_point_add();
				dex_point_add += stone->getDex_point_add();
				mag_point_add += stone->getMag_point_add();
				dodge += stone->getDodge();
				hitrate += stone->getHitrate();
				atk += stone->getAtk();
				def += stone->getDef();
				mag_atk += stone->getMag_atk();
				mag_def += stone->getMag_def();
				hard_hitrate += stone->getHard_hitrate();
				atk_speed += stone->getAtk_speed();
				mana_limit += stone->getMana_limit();
				life += stone->getLife();
				mana += stone->getMana();
			}
		}
		*/
		
		// 镶嵌
		if (byHole > 0) {
			sb << NDCommonCString("XiangQian") << ": " << vecStone.size() << "/" << int(byHole);
			Item* stone;
			int size = vecStone.size();
			if (size > 0 && bolShowColor) {
				sb << "<c199900 \n";
			} else {
				sb << "\n";
			}
			for (int i = 0; i < size; i++) {
				stone = vecStone[i];
				atk_point_add += stone->getAtk_point_add();
				if (stone->getAtk_point_add() > 0) {
					sb << NDCommonCString("Liliang") << "+" << stone->getAtk_point_add();
				}
				def_point_add += stone->getDef_point_add();
				if (stone->getDef_point_add() > 0) {
					sb << NDCommonCString("TiZhi") << "+" << stone->getDef_point_add();
				}
				dex_point_add += stone->getDex_point_add();
				if (stone->getDex_point_add() > 0) {
					sb << NDCommonCString("MingJie") << "+" << stone->getDex_point_add();
				}
				mag_point_add += stone->getMag_point_add();
				if (stone->getMag_point_add() > 0) {
					sb << NDCommonCString("ZhiLi") << "+" << stone->getMag_point_add();
				}
				dodge += stone->getDodge();
				if (stone->getDodge() > 0) {
					sb << NDCommonCString("Dodge") << "+" << stone->getDodge();
				}
				hitrate += stone->getHitrate();
				if (stone->getHitrate() > 0) {
					sb << NDCommonCString("PhyHit") << "+" << stone->getHitrate();
				}
				atk += stone->getAtk();
				if (stone->getAtk() > 0) {
					sb << NDCommonCString("PhyAtk") << "+" << stone->getAtk();
				}
				def += stone->getDef();
				if (stone->getDef() > 0) {
					sb << NDCommonCString("PhyDef") << "+" << stone->getDef();
				}
				mag_atk += stone->getMag_atk();
				if (stone->getMag_atk() > 0) {
					sb << NDCommonCString("MagicAtk") << "+" << stone->getMag_atk();
				}
				mag_def += stone->getMag_def();
				if (stone->getMag_def() > 0) {
					sb << NDCommonCString("MagDef") << "+" << stone->getMag_def();
				}
				hard_hitrate += stone->getHard_hitrate();
				if (stone->getHard_hitrate() > 0) {
					sb << NDCommonCString("PhyCriticalHit") << "+" << stone->getHard_hitrate();
				}
				atk_speed += stone->getAtk_speed();
				if (stone->getAtk_speed() > 0) {
					sb << NDCommonCString("ChuShouSpeed") << " +" << stone->getAtk_speed();
				}
				mana_limit += stone->getMana_limit();
				if (stone->getMana_limit() > 0) {
					sb << NDCommonCString("MagicCriticalHit") << "+" << stone->getMana_limit();
				}
				life += stone->getLife();
				if (stone->getLife() > 0) {
					sb << NDCommonCString("LifeZhuiJia") << "+" << stone->getLife();
				}
				mana += stone->getMana();
				if (stone->getMana() > 0) {
					sb << NDCommonCString("MagicZhuiJia") << "+" << stone->getMana();
				}
				sb << "(" << stone->getItemLevel() << NDCommonCString("Ji")
						  << stone->getItemName() << ")";
				
				if (i != size - 1) {
					sb << "\n";
				}
			}
			if (size > 0 && bolShowColor) {
				sb << "/e \n";
			} else if (size > 0 && !bolShowColor) {
				sb << "\n";
			}
		}
		
		// 追加
		if (iAddition >= 1) {
			life += getOnlyAdditionPoint(itemtype->m_data.m_enhancedId, iAddition, getLife());
			mana += getOnlyAdditionPoint(itemtype->m_data.m_enhancedId, iAddition, getMana());
			atk += getOnlyAdditionPoint(itemtype->m_data.m_enhancedId, iAddition, getAtk());
			def += getOnlyAdditionPoint(itemtype->m_data.m_enhancedId, iAddition, getDef());
			mag_atk += getOnlyAdditionPoint(itemtype->m_data.m_enhancedId, iAddition, getMag_atk());
			mag_def += getOnlyAdditionPoint(itemtype->m_data.m_enhancedId, iAddition, getMag_def());
		}
		
	} else if (type == 3)
	{ // 任务物品
		sb << NDCommonCString("QuestItem") << "\n";
	} else 
	{
		switch (iItemType / 1000000)
		{
			case 10:
				sb << NDCommonCString("pet");
				break;
			case 11:
				sb << NDCommonCString("ZhangChong");
				break;
			case 14:
				sb << NDCommonCString("QiChong");
				break;
			case 22:
				sb << NDCommonCString("material");
				break;
			case 24:
				sb << NDCommonCString("JuangZhou");
				break;
			case 25:
				sb << NDCommonCString("book");
				break;
			case 23:
				sb << NDCommonCString("PeiFang");
				break;
			case 26:
				sb << NDCommonCString("ParticularItem");
				break;
			case 27:
				sb << NDCommonCString("TouXiang");
				break;
			case 29:
				sb << NDCommonCString("BaoShi");
				break;
			case 61:
				sb << NDCommonCString("YaoCai");
				break;
			case 62:
				sb << NDCommonCString("KuangShi");
				break;
			default:
				sb << NDCommonCString("other");
				break;
		}
		
		sb << "\n";
	}
	
	
	if (itemtype->m_data.m_req_level != 0) {
		sb << NDCommonCString("UseLevel") << ": ";
		sb << itemtype->m_data.m_req_level;
		sb << "\n";
	}
	
	if(byBindState == BIND_STATE_BIND){
		sb << NDCommonCString("hadbind") << " ";
		sb << ("\n");
	}
	
	if (itemtype->m_data.m_idUplev != 0) {
		NDItemType *upItemType = ItemMgrObj.QueryItemType(itemtype->m_data.m_idUplev);
		if (upItemType) 
		{
			sb << NDCommonCString("up") << ": ";
			if (bolShowColor) 
			{
				sb << "<c" << NDItemType::getItemStrColor(itemtype->m_data.m_idUplev%10);
			}
			
			sb << upItemType->m_name;
			
			if (bolShowColor) 
			{
				sb << "/e";
			}
			
			sb << "\n";
		}
	}
	
	if (itemtype->m_data.m_req_sex != 0) {
		sb << NDCommonCString("SexReq") << ": ";
		if (itemtype->m_data.m_req_sex == 1) {
			sb << NDCommonCString("male");
		} else if (itemtype->m_data.m_req_sex == 2) {
			sb << NDCommonCString("female");
		}
		sb << "\n";
	}
	
	if (itemtype->m_data.m_req_phy != 0) {
		sb << NDCommonCString("LiLiangReq") << ": ";
		sb << itemtype->m_data.m_req_phy;
		sb << "\n";
	}
	
	if (itemtype->m_data.m_req_def != 0) {
		sb << NDCommonCString("TiZhiReq") << ": ";
		sb << itemtype->m_data.m_req_def;
		sb << "\n";
	}
	
	if (itemtype->m_data.m_req_dex != 0) {
		sb << NDCommonCString("MingJieReq") << ": ";
		sb << itemtype->m_data.m_req_dex;
		sb << "\n";
	}
	
	if (itemtype->m_data.m_req_mag != 0) {
		sb << NDCommonCString("ZhiLiReq") << ": ";
		sb << itemtype->m_data.m_req_mag;
		sb << "\n";
	}
	
	if (type == 0) {
		sb << NDCommonCString("NaiJiu") << ": ";
		if (iAmount >= 0) {
			//sb << (iAmount / 100);
			sb << (iAmount);
		} else {
			//sb << (itemtype->m_data.m_amount_limit / 100);
			sb << (itemtype->m_data.m_amount_limit);
		}
		sb << ("/");
		//sb << (itemtype->m_data.m_amount_limit / 100);
		sb << (itemtype->m_data.m_amount_limit);
		sb << ("\n");
	}
	
	std::string tmp;
	appendPointsDes(tmp, itemtype->m_data.m_life, life, NDCommonCString("LifePlus"), bolShowColor);						sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_mana, mana, NDCommonCString("MagicPlus"), bolShowColor);						sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_hard_hitrate, hard_hitrate, NDCommonCString("PhyCriticalPlus"), bolShowColor);		sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_mana_limit, mana_limit, NDCommonCString("MagicCriticalPlus"), bolShowColor);			sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_atk_point_add, atk_point_add, NDCommonCString("LiLiangPlus"), bolShowColor);		sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_def_point_add, def_point_add, NDCommonCString("TiZhiPlus"), bolShowColor);		sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_dex_point_add, dex_point_add, NDCommonCString("MingJiePlus"), bolShowColor);		sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_mag_point_add, mag_point_add, NDCommonCString("ZhiLiPlus"), bolShowColor);		sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_atk, atk, NDCommonCString("PhyAtkPlus"), bolShowColor);						sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_def, def, NDCommonCString("PhyDefPlus"), bolShowColor);						sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_mag_atk, mag_atk, NDCommonCString("MagicAtkPlus"), bolShowColor);				sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_mag_def, mag_def, NDCommonCString("MagicDefPlus"), bolShowColor);				sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_hitrate, hitrate, NDCommonCString("HitPlus"), bolShowColor);					sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_atk_speed, atk_speed, NDCommonCString("AtkSpeedPlus"), bolShowColor);			sb << tmp; tmp.clear();
	appendPointsDes(tmp, itemtype->m_data.m_dodge, dodge, NDCommonCString("DodgePlus"), bolShowColor);						sb << tmp; tmp.clear();
	
	if(isRidePet()){
		sb << NDCommonCString("ShouMing") << ":";
		if (iID != 0) {
			sb << ((this->sAge + 99) / 100);
		} else {
			sb << (100);
		}
		sb << ("\n");
		sb << NDCommonCString("TiLi") << ":";
		if (iID != 0) {
			sb << (iAmount);
		} else {
			sb << (getAmount_limit());
		}
		sb << ("\n");
	}
	
	bool isTimeLimited = false;
	
	if (itemtype->m_data.m_save_time > 0 || itemtype->m_data.m_recycle_time > 0) {
		isTimeLimited = true;
	}
	
	if (itemtype->m_data.m_monopoly != 0) {
		stringstream sbLimit;
		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_TRADE) > 0 ||
			isTimeLimited
			) 
		{
			sbLimit << NDCommonCString("CantTrade") << ";\n";
			sbLimit << NDCommonCString("CantMail") << ";\n";
		}
		else if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_MAIL) > 0) 
		{
			sbLimit << NDCommonCString("CantMail") << ";\n";
		}

		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_STORAGE) > 0) {
			sbLimit << NDCommonCString("CantStorage") << ";\n";
		}
		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_MISS) > 0) {
			sbLimit << NDCommonCString("DieCantDiaoLuo") << ";\n";
		}
		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_SALE) > 0 ||
			isTimeLimited
			) 
		{
			sbLimit << NDCommonCString("CantSale") << ";\n";
		}
		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_USE) > 0) {
			sbLimit << NDCommonCString("CantUse") << ";\n";
		}
		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_DROP) > 0) {
			sbLimit << NDCommonCString("CantDrop") << ";\n";
		}
		
		/*
		if ((itemtype->m_data.m_monopoly & ITEMTYPE_MONOPOLY_NOT_ENHANCE) > 0) {
			sbLimit << ("不可强化;\n");
		}
		*/
		if (!isCanEnhance()) {
			sbLimit << NDCommonCString("CantDuanZhao") << ";\n";
		}
		
		if (!sbLimit.str().empty()) {
			sb << NDCommonCString("limit") << ": ";
			sb << (sbLimit.str().c_str());
		}
	}
	
	{
		
		if (iID != 0) 
		{
			//sb << getStringTime(iCreateTime + itemtype->m_data.m_save_time);
			// iCreateTime YYMMDDHHmm
			if (iCreateTime != 0)
			{
				uint recycle = iCreateTime/100; // YYMMDDHH
				sb << "20" <<(recycle / 1000000) << NDCommonCString("year")
				<< (recycle % 1000000 / 10000) << NDCommonCString("month")
				<< (recycle % 10000 / 100) << NDCommonCString("day")
				<< (recycle % 100) << NDCommonCString("hour") 
				<< (iCreateTime%100) << NDCommonCString("minute")
				<<  "<cff0000" << " " << NDCommonCString("RecycleBySys") << "/e";
			}
			
		} else {
			std::string strDelTime;
			
			uint unDelTime = 0;
			int nSaveTime = itemtype->m_data.m_save_time;
			if (nSaveTime > 0)
			{
				std::stringstream ssDelTime;
				unDelTime = TimeConvert(TIME_MINUTE, time(NULL)+nSaveTime);
				
				ssDelTime << NDCommonCString("ValidDate") << ": ";
				ssDelTime << (itemtype->m_data.m_save_time / 3600);
				ssDelTime << NDCommonCString("XiaoShi");
				
				strDelTime = ssDelTime.str();
			}
			
			uint unRecycleTime = itemtype->m_data.m_recycle_time;
			if (unRecycleTime > 0)
			{
				unRecycleTime = unRecycleTime % 100000000 *100;
				if (0 == unDelTime || unDelTime > unRecycleTime)
				{
					std::stringstream ssDelTime;
					
					uint recycle = itemtype->m_data.m_recycle_time% 100000000; // YYMMDDHH
					ssDelTime << "20" << (recycle / 1000000) << NDCommonCString("year") 
					   << (recycle % 1000000 / 10000) << NDCommonCString("month")
					   << (recycle % 10000 / 100) << NDCommonCString("day")
					   <<  (recycle % 100) << NDCommonCString("hour") 
					   << "0" << NDCommonCString("minute")
					   << "<cff0000" << " " << NDCommonCString("RecycleBySys") << "/e";
					strDelTime = ssDelTime.str();
				}
			}
			
			sb << strDelTime;
		}
		sb << ("\n");
	}
	
	if (!itemtype->m_des.empty()) {
		sb << NDCommonCString("ShuoMing") << ": ";
		sb << (itemtype->m_des);
		sb << ("\n");
	}
	
	if (isStone()) {
		sb << NDCommonCString("XiangQianPos") << ": ";
		sb << (getInlayPos());
		sb << ("\n");
	}
	
	if(itemtype->m_data.m_suitData!=0&&type==0){
		SuitTypeObj* Obj=SuitTypeObj::findSuitType(itemtype->m_data.m_suitData);
		if(Obj!=NULL){
			SuitTypeObj& suitTypeObj = *Obj;
			int suitData=itemtype->m_data.m_suitData;
			Item *item;
			int allAmount=0;
			int hasAmount=0;
			if(suitTypeObj.equip_id_1!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_1);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
				
			}
			if(suitTypeObj.equip_id_2!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_2);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
			}
			if(suitTypeObj.equip_id_3!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_3);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
			}
			if(suitTypeObj.equip_id_4!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_4);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
			}
			if(suitTypeObj.equip_id_5!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_5);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
			}
			if(suitTypeObj.equip_id_6!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_6);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
			}
			if(suitTypeObj.equip_id_7!=0){
				allAmount++;
				item=findItemByItemType(suitTypeObj.equip_id_7);
				if(item!=NULL&&item->getSuitData()==suitData&&item->iAmount>0){
					hasAmount++;
				}
			}
			
			
			if(!suitTypeObj.name.empty()){
				if(bolShowColor){
					sb << " <c" << color << suitTypeObj.name << "(" << hasAmount << "/" << allAmount << ")" << "/e \n";
				}else{
					sb << suitTypeObj.name << "("<< hasAmount << "/" << allAmount << ")" << "\n";
				}
			}
			if(!suitTypeObj.equip_name_1.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_1);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_1 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_1 << "\n";
				}
			}
			if(!suitTypeObj.equip_name_2.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_2);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_2 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_2 << "\n";
				}
			}
			if(!suitTypeObj.equip_name_3.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_3);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_3 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_3 << "\n";
				}
			}
			if(!suitTypeObj.equip_name_4.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_4);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_4 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_4 << "\n";
				}
			}
			if(!suitTypeObj.equip_name_5.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_5);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_5 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_5 << "\n";
				}
			}
			if(!suitTypeObj.equip_name_6.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_6);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_6 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_6 << "\n";
				}
			}
			if(!suitTypeObj.equip_name_7.empty()){
				item=findItemByItemType(suitTypeObj.equip_id_7);
				if(item!=NULL&&item->getSuitData()==suitData&&bolShowColor&&item->iAmount>0){
					sb << "   <c199900" << suitTypeObj.equip_name_7 << "/e \n";
				}else{
					sb << "   " << suitTypeObj.equip_name_7 << "\n";
				}
			}
			
			if(hasAmount>=suitTypeObj.equip_set_1_num&&bolShowColor){
				sb << " <c199900" << NDCommonCString("TaoZhuang") << "(" << suitTypeObj.equip_set_1_num << ")" << suitTypeObj.equip_set_1_des << "/e \n";
			}else{
				sb << " " << NDCommonCString("TaoZhuang") << "(" << int(suitTypeObj.equip_set_1_num) << ")" << suitTypeObj.equip_set_1_des << "\n";
			}
			
			if(hasAmount>=suitTypeObj.equip_set_2_num&&bolShowColor){
				sb << " <c199900" << NDCommonCString("TaoZhuang") << "(" << int(suitTypeObj.equip_set_2_num) << ")" << suitTypeObj.equip_set_2_des << "/e \n";
			}else{
				sb << " " << NDCommonCString("TaoZhuang") << "(" << int(suitTypeObj.equip_set_2_num) << ")" << suitTypeObj.equip_set_2_des << " \n";
			}
			if(hasAmount>=suitTypeObj.equip_set_3_num&&bolShowColor){
				sb << " <c199900" << NDCommonCString("TaoZhuang") << "(" << int(suitTypeObj.equip_set_3_num) << ")" << suitTypeObj.equip_set_3_des << "/e \n";
			}else{
				sb << " " << NDCommonCString("TaoZhuang") << "(" << int(suitTypeObj.equip_set_3_num) << ")" << suitTypeObj.equip_set_3_des << "\n";
			}	
		}
	}
	
	// 锻造描述
	if (type == 0 && itemtype->m_data.m_enhancedStatus != 0) {
		sb << ("\n ");
		SuitTypeObj* suitTypeObj = SuitTypeObj::findSuitType(itemtype->m_data.m_enhancedStatus);
		if (suitTypeObj) {
			if (bolShowColor) {
				sb << "<c199900" << NDCommonCString("DuanZhaoAttach") << "：/e \n";
			} else {
				sb << NDCommonCString("DuanZhaoAttach") << "\n";
			}
			
			if(suitTypeObj->equip_set_1_num!=0){
				if (iAddition >= suitTypeObj->equip_set_1_num
					&& bolShowColor) {
					sb << " <c199900+" << (int)suitTypeObj->equip_set_1_num
							  << ":" << suitTypeObj->equip_set_1_des << "/e \n";
				} else {
					sb << " +" << (int)suitTypeObj->equip_set_1_num << ":" << suitTypeObj->equip_set_1_des << "\n";
				}
			}
			if(suitTypeObj->equip_set_2_num!=0){
				if (iAddition >= suitTypeObj->equip_set_2_num
					&& bolShowColor) {
					sb << " <c199900+" << (int)suitTypeObj->equip_set_2_num
							  << ":" << suitTypeObj->equip_set_2_des << "/e \n";
				} else {
					sb << " +" << (int)suitTypeObj->equip_set_2_num << ":" << suitTypeObj->equip_set_2_des << "\n";
				}
			}
			if(suitTypeObj->equip_set_3_num!=0){
				if (iAddition >= suitTypeObj->equip_set_3_num
					&& bolShowColor) {
					sb << " <c199900+" << (int)suitTypeObj->equip_set_3_num
							  << ":" << suitTypeObj->equip_set_3_des << "/e \n";
				} else {
					sb << " +" << (int)suitTypeObj->equip_set_3_num << ":" << suitTypeObj->equip_set_3_des << "\n";
				}
			}
		}
	}
	
	return std::string(sb.str().c_str());
}

/**
 * 添加属性值描述信息
 * @param sb 添加到的字符串
 * @param equipPoint 基本属性值
 * @param stonePoint 镶嵌宝石属性值
 * @param des 基本描述
 * @param bolShowColor 附加属性是否显示颜色
 */
void Item::appendPointsDes(string& str, int equipPoint, int stonePoint, std::string des, bool bolShowColor)
{
	stringstream sb;
	if (equipPoint + stonePoint > 0) {
		sb << (des);
		sb << (equipPoint);
		stringstream ss; ss << "+"; ss << stonePoint;
		if (stonePoint > 0) {
			if (bolShowColor) {
				sb << "(" << getAdd(ss.str()) << ")";
			} else {
				sb << "(+" << stonePoint << ")";
			}
		}
		sb << "\n";
	}
	
	str = sb.str();
}

std::string Item::getInlayPos()
{
	switch ((iItemType / 1000) % 100) {
		case 1:
			return NDCommonCString("WuQi");
		case 41:
			return NDCommonCString("TouKui");
		case 42:
			return NDCommonCString("JianBang");
		case 43:
			return NDCommonCString("XiongJia");
		case 44:
			return NDCommonCString("HuWang");
		case 46:
			return NDCommonCString("HuTui");
		case 47:
			return NDCommonCString("XieZhi");
		case 51:
			return NDCommonCString("XiangLiang");
		case 52:
			return NDCommonCString("ErHuan");
		case 54:
			return NDCommonCString("JieZhi");
	}
	return NDCommonCString("wu");
}

string Item::makeItemName()
{
	stringstream ss;
	
	ss << this->getItemNameWithAdd();
	
	if (!this->isRidePet()) {
		int type = this->iItemType / 10000000;
		if (type > 0 && this->iAmount > 1) {
			ss << " × " << this->iAmount;
		}
	}
	return ss.str();
}

std::string Item::getItemName() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (itemtype) 
	{
		return itemtype->m_name;
	}
	
	return std::string("");
}

std::string Item::getItemNameWithAdd()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (itemtype) 
	{
		stringstream ss;
		ss << itemtype->m_name;
		if (iAddition > 0)
		{
			ss << "+" << iAddition;
		}
		return std::string(ss.str().c_str());
	}
	
	return std::string("");
}

int Item::getAtk_point_add() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_atk_point_add;
}

int Item::getDef_point_add() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_def_point_add;
}

int Item::getDex_point_add() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_dex_point_add;
}

int Item::getMag_point_add() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_mag_point_add;
}

int Item::getDodge() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_dodge;
}

int Item::getHitrate() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_hitrate;
}

int Item::getAtk() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_atk;
}

int Item::getDef() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_def;
}

int Item::getMag_atk() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_mag_atk;
}

int Item::getHard_hitrate() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_hard_hitrate;
}

int Item::getAtk_speed() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_atk_speed;
}

int Item::getMana_limit() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_mana_limit;
}

int Item::getLife() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_life;
}

int Item::getMana() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_mana;
}

int Item::getMag_def() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_mag_def;
}

int Item::getAmount_limit() {
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_amount_limit;
}

int Item::getPrice()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_price;
}

int Item::getReq_level()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_req_level;
}

int Item::getReq_phy()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_req_phy;
}

int Item::getReq_dex()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_req_dex;
}

int Item::getReq_mag()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_req_mag;
}

int Item::getReq_def()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_req_def;
}

int Item::getItemLevel()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_level;
}

int Item::getReq_profession()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_req_profession;
}

int Item::getSave_time()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_save_time;
}

int Item::getRecycle_time()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_recycle_time;
}

int Item::getEmoney()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_emoney;
}

int Item::getSuitData()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_suitData;
}

int Item::getIdUpLev()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_idUplev;
}

bool Item::IsNeedRepair()
{
	if (!isEquip() || isRidePet()) 
	{
		return false;
	}
	
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return false;
	}
	
	if (itemtype->m_data.m_amount_limit > iAmount) 
	{
		return true;
	}
	
	return false;
}

bool Item::isEquip()
{
	int type = Item::getIdRule(iItemType, Item::ITEM_TYPE);
	if (type == 0 || type == 1) {
		return true;
	}
	return false;
}

bool Item::isItemCanTrade()
{
	if ((getMonopoly() & ITEMTYPE_MONOPOLY_NOT_TRADE) != 0) {
		return false;
	}
	
	if (hasTimeLitmit()) {
		return false;
	}
	
	return true;
}

bool Item::isItemCanUse()
{
	if ((getMonopoly() & ITEMTYPE_MONOPOLY_NOT_USE) != 0) {
		return false;
	}
	return true;
}

bool Item::isItemCanStore()
{
	if ((getMonopoly() & ITEMTYPE_MONOPOLY_NOT_STORAGE) != 0) {
		return false;
	}
	return true;
}

bool Item::isFormulaExt()
{
	std::vector<int> arr = getItemType(iItemType);
	int item_type = arr[0]; // 千万
	int item_equip = arr[1]; // 百万
	int item_class = arr[2]; // 十万
	if (item_type != 2 || (item_equip * 10 + item_class) != 51) { //2表消耗品,51
		return false;
	}
	return true;
}

bool Item::isCanEnhance(){
	int enhanceId = getEnhanceId();
	return enhanceId > 0 && ItemMgrObj.QueryEnhancedType(enhanceId + iAddition + 1) != NULL;
}

bool Item::canOpenHole()
{
	std::vector<int> rule = getItemType(iItemType);
	if (rule[0] == 0) {
		return true;
	}
	return false;
}

NDEngine::NDUIDialog* Item::makeItemDialog(std::vector<std::string>& vec_str)
{
	std::string tempStr = makeItemDes(false, true);
	std::stringstream name;
	name << getItemNameWithAdd();
	
	//ChatRecord.parserChat(tempStr,7) 
	
	
	if(getSuitData()>0&&iItemType / 10000000==0){ 
		name << "[" << NDCommonCString("tao") << "]";
	}
	
	//int color=ItemType.getItemColor(itemType); todo
	//			if(color==-1){
	//				color=0xe5cc80;
	//			}
	//			dialog.setTitleCorlor(color);
	
	NDUIDialog *dlg = new NDUIDialog;
	dlg->Initialization();
	dlg->Show(name.str().c_str(), tempStr.c_str(), NDCommonCString("return"), vec_str);
	return dlg;
}

/**
 * 丢弃是否有提醒
 * 
 * @param itemType
 * @return
 */
bool Item::isItemDropReminder()
{
	if ((getMonopoly() & ITEMTYPE_MONOPOLY_DROP_REMINDER) != 0)
	{
		return true;
	}
	return false;
}

bool Item::isItemUseReminder()
{
	if ((getMonopoly() & ITEMTYPE_MONOPOLY_USE_REMINDER) != 0) {
		return true;
	}
	return false;
}

bool Item::isItemCanSale()
{
	if ((getMonopoly() & ITEMTYPE_MONOPOLY_NOT_SALE) != 0) 
	{
		return false;
	}
	return true;
}

int Item::getIdRule(int nItemType, int rule) {
	switch (rule) {
		case ITEM_QUALITY: {
			return nItemType % 10;
		}
		case ITEM_GRADE: {
			return nItemType % 1000 / 10;
		}
		case ITEM_PROPERTY: {
			return nItemType % 100000 / 1000;
		}
		case ITEM_CLASS: {
			return nItemType % 1000000 / 100000;
		}
		case ITEM_EQUIP: {
			return nItemType % 10000000 / 1000000;
		}
		case ITEM_TYPE: {
			return nItemType % 100000000 / 10000000;
		}
	}
	
	return 0;
}

Item* Item::findItemByItemType(int idItem)
{
	NDScene* scene = NDDirector::DefaultDirector()->GetRunningScene();
	if (scene && scene->IsKindOfClass(RUNTIME_CLASS(ManualRoleEquipScene))) 
	{
		return ((ManualRoleEquipScene*)scene)->GetSuitItem(idItem);
	}
	
	return ItemMgrObj.GetSuitItem(idItem);
}

bool Item::IsPetUseItem()
{
	if (iItemType == 28000005 
		|| iItemType == 28000006 
		|| (28000015 <= iItemType && iItemType <= 28000017)
		|| iItemType / 100000 == 262
		|| this->IsPetSkillItem()) {
		return true;
	}
	return false;
}

bool Item::IsPetSkillItem()
{
	if (iItemType / 100000 == 252) {
		return true;
	}
	return false;
}

int Item::getLookFace()
{
	NDItemType *itemtype = ItemMgrObj.QueryItemType(iItemType);
	if (!itemtype) 
	{
		return 0;
	}
	return itemtype->m_data.m_lookface;
}


void sendQueryDesc(int itemID)
{
	NDTransData bao(_MSG_QUERY_DESC);
	bao << itemID;
//	SEND_DATA(bao);
	ShowProgressBar;
}

int getItemColor(Item* item) 
{
	if (item == NULL) {
		return 0xe5cc80;
	}
	int color = NDItemType::getItemColor(item->iItemType);
	if (color == -1) {
		return 0xe5cc80;
	}
	
	return color;
}
