
DB_GSCONFIG=
{
	ID 				= 0;
	NAME 			= 1;
	TYPE 			= 2;
	RANK 			= 3;
	COST_GHOST 		= 4;
	LEVEL_LIMIT 	= 5;
	ATTR1 			= 6;
	VALUE1 			= 7;
	ATTR2 			= 8;
	VALUE2 			= 9;
	STATION_EFFECT	=10;
	EFFECT_VALUE	=11;
	SKILL			=12;
}

DB_ACTIVITY=
{
	ID	=0,
	TYPE	=1,
	SUBTYPE	=2,
	IDOWNER	=3,
	NAME	=4,
	DATA0	=5,
	DATA1	=6,
	DATA2	=7
};

DB_ANTHROPOLOGTYPE=
{
	USERID	=0,
	ANTHROPOLOG_TIME	=1,
	GENERAL_CHANCE	=2,
	MONEYREIKI_COLLECT	=3,
	MAP_MONSTER1	=4,
	MAP_MONSTER2	=5,
	MAP_BOSSMONSTER	=6
};

DB_AUCTION=
{
	ID	=0,
	IDITEM	=1,
	IDOWNER	=2,
	IDITEMTYPE	=3,
	OWNER_NAME	=4,
	BEGINTIME	=5,
	MIN_PRICE	=6,
	IDBIDDER	=7,
	BIDDER_NAME	=8,
	MAX_PRICE	=9,
	PRICETYPE	=10,
	GMONEY	=11
};

DB_BATTLE_RECORD=
{
	ID	=0,
	TYPE	=1,
	COUNT	=2,
	TIME	=3,
	MSG	=4
};

DB_BATTLEFIELD_MAP_TYPE=
{
	ID	=0,
	NAME	=1,
	TYPE	=2,
	MAPDOC	=3,
	JOIN_LV_MIN	=4,
	JOIN_NUM_MIN	=5,
	JOIN_NUM_MAX	=6,
	BATTLEFIELD_TIME	=7,
	CAMP_ID_1	=8,
	CAMP_NAME_1	=9,
	CAMP_BANNER_1	=10,
	CAMP_ID_2	=11,
	CAMP_NAME_2	=12,
	CAMP_BANNER_2	=13,
	BIRTH_MAPID_1	=14,
	BIRTH_X_1	=15,
	BIRTH_Y_1	=16,
	BIRTH_MAPID_2	=17,
	BIRTH_X_2	=18,
	BIRTH_Y_2	=19,
	WIN_TYPE	=20,
	PARAMETER_1	=21,
	PARAMETER_2	=22,
	PARAMETER_3	=23,
	INITIAL_INTEGRAL	=24,
	ITEM_1	=25,
	ITEM_2	=26,
	ITEM_3	=27
};

DB_BOSS_GROW=
{
	MONSTER_TYPE	=0,
	LIFE_GROW	=1,
	LIFE_GROW_MAX	=2,
	PHY_ATK_GROW	=3,
	SKILL_ATK_GROW	=4,
	LEVEL_MAX	=5,
	MONEY	=6,
	MONEY_GROW	=7,
	MONEY_GROW_MAX	=8
};

DB_BOX_ITEM=
{
	ID	=0,
	ITEMTYPE	=1,
	AMOUNT	=2,
	CHANCE	=3
};

DB_BOX_TYPE=
{
	ID	=0,
	NAME	=1,
	MONEY	=2,
	EMONEY	=3,
	ITEMNUM	=4,
	BIND_FLAG	=5
};

DB_BUG_REPORT=
{
	ID_REPORTER	=0,
	OCCUR_TIME	=1,
	INFO	=2
};

DB_CAMP_STORAGE=
{
	ID	=0,
	CAMP	=1,
	REPUTE_TOTAL	=2,
	CAMP_REPUTE_TOTAL	=3,
	MONEY	=4,
	EMONEY	=5,
	WEAPON	=6,
	ARMOR	=7,
	MEDICINE	=8
};

DB_CHARGEGIFT=
{
	ID	=0,
	BEGIN_COUNT	=1,
	COUNT	=2,
	ITEMTYPE	=3,
	ITEM_AMOUNT	=4,
	FLAG	=5,
	START_TIME	=6,
	END_TIME	=7,
	BIND_FLAG	=8
};

DB_COMPETITION=
{
	ID	=0,
	PERIOD	=1,
	TYPE	=2,
	USER_ID	=3,
	USER_NAME	=4,
	TARGET_ID	=5,
	WIN	=6,
	WIN_NUM	=7,
	RANKING	=8,
	USER_LEVEL	=9
};

DB_CONFIG=
{
	ID	=0,
	TYPE	=1,
	DATA1	=2,
	DATA2	=3,
	DATA3	=4,
	DATA4	=5,
	DESCRIB	=6
};

DB_CQ_CARD=
{
	ID	=0,
	TYPE	=1,
	ACCOUNT_ID	=2,
	REF_ID	=3,
	CHK_SUM	=4,
	TIME_STAMP	=5,
	USED	=6,
	ORDERNUMBER	=7,
	FLAG	=8,
	CARD_IN_TIME	=9,
	ITEMCOUNT	=10,
	SYSTEMTYPE	=11
};

DB_CQ_CARD2=
{
	ID	=0,
	TYPE	=1,
	ACCOUNT_ID	=2,
	REF_ID	=3,
	CHK_SUM	=4,
	TIME_STAMP	=5,
	USED	=6,
	ORDERNUMBER	=7,
	FLAG	=8,
	CARD_IN_TIME	=9,
	ITEMCOUNT	=10,
	SYSTEMTYPE	=11
};

DB_DAILY_ACTIVITY=
{
	ID	=0,
	PRE_TASK	=1,
	TYPE	=2,
	PARAM	=3,
	NAME	=4,
	DESC	=5,
	DESC1	=6,
	EXTRA_EXP	=7,
	EXTRA_MONEY	=8,
	EXTRA_SOPH	=9,
	EXTRA_ITEM	=10
};

DB_DAO_LEVELUP_EXP=
{
	ID	=0,
	QUALITY	=1,
	LEVEL	=2,
	EXP	=3
};

DB_DROP_RULE=
{
	ID	=0,
	MONSTER_DROP_RULE	=1,
	TYPE	=2,
	CHANCE	=3,
	ITEMTYPE	=4,
	EQUIPTYPE	=5,
	QUALITY0	=6,
	QUALITY3	=7,
	QUALITY5	=8,
	QUALITY6	=9,
	QUALITY7	=10,
	AGAIN_DROP	=11,
	BEGIN_TIME	=12,
	END_TIME	=13
};

DB_DROP_RULE_NUM=
{
	ITEMTYPE	=0,
	NUM_DAY	=1,
	NUM_ALL	=2,
	NUM	=3
};

DB_DYNAMAP=
{
	ID	=0,
	NAME	=1,
	DESCR	=2,
	MAPDOC	=3,
	TYPE	=4,
	OWNERID	=5,
	OWNERTYPE	=6,
	PORTAL0_X	=7,
	PORTAL0_Y	=8,
	REBORN_MAP_ID	=9,
	REBORN_X	=10,
	REBORN_Y	=11,
	LINK_MAP_ID	=12,
	LINK_MAP_X	=13,
	LINK_MAP_Y	=14,
	RESOURCE_LEV	=15,
	IDSERVER	=16,
    
    --** chh 2012-06-17 **--
    MAP_LV	=17,
    MUSIC	=18,
    INSTANCING_GROUP	=19,
    INSTANCING_PRE_CONDITION	=20,
    INSTANCING_IS_ELITE	=21,
    INSTANCING_IS_BOSS	=22,
    INSTANCING_MONSTER_LEVEL	=23,
    INSTANCING_EXTRA_MONEY	=24,
    INSTANCING_EXTRA_SOPH	=25,
    INSTANCING_ICON	=26,
    INSTANCING_ORDER	=27,
    NEED_STAGE	=28,
    TITLE	=29,
    INSTANCING_EXTRA_EXP	=30,
};

