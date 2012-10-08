---------------------------------------------------
--描述: 物品类型枚举
--时间: 2012.3.1
--作者: jhzheng
---------------------------------------------------

Item = {};
local p = Item;

-- 所有者类型
p.OWNER_TYPE_NONE				= 0;
p.OWNER_TYPE_USER				= p.OWNER_TYPE_NONE + 1;	--玩家物品(可以是背包,仓库等,具体用position区分)
p.OWNER_TYPE_PET				= p.OWNER_TYPE_NONE + 2;	--装备类物品
p.OWNER_TYPE_ITEM				= p.OWNER_TYPE_NONE + 3;	--镶嵌类物品

-- 物品位置
p.POSITION_NONE					= 0;
p.POSITION_PACK					= 1;	--物品背包
p.POSITION_PARTS_PACK	            = 2;	--器灵背包
p.POSITION_DAO_FA_PACK            = 3;	--道法背包
p.POSITION_STORAGE	            = 4;	--仓库

p.POSITION_EQUIP_1				= 11;	--装备   --归属于宠物
p.POSITION_EQUIP_2				= 12;
p.POSITION_EQUIP_3				= 13;
p.POSITION_EQUIP_4				= 14;
p.POSITION_EQUIP_5				= 15;
p.POSITION_EQUIP_6				= 16;

p.POSITION_PARTS_1				= 21;	--器灵   --归属于物品
p.POSITION_PARTS_2				= 22;
p.POSITION_PARTS_3				= 23;
p.POSITION_PARTS_4				= 24;
p.POSITION_PARTS_5				= 25;
p.POSITION_PARTS_6				= 26;

p.POSITION_DAO_FA_1				= 31;	--道法   --归属于宠物
p.POSITION_DAO_FA_2				= 32;
p.POSITION_DAO_FA_3				= 33;
p.POSITION_DAO_FA_4				= 34;
p.POSITION_DAO_FA_5				= 35;
p.POSITION_DAO_FA_6				= 36;
p.POSITION_DAO_FA_7				= 37;
p.POSITION_DAO_FA_8				= 38;

p.POSITION_AUCTION				= 91;--物品在拍卖行
p.POSITION_MAIL					= 92;--邮件物品
p.POSITION_SYSTEM					= 93;--系统赠品
p.POSITION_PETBAG					= 94;--宠物背包
p.POSITION_SOLD					= 100;--已售物品

-- 物品属性枚举
p.ATTR_TYPE_NONE				= 0;
p.ATTR_TYPE_PHY					= p.ATTR_TYPE_NONE + 1;				-- 武力
p.ATTR_TYPE_SKILL				= p.ATTR_TYPE_NONE + 2;			-- 绝技
p.ATTR_TYPE_MAGIC				= p.ATTR_TYPE_NONE + 3;			-- 法术s
p.ATTR_TYPE_LIFE				= p.ATTR_TYPE_NONE + 4;				-- 生命
p.ATTR_TYPE_LIFE_LIMIT			= p.ATTR_TYPE_NONE + 5;		-- 生命上限
p.ATTR_TYPE_MANA				= p.ATTR_TYPE_NONE + 6;				-- 气势
p.ATTR_TYPE_MANA_LIMIT			= p.ATTR_TYPE_NONE + 7;		-- 气势上限
p.ATTR_TYPE_PHY_ATK				= p.ATTR_TYPE_NONE + 8;			-- 普通攻击
p.ATTR_TYPE_SKILL_ATK			= p.ATTR_TYPE_NONE + 9;		-- 绝技攻击
p.ATTR_TYPE_MAGIC_ATK			= p.ATTR_TYPE_NONE + 10;		-- 法术攻击
p.ATTR_TYPE_PHY_DEF				= p.ATTR_TYPE_NONE + 11;			-- 普通防御
p.ATTR_TYPE_SKILL_DEF			= p.ATTR_TYPE_NONE + 12;		-- 绝技防御
p.ATTR_TYPE_MAGIC_DEF			= p.ATTR_TYPE_NONE + 13;		-- 法术防御
p.ATTR_TYPE_DRITICAL			= p.ATTR_TYPE_NONE + 14;			-- 暴击
p.ATTR_TYPE_HITRATE				= p.ATTR_TYPE_NONE + 15;			-- 命中
p.ATTR_TYPE_WRECK				= p.ATTR_TYPE_NONE + 16;			-- 破击
p.ATTR_TYPE_HURT_ADD			= p.ATTR_TYPE_NONE + 17;			-- 必杀
p.ATTR_TYPE_TENACITY			= p.ATTR_TYPE_NONE + 18;			-- 韧性
p.ATTR_TYPE_DODGE				= p.ATTR_TYPE_NONE + 19;			-- 闪避
p.ATTR_TYPE_BLOCK				= p.ATTR_TYPE_NONE + 20;			-- 格挡

--物品分类枚举
p.TypeInvalid					= 0;
p.TypeNone						= 1; --暂时不做划分的物品
p.TypeEquip						= 2; --装备
p.TypeQiLing					= 3; --器灵
p.TypeDaoFa						= 4; --道法
p.TypeRide						= 5; --坐骑
p.TypeConsume					= 6; --消耗类
p.TypeComposeRoll				= 7; --合成卷
p.TypeQuest						= 8; --任务物品
p.TypeGift						= 9; --礼包

--属性类型枚举

p.ATTR_TYPE_NONE				= 0;
p.ATTR_TYPE_PHY					= 1			-- 武力
p.ATTR_TYPE_SKILL              = 2;			-- 绝技
p.ATTR_TYPE_MAGIC              = 3;		-- 法术
p.ATTR_TYPE_LIFE              =	4;			-- 生命
p.ATTR_TYPE_LIFE_LIMIT              = 5;		-- 生命上限
p.ATTR_TYPE_MANA              =	6;			-- 气势
p.ATTR_TYPE_MANA_LIMIT              = 7;		-- 气势上限
p.ATTR_TYPE_PHY_ATK              = 8;			-- 普通攻击
p.ATTR_TYPE_SKILL_ATK              = 9;		-- 绝技攻击
p.ATTR_TYPE_MAGIC_ATK              = 10;		-- 法术攻击
p.ATTR_TYPE_PHY_DEF              = 11;			-- 普通防御
p.ATTR_TYPE_SKILL_DEF              = 12;		-- 绝技防御
p.ATTR_TYPE_MAGIC_DEF              = 13;		-- 法术防御
p.ATTR_TYPE_DRITICAL              =	14;		-- 暴击(%)
p.ATTR_TYPE_HITRATE              = 15;			-- 命中(%)
p.ATTR_TYPE_WRECK              = 16;			-- 破击(%)
p.ATTR_TYPE_HURT_ADD              =	17;		-- 必杀(%)
p.ATTR_TYPE_TENACITY              =	18;		-- 韧性(%)
p.ATTR_TYPE_DODGE              = 19;			-- 闪避(%)
p.ATTR_TYPE_BLOCK              = 20;			-- 格挡(%)

--品质颜色
p.QUALITY_WHITE					= 1; --白色
p.QUALITY_GREEN					= 2; --绿色
p.QUALITY_BLUE					= 3; --蓝色
p.QUALITY_PURPLE				= 4; --紫色
p.QUALITY_GOLDEN				= 5; --金色

--器灵的品质颜色
p.QL_QUALITY_BLUE				= 1; --蓝色
p.QL_QUALITY_PURPLE				= 2; --紫色
p.QL_QUALITY_GOLDEN				= 3; --金色


