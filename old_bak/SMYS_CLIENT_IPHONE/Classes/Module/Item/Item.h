/*
 *  Item.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _ITEM_H_
#define _ITEM_H_
#include <vector>
#include <string>
#include "define.h"
#include "NDUIDialog.h"

class Item
{
public:
	enum  
	{
		/** 商店物品 */
		ITEM_SHOP = 0,
		
		/** 使用 */
		ITEM_USE = 1,
		
		ITEM_DROP = 4,
		
		ITEM_UNEQUIP = 10,
		
		/** 查询物品 */
		ITEM_QUERY = 16,
		
		/** 查询物品失败 */
		ITEM_QUERY_FAIL = 17,
		
		/** 存 */
		ITEM_BANKSAVE = 5,
		
		/** 取 */
		ITEM_BANDDRAW = 6,
		
		/** 购买 */
		_SHOPACT_BUY = 1,
		
		/** 出售 */
		_SHOPACT_SELL = 2,
		
		/** 叠加数量 */
		_SHOPACT_AMOUNT = 3,
		
		/** 修理单件装备 */
		_ITEMACT_REPAIR = 18,
		
		/** 叠加身上所有装备 */
		_ITEMACT_REPAIR_ALL = 19,
		
		/** 使用物品类型 */
		_ITEMACT_USETYPE = 99,
		
		ITEM_QUALITY = 0, // 物品id规则个位
		
		ITEM_GRADE = 1, // 物品id规则百位十位
		
		ITEM_PROPERTY = 2, // 物品id规则万位千位
		
		ITEM_CLASS = 3, // 物品id规则十万位
		
		ITEM_EQUIP = 4, // 物品id规则百万位
		
		ITEM_TYPE = 5, // 物品id规则千万位
	};
	
	enum  
	{
		//TRANSPORTITEMTYPE = 28000007,
		
		OPENHOLE = 28000008,
		
		EUQIP_QUALITIY = 28000001,
		
		EUQIP_ENHANCE = 28000002,
		
		CLEAR_POINT = 24010009,
		
		EQUIP_TLS = 28000010,
		
		REVERT = 28000004,
	};
	
	enum
	{
		ITEMTYPE_MONOPOLY_NONE = 0, // 默认为一般常规物品.所有规则都允许执行.
		ITEMTYPE_MONOPOLY_NOT_TRADE = 1, // 不可以交易(同时包括不可交易,不可拍卖,不可摆摊出售,)(//
		// 即离开身体则消失)
		ITEMTYPE_MONOPOLY_NOT_STORAGE = 2, // 不可以存仓(同时包括不可以存常规仓库和VIP仓库以及宠物仓库)
		ITEMTYPE_MONOPOLY_DROP_REMINDER = 4, // 丢弃提示(丢弃时客户端弹出确认窗口,提示内容:请确认要丢弃
		// )
		ITEMTYPE_MONOPOLY_SALE_REMINDER = 8, // 出售提示(贵重物品出售时,客户端弹出确认窗口,提示内容:
		// 请确认要丢弃)
		ITEMTYPE_MONOPOLY_NOT_MISS = 16, // 死亡不会掉落(在掉落相关规则中优先级最高,比如即使人物是黑名,//
		// 被杀死也不会爆.)
		ITEMTYPE_MONOPOLY_NOT_SALE = 32, // 不可出售
		ITEMTYPE_MONOPOLY_BATTLE = 64, // 战斗内可用
		ITEMTYPE_MONOPOLY_NOT_USE = 128,// 不可使用
		ITEMTYPE_MONOPOLY_USE_REMINDER = 256,// //使用提示(使用物品时,客户端弹出确认窗口,提示内容:
		ITEMTYPE_MONOPOLY_NOT_EMAIL = 0x0200,	// 不可邮寄
		ITEMTYPE_MONOPOLY_NOT_ENHANCE = 0x0400,	// 不可强化
		ITEMTYPE_MONOPOLY_NOT_DROP = 0x0800,	// 不可丢弃
	};
	
	//old 0肩 1头 2胸甲 3项链 4耳环 5腰带--披风 6主武器 7副武 8徽记 9手 10宠物 11护腿 12鞋子 13左戒指 14右戒指 15坐骑
	//new 0护肩 1头盔 2项链 3耳环 4衣服 5腰带--披风 6主武器 7副武 8护腕 9护腿 10左戒指 11右戒指 12徽章 13鞋子 14宠物 15坐骑
	enum eEquip_Pos 
	{
		eEP_Begin = 0,
		eEP_Shoulder = eEP_Begin,				// 护肩
		eEP_Head,								// 头盔
		eEP_XianLian,							// 项链
		eEP_ErHuan,								// 耳环
		eEP_Armor,								// 胸甲(衣服)
		eEP_YaoDai,								// 腰带--披风
		eEP_MainArmor,							// 主武器
		eEP_FuArmor,							// 副武
		eEP_Shou,								// 手(护腕)
		eEP_HuTui,								// 护腿
		eEP_LeftRing,							// 左戒指
		eEP_RightRing,							// 右戒指
		eEP_HuiJi,								// 徽记(徽章)
		eEP_Shoes,								// 鞋子
		eEP_Decoration,							// 勋章
		eEP_Ride,								// 坐骑
		eEP_End,								
	};
	
	enum  
	{
		LIFESKILL_INLAY = 0, // 镶嵌
		LIFESKILL_INLAY_FALSE = 1, // 镶嵌失败
		LIFESKILL_DIGOUT = 2, // 挖除
		LIFESKILL_DIGOUT_FALSE = 3, // 挖除失败
	};
	
