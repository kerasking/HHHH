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


--[[
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
]]

--** chh 2012-6-14 **--
p.ATTR_TYPE_NONE				= 0;
p.ATTR_TYPE_POWER				= p.ATTR_TYPE_NONE + 1;     --力量
p.ATTR_TYPE_AGILITY             = p.ATTR_TYPE_NONE + 2;		--敏捷
p.ATTR_TYPE_INTEL				= p.ATTR_TYPE_NONE + 3;		--智力
p.ATTR_TYPE_LIFE				= p.ATTR_TYPE_NONE + 4;		--生命
p.ATTR_TYPE_POWER_RATE			= p.ATTR_TYPE_NONE + 5;		--力量成长率
p.ATTR_TYPE_AGILITY_RATE		= p.ATTR_TYPE_NONE + 6;		--敏捷成长率
p.ATTR_TYPE_INTEL_RATE			= p.ATTR_TYPE_NONE + 7;		--智力成长率
p.ATTR_TYPE_LIFE_RATE			= p.ATTR_TYPE_NONE + 8;		--生命成长率
p.ATTR_TYPE_PHY_ATK             = p.ATTR_TYPE_NONE + 9;		--物攻
p.ATTR_TYPE_PHY_DEF             = p.ATTR_TYPE_NONE + 10;	--物防
p.ATTR_TYPE_MAGIC_ATK			= p.ATTR_TYPE_NONE + 11;	--法攻
p.ATTR_TYPE_MAGIC_DEF			= p.ATTR_TYPE_NONE + 12;	--法防
p.ATTR_TYPE_SPEED				= p.ATTR_TYPE_NONE + 13;	--速度
p.ATTR_TYPE_HIT                 = p.ATTR_TYPE_NONE + 14;	--命中率
p.ATTR_TYPE_DODGE				= p.ATTR_TYPE_NONE + 15;	--闪避率
p.ATTR_TYPE_DRITICAL			= p.ATTR_TYPE_NONE + 16;	--暴击率
p.ATTR_TYPE_TENACITY			= p.ATTR_TYPE_NONE + 17;	--格挡率
p.ATTR_TYPE_BLOCK				= p.ATTR_TYPE_NONE + 18;	--格挡率
p.ATTR_TYPE_WRECK				= p.ATTR_TYPE_NONE + 19;	--破击率
p.ATTR_TYPE_UNION_ATK			= p.ATTR_TYPE_NONE + 20;	--合击率
p.ATTR_TYPE_HELP				= p.ATTR_TYPE_NONE + 21;	--求援率
p.ATTR_TYPE_MANA				= p.ATTR_TYPE_NONE + 22;	--士气





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


p.bTypeEquip                    = 0; --装备
p.bTypeGem						= 1; --宝石
p.bTypeMate						= 2; --材料
p.bTypeProp                     = 3; --道具


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

--** chh 2012-08-08 **--
--主角和武将的颜色
ItemColor = 
{
    [0] = ccc4(255,255,255,255),    --白色
    [1] = ccc4(28,237,93,255),      --绿色
    [2] = ccc4(23,155,252,255),     --蓝色
    [3] = ccc4(255,0,252,255),      --紫色
    [4] = ccc4(228,112,18,255),     --橙色
    [5] = ccc4(255,15,15,255),      --红色
    [6] = ccc4(255,15,15,255),      --红色
}

--祭祀反馈物品颜色
FeteColor = {
    [1] = ccc4(237,240,0,255),
    [2] = ccc4(255,0,252,255),
    [4] = ccc4(228,112,18,255),
    [10] = ccc4(255,15,15,255),
}

--一般文本颜色
FontColor = {
    Text = ccc4(237,240,0,255),           --提示的文本
    Reput = ccc4(36,255,0,255),            --声望
    Stamina = ccc4(36,255,0,255),          --军令
    Exp = ccc4(36,255,0,255),              --经验
    Soul = ccc4(36,255,0,255),             --将魂
    Silver = ccc4(237,240,0,255),          --银币
    Coin = ccc4(237,240,0,255),            --金币
}

--** 获得颜色 **--
function p.GetColor(nIndex) 
    local cColor = ItemColor[nIndex];
    if(cColor == nil) then
        cColor = ItemColor[0];
    end
    return cColor;
end

