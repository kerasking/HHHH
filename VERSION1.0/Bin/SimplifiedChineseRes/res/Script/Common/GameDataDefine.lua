
NScriptData = 
{
	eDataBase					= 0,
	eRole						= 1,
	eNpc						= 2,
	eMonster					= 3,
	eTaskConfig					= 4,
	eItemInfo					= 5,
	eSysItem					= 6,
	ePetInfo					= 7,
	eMagic						= 8,
	eAffixBoss					= 9,
	--...
};

NRoleData =
{
	eBasic						= 0,
	ePet						= 1,
	eSkill						= 2,
	eState						= 3,
	eItem						= 4,
	eTask						= 5,
	eTaskCanAccept				= 6,
	eUserState       			= 7,
	eUserEmail       			= 8,
	eFriend                     = 9,
	eHeroStar					= 10,
	--...
};

NIDList = 
{
	eType1						= 0;
	eType2						= 1;
	eType3						= 2;
};

-- 任务内容数据枚举
TASK_CEL_DATA =
{
	SM_TASK_CELL_TYPE						= 0,
	SM_TASK_CELL_ID							= 1,
	SM_TASK_CELL_MAP_ID						= 2,
	SM_TASK_CELL_MAP_X						= 3,
	SM_TASK_CELL_MAP_Y						= 4,
	SM_TASK_CELL_NUM						= 5,
	SM_TASK_CELL_CAN_TRANS					= 6,
	SM_TASK_CELL_TIP						= 7,
};

-- 任务数据枚举
TASK_DATA =
{
	ID										= 1,
	TASK_STATE								= 2,
	DATA1									= 3,
	DATA2									= 4,
	DATA3									= 5,
	DATA4									= 6,
	DATA5									= 7,
	DATA6									= 8,
};

--任务条件枚举
TASK_CONTIDTION_TYPE =	
{
	ITEM		=1,	--物品
	MONSTER 	=2,	--杀怪
	GUIDE		=3, --引导
};

--引导任务类型枚举
TASK_GUIDE_PARAM =
{
	USE_ITEM 			=1,--使用物品
	MONEY				=2,--花费银币		--
	EMONEY				=3,--话费金币
	ADDFRIEND			=4,--添加好友
	SPORT				=5,--挑战竞技场
	STRENGTHEN_EQUIP	=6,--强化装备
	GS					=7,--升级将星
	LEVY				=8,--征收
	HORSE				=9,--坐骑培养
	STRENGTHEN_PET		=10,--升级武将至指定等级
	SOLIDER				=11,--升级军衔至指定声望	--
	EXCHANGE_SKILL		=12,--切换技能
	SYSDICATE_LEVEL		=13,--帮派等级
	BUY_ITEM			=14,--购买物品
	WASH_EQUIP			=15,--装备洗练
	ADD_SYSDICATE		=16,--创建或加入帮派
	RECHARGE			=17,--充值				--
	RECRUIT_PET			=18,--招募武将
	WORSHIP				=19,--祭祀
	MOSAIC				=20,--镶嵌宝石
};


TASK_TYPE =	--任务类型，新增10-新手引导任务
{
	NORMAL			= 0,--普通任务
	CAMP			= 1,--阵营任务
	SYNDICATE		= 2,--军团任务
	HU_BIAO			= 3,--护镖任务
	EQUIP			= 4,--自动装备任务物品
	GROWP 			= 6,--成长任务
	HISTORY 		= 7,--史诗任务	
	EVERYDAY		= 8,--日常任务
	ACTIVITY		= 9,--活动任务	
	GUIDE 			= 10--新手引导任务
};

