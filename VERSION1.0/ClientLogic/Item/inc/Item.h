/*
 *  Item.h
 *  DragonDrive
 *
 *  Created by jhzheng on 11-1-24.
 *  Copyright 2011 (缃戦緳)DeNA. All rights reserved.
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
		/** 鍟嗗簵鐗╁搧 */
		ITEM_SHOP = 0,

		/** 浣跨敤 */
		ITEM_USE = 1,

		ITEM_DROP = 4,

		ITEM_UNEQUIP = 10,

		/** 鏌ヨ鐗╁搧 */
		ITEM_QUERY = 16,

		/** 鏌ヨ鐗╁搧澶辫触 */
		ITEM_QUERY_FAIL = 17,

		/** 瀛� */
		ITEM_BANKSAVE = 5,

		/** 鍙� */
		ITEM_BANDDRAW = 6,

		/** 璐拱 */
		_SHOPACT_BUY = 1,

		/** 鍑哄敭 */
		_SHOPACT_SELL = 2,

		/** 鍙犲姞鏁伴噺 */
		_SHOPACT_AMOUNT = 3,

		/** 淇悊鍗曚欢瑁呭 */
		_ITEMACT_REPAIR = 18,

		/** 鍙犲姞韬笂鎵�鏈夎澶� */
		_ITEMACT_REPAIR_ALL = 19,

		/** 浣跨敤鐗╁搧绫诲瀷 */
		_ITEMACT_USETYPE = 99,

		ITEM_QUALITY = 0, // 鐗╁搧id瑙勫垯涓綅

		ITEM_GRADE = 1, // 鐗╁搧id瑙勫垯鐧句綅鍗佷綅

		ITEM_PROPERTY = 2, // 鐗╁搧id瑙勫垯涓囦綅鍗冧綅

		ITEM_CLASS = 3, // 鐗╁搧id瑙勫垯鍗佷竾浣�

		ITEM_EQUIP = 4, // 鐗╁搧id瑙勫垯鐧句竾浣�

		ITEM_TYPE = 5, // 鐗╁搧id瑙勫垯鍗冧竾浣�
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
		ITEMTYPE_MONOPOLY_NONE = 0, // 榛樿涓轰竴鑸父瑙勭墿鍝�.鎵�鏈夎鍒欓兘鍏佽鎵ц.
		ITEMTYPE_MONOPOLY_NOT_TRADE = 1, // 涓嶅彲浠ヤ氦鏄�(鍚屾椂鍖呮嫭涓嶅彲浜ゆ槗,涓嶅彲鎷嶅崠,涓嶅彲鎽嗘憡鍑哄敭,)(//
		// 鍗崇寮�韬綋鍒欐秷澶�)
		ITEMTYPE_MONOPOLY_NOT_STORAGE = 2, // 涓嶅彲浠ュ瓨浠�(鍚屾椂鍖呮嫭涓嶅彲浠ュ瓨甯歌浠撳簱鍜孷IP浠撳簱浠ュ強瀹犵墿浠撳簱)
		ITEMTYPE_MONOPOLY_DROP_REMINDER = 4, // 涓㈠純鎻愮ず(涓㈠純鏃跺鎴风寮瑰嚭纭绐楀彛,鎻愮ず鍐呭:璇风‘璁よ涓㈠純
		// )
		ITEMTYPE_MONOPOLY_SALE_REMINDER = 8, // 鍑哄敭鎻愮ず(璐甸噸鐗╁搧鍑哄敭鏃�,瀹㈡埛绔脊鍑虹‘璁ょ獥鍙�,鎻愮ず鍐呭:
		// 璇风‘璁よ涓㈠純)
		ITEMTYPE_MONOPOLY_NOT_MISS = 16, // 姝讳骸涓嶄細鎺夎惤(鍦ㄦ帀钀界浉鍏宠鍒欎腑浼樺厛绾ф渶楂�,姣斿鍗充娇浜虹墿鏄粦鍚�,//
		// 琚潃姝讳篃涓嶄細鐖�.)
		ITEMTYPE_MONOPOLY_NOT_SALE = 32, // 涓嶅彲鍑哄敭
		ITEMTYPE_MONOPOLY_BATTLE = 64, // 鎴樻枟鍐呭彲鐢�
		ITEMTYPE_MONOPOLY_NOT_USE = 128, // 涓嶅彲浣跨敤
		ITEMTYPE_MONOPOLY_USE_REMINDER = 256, // //浣跨敤鎻愮ず(浣跨敤鐗╁搧鏃�,瀹㈡埛绔脊鍑虹‘璁ょ獥鍙�,鎻愮ず鍐呭:
		ITEMTYPE_MONOPOLY_NOT_EMAIL = 0x0200,	// 涓嶅彲閭瘎
		ITEMTYPE_MONOPOLY_NOT_ENHANCE = 0x0400,	// 涓嶅彲寮哄寲
		ITEMTYPE_MONOPOLY_NOT_DROP = 0x0800,	// 涓嶅彲涓㈠純
	};

	//old 0鑲� 1澶� 2鑳哥敳 3椤归摼 4鑰崇幆 5鑵板甫--鎶 6涓绘鍣� 7鍓 8寰借 9鎵� 10瀹犵墿 11鎶よ吙 12闉嬪瓙 13宸︽垝鎸� 14鍙虫垝鎸� 15鍧愰獞
	//new 0鎶よ偐 1澶寸洈 2椤归摼 3鑰崇幆 4琛ｆ湇 5鑵板甫--鎶 6涓绘鍣� 7鍓 8鎶よ厱 9鎶よ吙 10宸︽垝鎸� 11鍙虫垝鎸� 12寰界珷 13闉嬪瓙 14瀹犵墿 15鍧愰獞
	enum eEquip_Pos
	{
		eEP_Begin = 0, eEP_Shoulder = eEP_Begin,				// 鎶よ偐
		eEP_Head,								// 澶寸洈
		eEP_XianLian,							// 椤归摼
		eEP_ErHuan,								// 鑰崇幆
		eEP_Armor,								// 鑳哥敳(琛ｆ湇)
		eEP_YaoDai,								// 鑵板甫--鎶
		eEP_MainArmor,							// 涓绘鍣�
		eEP_FuArmor,							// 鍓
		eEP_Shou,								// 鎵�(鎶よ厱)
		eEP_HuTui,								// 鎶よ吙
		eEP_LeftRing,							// 宸︽垝鎸�
		eEP_RightRing,							// 鍙虫垝鎸�
		eEP_HuiJi,								// 寰借(寰界珷)
		eEP_Shoes,								// 闉嬪瓙
		eEP_Decoration,							// 鍕嬬珷
		eEP_Ride,								// 鍧愰獞
		eEP_End,
	};

	enum
	{
		LIFESKILL_INLAY = 0, // 闀跺祵
		LIFESKILL_INLAY_FALSE = 1, // 闀跺祵澶辫触
		LIFESKILL_DIGOUT = 2, // 鎸栭櫎
		LIFESKILL_DIGOUT_FALSE = 3, // 鎸栭櫎澶辫触
	};