DB_DYNAMAP_CFG=
{
	ID	=0,
	ID_MOTHERMAP	=1,
	ID_MOTHERMAP_NAME	=2,
	HUMAN_LIMIT	=3,
	ENTER_TIME_LIMIT	=4,
	ENTER_TYPE	=5,
	LEVEL_REQ	=6,
	LEVEL_LIMIT	=7,
	CONDITION_RANGE	=8,
	KEEP_TIME	=9
};

DB_DYNANPC=
{
	ID	=0,
	NAME	=1,
	TYPE	=2,
	LOOKFACE	=3,
	BASE	=4,
	IDXSERVER	=5,
	MAPID	=6,
	CELLX	=7,
	CELLY	=8,
	ID_ACTION	=9,
	TASK0	=10,
	TASK1	=11,
	TASK2	=12,
	TASK3	=13,
	TASK4	=14,
	TASK5	=15,
	TASK6	=16,
	TASK7	=17,
	TASK8	=18,
	TASK9	=19,
	DATA0	=20,
	DATA1	=21,
	DATA2	=22,
	DATA3	=23,
	DATASTR	=24,
	SORT	=25,
	SHOPID	=26,
	CAMP	=27,
	DYNAFLAG	=28,
	ID_MONSTER_TYPE	=29,
	ID_GENERATE	=30
};

DB_EMONEY=
{
	ID	=0,
	TYPE	=1,
	ID_SOURCE	=2,
	ID_TARGET	=3,
	NUMBER	=4,
	CHK_SUM	=5,
	TIME_STAMP	=6,
	SOURCE_EMONEY	=7,
	TARGET_EMONEY	=8
};

DB_EMONEY_WATER=
{
	ID	=0,
	TYPE	=1,
	ID_SOURCE	=2,
	IDTARGET	=3,
	NUMBER	=4,
	CHK_SUM	=5,
	TIME_STAMP	=6,
	SOURCE_EMONEY	=7,
	TARGET_EMONEY	=8
};

DB_ENHANCED=
{
	ID	=0,
	REQ_MONEY	=1
};

DB_ENTITY_CONFIG=
{
	ID	=0,
	NAME	=1,
	LOOKFACE	=2,
	NPC	=3,
	LEVEL	=4,
	USER_LEVEL	=5,
	UPLEV_DEPEND_1	=6,
	UPLEV_DEPEND_2	=7,
	UPLEV_NEED_RICE	=8,
	UPLEV_NEED_TIMBER	=9,
	UPLEV_NEED_STONE	=10,
	UPLEV_NEED_GOLD	=11,
	UPLEV_NEED_VAMISH	=12,
	UPLEV_NEED_MONEY	=13,
	UPLEV_NEED_EMONEY	=14,
	UPKEEP_NEED_RICE	=15,
	UPKEEP_NEED_TIMBER	=16,
	UPKEEP_NEED_STONE	=17,
	UPKEEP_NEED_GOLD	=18,
	UPKEEP_NEED_VAMISH	=19,
	UPLEV_NEED_TIME	=20,
	AMOUNT_LIMIT	=21,
	PRODUCT_EXP	=22,
	MAX_NUM	=23
};

DB_EQUIPSET_CFG=
{
	ID	=0,
	NAME	=1,
	EQUIP_ID_1	=2,
	EQUIP_NAME_1	=3,
	EQUIP_ID_2	=4,
	EQUIP_NAME_2	=5,
	EQUIP_ID_3	=6,
	EQUIP_NAME_3	=7,
	EQUIP_ID_4	=8,
	EQUIP_NAME_4	=9,
	EQUIP_ID_5	=10,
	EQUIP_NAME_5	=11,
	EQUIP_ID_6	=12,
	EQUIP_NAME_6	=13,
	EQUIP_ID_7	=14,
	EQUIP_NAME_7	=15,
	EQUIP_SET_1_NUM	=16,
	EQUIP_SET_1_EFFECT	=17,
	EQUIP_SET_1_DES	=18,
	EQUIP_SET_2_NUM	=19,
	EQUIP_SET_2_EFFECT	=20,
	EQUIP_SET_2_DES	=21,
	EQUIP_SET_3_NUM	=22,
	EQUIP_SET_3_EFFECT	=23,
	EQUIP_SET_3_DES	=24,
	FLAG	=25
};

DB_EVENT=
{
	ID	=0,
	TYPE	=1,
	DATA	=2,
	PARAM	=3
};

DB_EXCHANGE=
{
	ID	=0,
	TYPE	=1,
	TEXT	=2,
	ITEMTYPE	=3,
	NUM	=4
};

DB_FARM_MESSAGE=
{
	ID	=0,
	FARM_ID	=1,
	TYPE	=2,
	ENTITY_ID	=3,
	PROD_ID	=4,
	SENDER_ID	=5,
	SENDER_NAME	=6,
	CONTENT	=7,
	SEND_TIME	=8
};

DB_FARM_PRODUCT=
{
	ID	=0,
	FARM_ID	=1,
	ENTITY_ID	=2,
	LAND_TYPE	=3,
	PRODUCT_CONFIG_ID	=4,
	CUR_SEASON	=5,
	HARVEST_TIME	=6,
	PRODUCT_NUM	=7
};

DB_FARM_PRODUCT_CONFIG=
{
	ID	=0,
	PRODUCT_NAME	=1,
	PRODUCT_TYPE	=2,
	PRODUCT_SEASON	=3,
	SEED_LOOKFACE	=4,
	HARVEST_LOOKFACE	=5,
	TIME_TO_HARVEST	=6,
	NEXT_HARVEST_TIME	=7,
	BASIC_PRODUCT_NUM	=8,
	PRODUCT_ID	=9,
	FARM_EXP	=10,
	STEAL_NUM_LIMIT	=11
};

DB_FARMENTITY=
{
	ID	=0,
	NAME	=1,
	TYPE	=2,
	OWNER_FARMID	=3,
	STATUS	=4,
	NPC_ID	=5,
	CREATE_TIME	=6,
	UPLEV_END_TIME	=7
};

DB_FARMLAND=
{
	ID	=0,
	NAME	=1,
	ADDRESS	=2,
	NPC_ID	=3,
	LOOKFACE	=4,
	OWNER_ID	=5,
	OWNER_TYPE	=6,
	MOTHERLAND	=7,
	MAP_ID	=8,
	CREATE_TIME	=9,
	UPKEEP_TIME	=10,
	DEL_TIME	=11,
	RICE	=12,
	TIMBER	=13,
	STONE	=14,
	GOLD	=15,
	VAMISH	=16,
	IRON	=17,
	HORSE	=18,
	RICE_LIMIT	=19,
	TIMBER_LIMIT	=20,
	STONE_LIMIT	=21,
	GOLD_LIMIT	=22,
	VAMISH_LIMIT	=23,
	IRON_LIMIT	=24,
	HORSE_LIMIT	=25,
	OWE_DAY	=26,
	FREEZE	=27,
	LOCK_STATUS	=28,
	DOOR_LEVEL	=29
};

DB_FORMULA=
{
	ID	=0,
	OWNERID	=1,
	TYPEID	=2
};