--++Guosen 2012.6.19
-- 玩家信息枚举
USER_ATTR =
{
    --帐户相关
	 USER_ATTR_BEGIN						= 0,
     USER_ATTR_ID	=	0,					--人物角色ID	
     USER_ATTR_ACCOUNT_ID	=	1,			--玩家帐户ID			
     USER_ATTR_NAME	=	2,					--玩家名字	
     USER_ATTR_CREATETIME	=	3,			--创建时间			
     USER_ATTR_LOOKFACE	=	4,				--人物外形头像		
     USER_ATTR_PROFESSION	=	5,		--职业			
     USER_ATTR_MONEY	=	6,					--身上现金数	
     USER_ATTR_MONEY_SAVED	=	7,			--存款			
     USER_ATTR_MONEY_SAVED2	=	8,			--存款			
     USER_ATTR_EMONEY	=	9,				--身上现太阳石数		
     USER_ATTR_EMONEY_SAVE	=	10,			--仓库代币			
     USER_ATTR_EMONEY_CHK	=	11,			--身上现太阳石数			
     USER_ATTR_STORAGELIMIT	=	12,			--仓库重量上限			
     USER_ATTR_PACKAGE_LIMIT	=	13,			--背包上限			
     USER_ATTR_LOCK_KEY	=	14,				--二级密码		
     USER_ATTR_RECORD_MAP	=	15,			--玩家离线时所在的地图id			
     USER_ATTR_RECORD_X	=	16,				--玩家离线时所在的地图x坐标		
     USER_ATTR_RECORD_Y	=	17,				--玩家离线时所在的地图y坐标		
     USER_ATTR_LAST_LOGIN	=	18,			--上次登陆时间点（年月日，如20040623）]			
     USER_ATTR_ONLINE_TIME2	=	19,			--在线时间2			
     USER_ATTR_IP	=	20,					--玩家注册时的IP地址	
     USER_ATTR_REBORN_MAPID	=	21,			--玩家复活的地图id			
     USER_ATTR_ONLINE_TIME	=	22,			--在线时间			
     USER_ATTR_AUTO_EXERCISE	=	23,		--品质				
     USER_ATTR_LEVEL	=	24,				--等级		
     USER_ATTR_EXP	=	25,					--经验值	
     USER_ATTR_PK	=	26,					--PK值	
     USER_ATTR_LIFE	=	27,					--生命值	
     USER_ATTR_MANA	=	28,					--魔法值	
     USER_ATTR_PHY_POINT	=	29,			--力量点数			
     USER_ATTR_DEX_POINT	=	30,			--敏捷点数			
     USER_ATTR_MAG_POINT	=	31,			--智力点数			
     USER_ATTR_DEF_POINT	=	32,			--体质点数			
     USER_ATTR_FORB_WORDS	=	33,			--禁言标志 			
     USER_ATTR_RANK	=	34,					--军衔	
     USER_ATTR_CAMP	=	35,					--阵营	
     USER_ATTR_MARRY_ID	=	36,				--结婚id		
     USER_ATTR_REIKI	=	37,				--灵气值		
     USER_ATTR_STATUS	=	38,				--玩家状态		
     USER_ATTR_CHANNEL	=	39,				--渠道ID		
     USER_ATTR_GMONEY	=	40,				--赠币		
     USER_ATTR_GMONEY_SAVE	=	41,		--仓库赠币				
     USER_ATTR_ACCOUNT_NAME	=	42,			--帐号名			
     USER_ATTR_MOBILE_TYPE	=	43,			--用户机型			
     USER_ATTRIB_ACTIVITY_POINT	=	44,		--活力				
     USER_ATTRIB_MAX_ACTIVITY	=	45,		--活力上限				
     USER_ATTRIB_MAX_SKILL_SLOT	=	46,		--技能槽上限				
     USER_ATTR_VIP_RANK	=	47,				--vip等级		
     USER_ATTR_VIP_EXP	=	48,				--vip经验		
     USER_ATTR_PEERAGE	=	49,				--爵位		
     USER_ATTR_MATRIX	=	50,				--当前阵形		
     USER_ATTR_REPUTE	=	51,				--声望		
     USER_ATTR_SOPH	=	52,					--将魂	
     USER_ATTR_PARTS_BAG	=	53,			--器灵背包			
     USER_ATTR_EQUIP_ENHANCE_SAVE_MONEY	=	54,			--强化降费节省银币数			
     USER_ATTR_SP_LEVUP_CD	=	55	,					
     USER_ATTR_EQUIP_CRIT_SAVE_MONEY	=	56,			--装备强化暴击节省银币数			
     USER_ATTR_EQUIP_CRIT_COUNT	=	57,             --装备强化暴击累加次数
     USER_ATTR_EQUIP_QUEUE_COUNT	=	58,						
     USER_ATTR_EQUIP_UPGRADE_TIME1	=	59,						
     USER_ATTR_EQUIP_UPGRADE_TIME2	=	60,						
     USER_ATTR_EQUIP_UPGRADE_TIME3	=	61,						
     USER_ATTR_PET_LIMIT	=	62,			--伙伴上限			
     USER_ATTR_STAGE	=	63,				--阶段		
     USER_ATTR_STAMINA	=	64,				--军令		
     USER_ATTR_STAMINA_LAST_STAMINA	=	65,	--					
     USER_ATTR_STAMINA_LAST_BUFF	=	66,						
     USER_ATTR_PARTS_CAST_COUNT	=	67,			--每天洗练的次数			
     USER_ATTR_PARTS_CHIPS	=	68,			--玩家的器灵碎片			
     USER_ATTR_DAY_FLOWER_TIMES	=	69,						
     USER_ATTR_FLOWER_RECEIVED	=	70,						
     USER_ATTR_HAVE_BUY_STAMINA	=	71,			--每天已购买军令数			
     USER_ATTR_LAST_BUY_STAMINA_TIME	=	72,	--最后购买军令时间					
     USER_ATTR_BUYED_GEM	=	73,				--每日9：30到19：00  或19：00到9：30 已购宝石数		
     USER_ATTR_LAST_BUY_GEM_TIME	=	74,		--最后购买宝石时间				
     USER_ATTR_BUYED_LEVY	=	75,				--每天已购宝石		
     USER_ATTR_LAST_BUY_LEVY_TIME	=	76,		--最后购买征收时间				
     USER_ATTR_RECHARGE_EMONEY	=	77,			--充值金币数			
     USER_ATTR_INSTANCING_RESET_TIME	=	78,		--副本重置时间				
     USER_ATTR_INSTANCING_RESET_COUNT	=	79,		--副本重置次数				
     USER_ATTR_CLEARUP_MAP	=	80,						
     USER_ATTR_CLEARUP_CHECKTIME	=	81,			--副本扫荡检查时间			
     USER_ATTR_CLEARUP_REMAINTIMES	=	82,			--副本扫荡检查时间时的剩余次数			
     USER_ATTR_LAST_LOGOUT	=	83,					--上次登出时间点（年月日，如20040623）
     
