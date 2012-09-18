/*
 *  Item.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 (网龙)DeNA. All rights reserved.
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

		/** �?? */
		ITEM_BANKSAVE = 5,

		/** �?? */
		ITEM_BANDDRAW = 6,

		/** 购买 */
		_SHOPACT_BUY = 1,

		/** 出售 */
		_SHOPACT_SELL = 2,

		/** 叠加数量 */
		_SHOPACT_AMOUNT = 3,

		/** 修理单件装备 */
		_ITEMACT_REPAIR = 18,

		/** 叠加身上�??有装�?? */
		_ITEMACT_REPAIR_ALL = 19,

		/** 使用物品类型 */
		_ITEMACT_USETYPE = 99,

		ITEM_QUALITY = 0, // 物品id规则个位

		ITEM_GRADE = 1, // 物品id规则百位十位

		ITEM_PROPERTY = 2, // 物品id规则万位千位

		ITEM_CLASS = 3, // 物品id规则十万�??

		ITEM_EQUIP = 4, // 物品id规则百万�??

		ITEM_TYPE = 5, // 物品id规则千万�??
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
		ITEMTYPE_MONOPOLY_NONE = 0, // 默认为一般常规物�??.�??有规则都允许执行.
		ITEMTYPE_MONOPOLY_NOT_TRADE = 1, // 不可以交�??(同时包括不可交易,不可拍卖,不可摆摊出售,)(//
		// 即离�??身体则消�??)
		ITEMTYPE_MONOPOLY_NOT_STORAGE = 2, // 不可以存�??(同时包括不可以存常规仓库和VIP仓库以及宠物仓库)
		ITEMTYPE_MONOPOLY_DROP_REMINDER = 4, // 丢弃提示(丢弃时客户端弹出确认窗口,提示内容:请确认要丢弃
		// )
		ITEMTYPE_MONOPOLY_SALE_REMINDER = 8, // 出售提示(贵重物品出售�??,客户端弹出确认窗�??,提示内容:
		// 请确认要丢弃)
		ITEMTYPE_MONOPOLY_NOT_MISS = 16, // 死亡不会掉落(在掉落相关规则中优先级最�??,比如即使人物是黑�??,//
		// 被杀死也不会�??.)
		ITEMTYPE_MONOPOLY_NOT_SALE = 32, // 不可出售
		ITEMTYPE_MONOPOLY_BATTLE = 64, // 战斗内可�??
		ITEMTYPE_MONOPOLY_NOT_USE = 128, // 不可使用
		ITEMTYPE_MONOPOLY_USE_REMINDER = 256, // //使用提示(使用物品�??,客户端弹出确认窗�??,提示内容:
		ITEMTYPE_MONOPOLY_NOT_EMAIL = 0x0200,	// 不可邮寄
		ITEMTYPE_MONOPOLY_NOT_ENHANCE = 0x0400,	// 不可强化
		ITEMTYPE_MONOPOLY_NOT_DROP = 0x0800,	// 不可丢弃
	};

	//old 0�?? 1�?? 2胸甲 3项链 4耳环 5腰带--披风 6主武�?? 7副武 8徽记 9�?? 10宠物 11护腿 12鞋子 13左戒�?? 14右戒�?? 15坐骑
	//new 0护肩 1头盔 2项链 3耳环 4衣服 5腰带--披风 6主武�?? 7副武 8护腕 9护腿 10左戒�?? 11右戒�?? 12徽章 13鞋子 14宠物 15坐骑
	enum eEquip_Pos
	{
		eEP_Begin = 0, eEP_Shoulder = eEP_Begin,				// 护肩
		eEP_Head,								// 头盔
		eEP_XianLian,							// 项链
		eEP_ErHuan,								// 耳环
		eEP_Armor,								// 胸甲(衣服)
		eEP_YaoDai,								// 腰带--披风
		eEP_MainArmor,							// 主武�??
		eEP_FuArmor,							// 副武
		eEP_Shou,								// �??(护腕)
		eEP_HuTui,								// 护腿
		eEP_LeftRing,							// 左戒�??
		eEP_RightRing,							// 右戒�??
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

	Item(const Item& rhs); //拷贝构�??�函�??
	Item& operator =(const Item& rhs); //赋�??�符重载

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
	static int getOnlyAdditionPoint(int enhancedId, Byte btAddition,
			int srcPoint);
	static int getPercentByLevel(int btAddition);
	static int getItemColorTag(int i)
	{
		std::vector<int> ids = Item::getItemType(i);
		if (ids[0] > 1)
		{
			return 0;
		}
		return ids[7];
	}

	int getMonopoly();
	int getIconIndex();
	int getItemColor();
	int getEnhanceId();

	/**
	 * 是否是配�??
	 * @return
	 */
	bool isFormula()
	{
		return (m_nItemType / 100000) == 251;
	}

	/**
	 * 是否是草�??
	 */
	bool isRemedy()
	{
		return (m_nItemType / 1000000) == 61;
	}

	/**
	 * 是否为宠�??
	 * 
	 * @return
	 */
	bool isItemPet()
	{
		std::vector<int> ids = Item::getItemType(m_nItemType);
		return ids[0] == 1 && ids[1] == 1;
	}

	bool isSkillBook()
	{
		return ((m_nItemType / 100000) == 250) || ((m_nItemType / 100000) == 252);
	}

	std::string makeItemDes(bool bolIncludeName, bool bolShowColor = false);

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

	bool isRidePet()
	{
		return m_nItemType / 1000000 == 14;
	}

	bool isStone()
	{
		return (m_nItemType / 1000000) == 29;
	}

	std::string getInlayPos();

	bool isEquip();

	bool isItemCanUse();

	bool isItemCanTrade();

	bool isItemCanStore();

	bool isFormulaExt();

	// savetime与recycletime限制
	bool hasTimeLitmit()
	{
		return (getSave_time() != 0 || getRecycle_time() != 0);
	}

	bool canInlay()
	{
		if (m_nHole > m_vStone.size())
		{
			return true;
		}
		return false;
	}

	bool canChaiFen()
	{
		return 0 != (m_nItemType / 10000000) && m_nAmount > 1;
	}

	bool isCanEmail()
	{
		return ((getMonopoly() & ITEMTYPE_MONOPOLY_NOT_EMAIL)
				!= ITEMTYPE_MONOPOLY_NOT_EMAIL) && (!hasTimeLitmit());
	}

	bool isCanEnhance();

	bool canOpenHole();

	NDEngine::NDUIDialog* makeItemDialog(std::vector<std::string>& vec_str);

	/**
	 * 丢弃是否有提�??
	 * 
	 * @param itemType
	 * @return
	 */
	bool isItemDropReminder();

	bool isItemUseReminder();

	bool isItemCanSale();

	std::string getItemDesc();

	int getCurHoleNum()
	{
		return m_nHole;
	}

	int getMaxHoleNum()
	{
		return (m_nItemType % 10) - 3;
	}
	int getStonesCount()
	{
		return m_vStone.size();
	}

	int getSuitData();
	static int getIdRule(int nItemType, int rule);

	int getIdUpLev();

	bool IsNeedRepair();

	int getLookFace();
	/**
	 * 取得缩小值后的�??�久�??
	 * 
	 * @return
	 */
	static int getdwAmountShow(int value)
	{
		int result = value; // / 100;
		if (value > 0)
		{
			if (result == 0)
			{
				result = 1;
			}
		}
		else
		{
			result = 0;
		}
		return result;
	}

	static std::vector<int> getItemType(int iType);

	static bool isDefEquip(int itemType); // 是否防具和副�??,都算做防�??

	static bool isAccessories(int itemType); // 是否饰品	

	static bool isWeapon(int itemType); // 是否武器,包括单双�??

	static std::string getEffectString(std::string name, int tempInt1,
			int addNum1, int tempInt2, int addNum2);

	static std::string makeCompareItemDes(Item* item1, Item* item2,
			int whichStore);

	static std::string getAdd(std::string text)
	{
		std::string res;
		res += "<c1232f8";
		res += text;
		res += "/e ";
		return res;
	}

	static std::string getSub(std::string text)
	{
		std::string res;
		res += "<cf70a0f";
		res += text;
		res += "/e ";
		return res;
	}

	static Item* findItemByItemType(int idItem);

	// 是否宠物用的物品
	bool IsPetUseItem();
	// 是否宠物�??能书
	bool IsPetSkillItem();
private:
	void init();
	/**
	 * 添加属�??��??�描述信�??
	 * @param sb 添加到的字符�??
	 * @param equipPoint 基本属�??��????
	 * @param stonePoint 镶嵌宝石属�??��????
	 * @param des 基本描述
	 * @param bolShowColor 附加属�??�是否显示颜�??
	 */
	void appendPointsDes(std::string& str, int equipPoint, int stonePoint,
			std::string des, bool bolShowColor);
public:
	int m_nID;					// 物品的Id
	int m_nOwnerID;				// 物品的所有�??�id
	int m_nItemType;				// 物品类型 id
	int m_nAmount;				// 物品数量/耐久�??
	int m_nPosition;				// 物品位置
	int m_nAddition;				// 装备追加
	Byte m_nBindState;			// 绑定状�????
	Byte m_nHole;				// 装备有几个洞
	int m_nCreateTime;			// 创建时间
	int m_nAge;					// 骑宠寿命
	std::vector<Item*> m_vStone;	// stone
	bool m_bIsActive;
	//.. 其它属�????
};

struct ItemTypeLessThan
{
	bool operator ()(Item* first, Item* second)
	{
		if (!first || !second)
		{
			return false;
		}
		return first->m_nItemType < second->m_nItemType;
	}
};

void sendQueryDesc(int itemID);

int getItemColor(Item* item);

#endif// _ITEM_H_