DB_FORMULATYPE=
{
	ID	=0,
	NAME	=1,
	LEVEL	=2,
	MATERIAL1	=3,
	NUM1	=4,
	MATERIAL2	=5,
	NUM2	=6,
	MATERIAL3	=7,
	NUM3	=8,
	MATERIAL4	=9,
	NUM4	=10,
	MATERIAL5	=11,
	NUM5	=12,
	MATERIAL6	=13,
	NUM6	=14,
	PRODUCT	=15,
	PRODUCT_NUM	=16,
	RATE	=17,
	SUCC_RATE	=18,
	FEE_MONEY	=19,
	FEE_EMONEY	=20,
	ICONINDEX	=21,
	ICONNAME	=22,
	TYPE		= 23
};

DB_FRIEND=
{
	ID	=0,
	USERID	=1,
	FRIENDID	=2,
	FRIENDNAME	=3
};

DB_GAMBLE=
{
	ID	=0,
	IDNPC	=1,
	ODDS	=2
};

DB_GAME_LOG=
{
	ID	=0,
	TYPE	=1,
	TIME	=2,
	TEXT	=3
};

DB_GIFT=
{
	ID	=0,
	SERIES	=1,
	BOX_ID	=2,
	OWNER_ID	=3,
	FLAG	=4,
	TEXT	=5,
	ITEMAMOUNT	=6,
	MONEY	=7,
	EMONEY	=8,
	JI_FEN	=9,
	CAM_START	=10,
	CAM_END	=11,
	BIND_FLAG	=12
};

DB_GIFTPACK=
{
	ID	=0,
	OWNER_ID	=1,
	ITEM_TYPE	=2,
	RECEIVE_TIME	=3
};

DB_GMMAIL=
{
	ID	=0,
	SENDER_ID	=1,
	SENDER_NAME	=2,
	RECEIVER_ID	=3,
	TEXT	=4,
	ATTACH_STATE	=5,
	ATTACH_ITEM_ID	=6,
	ATTACH_ITEM_NUM	=7,
	ATTACH_MONEY	=8,
	ATTACH_EMONEY	=9,
	REQUIRE_MONEY	=10,
	REQUIRE_EMONEY	=11,
	SEND_TIME	=12,
	ANSWER_TIME	=13,
	ANSWERGM	=14,
	ATTACH_GMONEY	=15
};

DB_GROUP_BATTLE=
{
	ID	=0,
	WAVE1	=1,
	WAVE2	=2,
	WAVE3	=3,
	WAVE4	=4,
	WAVE5	=5,
	WAVE6	=6
};

DB_HAMLET=
{
	ID	=0,
	NAME	=1,
	OWNER_ID	=2,
	OWNER_TYPE	=3,
	MAP_ID	=4,
	CREATE_TIME	=5,
	FROZEN_TIME	=6,
	DEL_TIME	=7
};

DB_INSTANCING_PROGRESS=
{
	ID	=0,
	OWNER_ID	=1,
	INSTANCING_TYPE	=2,
	RANK	=3,
	CD_TIMESTAMP	=4,
	RESET_COUNT	=5,
	LAST_RESETTIME	=6,
	CLEARUP_MAP	=7,
	CLEARUP_RESTCOUNT	=8
};

DB_ITEM=
{
	ID	=0,
	TYPE	=1,
	OWNERTYPE	=2,
	OWNER_ID	=3,
	PLAYER_ID	=4,
	POSITION	=5,
	AMOUNT	=6,
	DATA	=7,
	SALE_TIME	=8,
	FORGENAME	=9,
	ADDITION	=10,
	EXP	=11,
	CREATE_TIME	=12,
	ATTR_TYPE_1	=13,
	ATTR_VALUE_1	=14,
	ATTR_TYPE_2	=15,
	ATTR_VALUE_2	=16,
	ATTR_TYPE_3	=17,
	ATTR_VALUE_3	=18
};

DB_ITEM_RECORD=
{
	ID	=0,
	ITEMTYPE	=1,
	OWNER_ID	=2,
	TARGET_ID	=3,
	AMOUNT	=4,
	TIME	=5,
	ITEM_ID	=6,
	TYPE	=7
};

DB_ITEMTYPE=
{
	ID	=0,
	NAME	=1,
	REQ_LEVEL	=2,
	PRICE	=3,
	EMONEY	=4,
	SAVE_TIME	=5,
	ID_ACTION	=6,
	AMOUNT_LIMIT	=7,
	MONOPOLY	=8,
	STATE_TYPE	=9,
	LOOKFACE	=10,
	ICONINDEX	=11,
	LIFE	=12,
	ATTR_TYPE_1	=13,
	ATTR_VALUE_1	=14,
	ATTR_GROW_1	=15,
	ATTR_TYPE_2	=16,
	ATTR_VALUE_2	=17,
	ATTR_GROW_2	=18,
	ATTR_TYPE_3	=19,
	ATTR_VALUE_3	=20,
	ATTR_GROW_3	=21,
	ATTR_TYPE_4	=22,
	ATTR_VALUE_4 =23,
	ATTR_GROW_4	=24,	
	DATA	=25,
	DESCRIPT	=26,
	DROP_FLAG	=27,
	RECYCLE_TIME	=28,
	FLAG	=29,
	FORMULA_EMONEY	=30,
	ORIGIN_MAP	=31,
	ENHANCED_ID	=32,
	SOCKET_LIMIT = 33,
    QUALITY     = 34,
    DAOFA_ASTROLOGY_LEVEL = 35,
    STATUS_ATTR_TYPE1 = 36,
    STATUS_ATTR_VALUE1 = 37,
    STATUS_ATTR_GROW1 = 38,
};

DB_LEAVEWORD=
{
	ID	=0,
	USER_ID	=1,
	SEND_NAME	=2,
	TIME	=3,
	WORDS	=4
};

DB_LEVEXP=
{
	LEVEL	=0,
	METEMPSYCHOSIS	=1,
	EXP	=2,
	PER_BATTLE_MAX	=3
};

DB_LIFESKILL=
{
	ID	=0,
	TYPEID	=1,
	OWNERID	=2,
	LEVEL	=3,
	EXP	=4
};

DB_LUA=
{
	ID	=0,
	BLOCK	=1,
	NAME	=2
};

DB_LUA_SCRIPT=
{
	ID	=0,
	NAME	=1
};

DB_LUCK_NUM=
{
	CLASS	=0,
	LUCKNUM	=1,
	OWNERID	=2,
	OWNENAME	=3,
	GENTIME	=4
};

DB_LYOL_HZ_CARD_INFO=
{
	ID	=0,
	PAY_USER_AMOUNT	=1,
	PAY_USER_NEW	=2,
	PAY_AMOUNT	=3,
	PAY_CHANNEL	=4,
	PAY_DATE	=5
};

DB_LYOL_HZ_ONLINE=
{
	ID	=0,
	TOTAL_ONLINE_AMOUNT	=1,
	TOTAL_ONLINE_TIME	=2,
	TOTAL_ONLINE_MAX	=3,
	HZ_HOUR	=4,
	CHANNEL	=5
};

DB_LYOL_HZ_USER_INFO=
{
	ID	=0,
	TOTAL_USER	=1,
	TOTAL_ROLE	=2,
	TOTAL_LOGIN_USER	=3,
	TOTAL_LOGIN_ROLE	=4,
	TOTAL_LOGIN_COUNT	=5,
	TOTAL_NEW_USER	=6,
	TOTAL_NEW_ROLE	=7,
	HZ_TYPE	=8,
	HZ_DATE	=9,
	CHANNEL	=10
};