--chh 2012.7.15
     USER_ATTR_GUIDE_STAGE = 84,                      --教程状态

--Guosen 2012.7.14
     USER_ATTR_RIDE_STATUS	= 60,	-- 骑乘状态 0=步行,1=骑行 == USER_ATTR_EQUIP_UPGRADE_TIME2
     USER_ATTR_MOUNT_TYPE	= 61,	-- 坐骑的类型 == USER_ATTR_EQUIP_UPGRADE_TIME3
};

PET_ATTR =
{
	PET_ATTR_HELP 						= 54,						--护驾
	PET_ATTR_ID							= 0,						-- ID
	PET_ATTR_NAME						= 1,						-- 名字
	PET_ATTR_TYPE						= 2,						-- 类型
	PET_ATTR_MAIN						= 3,						-- 是否主角
	PET_ATTR_OWNER_ID					= 4,					-- 所有者
	PET_ATTR_POSITION					= 5,					-- 位置
	PET_ATTR_LEVEL						= 6,						-- 等级
	PET_ATTR_GRADE						= 7,						-- 境界
	PET_ATTR_EXP						= 8,						-- 经验
	PET_ATTR_LIFE						= 9,						-- 生命
	PET_ATTR_LIFE_LIMIT					= 10,				-- 生命上限
	PET_ATTR_MANA						= 11,				-- 气势
	PET_ATTR_MANA_LIMIT					= 12,				-- 气势上限
	PET_ATTR_SKILL						= 13,						-- 技能
	PET_ATTR_PHYSICAL					= 14,					-- 武力
	PET_ATTR_DEX						= 15,				-- 敏捷
	PET_ATTR_MAGIC						= 16,						-- 法术
	PET_ATTR_PHY_FOSTER					= 17,				-- 武力培养
	PET_ATTR_SUPER_SKILL_FOSTER			= 18,		-- 绝技培养
	PET_ATTR_MAGIC_FOSTER				= 19,				-- 法术培养
	PET_ATTR_PHY_ELIXIR1				= 20,				-- 一品武力丹
	PET_ATTR_PHY_ELIXIR2				= 21,				-- 二品武力丹
	PET_ATTR_PHY_ELIXIR3				= 22,				-- 三品武力丹
	PET_ATTR_PHY_ELIXIR4				= 23,				-- 四品武力丹
	PET_ATTR_PHY_ELIXIR5				= 24,				-- 五品武力丹
	PET_ATTR_PHY_ELIXIR6				= 25,				-- 六品武力丹
	PET_ATTR_SUPER_SKILL_ELIXIR1		= 26,		-- 一品绝技丹
	PET_ATTR_SUPER_SKILL_ELIXIR2		= 27,		-- 二品绝技丹
	PET_ATTR_SUPER_SKILL_ELIXIR3		= 28,		-- 三品绝技丹
	PET_ATTR_SUPER_SKILL_ELIXIR4		= 29,		-- 四品绝技丹
	PET_ATTR_SUPER_SKILL_ELIXIR5		= 30,		-- 五品绝技丹
	PET_ATTR_SUPER_SKILL_ELIXIR6		= 31,		-- 六品绝技丹
	PET_ATTR_MAGIC_ELIXIR1				= 32,				-- 一品法术丹
	PET_ATTR_MAGIC_ELIXIR2				= 33,				-- 二品法术丹
	PET_ATTR_MAGIC_ELIXIR3				= 34,				-- 三品法术丹
	PET_ATTR_MAGIC_ELIXIR4				= 35,				-- 四品法术丹
	PET_ATTR_MAGIC_ELIXIR5				= 36,				-- 五品法术丹
	PET_ATTR_MAGIC_ELIXIR6				= 37,				-- 六品法术丹	
	PET_ATTR_IMPART						= 38,				-- 传承
	PET_ATTR_OBTAIN						= 39,				-- 被传承
	PET_ATTR_QUALITY                    = 40,               -- 品质
	
	PET_ATTR_LOGIC_BEGIN				= 1000,		-- 逻辑定义起点
	PET_ATTR_PHY_ATK					= 1001,					-- 普通攻击
	PET_ATTR_SPEED						= 1002,					-- 速度
	PET_ATTR_MAGIC_ATK					= 1003,					-- 法术攻击
	PET_ATTR_PHY_DEF					= 1004,					-- 普通防御
	PET_ATTR_SUPER_SKILL				= 1005,					-- 绝技防御
	PET_ATTR_MAGIC_DEF					= 1006,					-- 法术防御
	PET_ATTR_DRITICAL					= 1007,					-- 暴击
	PET_ATTR_HITRATE					= 1008,					-- 命中
	PET_ATTR_WRECK						= 1009,						-- 破击
	PET_ATTR_HURT_ADD					= 1010,					-- 必杀
	PET_ATTR_TENACITY					= 1011,					-- 韧性
	PET_ATTR_DODGE						= 1012,						-- 闪避
	PET_ATTR_BLOCK						= 1013,						-- 格挡
	PET_ATTR_STAND_TYPE					= 1014,                     --技能
};

FRIEND_DATA =
{
	FRIEND_ID                           = 1,					--好友id 
    FRIEND_NAME                         = 2,					--好友名称 
	FRIEND_LEVEL                        = 3,					--好友等级 
	FRIEND_ONLINE                       = 4,					--好友是否在线 
	FRIEND_LOOKFACE						=5,						--外形
	FRIEND_PROFESSION					=6,						--职业
	FRIEND_REPUTE						=7,						--声望
	FRIEND_SYNDYCATE					=8,						--帮派
	FRIEND_SPORTS						=9,						--竞技场排行
	FRIEND_CAPACITY						=10,					--战斗力
	FRIEND_QUALITY						=11,					--品质颜色
}

HEROSTAR_DATA =
{
GRADE   = 1,--星图类型
LEVEL	= 2,--星图等级
}

--道法（占星）数据
DAOFA_QUALITY_DATA = {
    GRAY                = 0,        --灰色品质
    RED                 = 1,        --红色品质
    GREEN               = 2,        --绿色
    BLUE                = 3,        --蓝色
    PURPLE              = 4,        --紫色
    ORANGE              = 5,        --橙色
}