public:
	Item();
	Item(int iItemType);
	~Item();

	Item(const Item& rhs); //鎷疯礉鏋勯�犲嚱鏁�
	Item& operator =(const Item& rhs); //璧嬪�肩閲嶈浇

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
	 * 鏄惁鏄厤鏂�
	 * @return
	 */
	bool isFormula()
	{
		return (iItemType / 100000) == 251;
	}

	/**
	 * 鏄惁鏄崏鑽�
	 */
	bool isRemedy()
	{
		return (iItemType / 1000000) == 61;
	}

	/**
	 * 鏄惁涓哄疇鐗�
	 * 
	 * @return
	 */
	bool isItemPet()
	{
		std::vector<int> ids = Item::getItemType(iItemType);
		return ids[0] == 1 && ids[1] == 1;
	}

	bool isSkillBook()
	{
		return ((iItemType / 100000) == 250) || ((iItemType / 100000) == 252);
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
		return iItemType / 1000000 == 14;
	}

	bool isStone()
	{
		return (iItemType / 1000000) == 29;
	}

	std::string getInlayPos();

	bool isEquip();

	bool isItemCanUse();

	bool isItemCanTrade();

	bool isItemCanStore();

	bool isFormulaExt();

	// savetime涓巖ecycletime闄愬埗
	bool hasTimeLitmit()
	{
		return (getSave_time() != 0 || getRecycle_time() != 0);
	}

	bool canInlay()
	{
		if (byHole > vecStone.size())
		{
			return true;
		}
		return false;
	}

	bool canChaiFen()
	{
		return 0 != (iItemType / 10000000) && iAmount > 1;
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
	 * 涓㈠純鏄惁鏈夋彁閱�
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
		return byHole;
	}

	int getMaxHoleNum()
	{
		return (iItemType % 10) - 3;
	}
	int getStonesCount()
	{
		return vecStone.size();
	}

	int getSuitData();
	static int getIdRule(int nItemType, int rule);

	int getIdUpLev();

	bool IsNeedRepair();

	int getLookFace();
	/**
	 * 鍙栧緱缂╁皬鍊煎悗鐨勮�愪箙搴�
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

	static bool isDefEquip(int itemType); // 鏄惁闃插叿鍜屽壇鎵�,閮界畻鍋氶槻鍏�

	static bool isAccessories(int itemType); // 鏄惁楗板搧	

	static bool isWeapon(int itemType); // 鏄惁姝﹀櫒,鍖呮嫭鍗曞弻鎵�

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

	// 鏄惁瀹犵墿鐢ㄧ殑鐗╁搧
	bool IsPetUseItem();
	// 鏄惁瀹犵墿鎶�鑳戒功
	bool IsPetSkillItem();
private:
	void init();
	/**
	 * 娣诲姞灞炴�у�兼弿杩颁俊鎭�
	 * @param sb 娣诲姞鍒扮殑瀛楃涓�
	 * @param equipPoint 鍩烘湰灞炴�у��
	 * @param stonePoint 闀跺祵瀹濈煶灞炴�у��
	 * @param des 鍩烘湰鎻忚堪
	 * @param bolShowColor 闄勫姞灞炴�ф槸鍚︽樉绀洪鑹�
	 */
	void appendPointsDes(std::string& str, int equipPoint, int stonePoint,
			std::string des, bool bolShowColor);
public:
	int iID;					// 鐗╁搧鐨処d
	int iOwnerID;				// 鐗╁搧鐨勬墍鏈夎�卛d
	int iItemType;				// 鐗╁搧绫诲瀷 id
	int iAmount;				// 鐗╁搧鏁伴噺/鑰愪箙搴�
	int iPosition;				// 鐗╁搧浣嶇疆
	int iAddition;				// 瑁呭杩藉姞
	Byte byBindState;			// 缁戝畾鐘舵��
	Byte byHole;				// 瑁呭鏈夊嚑涓礊
	int iCreateTime;			// 鍒涘缓鏃堕棿
	int sAge;					// 楠戝疇瀵垮懡
	std::vector<Item*> vecStone;	// stone
	bool active;
	//.. 鍏跺畠灞炴��
};

struct ItemTypeLessThan
{
	bool operator ()(Item* first, Item* second)
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