DB_LYOL_SHOP_ITEM_WATER=
{
	ID	=0,
	ITEM_TYPE	=1,
	ITEM_NAME	=2,
	ITEM_AMOUNT	=3,
	SELL_EMONEY	=4,
	SELL_PRICE	=5,
	BUY_USERID	=6,
	BUY_CHANNEL	=7,
	SELL_DATETIME	=8
};

DB_MAIL=
{
	ID	=0,
	SENDER_ID	=1,
	SENDER_NAME	=2,
	RECEIVER_ID	=3,
	TEXT	=4,
	ATTACH_STATE	=5,
	ATTACH_ITEM_ID	=6,
	ATTACH_ITEM_NUM	=7,
	ATTACH_MONEY	=8,
	ATTACH_EMONEY	=9,
	REQUIRE_MONEY	=10,
	REQUIRE_EMONEY	=11,
	SEND_TIME	=12,
	FAIL_TIME	=13,
	ATTACH_GMONEY	=14,
	FLAG	=15,
	DEL_TIME	=16,
	ASS_ID	=17
};

DB_MAP=
{
	ID	=0,
	NAME	=1,
	DESCR	=2,
	MAPDOC	=3,
	TYPE	=4,
	OWNERID	=5,
	OWNERTYPE	=6,
	PORTAL0_X	=7,
	PORTAL0_Y	=8,
	REBORN_ID	=9,
	REBORN_X	=10,
	REBORN_Y	=11,
	LINK_ID	=12,
	LINK_X	=13,
	LINK_Y	=14,
	RESOURCE_LEV	=15,
	IDSERVER	=16,
	LV	=17,
	MUSIC	=18,
	INSTANCING_GROUP	=19,
	INSTANCING_PRE_CONDITION	=20,
	INSTANCING_IS_ELITE	=21,
	INSTANCING_IS_BOSS	=22,
	INSTANCING_MONSTER_LEVEL	=23,
	INSTANCING_EXTRA_EXP	=24,
	INSTANCING_EXTRA_SOPH	=25,
	INSTANCING_ICON	=26,
	INSTANCING_ORDER	=27,
	NEED_STAGE	=28,
	TITLE	=29
};

DB_MAPZONE=
{
	ID	=0,
	MAPID	=1,
	POS_X	=2,
	POS_Y	=3,
	MONSTER_TYPE	=4,
	ELITE_FLAG	=5,
	GENERATE_RULE_ID	=6,
	UPDATE_TIME	=7,
	AI_TYPE	=8,
	ATK_AREA	=9
};

DB_MARTIAL=
{
	ID	=0,
	OWNER_ID	=1,
	TYPE	=2,
	LEVEL	=3
};

DB_MARTIALTYPE=
{
	ID	=0,
	NAME	=1,
	DESCRIPT	=2,
	LOOKFACE	=3,
	EFFECT_TYPE	=4,
	EFFECT_INIT	=5,
	EFFECT_UP	=6,
	CD_TIME	=7,
	INI_SOPH	=8,
	UP_SOPH	=9,
	REQ_TASK	=10
};

DB_MATRIX=
{
	ID	=0,
	OWNER_ID	=1,
	TYPE	=2,
	LEVEL	=3,
	STATIONS1	=4,
	STATIONS2	=5,
	STATIONS3	=6,
	STATIONS4	=7,
	STATIONS5	=8,
	STATIONS6	=9,
	STATIONS7	=10,
	STATIONS8	=11,
	STATIONS9	=12
};

DB_MATRIX_CONFIG=
{
	ID	=0,
	NAME	=1,
	DESCRIPT	=2,
	LOOKFACE	=3,
	EFFECT_TYPE	=4,
	EFFECT	=5,
	REQ_LEVEL1	=6,
	REQ_LEVEL2	=7,
	REQ_LEVEL4	=8,
	REQ_LEVEL5	=9,
	REQ_LEVEL6	=10,
	REQ_LEVEL7	=11,
	REQ_LEVEL3	=12,
	REQ_LEVEL8	=13,
	REQ_LEVEL9	=14
};

DB_MATRIX_UP_LEVEL=
{
	LEVEL	=0,
	USER_LEVEL	=1,
	REQ_SOPH	=2,
	CD_TIME	=3
};

DB_MONSTER_BOSS=
{
	ID	=0,
	TYPE	=1,
	MAP_ID	=2,
	POS_X	=3,
	POS_Y	=4,
	LEVEL	=5,
	LIFE	=6,
	MANA	=7,
	PHY_ATK	=8,
	SKILL_ATK	=9,
	MAGIC_ATK	=10,
	PHY_DEF	=11,
	SKILL_DEF	=12,
	MAGIC_DEF	=13,
	DRITICAL	=14,
	HITRATE	=15,
	WRECK	=16,
	HURT_ADD	=17,
	TENACITY	=18,
	DODGE	=19,
	BLOCK	=20,
	MONEY	=21,
	BORN_TIME	=22
};

DB_MONSTER_GENERATE=
{
	ID	=0,
	STATIONS1	=1,
	STATIONS2	=2,
	STATIONS3	=3,
	STATIONS4	=4,
	STATIONS5	=5,
	STATIONS6	=6,
	STATIONS7	=7,
	STATIONS8	=8,
	STATIONS9	=9
};

DB_MONSTERTYPE=
{
	ID	=0,
	NAME	=1,
	LOOKFACE	=2,
	TYPE	=3,
	ATK_TYPE	=4,
	DISTANCE	=5,
	LEVEL	=6,
	LIFE	=7,
	MANA	=8,
	PHY_ATK	=9,
	SKILL_ATK	=10,
	MAGIC_ATK	=11,
	PHY_DEF	=12,
	SKILL_DEF	=13,
	MAGIC_DEF	=14,
	DRITICAL	=15,
	HITRATE	=16,
	WRECK	=17,
	HURT_ADD	=18,
	TENACITY	=19,
	DODGE	=20,
	BLOCK	=21,
	AI_TYPE	=22,
	AWARD_EXP	=23,
	SKILL	=24,
	DROP_RULE0	=25,
	DROP_RULE1	=26,
	DROP_RULE2	=27,
	ATK_AREA	=28,
	RARE_RATE	=29
};

DB_NPC=
{
	ID	=0,
	NAME	=1,
	TYPE	=2,
	LOOKFACE	=3,
	BASE	=4,
	IDXSERVER	=5,
	MAPID	=6,
	CELLX	=7,
	CELLY	=8,
	ID_ACTION	=9,
	TASK0	=10,
	TASK1	=11,
	TASK2	=12,
	TASK3	=13,
	TASK4	=14,
	TASK5	=15,
	TASK6	=16,
	TASK7	=17,
	TASK8	=18,
	TASK9	=19,
	DATA0	=20,
	DATA1	=21,
	DATA2	=22,
	DATA3	=23,
	DATASTR	=24,
	SORT	=25,
	SHOPID	=26,
	CAMP	=27,
	DYNAFLAG	=28,
	ID_MONSTER_TYPE	=29,
	ID_GENERATE	=30,
	FOREWORD	=31,
	BEGIN_TIME	=32,
	END_TIME	=33,
	MAP_GROUP	=34,
	ICON = 35,
    HEAD_PIC = 36,
    WHOLE_PIC = 37,
};

DB_PASSWAY=
{
	ID	=0,
	MAPID	=1,
	INDEX	=2,
	DEST_MAPID	=3,
	DEST_PORTAL_INDEX	=4
};