public:
	Item();
	Item(int iItemType);
	~Item();
	
	Item(const Item& rhs); //拷贝构造函数
	Item& operator = (const Item& rhs); //赋值符重载
	
	void AddStone(int iItemType);
	void DelStone(int iItemID);
	void DelAllStone();
	
	int getInlayAtk_speed();
	int getInlayAtk();
	int getInlayDef();
	int getInlayHard_hitrate();
	int getInlayMag_atk();
	int getInlayMag_def();
	int getInlayMana_limit();
	int getInlayDodge();
	int getInlayHitrate();
	
	int getAdditionResult(int enhancedId, Byte btAddition, int srcPoint);
	static int getOnlyAdditionPoint(int enhancedId, Byte btAddition, int srcPoint);
	static int getPercentByLevel(int btAddition);
	static int getItemColorTag(int i) {
		std::vector<int> ids = Item::getItemType(i);
		if (ids[0] > 1) {
			return 0;
		}
		return ids[7];
	}
	
	int getMonopoly();
	int getIconIndex();
	int getItemColor();
	int getEnhanceId();
	
	/**
	 * 是否是配方
	 * @return
	 */
	bool isFormula() {
		return (iItemType / 100000) == 251;
	}
	
	/**
	 * 是否是草药
	 */
	bool isRemedy() {
		return (iItemType / 1000000) == 61;
	}
	
	/**
	 * 是否为宠物
	 * 
	 * @return
	 */
	bool isItemPet() {
		std::vector<int> ids = Item::getItemType(iItemType);
		return ids[0] == 1 && ids[1] == 1;
	}
	
	bool isSkillBook() {
		return ((iItemType / 100000) == 250) || ((iItemType / 100000) == 252);
	}
	
	std::string makeItemDes(bool bolIncludeName, bool bolShowColor=false);
	
	string makeItemName();
	
	std::string getItemName();
	
	std::string getItemNameWithAdd();
	
	int getAtk_point_add();	
	
	int getDef_point_add();
	
	int getDex_point_add();
	
	int getMag_point_add();
	
	int getDodge();
	
	int getHitrate();
	
	int getAtk();
	
	int getDef();
	
	int getMag_atk();
	
	int getHard_hitrate();
	
	int getAtk_speed();
	
	int getMana_limit();
	
	int getLife();
	
	int getMana();
	
	int getMag_def();
	
	int getAmount_limit();
	
	int getPrice();
	
	int getReq_level();
	
	int getReq_phy();
	
	int getReq_dex();
	
	int getReq_mag();
	
	int getReq_def();
	
	int getItemLevel();
	
	int getReq_profession();
	
	int getSave_time();
	
	int getRecycle_time();
	
	int getEmoney();
	
	bool isRidePet() {
		return iItemType / 1000000 == 14;
	}
	
	bool isStone() {
		return (iItemType / 1000000) == 29;
	}
	
	std::string getInlayPos(); 
	
	bool isEquip();
	
	bool isItemCanUse();
	
	bool isItemCanTrade();
	
	bool isItemCanStore();
	
	bool isFormulaExt();
	
	// savetime与recycletime限制
	bool hasTimeLitmit() {
		return (getSave_time() != 0 || getRecycle_time() != 0);
	}
	
	bool canInlay() {
		if (byHole > vecStone.size()) {
			return true;
		}
		return false;
	}
	
	bool canChaiFen(){
		return 0 != (iItemType / 10000000) && iAmount > 1;
	}
	
	bool isCanEmail(){
		return ((getMonopoly() & ITEMTYPE_MONOPOLY_NOT_EMAIL) != ITEMTYPE_MONOPOLY_NOT_EMAIL)
				&& (!hasTimeLitmit());
	}
	
	bool isCanEnhance();
	
	bool canOpenHole();
	 
	NDEngine::NDUIDialog* makeItemDialog(std::vector<std::string>& vec_str);
	
	/**
	 * 丢弃是否有提醒
	 * 
	 * @param itemType
	 * @return
	 */
	bool isItemDropReminder();
	
	bool isItemUseReminder();
	
	bool isItemCanSale();
	
	std::string getItemDesc();
	
	int getCurHoleNum(){ 
		return byHole;
	}
	
	int getMaxHoleNum(){
		return (iItemType % 10) - 3;	
	}
	int getStonesCount(){
		return vecStone.size();
	}
	
	int getSuitData();
	static int getIdRule(int nItemType, int rule);
	
	int getIdUpLev();
	
	bool IsNeedRepair();
	
	int getLookFace();
	/**
	 * 取得缩小值后的耐久度
	 * 
	 * @return
	 */
	static int getdwAmountShow(int value) {
		int result = value;// / 100;
		if (value > 0) {
			if (result == 0) {
				result = 1;
			}
		} else {
			result = 0;
		}
		return result;
	}
	
	static std::vector<int> getItemType(int iType);
	
	static bool isDefEquip(int itemType); // 是否防具和副手,都算做防具
	
	static bool isAccessories(int itemType); // 是否饰品	
	
	static bool isWeapon(int itemType); // 是否武器,包括单双手
	
	static std::string getEffectString(std::string name, int tempInt1, int addNum1, int tempInt2, int addNum2);
	
	static std::string makeCompareItemDes(Item* item1, Item* item2, int whichStore);
	
	static std::string getAdd(std::string text) {
		std::string res;
		res += "<c1232f8"; res += text; res += "/e ";
		return res;
	}
	
	static std::string getSub(std::string text) {
		std::string res;
		res += "<cf70a0f"; res += text; res += "/e ";
		return res;
	}
	
	static Item* findItemByItemType(int idItem);
	
	// 是否宠物用的物品
	bool	IsPetUseItem();
	// 是否宠物技能书
	bool	IsPetSkillItem();
private:
	void init();
	/**
	 * 添加属性值描述信息
	 * @param sb 添加到的字符串
	 * @param equipPoint 基本属性值
	 * @param stonePoint 镶嵌宝石属性值
	 * @param des 基本描述
	 * @param bolShowColor 附加属性是否显示颜色
	 */
	void appendPointsDes(std::string& str, int equipPoint, int stonePoint, std::string des, bool bolShowColor);
public:
	int iID;					// 物品的Id
	int iOwnerID;				// 物品的所有者id
	int iItemType;				// 物品类型 id
	int iAmount;				// 物品数量/耐久度
	int iPosition;				// 物品位置
	int iAddition;				// 装备追加
	Byte byBindState;			// 绑定状态
	Byte byHole;				// 装备有几个洞
	int iCreateTime;			// 创建时间
	int sAge;					// 骑宠寿命
	std::vector<Item*> vecStone;	// stone
	bool active;
	//.. 其它属性
};

struct ItemTypeLessThan
{
	bool operator () (Item* first, Item* second)	
	{
		if (!first || !second)
		{
			return false;
		}
		return first->iItemType < second->iItemType;
	}
};

void sendQueryDesc(int itemID);

int getItemColor(Item* item);

#endif// _ITEM_H_