DB_PASSWAY_COPY=
{
	ID	=0,
	MAPID	=1,
	PASSWAY_INDEX	=2,
	DEST_MAPID	=3,
	DEST_PORTAL_INDEX	=4
};

DB_PET=
{
	ID	=0,
	NAME	=1,
	TYPE	=2,
	MAIN	=3,
	OWNER_ID	=4,
	POSITION	=5,
	LEVEL	=6,
	GRADE	=7,
	EXP	=8,
	LIFE	=9,
	LIFE_LIMIT	=10,
	MANA	=11,
	MANA_LIMIT	=12,
	SKILL	=13,
	PHYSICAL	=14,
	SUPER_SKILL	=15,
	MAGIC	=16,
	PHY_FOSTER	=17,
	SUPER_SKILL_FOSTER	=18,
	MAGIC_FOSTER	=19,
	PHY_ELIXIR1	=20,
	PHY_ELIXIR2	=21,
	PHY_ELIXIR3	=22,
	PHY_ELIXIR4	=23,
	PHY_ELIXIR5	=24,
	PHY_ELIXIR6	=25,
	SUPER_SKILL_ELIXIR1	=26,
	SUPER_SKILL_ELIXIR2	=27,
	SUPER_SKILL_ELIXIR3	=28,
	SUPER_SKILL_ELIXIR4	=29,
	SUPER_SKILL_ELIXIR5	=30,
	SUPER_SKILL_ELIXIR6	=31,
	MAGIC_ELIXIR1	=32,
	MAGIC_ELIXIR2	=33,
	MAGIC_ELIXIR3	=34,
	MAGIC_ELIXIR4	=35,
	MAGIC_ELIXIR5	=36,
	MAGIC_ELIXIR6	=37,
	IMPART	=38,
	OBTAIN	=39
};

DB_PET_LEVEXP=
{
	LEVEL	=0,
	EXP	=1
};

DB_PORTAL=
{
	ID	=0,
	MAPID	=1,
	INDEX	=2,
	PORTALX	=3,
	PORTALY	=4,
	LOOKFACE	=5
};

DB_REPUTE=
{
	USER_ID	=0,
	COUNTRY	=1,
	CAMP	=2,
	HONOUR	=3,
	SOLDIER_PAY_FLAG	=4,
	EXPEND_HONOUR	=5,
	SIGNIN_TIMESTAMP	=6,
	SIGNIN_CHAINCOUNT	=7
};

DB_SERVER_CFG=
{
	SERVER_ID	=0,
	SERVER_NAME	=1,
	SERVER_IP	=2,
	SERVER_PORT	=3
};

DB_SHOP=
{
	ID	=0,
	NAME	=1,
	ITEMTYPE	=2,
	PAY_TYPE	=3,
	SALE_AMOUNT	=4,
	REQ_REPUTE	=5,
	REQ_RANK	=6,
	REQ_COUNTRY_REPUTE	=7,
	DISCOUNT_FLAG	=8,
	GIFTTYPE	=9,
	BEGIN_TIME	=10,
	END_TIME	=11,
	TYPE	=12,
	MEDAL_ID	=13,
	MEDAL_NUM	=14,
	HONOUR	=15,
	BIND_FLAG	=16
};

DB_SKILL_CONFIG=
{
    ID = 0,
	NAME = 1,
	ICONINDEX = 2,
	TYPE = 3,
	LOOKFACE_ID = 4,
	LOOKFACE_TARGET_ID = 5,
	ATK_TYPE = 6,
	TARGET_TYPE = 7,
	BLOCK_TYPE = 8,
	MAIN_RATE = 9,
	DESCRRIPTION = 10,
	COST_MANA = 11,
	MOD_ATT1 = 12,
	MOD_VALUE1 = 13,
	MOD_ATTR2 = 14,
	MOD_VALUE2 = 15,
	MOD_ATTR3 = 16,
	MOD_VALUE3 = 17,
	EFFECT1 = 18,
	EFFECT_VALUE1 = 19,
	EFFECT_BOUT1 = 20,
	EFFECT2 = 21,
	EFFECT_VALUE2 = 22,
	EFFECT_BOUT2 = 23,
	EFFECT3 = 24,
	EFFECT_VALUE3 = 25,
	EFFECT_BOUT3 = 26,
	SELF_TARGET_TYPE = 27,
	SELF_EFFECT1 = 28,
	SELF_EFFECT_VALUE1 = 29,
	SELF_EFFECT_BOUT1 = 30,
	SELF_EFFECT2 = 31,
	SELF_EFFECT_VALUE2 = 32,
	SELF_EFFECT_BOUT2 = 33,
	SELF_EFFECT3 = 34,
	SELF_EFFECT_VALUE3 = 35,
	SELF_EFFECT_BOUT3 = 36,
};


DB_SKILL_RESULT_CFG=
{
	ID	=0,
	LOOKFACE	=1,
	BACK	=2,
	SELF	=3,
	SORT    =4,
	EFFECT_TYPE	=5,
	RELY_SELF	=6,
	RELY_TYPE	=7,
	VALUE	=8,
	RATE	=9,
	BOUT	=10
};


--静态表sports_prize
DB_SPORTS_PRIZE=
{
    ID = 0,       
	RANKING	= 1,       --排名
	MONEY	    = 2,        --银币
	REPUTE	    = 3,        --声望
    STAMINA    = 4,        --军令
    ITEM           = 5,        --物品
    ITEMCOUNT    = 6,      --物品类型
    EMONEY    = 7        --金币 
};

DB_SPORTS_REPORT=
{
	ID	=0,
	USER_ID	=1,
	RANKING	=2,
	BATTLE	=3,
	TARGET	=4,
	NAME	=5,
	TIME	=6,
	WIN	=7,
	IS_ATK	=8
};

DB_STONE=
{
	ID	=0,
	ITEMID	=1,
	TYPE	=2,
	OWNERID	=3
};

DB_STORAGE=
{
	ID	=0,
	ID_USER	=1,
	ID_MAP	=2,
	TYPE	=3,
	ITEM0	=4,
	ITEM1	=5,
	ITEM2	=6,
	ITEM3	=7,
	ITEM4	=8,
	ITEM5	=9,
	ITEM6	=10,
	ITEM7	=11
};

DB_SYNDICATE=
{
	ID	=0,
	NAME	=1,
	CREATER_ID	=2,
	CREATER_NAME	=3,
	CREATE_TIME	=4,
	CAMP	=5,
	FLAG	=6,
	MONEY	=7,
	EMONEY	=8,
	CONTRIBUTION	=9,
	COUNTRY_REPUTE	=10,
	MBR_NUM_LIMIT	=11,
	APPLY_NUM_LIMIT	=12,
	RANK	=13,
	WOOD	=14,
	STONE	=15,
	PAINT	=16,
	COAL	=17,
	ANNOUNCE	=18
};

DB_SYNDICATE_LEVEL=
{
	LEVEL	=0,
	MBR_LIMIT	=1,
	APPLY_LIMIT	=2,
	CONSUME_MONEY	=3,
	CONSUME_WOOD	=4,
	CONSUME_STONE	=5,
	CONSUME_PAINT	=6,
	CONSUME_COAL	=7,
	REQUIRE_CONTRIBUTE	=8,
	REQUIRE_MBR	=9
};

DB_SYNDICATE_VOTE=
{
	ID	=0,
	SYN_ID	=1,
	TYPE	=2,
	DATA	=3,
	SPONSOR_ID	=4,
	START_TIME	=5,
	END_TIME	=6
};

DB_SYNMBR=
{
	ID	=0,
	SYN_ID	=1,
	PLAYER_ID	=2,
	PLAYER_NAME	=3,
	RANK	=4,
	DONATE_MONEY	=5,
	CONTRIBUTE	=6
};

DB_SYNMBR_REQUEST=
{
	ID	=0,
	PLAYER_ID	=1,
	PLAYER_NAME	=2,
	SYN_ID	=3,
	FLAG	=4,
	OVER_TIME	=5
};

DB_SYNMBR_VOTE=
{
	ID	=0,
	VOTE_ID	=1,
	VOTER_ID	=2,
	RESULT	=3
};

DB_TASK=
{
	ID	=0,
	ID_NEXT	=1,
	ID_NEXTFAIL	=2,
	ITEMNAME1	=3,
	ITEMNAME2	=4,
	MONEY	=5,
	PROFESSION	=6,
	SEX	=7,
	MIN_PK	=8,
	MAX_PK	=9,
	TEAM	=10,
	METEMPSYCHOSIS	=11,
	QUERY	=12,
	MARRIAGE	=13,
	CLIENT_ACTIVE	=14
};

DB_TASK_AGENT=
{
	ID	=0,
	OWNER_ID	=1,
	TASK_TYPE	=2,
	TAGS	=3,
	SET_TIME	=4
};

DB_TASK_DETAIL=
{
	ID	=0,
	USER_ID	=1,
	TASK_ID	=2,
	TASK_STATE	=3,
	DATA1	=4,
	DATA2	=5,
	DATA3	=6,
	DATA4	=7,
	DATA5	=8,
	DATA6	=9
};

DB_TASK_DONE=
{
	ID	=0,
	USER_ID	=1,
	TASK_ID	=2,
	COMPLETE_TIME_DAY	=3,
	COMPLETE_TIME_ALL	=4
};

DB_TASK_DROP=
{
	ID	=0,
	MONSTER_ID	=1,
	TASK_ID	=2,
	ITEMTYPE	=3,
	RANK	=4,
	NUM	=5
};

DB_TASK_TYPE=
{
	ID	=0,
	NAME	=1,
	TYPE	=2,
	PRE_TASK_ID	=3,
	PRE_TASK_ID_2	=4,
	LV_MIN	=5,
	LV_MAX	=6,
	NPC	=7,
	FINISH_NPC	=8,
	PRE_AWARD_ITEM	=9,
	COMPLETE_TIME_LIMIT_DAY	=10,
	COMPLETE_TIME_LIMIT_ALL	=11,
--DEL_ITEMTYPE1	=12,
--DEL_ITEMTYPE1_NUM	=13,
--DEL_ITEMTYPE2	=14,
--DEL_ITEMTYPE2_NUM	=15,
--DEL_ITEMTYPE3	=16,
--DEL_ITEMTYPE3_NUM	=17,
	CONDITION_1	=12,		--对应TASK_CONTIDTION_TYPE
	CONDITION_1_LPARAM =13,	--对应物品类型，怪物类型或者TASK_GUIDE_PARAM值
	CONDITION_1_WPARAM =14,	--需要物品数，杀怪数，或者引导需求
	CONDITION_2 = 15,
	CONDITION_2_LPARAM = 16,
	CONDITION_2_WPARAM = 17,
	CONDITION_3 = 18,
	CONDITION_3_LPARAM = 19,
	CONDITION_3_WPARAM = 20,
	CONDITION_4 = 21,
	CONDITION_4_LPARAM = 22,
	CONDITION_4_WPARAM = 23,
	
	AWARD_EXP	=24,
	AWARD_MONEY	=25,
	AWARD_ITEM_FLAG	=26,
	AWARD_ITEMTYPE1	=27,
	AWARD_ITEMTYPE1_NUM	=28,
	AWARD_ITEMTYPE2	=29,
	AWARD_ITEMTYPE2_NUM	=30,
	AWARD_ITEMTYPE3	=31,
	AWARD_ITEMTYPE3_NUM	=32,
	CONTENT	=33,
	AWARD_REPUTE	=34,
	AWARD_HONOUR	=35,
	
	
--MONSTER1	=30,
--MON_NUM1	=31,
--MONSTER2	=32,
--MON_NUM2	=33,
--MONSTER3	=34,
--MON_NUM3	=35,
--MONSTER4	=36,
--MON_NUM4	=37,

	PRE_AWARD_ITEM_NUM	=36,
	RECYCLE_FLAG	=37,
	BIND_FLAG	=38,
	NEED_REPUTE	=39,
	NEED_SOLDIERRANK	=40,
	NEED_PEERAGE	=41,
	AWARD_PEERAGE	=42,
	AWARD_SOLDIERRANK	=43,
	DEL_MONEY	=44,
	ACTIVE_BEGIN	=45,
	ACTIVE_END	=46
};

DB_TIME_QUEUE=
{
	ID	=0,
	OWNER_ID	=1,
	TYPE	=2,
	NUMBER	=3,
	LAST_TIME	=4
};

DB_UNLAWFUL_NAME=
{
	ID	=0,
	NAME	=1
};

DB_UNLAWFUL_TALK=
{
	ID	=0,
	TALK	=1
};

DB_URL=
{
	ID	=0,
	CHANNEL	=1,
	URL	=2,
	MODEL	=3
};

DB_USER=
{
	ID	=0,
	ACCOUNT_ID	=1,
	NAME	=2,
	TITLE	=3,
	CREATETIME	=4,
	LOOKFACE	=5,
	PROFESSION	=6,
	HAIR	=7,
	MONEY	=8,
	MONEY_SAVED	=9,
	MONEY_SAVED2	=10,
	EMONEY	=11,
	EMONEY_SAVE	=12,
	EMONEY_CHK	=13,
	STORAGE_LIMIT	=14,
	PACKAGE_LIMIT	=15,
	LOCK_KEY	=16,
	RECORDMAP_ID	=17,
	RECORDX	=18,
	RECORDY	=19,
	LAST_LOGIN	=20,
	ONLINE_TIME2	=21,
	OFFINE_TIME	=22,
	LAST_LOGOUT2	=23,
	LOGIN_TIME	=24,
	IP	=25,
	REBORN_MAPID	=26,
	ONLINE_TIME	=27,
	AUTO_EXERCISE	=28,
	LEVEL	=29,
	EXP	=30,
	PK	=31,
	LIFE	=32,
	MANA	=33,
	PHY_POINT	=34,
	DEX_POINT	=35,
	MAG_POINT	=36,
	DEF_POINT	=37,
	FORBITDDEN_WORDS	=38,
	RANK	=39,
	CAMP	=40,
	MARRYID	=41,
	REIKI	=42,
	CHKSUM	=43,
	CHANNEL	=44,
	GMONEY	=45,
	GMONEY_SAVE	=46,
	ACCOUNT_NAME	=47,
	MOBILE	=48,
	ACTIVITY_POINT	=49,
	MAX_ACTIVITY	=50,
	MAX_SKILL_SLOT	=51,
	VIP_RANK	=52,
	VIP_EXP	=53,
	PEERAGE	=54,
	MATRIX	=55,
	REPUTE	=56,
	SOPH	=57,
	PARTS_BAG	=58,
	DAO_FA_BAG	=59,
	SPORTS	=60,
	SPORTS_COUNT	=61,
	UP_SPORTS	=62,
	WINNING_STREAK	=63,
	ADD_SPORTS_COUNT	=64,
	SP_LEVUP_CD	=65,
	LAST_GRASP_DAO_TIME	=66,
	SPACIAL_GRASP_COUNT	=67,
	EQUIP_QUEUE_COUNT	=68,
	EQUIP_UPGRADE_TIME1	=69,
	EQUIP_UPGRADE_TIME2	=70,
	EQUIP_UPGRADE_TIME3	=71,
	PET_LIMIT	=72,
	STAGE	=73,
	STAMINA	=74
};

DB_USER_ATTRIBUTE_TYPE=
{
	ID	=0,
	PROFESSION	=1,
	LEVEL	=2,
	STR	=3,
	AGI	=4,
	STA	=5,
	INT	=6,
	PHY_HITERATE	=7,
	MAGIC_HITERATE	=8,
	LIFE	=9,
	MANA	=10,
	UPLEV_POINT	=11,
	UPLEV_SKILL_POINT	=12
};

DB_USER_STATE=
{
	ID	=0,
	USER_ID	=1,
	STATE_TYPE	=2,
	END_TIME	=3,
	DATA	=4
};

DB_USER_STATE_TYPE=
{
	ID	      =0,
	RULE	  =1,
	TYPE      =2;
	DATA	  =3,
	LAST_TIME =4,
	NOT_SEND  =5,
	NAME	  =6,
	ICONINDEX =7,
	ICONNAME  =8,
	SHORT_TIP =9,
	DESCRIPT  =10
};

DB_WISH=
{
	ID	=0,
	USER_ID	=1,
	USER_NAME	=2,
	TIME	=3,
	CONTENT	=4,
	EMONEY	=5
};
DB_RANK=
{
    ID          = 0,
    RANK_NAME   = 1,
    STR         = 2,
    AGI         = 3,
    INI         = 4,
    LIFE        = 5,
    MAX_OWN_PET = 6,
    MAX_FIGHT_PET   = 7,
    REPUTE      = 8,
    MONEY       = 9
};
--chh add(2012-06-06)
DB_MOUNT=
{
    ID              = 0,
    LEVEL           = 1,
    STR             = 2,
    AGI             = 3,
    INI             = 4,
    LIFE            = 5,
    SPEED           = 6,
    EXP             = 7,
    SILVER_EDU      = 8,   
    SILVER_EDU_EXP  = 9,       
    SILVER_EDU_CRIT = 10,        
    GOLD_EDU        = 11, 
    GOLD_EDU_EXP    = 12,     
    GOLD_EDU_CRIT   = 13,      
    HIGH_EDU_CRIT   = 14, 
};

DB_MOUNT_MODEL=
{
    ID              = 0,
    REQ_LEVEL       = 1,
    NAME            = 2,
    ICON            = 3,
    LOOKFACE        = 4,
};



--++ Guosen ++-- 2012.6.2
DB_PET_CONFIG=
{
	ID					=0,
	NAME				=1,
	PROFESSION			=2,
	PRO_NAME			=3,
	ATK_TYPE			=4,
	LOCKFACE			=5,
	ICON				=6,
	SKILL				=7,
	LIFE_GROW			=8,
	INIT_LIFE			=9,
	INIT_MANA			=10,
	INIT_PHYSICAL		=11,
	INIT_SUPER_SKILL	=12,
	INIT_MAGIC			=13,
	INIT_DRITICAL		=14,
	INIT_HITRATE		=15,
	INIT_WRECK			=16,
	INIT_HURT_ADD		=17,
	INIT_TENACITY		=18,
	INIT_DODGE			=19,
	INIT_BLOCK			=20,
	CAN_CALL			=21,
	REPUTE				=22,
	REPUTE_LEV			=23,
	RECOMMEND			=24,
	MONEY				=25,
	DESCRIBE			=26,	
	NEED_STAGE			=27,
	ADD_PHYSICAL		=28,	
	ADD_SUPER_SKILL		=29,
	ADD_MAGIC			=30,	
	ADD_LIFE			=31,	
	INIT_HELP			=32,
	STAND_TYPE			=33,
	CAMP				=34,	-- ’Û”™
	EMONEY				=35,
	REQ_VIP				=36,	-- VIPµ»º∂
	REQ_LEVEL			=37,	
	BODY_PIC			=38,	--半身像
    QUALITY             =39,    --武将品质
};
--++ Guosen ++-- 2012.6.2
DB_RANK_CONFIG=
{
	ID				=0,
	RANK_NAME		=1,
	STR				=2,
	AGI				=3,
	INI				=4,
	LIFE			=5,
	MAX_OWN_PET		=6,
	MAX_FIGHT_PET	=7,
	REPUTE			=8,
	MONEY			=9,
};


--** chh 2012.6.21 **--
DB_GIFTPACK_CONFIG=
{
	ID				=0,
	NAME            =1,
    DESCRIBE        =2,
    ICON            =3,
};

DB_GUIDE_CONFIG=
{
	ID				=0,
	STAGE           =1,
    FUNC_INDEX      =2,
    DESCRIBE        =3,
};

DB_ACHIEVEMENT_CONFIG=
{
	ID				                  = 0,
	TYPE                         = 1,
    AWARD_MONEY      =2,
    AWARD_ITEM          =3,
    ITEM_COUNT           =4,
    TITLE                        =5,
    DESCRIBE               =6,
};

DB_VIP_CONFIG= 
{
    ID                      =0,
    EMONEY                  =1,     --升级VIP需要的金币
    LEVY_NUM                =2,     --征收次数
    STAMINA_NUM             =3,     --军令够买上线
    BATCH_LEVY              =4,     --是否可以批量征收
    EQUIP_EDU               =5,     --装备的洗炼类型
    INS_CLEARUP_CLEARTIME   =6,     --是否有副本扫荡时间
    TRAIN_PET               =7,     --武将培养类型
    ENHANCE_CLEARTIME       =8,     --是否有强化冷却时间
    SPORTS_CHALLENGE_NUM    =9,     --竞技场挑战次数
    ELITE_MAP_RESET_NUM     =10,    --精英副本重置数量
    BATTLE_FAST_FLAG        =11,    --快速战斗
    BAG_NUM                 =12,    --背包
    ENHANCE_CRIT_FLAG       =13,    --是否开启暴击功能
    ENHANCE_REDUCE_PECENT   =14,    --节约强化费的百分比
    FIGHT_AUTO              =15,    --自动战斗（boss战，大乱斗等自动战斗开启）
    DESTINY_BAG_NUM         =16,    --
    DESTINY_CALL_QIMEN      =17,    --
    DESTINY_ASTROLOGY_AUTO  =18,    --

};

DB_VIP_CONFIG_EQUIP_EDU = {
    NORMAL      = 1,        --正常洗炼
    PLATINA     = 2,        --白金洗炼
    EXTREME     = 3,        --至尊洗炼
};

--洗炼
DB_EQUIP_EDU_CONFIG= 
{
    ID                      =0,
    NAME                    =1,
    TYPE                    =2,
    PRICE                   =3,
    DESCRIPT                =4,
};

--坐骑培养
DB_MOUNT_TRAIN_CONFIG= 
{
    ID                      =0,
    NAME                    =1,
    TYPE                    =2,
    PRICE                   =3,
    DESCRIPT                =4,
};

--洗炼类型
BaptizeType = {
    SilVer  = 1,        --银币洗炼
    Coin    = 2,        --金币洗炼
    Extreme = 3,        --至尊洗炼
};

--金钱类型
PriceType = {
    Sliver  = 0,        --银币
    Coin    = 1,        --金币
};

--礼包类型表
DB_BOX_TYPE=
{
    ID              = 0,
    NAME            = 1,
    MONEY           = 2,
    EMONEY          = 3,
    ITEMNUM         = 4,
    BIND_FLAG       = 5,
};


--静态表event_config 字段说明表
DB_EVENT_CONFIG = 
{
	ID = 0,			                --活动ID
    NAME = 1,                  --活动名字
	TYPE = 2,                    --活动类型
    UI_GROUP = 3,         --分类(值相同都同时在一个界面当中)
	TIME_TYPE = 4,	       --活动时间类型
	TIME_BEGIN = 5,	   --活动开始时间
	TIME_END = 6,	       --活动结束时间
	CONTENT = 7,	           --活动内容
	BROAD = 8,		          --活动开始广播内容
    SERVERID = 9,            --活动对应的服务器id
};


--静态表 event_award字段说明表
DB_EVENT_AWARD = 
{
	ID = 0,
	CONFIG_ID = 1,		              --对应DB_EVENT_CONFIG表ID
	STAGE = 2,		                      --活动阶段
    STAGE_CONDITION = 3,     --阶段条件
	ITEM_TYPE = 4,		              --物品奖励
	ITEM_AMOUNT = 5,	              --物品数
	EMONEY = 6,		                  --金币
	STAMINA = 7,		                  --军令
	MONEY = 8,		                      --银币
	SOPH = 9,		                          --将魂
	REPUTE = 10,		                      --声望
	PARAM1 = 11,	                          --活动参数
	PARAM2 = 12,
	PARAM3 = 13,
};


--静态表 grain_static 字段说明表
DB_GRAIN_STATIC = 
{
	ID = 0,
	LOOT_MAX = 1,		                            --截粮次数上限
	BE_LOOT_MAX = 2,		                    --单次被截上限
    ESCORT_MAX = 3,                            --护送次数上限
	REFRESH_MAX = 4,		                    --刷新粮车品质次数上限
	QUICK_ESCORT_AWARD_BASE = 5,	   --快速护送所需金币基础值
	QUICK_ESCORT_AWARD_GROW = 6,  --快速护送所需金币乘以时间的基础值
	REFRESH_CAR_NEED_BASE = 7,	--刷新粮车所需金币基础值
	REFRESH_CAR_NEED_GROW = 8,  --刷新粮车所需金币乘以时间的基础值    
 	CLEAE_ESCORT_CDTIME_BASE = 9,	   --去除拦截冷却时间所需金币基础值
	CLEAE_ESCORT_CDTIME_GROW = 10,  --去除拦截冷却时间所需金币乘以时间的基础值
    CALL_MAX_CAR_NEED_BASE = 11,               --召唤粮车所需金币
    ENCOURAGE_PER_PERCENT = 12,                --每次鼓舞士气加成百分比
    ENCOURAGE_MAX = 13,                                  --士气加成最高点  
    ENCOURAGE_NEED_BASE = 14,                    --每次鼓舞士气所需金币
    BE_LOOT_BENIFIT_PERCENT = 15,              --每次被截粮降收益百分比
    LOOT_GRAIN_CD = 16,                                  --拦截冷却时间
    SEE_PERSON_NUM = 17,                              --屏幕可视人数   
    FUNC_REQ_LEVEL = 18,                              --运粮活动所需等级       
};

--静态表 grain_config字段说明表
DB_GRAIN_CONFIG = 
{
	ID = 0,                                             --粮车类型
	NAME = 1,		                                --粮车名字
	UP_PECENT = 2,		                    --成功刷新几率
    LAST_TIME = 3,                             --运送粮车持续时间
	AWARD_REPUTE = 4,		              --奖励声望
	AWARD_MONEY_BASE = 5,	           --奖励银币基础
	AWARD_MONEY_GROW = 6,		   --奖励银币因子
	AWARD_EMONEY_BASE = 7,		   --奖励金币基础
	AWARD_EMONEY_GROW = 8,		   --奖励金币因子
	AWARD_SOPH = 9,		                  --奖励将魂
	AWARD_STAMINA = 10,		         --奖励军令
	AWARD_ITEM_TYPE = 11,	          --奖励物品类型
	AWARD_ITEM_COUNT = 12,          --奖励物品数量
	BE_LOOT_ITEM_ODDS_PERCENT = 13,   --物品被截时掉落概率
};


--静态表 event_activity字段说明表
DB_EVENT_ACTIVITY = 
{
	ID = 0,                                              --活动id
	NAME = 1,		                                 --活动名字
	ICON = 2,                                         --活动图标
    TYPE = 3,                                         --活动类型
	GROUP = 4,		                              --活动分组  1:世界活动  2:帮派活动
	TIME_TYPE = 5,	                              --时间类型  0:指定日期 1:每天 2:每周 3:每月
	BEGIN_DAY = 6,		                          --时间点  如果time_type为0则为起始日期 其他...
    END_DAY = 7,                                  --结束时间点
    POINT_TIME = 8,                             --开始的时间点
    CONTINOUANS = 9,                        --持续的时间
    DATA1 = 10,              
    DATA2 = 11,    
    DATA3 = 12,    
    DESCRIBE= 13,                               --活动说明          
};


--boss战活动 字段说明
DB_EVENT_ACTIVITY_CONFIG = {
    ID          = 0,
    NAME        = 1,
    ICON        = 2,
    TYPE        = 3,
    GROUP       = 4,
    TIME_TYPE   = 5,
    BEGIN_DAY   = 6,
    END_DAY     = 7,
    POINT_TYPE  = 8,
    CONTINOUANS = 9,
    BOSS_TYPE_ID= 10,        --boss id
    DATA2       = 11,
    DATA3       = 12,
    DESCRIBE    = 13,
};

--鼓舞配置表
DB_ENCOURAGE_CONFIG = {
    ID          = 0,
    MAX_TIMES   = 1,
    COST_EMONEY = 2,
    EMONEY_RATE = 3,
    COST_MONEY  = 4,
    MONEY_RATE  = 5,
    ARRT1       = 6,
    MODIFY_VALUE1   = 7,
    ARRT2       = 8,
    MODIFY_VALUE2   = 9,
    ARRT3       = 10,
    MODIFY_VALUE3   = 11,
    ARRT4       = 12,
    MODIFY_VALUE4   = 13,
}

DB_DAOFA_STATIC_CONFIG = {
    ID      = 0,
    VALUE   = 1,
    COMMENT = 2,
}
 
DB_DAOFA_STATIC_CONFIG_ID = {
    GRAY                = 1,
    RED                 = 2,
    GREEN               = 3,
    BLUE                = 4,
    PURPLE              = 5,
    ORANGE              = 6,
    DAOFA_OPEN_LEVEL    = 7,    --
    QMDJ_COIN           = 8,    --
}

DB_DAOFA_CONFIG = {
    ID                  = 0,
    NAME                = 1,
    REQ_MONEY           = 2,
    GRAY                = 3,
    GREEN               = 4,
    BLUE                = 5,
    PURPLE              = 6,
    GOLD                = 7,
    UPLEV_CHANCE        = 8,
};


DB_STAMINA_CONFIG = {
    ID          = 0,
    BUY_NUM     = 1,
    REQ_EMONEY  = 2,
}


DB_MOUNT_TRAIN_CONFIG = {
    ID          = 0,
    NAME        = 1,
    TYPE        = 2,
    PIRICE      = 3,
    DESCRIPT    = 4,
}

DB_MOUNT_TRAIN_TYPE_DESC = {
    MONEY   = 0,    
    EMONEY  = 1,   
}


DB_FINDBOX_CONFIG = {
	ID			= 0,
	VALUE		= 1,
	COMMENT		= 2,
};

